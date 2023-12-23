    $hostname3 = hostname
    $targetDirectory = "C:\ForensicMiner\MyCollectedFiles\01-SystemEvents"
    $eventLogsPath = "C:\Windows\System32\winevt\Logs\*"
    New-Item -ItemType Directory -Path $targetDirectory -ErrorAction SilentlyContinue | Out-Null

    $filesCount = (Get-ChildItem -Path $eventLogsPath -File).Count
    Copy-Item -Path $eventLogsPath -Destination $targetDirectory -Force > $null

    Write-Output "$filesCount Windows event logs was found on $Hostname3!"
    Write-Output "Important Windows event logs check: (Found\Missing)"
    Write-Output ""
    Write-Output "   Event                     Status"
    #Security.evtx
    if (Test-Path -Path "$targetDirectory\Security.evtx") {
      Write-Output "1. Security.evtx             Found"
    }

    else {
      Write-Output "1. Security.evtx             Missing"
    }

    #System.evtx
    if (Test-Path -Path "$targetDirectory\System.evtx") {
      Write-Output "2. System.evtx               Found"
    }


    else {
      Write-Output "2. System.evtx               Missing"
    }

    #Application.evtx
    if (Test-Path -Path "$targetDirectory\Application.evtx") {
      Write-Output "3. Application.evtx          Found"
    }


    else {
      Write-Output "3. Application.evtx          Missing"
    }

    #Windows PowerShell.evtx
    if (Test-Path -Path "$targetDirectory\Windows PowerShell.evtx") {
      Write-Output "4. Windows PowerShell.evtx   Found"
    }


    else {
      Write-Output "4. Windows PowerShell.evtx   Missing"
    }

    #Setup.evtx
    if (Test-Path -Path "$targetDirectory\Setup.evtx") {
      Write-Output "5. Setup.evtx                Found"
    }


    else {
      Write-Output "5. Setup.evtx                Missing"
    }
    Write-Output ""
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '|  Path - "C:\ForensicMiner\MyCollectedFiles\01-SystemEvents" |'
    Write-Output "+-------------------------------------------------------------+"