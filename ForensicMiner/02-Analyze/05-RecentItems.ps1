    Write-Output ""
    New-Item -ItemType Directory -Force -Path C:\ForensicMiner\MyEvidence\05-RecentItems | Out-Null
    $RecentFileLocation = "\AppData\Roaming\Microsoft\Windows\Recent"
    $UsersPath = Get-ChildItem C:\Users -Exclude ("Public","TEMP","Default") -Directory

    foreach ($User in $UsersPath) {
      $RecentFilePath = Join-Path -Path $User.FullName -ChildPath $RecentFileLocation
      $RecentItems = Get-ChildItem $RecentFilePath -Exclude ('CustomDestinations','AutomaticDestinations')| Select-Object -First 300 | Where-Object { $_.Name.Length -le 90 }
      Write-Output ""
      Write-Output "Recent Files Touched By -> $($User.Name)"
      Write-Output ""
      $count = 1
      $RecentItems | Sort-Object -Property LastAccessTime -Descending | ForEach-Object {
        $line = "#$count $($_.LastAccessTime) $($_.Name)"
        $count++
        $line
      } | Out-File -Force -FilePath "C:\ForensicMiner\MyEvidence\05-RecentItems\RecentItemsTouchedBy-$($User.Name).txt"

      Get-Content -Path "C:\ForensicMiner\MyEvidence\05-RecentItems\RecentItemsTouchedBy-$($User.Name).txt"
    }
    Write-Output ""
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '|     Path - "C:\ForensicMiner\MyEvidence\05-RecentItems"     |'
    Write-Output "+-------------------------------------------------------------+"