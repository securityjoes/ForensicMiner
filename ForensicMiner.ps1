param(
  #Options
  [Parameter(Mandatory = $false)]
  [ValidateSet('Menu','ZIP','Purge')]
  [string]$O,

  #Analyze
  [Parameter(Mandatory = $false)]
  [ValidateSet('RecentItems','WiFiHistory','BAM','RunMRU','RecentDocs','MUICache','BrowserAnalyzer','Harvest')]
  [string]$A,

  #Collect
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
Write-Output "                 github.com/YosfanEilay"
Write-Output "                     Version: 1.2v"
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
}


switch ($C) {
  'SystemEvents' {
    . $RunningPath\03-Collect\01-SystemEvents.ps1
  }
  'BrowserHistory' {
    . $RunningPath\03-Collect\02-BrowserHistory.ps1
  }
}
