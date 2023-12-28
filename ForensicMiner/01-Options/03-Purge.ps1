$Root_FM_Fodler = "C:\ForensicMiner\"

if (Test-Path -Path $Root_FM_Fodler) {
  Write-Output "List of deleted files from root ForensicMiner folder"
  Write-Output "+--------------------------------------------------+"
  $files = Get-ChildItem -Path "$Root_FM_Fodler\*"
  $filesToDelete = @()

  foreach ($file in $files) {
    $fileInfo = [pscustomobject]@{
      CreationTime = $file.CreationTime
      Name = $file.Name
    }
    $filesToDelete += $fileInfo
  }

  foreach ($fileInfo in $filesToDelete) {
    Write-Output ("Creation Time: {0}, Name: {1}" -f $fileInfo.CreationTime,$fileInfo.Name)
    Remove-Item -Path "$FolderRemove\$($fileInfo.Name)" -ErrorAction SilentlyContinue -Force -Recurse
  }
# space
Start-Sleep -Milliseconds 500
Write-Output ""
Write-Output "Purge Status"
Write-Output "+----------+"
Write-Output "[*] ForensicMiner has been successfully removed from this machine."
}

else {
Write-Output "An error occurred while attempting to remove ForensicMiner"
Write-Output "+--------------------------------------------------------+"
Write-Output "[!] Root ForensicMiner Folder was not found under C:\ - please remove manually."
Write-Output "[!] Verify if you running as Administrator, essential for proper removal."
Write-Output "[!] Alternatively, check where did you installed ForensicMiner."
}


# space
Write-Output ""

cd ..
$CurrentPath = Get-Location
Write-Output "Terminal Path Change"
Write-Output "+------------------+"
Write-Output "[*] Current directory path is now $CurrentPath"

# Double delete verify
Start-Sleep -Seconds 1.5
Remove-Item -Path "C:\ForensicMiner" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

# secret dev option related
Remove-Item "C:\Archive.zip" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# space
Write-Output ""
