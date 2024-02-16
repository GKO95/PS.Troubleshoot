# WER User Mode Dump: https://learn.microsoft.com/en-us/windows/win32/wer/collecting-user-mode-dumps
$process = "svchost.exe"
$regLocalDumps = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps"

$reg = @{
    DumpType = 2;   # 1: Custom dump, 2: Full dump, 3: Mini dump   
    DumpCount = 10; # Number of dump files to keep (default: 10)
    DumpFolder = "%LocalAppData%\CrashDumps"; # Default folder for crash dumps
}

# If the registry key for WER LocalDumps does not exist, create it.
if ( -not (Test-Path -Path $regLocalDumps -PathType Container) ) { New-Item -Path $regLocalDumps }
else
{
    # If process name is not empty and ends with .exe, append it to the registry key path.
    if ( ($process -ne "") -and ($process -like "*.exe") ) {
        $regLocalDumps += "\" + $process

        # If the registry key for per-process crash dumps under LocalDumps does not exist, create it.
        if ( -not (Test-Path -Path $regLocalDumps -PathType Container) ) { New-Item -Path $regLocalDumps }
    }
    else {
        Write-Error "Invalid process name."
        Exit
    }
}

# Set the registry values for WER LocalDumps (or per-process crash dumps under LocalDumps).
Set-ItemProperty -Path $regLocalDumps -Name DumpType -Type DWord -Value $reg['DumpType']
Set-ItemProperty -Path $regLocalDumps -Name DumpCount -Type DWord -Value $reg['DumpCount']
Set-ItemProperty -Path $regLocalDumps -Name DumpFolder -Type ExpandString -Value $reg['DumpFolder']
