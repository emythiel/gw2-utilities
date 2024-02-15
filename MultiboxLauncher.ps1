$gameDirectory = "C:\Game\Install\Directory" # Path to the game directory
$localDatBaseFolder = "C:\Users\USER\GW2Profiles\" # Path to where you store your local.dat folders
$handleExePath = "C:\Users\USER\GW2Profiles\handle.exe" # Path to handle.exe used for closing the gw2 mutex
$mutexName = "AN-Mutex-Window-Guild Wars" # Replace with actual mutex name

function LaunchGame($localDatFolder, $extraParameters) {
    $env:USERPROFILE = $localDatFolder
    Start-Process -FilePath $gameDirectory\Gw2-64.exe -ArgumentList "-nosound -provider Portal $extraParameters"
    Start-Sleep -Seconds 5  # Adjust as needed
}

function KillMutex($mutexName) {
    $gw2Processes = Get-Process -Name "Gw2-64"
    
    foreach ($process in $gw2Processes) {
        $mutexHandles = & $handleExePath -accepteula -nobanner -p $($process.Id) -a | Select-String $mutexName
        
        if ($mutexHandles) {
            $mutexHandleHex = $mutexHandles | ForEach-Object { if ($_ -match '\b([0-9A-F]+)\b') { $matches[1] } }

            Write-Host "Found process ID: $($process.Id)" -ForegroundColor DarkGreen
            Write-Host "Found mutex handle (Hex): $mutexHandleHex" -ForegroundColor DarkGreen

            # Wait before closing
            Start-Sleep -Seconds 1

            # Kill Mutex
            & $handleExePath -accepteula -nobanner -p $($process.Id) -c $mutexHandleHex -y
            Write-Host "Mutex closed successfully." -ForegroundColor DarkGreen
            
            # Wait for a moment to ensure the process has time to fully close and release the mutex
            Start-Sleep -Seconds 1
        }
    }
}

function FindLocalDatFolder($accountNumber) {
    $formattedAccountNumber = "{0:D2}" -f [int]$accountNumber # Format account number to be 01, 02, ...
    $accountFolderName = "Account$formattedAccountNumber"
    $localDatFolder = Get-ChildItem -Path $localDatBaseFolder | Where-Object { $_.Name -like "$accountFolderName-*" }

    if ($localDatFolder) {
        return $localDatFolder.FullName
    } else {
        Write-Host "No matching folder found for account: $accountFolderName" -ForegroundColor Red
        return $null
    }
}

function LaunchMainAccount() {
    cls
    Write-Host "Launching main account" -ForegroundColor Yellow
    LaunchGame $env:USERPROFILE "-shareArchive"
    KillMutex $mutexName
    # Clear history and go back to main menu once done
    cls
    ShowMenu
}

function MultiboxAccounts($startAccount, $endAccount, $batchSize) {
    cls
    for ($i = $startAccount; $i -le $endAccount; $i += $batchSize) {
        $batchEnd = [Math]::Min($i + $batchSize - 1, $endAccount)
        for ($j = $i; $j -le $batchEnd; $j++) {
            $accountNumber = [int]$j # Ensure that accountNumber is treated as an integer
            $formattedAccountNumber = "{0:D2}" -f $accountNumber # Format account number to be 01, 02, ...
            $localDatFolder = FindLocalDatFolder $formattedAccountNumber

            if ($localDatFolder -ne $null) {
                LaunchGame $localDatFolder "-shareArchive"
                KillMutex $mutexName  # Close mutex if it's open
            }
        }
        # Wait for user input before continuing to the next batch
        Read-Host "Press Enter to continue..." -ForegroundColor Yellow
    }

    # Clear history and go back to main menu once done
    cls
    ShowMenu
}

function SelectSpecificAccount() {
    cls
    Write-Host "Enter the account number to launch" -ForegroundColor Yellow
    $accountNumber = Read-Host
    $accountNumber = [int]$accountNumber # Ensure that accountNumber is treated as an integer
    $localDatFolder = FindLocalDatFolder $accountNumber
    if ($localDatFolder -ne $null) {
        LaunchGame $localDatFolder "-shareArchive"
        KillMutex $mutexName  # Close mutex if it's open
    }

    # Clear history and go back to main menu once done
    cls
    ShowMenu
}

