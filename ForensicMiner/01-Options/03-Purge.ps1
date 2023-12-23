$Root_FM_Fodler = "C:\ForensicMiner\"

if (Test-Path -Path $Root_FM_Fodler) {
  Write-Output "List Of Deleted Files From Root ForensicMiner Folder"
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

}

else {
Write-Output "List Of Deleted Files From Root ForensicMiner Folder"
Write-Output "+--------------------------------------------------+"
Write-Output "[!] Root ForensicMiner Folder was not found under C:\ - please remove manually."
Write-Output "[!] Verify if you running as Administrator, essential for proper removal."
Write-Output "[!] Alternatively, check where did you installed ForensicMiner."
}

# related vareable path
$FMextractor = "C:\FM-Extractor.ps1"
$FMpackage = "C:\FM-Package.zip"

Write-Output ""
Write-Output "Removing Installation Package"
Write-Output "+---------------------------+"

# deleting C:\FM-Extractor.ps1
if (Test-Path -Path $FMextractor -PathType Leaf) {
Write-Output "[*] FM-Extractor.ps1 Removed Successfully"
Remove-Item -Path $FMextractor -ErrorAction SilentlyContinue -Force -Recurse
}
else {
Write-Output "[!] FM-Extractor.ps1 not found under C:\ - please remove manually."
}

# deleting C:\FM-Package.ps1
if (Test-Path -Path $FMpackage -PathType Leaf) {
Write-Output "[*] FM-Package.ps1 Removed Successfully"
Remove-Item -Path $FMpackage -ErrorAction SilentlyContinue -Force -Recurse
}
else {
Write-Output "[!] FM-Package.ps1 not found under C:\ - please remove manually."
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
Remove-Item -Path "C:\FM-Package.zip" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path "C:\FM-Extractor.ps1" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

# space
Write-Output ""