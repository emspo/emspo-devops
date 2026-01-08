<#
.SYNOPSIS
Update user_master passwords on PostgreSQL server (all databases)
.PARAMETER Server
Choose 'dev' or 'staging'. Defaults to 'dev'.
#>

param(
    [string]$Server = "dev"
)

# === SERVER CONFIGURATION ===
switch ($Server.ToLower()) {
    "dev" {
        $PGHOST = "185.93.166.49"
        $PGUSER = "postgres"
        $PGPASSWORD = "sasa"
    }
    "staging" {
        $PGHOST = "103.27.74.207"
        $PGUSER = "postgres"
        $PGPASSWORD = "sasa"
    }
    default {
        Write-Host "Unknown server '$Server'. Use 'dev' or 'staging'."
        exit
    }
}

# === UPDATE SETTINGS ===
$NEW_PASSWORD = "secret"       # new password to set
$USE_HASH = $false             # $true = bcrypt hash
$LOG_FILE = "update_log.csv"

# Optional: list of databases to skip (e.g., production)
$SKIP_DATABASES = @("postgres", "production_db")

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

Write-Host "Databases to be processed on $Server server ($PGHOST):"
$databases | ForEach-Object { Write-Host " - $_" }

# --- STEP 2: DRY-RUN ---
Write-Host "`n=== DRY-RUN: Listing schemas ===`n"

foreach ($db in $databases) {
    Write-Host "===== DATABASE: $db ====="

    $schemas = psql -d $db -Atc "
SELECT table_schema
FROM information_schema.tables
WHERE table_name = 'user_master'
  AND table_schema NOT IN ('pg_catalog','information_schema')
" 

    foreach ($schema in $schemas) {
        Write-Host "Database: $db | Schema: $schema"
        "$Server,DryRun,$db,$schema,0,DryRun,$((Get-Date).ToString('s'))" | Out-File $LOG_FILE -Append -Encoding UTF8
    }
}

# --- STEP 3: Confirm update ---
$confirm = Read-Host "`nDry-run complete. Do you want to APPLY the update to all databases on $Server server? (Y/N)"
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
        $psqlCommand = $psqlCommand -replace '\$NEW_PASSWORD', $NEW_PASSWORD
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
        $psqlCommand = $psqlCommand -replace '\$NEW_PASSWORD', $NEW_PASSWORD
    }

    # Execute update and capture NOTICE messages
    try {
        psql -d $db -c $psqlCommand 2>&1 | ForEach-Object {
            Write-Host $_
            if ($_ -match "Database: (\S+) \| Schema: (\S+), Rows updated: (\d+)") {
                $dbName = $matches[1]
                $schemaName = $matches[2]
                $rows = $matches[3]
                "Update,$Server,$dbName,$schemaName,$rows,Success,$((Get-Date).ToString('s'))" | Out-File $LOG_FILE -Append -Encoding UTF8
            }
        }
    } catch {
        Write-Host "Error updating ${db}: $_"
        "Update,$Server,$db,N/A,0,Error,$((Get-Date).ToString('s'))" | Out-File $LOG_FILE -Append -Encoding UTF8
    }
}

Write-Host "`nAll done on $Server server. Log saved to $LOG_FILE"