function UpdateAllLocalDat() {
    cls
    Write-Host "`n`nUpdating all Local.dat files.`nLet it run by itself until it's finished." -ForegroundColor Blue
    for ($accountNumber = 1; $accountNumber -le 40; $accountNumber++) {
        $localDatFolder = FindLocalDatFolder $accountNumber

        if ($localDatFolder -ne $null) {
            Write-Host "`nUpdating Local.dat for Account: $accountNumber" -ForegroundColor Yellow
            # Launch account without killing mutexes and without -shareArchive
            LaunchGame $localDatFolder ""

            Start-Sleep -Seconds 5  # Adjust as needed for update time
            
            # Close Guild Wars 2
            Stop-Process -Name "Gw2-64" -Force

            # Wait for Guild Wars 2 to close completely
            do {
                Start-Sleep -Milliseconds 500
                $gw2Processes = Get-Process -Name Gw2-64 -ErrorAction SilentlyContinue
            } while ($gw2Processes.Count -gt 0)

            Start-Sleep -Seconds 1  # Extra pause for stability

            # Continue to the next account
        }
    }

    # Clear history and go back to main menu once done
    cls
    ShowMenu
}

function ToggleArcDPS() {
    cls

    $d3d11Path = "$gameDirectory\d3d11.dll"
    $d3d11DisabledPath = "$gameDirectory\d3d11.dll.DISABLED"

    if ((Test-Path $d3d11Path) -or (Test-Path $d3d11DisabledPath)) {
        if (Test-Path $d3d11DisabledPath) {
            # Enable ArcDPS by removing .DISABLED from filename
            Rename-Item $d3d11DisabledPath -NewName 'd3d11.dll'
            Write-Host "`n`nArcDPS has been Enabled" -ForegroundColor Green
        } else {
            # Disable ArcDPS by adding .DISABLED to filename
            Rename-Item $d3d11Path -NewName 'd3d11.dll.DISABLED'
            Write-Host "`n`nArcDPS has been Disabled" -ForegroundColor Red
        }
    } else {
        Write-Host "`n`nArcDPS not found. Please check the path or if the d3d11.dll file exists in the game directory." -ForegroundColor Yellow
    }

    # Go back to main menu once done
    ShowMenu
}

function ShowMenu() {
    # Set ArcDPS display as Enable or Disable
    $arcDpsOption = if (Test-Path "$gameDirectory\d3d11.dll") {
        "[6] Disable ArcDPS"
    } elseif (Test-Path "$gameDirectory\d3d11.dll.DISABLED") {
        "[6] Enable ArcDPS"
    } else {
        "[6] Toggle ArcDPS"
    }
    
    Write-Host ""
    Write-Host "==========================" -ForegroundColor DarkGray
    write-Host ""
    Write-Host "Select an option:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Launch Main Account" -ForegroundColor DarkYellow
    Write-Host "[2] Multibox Accounts 1-20" -ForegroundColor DarkYellow
    Write-Host "[3] Multibox Accounts 21-40" -ForegroundColor DarkYellow
    Write-Host "[4] Select Specific Account" -ForegroundColor DarkYellow
    Write-Host "[5] Update All Local.dat" -ForegroundColor DarkYellow
    Write-Host $arcDpsOption -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "[0] Exit" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "==========================" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "Input your choice and press 'ENTER' to confirm: $choice" -ForegroundColor Yellow
    $choice = Read-Host

    switch ($choice) {
        "1" { LaunchMainAccount }
        "2" { MultiboxAccounts 1 20 5 }
        "3" { MultiboxAccounts 21 40 5 }
        "4" { SelectSpecificAccount }
        "5" { UpdateAllLocalDat }
        "6" { ToggleArcDPS }
        "0" { Exit }
        default {
            cls
            Write-Host "`n`nInvalid choice. Please try again." -ForegroundColor Yellow
            ShowMenu
        }
    }
}

# Show the main menu at script launch
Write-Host "`n`n"
ShowMenu
