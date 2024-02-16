# RegistryEvent: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/regprov/registryevent
$regevt = "RegistryKeyChangeEvent"
$reg = @{ 
    Hive = "HKEY_LOCAL_MACHINE"; 
    Path = "SYSTEM\\CurrentControlSet\\Control\\CrashControl";
    Value = "";
}

# Check supported registry hives
switch -Exact ($Hive) {
    "HKEY_USERS" { Break }
    "HKEY_LOCAL_MACHINE" { Break }
    "HKEY_CURRENT_CONFIG" { Break }
    "HKEY_CLASSES_ROOT" { Write-Error "Unsupported registry hive."; Exit }
    "HKEY_CURRENT_USER" { Write-Error "Unsupported registry hive."; Exit }
    Default { Write-Error "Invalid registry hive."; Exit }
}

# Generate a WMI query based on the registry event type
$query = "SELECT * FROM $($regevt) WHERE Hive='$($reg['Hive'])'"
switch -Exact ($regevt) {
    "RegistryTreeChangeEvent" { $query += " AND RootPath='$($reg['Path'])'" }
    "RegistryKeyChangeEvent" { $query += " AND KeyPath='$($reg['Path'])'" }
    "RegistryValueChangeEvent" { $query += " AND KeyPath='$($reg['Path'])' AND ValueName='$($reg['Value'])'" }
    Default { Write-Error "Invalid registry event."; Exit }
}

# Create a ManagementEventWatcher object
$watcher = New-Object System.Management.ManagementEventWatcher $query

# Register an event that gets fired when an event arrives
Register-ObjectEvent -InputObject $watcher -EventName EventArrived -Action {
    $newEvent = $event.SourceEventArgs.NewEvent
    Write-Host "Event occurred!"
    Write-Host ($newEvent | Format-List | Out-String)

        # Write your code here

    # Stop the watcher
    $watcher.Stop()
} | Out-Null

Write-Host ($reg | Format-Table | Out-String)
Write-Host "Waiting for events..."

# Start the watcher
$watcher.Start()

# Keep the script running until it is manually stopped
while ($true) {
    Start-Sleep -Seconds 1
}
