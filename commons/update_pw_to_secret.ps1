# ------------------------------
# Safe Update user_master Password
# ------------------------------

# === CONFIGURATION ===
# $PGHOST = "185.93.166.49"
$PGHOST = "103.27.74.207"
$PGUSER = "postgres"
$PGPASSWORD = "sasa"   # <-- replace securely
$NEW_PASSWORD = "secret"             # <-- new password, or use hashed below
$USE_HASH = $false                   # $true = store bcrypt hash
$LOG_FILE = "update_log.csv"

# Optional: list of databases to skip (e.g., production)
$SKIP_DATABASES = @("postgres", "prod_db", "analytics_db")

# Set environment variables for psql
$env:PGHOST = $PGHOST
$env:PGUSER = $PGUSER
$env:PGPASSWORD = $PGPASSWORD

# Create or clear log file
"Mode,Database,Schema,RowsUpdated,Status,Timestamp" | Out-File $LOG_FILE -Encoding UTF8

# --- STEP 1: List all non-template databases ---
$databases = psql -d postgres -Atc "
SELECT datname
FROM pg_database
WHERE datistemplate = false
  AND datallowconn = true
"

# Filter out skipped databases
$databases = $databases | Where-Object { $SKIP_DATABASES -notcontains $_ }

Write-Host "Databases to be processed:"
$databases | ForEach-Object { Write-Host " - $_" }

# --- STEP 2: DRY-RUN ---
Write-Host "`n=== DRY-RUN: Listing schemas and row counts ===`n"

foreach ($db in $databases) {
    Write-Host "===== DATABASE: $db ====="

    # List schemas containing user_master and row counts
    $dryRunQuery = @"
SELECT table_schema,
       COUNT(*) AS rows_count
FROM information_schema.tables t
JOIN "$db".information_schema.tables t2
  ON t.table_schema = t2.table_schema
WHERE t.table_name = 'user_master'
  AND t.table_schema NOT IN ('pg_catalog','information_schema')
GROUP BY table_schema;
"@

    # Actually, better: just get the schemas; row counts will be fetched in UPDATE step
    $schemas = psql -d $db -Atc "
SELECT table_schema
FROM information_schema.tables
WHERE table_name = 'user_master'
  AND table_schema NOT IN ('pg_catalog','information_schema')
" 

    foreach ($schema in $schemas) {
        Write-Host "Database: $db | Schema: $schema"
        "$db,$schema,0,DryRun,$((Get-Date).ToString('s'))" | Out-File $LOG_FILE -Append -Encoding UTF8
    }
}

# --- STEP 3: Confirm update ---
$confirm = Read-Host "`nDry-run complete. Do you want to APPLY the update to all databases? (Y/N)"
if ($confirm -ne "Y") {
    Write-Host "Aborted by user. No changes made."
    exit
}

# --- STEP 4: Run actual updates ---
Write-Host "`n=== UPDATING PASSWORDS ===`n"

foreach ($db in $databases) {
    Write-Host "===== DATABASE: $db ====="

    if ($USE_HASH) {
        $psqlCommand = @'
DO $$
DECLARE
    r RECORD;
    affected INT;
BEGIN
    PERFORM 1 FROM pg_extension WHERE extname='pgcrypto';
    IF NOT FOUND THEN
        CREATE EXTENSION IF NOT EXISTS pgcrypto;
    END IF;

    FOR r IN
        SELECT table_schema
        FROM information_schema.tables
        WHERE table_name = 'user_master'
          AND table_schema NOT IN ('pg_catalog','information_schema')
    LOOP
        EXECUTE format(
            'UPDATE %I.user_master SET password = crypt(%L, gen_salt(''bf''))',
            r.table_schema,
            '$NEW_PASSWORD'
        );

        GET DIAGNOSTICS affected = ROW_COUNT;
        RAISE NOTICE 'Database: % | Schema: %, Rows updated: %', current_database(), r.table_schema, affected;
    END LOOP;
END $$;
'@
    } else {
        $psqlCommand = @'
DO $$
DECLARE
    r RECORD;
    affected INT;
BEGIN
    FOR r IN
        SELECT table_schema
        FROM information_schema.tables
        WHERE table_name = 'user_master'
          AND table_schema NOT IN ('pg_catalog','information_schema')
    LOOP
        EXECUTE format(
            'UPDATE %I.user_master SET password = %L',
            r.table_schema,
            '$NEW_PASSWORD'
        );

        GET DIAGNOSTICS affected = ROW_COUNT;
        RAISE NOTICE 'Database: % | Schema: %, Rows updated: %', current_database(), r.table_schema, affected;
    END LOOP;
END $$;
'@
    }

    # Execute update and capture NOTICE messages
    try {
        psql -d $db -c $psqlCommand 2>&1 | ForEach-Object {
            Write-Host $_
            if ($_ -match "Database: (\S+) \| Schema: (\S+), Rows updated: (\d+)") {
                $dbName = $matches[1]
                $schemaName = $matches[2]
                $rows = $matches[3]
                "Update,$dbName,$schemaName,$rows,Success,$((Get-Date).ToString('s'))" | Out-File $LOG_FILE -Append -Encoding UTF8
            }
        }
    } catch {
        Write-Host "Error updating ${db}: ${_}"
        "Update,$db,N/A,0,Error,$((Get-Date).ToString('s'))" | Out-File $LOG_FILE -Append -Encoding UTF8
    }
}

Write-Host "`nAll done. Log saved to $LOG_FILE"
