$regevt = "RegistryKeyChangeEvent"
$reg = @{ Hive = "HKEY_LOCAL_MACHINE"; Path = "SYSTEM\\CurrentControlSet\\Control\\CrashControl" }

# Create a ManagementEventWatcher object
$query = "SELECT * FROM $($regevt) WHERE Hive='$($reg['Hive'])'"
switch -Exact ($regevt) {
    "RegistryTreeChangeEvent" { $query += " AND RootPath='$($reg['Path'])'"; Break }
    "RegistryKeyChangeEvent" { $query += " AND KeyPath='$($reg['Path'])'"; Break }
    "RegistryValueChangeEvent" { $query += " AND KeyPath='$($reg['Path'])' AND ValueName='$($reg['Value'])'"; Break }
    Default { Write-Error "Invalid registry event."; Exit }
}
$watcher = New-Object System.Management.ManagementEventWatcher $query

# Register an event that gets fired when an event arrives
Register-ObjectEvent -InputObject $watcher -EventName EventArrived -Action {
    $newEvent = $event.SourceEventArgs.NewEvent
    Write-Host "Event occurred!"
    Write-Host ($newEvent | Format-List | Out-String)
} | Out-Null

Write-Host ($reg | Format-Table | Out-String)
Write-Host "Waiting for events..."

# Start the watcher
$watcher.Start()

# Keep the script running until it is manually stopped
while ($true) {
    Start-Sleep -Seconds 1
}
