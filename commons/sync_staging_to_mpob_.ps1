# Scheduler-triggered PowerShell script to execute Python file
# This script is called by Windows Task Scheduler

param(
    [string]$PythonScriptPath = "E:\scripts\sync_mpob_db\resync_all_entities.py"
)

try {
    Write-Host "Starting Python script execution at $(Get-Date)"
    
    # Execute Python script
    & python $PythonScriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Python script completed successfully at $(Get-Date)"
    } else {
        Write-Error "Python script failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}
catch {
    Write-Error "Error executing Python script: $_"
    exit 1
}
