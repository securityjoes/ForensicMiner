param(
  # Options
  [Parameter(Mandatory = $false)]
  [ValidateSet('Menu','ZIP','Purge','Update')]
  [string]$O,

  # Analyze
  [Parameter(Mandatory = $false)]
  [ValidateSet('RecentItems','WiFiHistory','BAM','RunMRU','RecentDocs','MUICache','BrowserAnalyzer','Harvest','TypedPaths')]
  [string]$A,

  # Collect
  [Parameter(Mandatory = $false)]
  [ValidateSet('BrowserHistory','SystemEvents')]
  [string]$C

)

# Variable to record from where the Forensic Miner is running (for the dot sourcing)
$RunningPath = Get-Location

#Create the "C:\ForensicMiner\MyEvidence" folder.
New-Item -ItemType Directory -Force -Path C:\ForensicMiner\MyEvidence | Out-Null

#Create the "C:\ForensicMiner\MyCollectedFiles" folder.
New-Item -ItemType Directory -Force -Path C:\ForensicMiner\MyCollectedFiles | Out-Null

# current script version
$CurrentVersion = "v1.4"

# test conection to GitHub domain
$ConnectionStatus = Test-Connection -ComputerName "GitHub.com" -Count 1 -ErrorAction SilentlyContinue

# statment to check if the there is connection to GitHub or not
if ($ConnectionStatus) {
$ConnectionFlag = "True"

# GitHub API URL for the repository releases
$FM_URL = "https://api.github.com/repos/YosfanEilay/ForensicMiner/releases/latest"

# Use Invoke-RestMethod to make a GET request to the GitHub API
$response = Invoke-RestMethod -Uri $FM_URL -Method Get -ErrorAction Continue

# Extract the version number from the response
$Latestversion = $response.tag_name

}

# execute this if connection to GitHub is NOT reachable
else {
$ConnectionFlag = "False"
}

Write-Output ""
Write-Output "███████╗ ██████╗ ██████╗ ███████╗███╗   ██╗███████╗██╗ ██████╗"
Write-Output "██╔════╝██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝██║██╔════╝"
Write-Output "█████╗  ██║   ██║██████╔╝█████╗  ██╔██╗ ██║███████╗██║██║"
Write-Output "██╔══╝  ██║   ██║██╔══██╗██╔══╝  ██║╚██╗██║╚════██║██║██║"
Write-Output "██║     ╚██████╔╝██║  ██║███████╗██║ ╚████║███████║██║╚██████╗"
Write-Output "╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═════╝"
Write-Output ""
Write-Output "        ███╗   ███╗██╗███╗   ██╗███████╗██████╗"
Write-Output "        ████╗ ████║██║████╗  ██║██╔════╝██╔══██╗"
Write-Output "        ██╔████╔██║██║██╔██╗ ██║█████╗  ██████╔╝"
Write-Output "        ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██╔══██╗"
Write-Output "        ██║ ╚═╝ ██║██║██║ ╚████║███████╗██║  ██║"
Write-Output "        ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝"

if ($ConnectionFlag -eq "True") {
# if statment to comper versions
if ($CurrentVersion -eq $Latestversion) {
Write-Output "          You are using the latest version $CurrentVersion"
Write-Output "                 No update is required."
}

else {
Write-Output "      Update Available: You are using version $CurrentVersion"
Write-Output "              The latest version is $latestVersion"
Write-Output "                  Update is required."
}
}

else {
Write-Output ""
Write-Output "                     Version: $CurrentVersion"
}

# space
Write-Output ""

switch ($O) {
  'ZIP' {
    . $RunningPath\01-Options\01-ZIP.ps1
  }
  'Menu' {
    . $RunningPath\01-Options\02-Menu.ps1
  }
  'Purge' {
    . $RunningPath\01-Options\03-Purge.ps1
  }
  'Update' {
    . $RunningPath\01-Options\04-Update.ps1
  }
}

switch ($A) {
  'Harvest' {
    . $RunningPath\02-Analyze\01-BAM.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\02-RunMRU.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\03-MUICache.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\04-RecentDocs.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\05-RecentItems.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\06-WiFiHistory.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\07-BrowserAnalyzer.ps1
    Start-Sleep -Milliseconds 500
    . $RunningPath\02-Analyze\08-TypedPaths.ps1
    }
  'BAM' {
    . $RunningPath\02-Analyze\01-BAM.ps1
  }
  'RunMRU' {
    . $RunningPath\02-Analyze\02-RunMRU.ps1
  }
  'MUICache' {
    . $RunningPath\02-Analyze\03-MUICache.ps1
  }
  'RecentDocs' {
    . $RunningPath\02-Analyze\04-RecentDocs.ps1
  }
  'RecentItems' {
    . $RunningPath\02-Analyze\05-RecentItems.ps1
  }
  'WiFiHistory' {
    . $RunningPath\02-Analyze\06-WiFiHistory.ps1
  }
  'BrowserAnalyzer' {
    . $RunningPath\02-Analyze\07-BrowserAnalyzer.ps1
  }
  'TypedPaths' {
    . $RunningPath\02-Analyze\08-TypedPaths.ps1
  }
}


switch ($C) {
  'SystemEvents' {
    . $RunningPath\03-Collect\01-SystemEvents.ps1
  }
  'BrowserHistory' {
    . $RunningPath\03-Collect\02-BrowserHistory.ps1
  }
}
