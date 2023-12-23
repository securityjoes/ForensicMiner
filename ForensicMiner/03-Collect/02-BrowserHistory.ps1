    Write-Output ""
    New-Item -ItemType Directory -Force -Path C:\ForensicMiner\MyCollectedFiles\02-BrowserHistory | Out-Null
    $UsersPath = Get-ChildItem C:\Users -Exclude ("Public","TEMP") -Directory
    $BrowserPaths = @{
      "Chrome" = "\AppData\Local\Google\Chrome\User Data\Default\History"
      "Brave" = "AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\History"
      "Firefox" = "AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite"
      "Edge" = "AppData\Local\Microsoft\Edge\User Data\Default\History"
      "Opera" = "AppData\Roaming\Opera Software\Opera Stable\History"
    }
    $UsersWithoutBrowser = @()
    $DestinationFolder = "C:\ForensicMiner\MyCollectedFiles\02-BrowserHistory"
    Write-Output "User Installed Browser"
    Write-Output "----------------------"
    if (-not (Test-Path $DestinationFolder)) {
      New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
    }

    foreach ($User in $UsersPath) {
      $InstalledBrowsers = @()
      foreach ($Browser in $BrowserPaths.Keys) {
        $CompleteBrowserPath = Join-Path -Path $User.FullName -ChildPath $BrowserPaths[$Browser]
        if (Test-Path $CompleteBrowserPath) {
          $InstalledBrowsers += $Browser.ToLower()
          $DestinationPath = Join-Path -Path $DestinationFolder -ChildPath "$($User.Name)_$Browser.sqlite"
          Copy-Item -Path $CompleteBrowserPath -Destination $DestinationPath -Force
        }
      }

      if ($InstalledBrowsers.Count -gt 0) {
        Write-Output "$($User.Name) - has history files of - $($InstalledBrowsers -join ', ')."
      } else {
        $UsersWithoutBrowser += $User.Name
      }
    }

    if ($UsersWithoutBrowser.Count -gt 0) {
      Write-Output ""
      Write-Output "#No Browser Found:"
      Write-Output "The following users do not have a browser installed: $($UsersWithoutBrowser -join ', ')."
    }
    Write-Output ""
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '| Path - "C:\ForensicMiner\MyCollectedFiles\02-BrowserHistory"|'
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|   Compatible with: Chrome, Brave, Firefox, Edge, Opera.     |"
    Write-Output "+-------------------------------------------------------------+"