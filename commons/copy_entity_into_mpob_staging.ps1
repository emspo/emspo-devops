# Define log file paths
$LogDir = "E:\Scheduled_Scripts"
$LogFile = "$LogDir\copy_entity_into_mpob_staging_Log.txt"
$ErrorLogFile = "$LogDir\copy_entity_into_mpob_staging_Error_Log.txt"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Get the current timestamp
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Log start of execution
"[$Timestamp] - Execution started for fn_insert_entity_into_mpob_staging()" | Out-File -Append $LogFile

try {
    # PostgreSQL Connection Details
    $PG_Host = "localhost"  # Change as needed
    $PG_Port = "5432"
    $PG_Database = "mspo_ts"
    $PG_User = "postgres"
    $PG_Password = "Msp0@202A"

    # $PG_Password = $env:PG_PASSWORD  # Set externally for security

    if ([string]::IsNullOrWhiteSpace($PG_Password)) {
        throw "PG_PASSWORD environment variable is not set."
    }

    # SQL command to execute
    $PG_Command = "SELECT * FROM fn_insert_entity_into_mpob_staging();"

    # Path to psql.exe
    $PG_Path = "C:\Program Files\PostgreSQL\16\bin\psql.exe"

    # Validate psql.exe exists
    if (-not (Test-Path $PG_Path)) {
        throw "psql.exe not found at: $PG_Path"
    }

    # Set PostgreSQL password as environment variable
    $env:PGPASSWORD = $PG_Password

    # Run the command and capture the exit code
    $Result = & $PG_Path -h $PG_Host -p $PG_Port -U $PG_User -d $PG_Database -c $PG_Command 2>&1
    $ExitCode = $LASTEXITCODE

    # Ensure result is always treated as a string
    $ResultString = "$Result".Trim()

    # Handle PostgreSQL errors based on exit code
    if ($ExitCode -ne 0) {
        throw "PostgreSQL execution failed with exit code $ExitCode. Error: $ResultString"
    }

    # Check if the query returned an empty result
    if ([string]::IsNullOrWhiteSpace($ResultString)) {
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$Timestamp] - Query executed successfully, but no data was returned." | Out-File -Append $LogFile
    }
    else {
        # Log successful result
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$Timestamp] - Query executed successfully. Output:`n$ResultString" | Out-File -Append $LogFile
    }
}
catch {
    # Capture error message
    $ErrorMessage = "$($_.Exception.Message)" # Ensure error is treated as a string
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Log error to separate error log file
    "[$Timestamp] - Execution failed: $ErrorMessage" | Out-File -Append $ErrorLogFile
}
finally {
    # Clear password from environment variable
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
