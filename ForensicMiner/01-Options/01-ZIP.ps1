# path variables
$Hostname = hostname
$ZipFolderPath = "C:\ForensicMiner\MyZIP"
$MyEvidence = "C:\ForensicMiner\MyEvidence"
$MyCollectedFiles = "C:\ForensicMiner\MyCollectedFiles"
$ZipFileName = "C:\ForensicMiner\MyZIP\$Hostname.zip"

# ZIP status
Write-Output ""
Write-Output "ZIP Status"
Write-Output "+--------+"

# check if $ZipFolderPath already exist
if (Test-Path -Path $ZipFolderPath) {
Remove-Item -Path $ZipFolderPath -Forc -Recurse | Out-Null
Start-Sleep -Milliseconds 300
Write-Output "[*] Old MyZIP folder was successfully removed."
}

# check if MyZIP folder was created
New-Item -ItemType Directory -Force -Path $ZipFolderPath | Out-Null
if (Test-Path -Path $ZipFolderPath) {
Start-Sleep -Milliseconds 300
Write-Output "[*] MyZIP folder was successfully created."
}
else {
Start-Sleep -Milliseconds 300
Write-Output "[!] MyZIP folder failed to be cretaed, check terminal permissions."
Start-Sleep -Milliseconds 300
Write-Output "[!] Stopping ZIP process."
Exit
}

# create and check $ZipFileName
New-Item -Path $ZipFileName -Force | Out-Null
if (Test-Path -Path $ZipFileName) {
Start-Sleep -Milliseconds 300
Write-Output "[*] $Hostname.zip was successfully created under MyZIP folder."
}
else {
Start-Sleep -Milliseconds 300
Write-Output "$Hostname.zip failed to be created undesr MyZIP folder."
Start-Sleep -Milliseconds 300
Write-Output "[!] Stopping ZIP process."
Exit
}

if ((Get-ChildItem -Path $MyEvidence -Force).Count -ge 1) {
Compress-Archive -Path $MyEvidence -DestinationPath $ZipFileName -Update
Start-Sleep -Milliseconds 300
Write-Output "[*] Adding MyEvidence to MyZIP folder."
}

else {
Start-Sleep -Milliseconds 300
Write-Output "[*] MyEvidence is empty."
}

if ((Get-ChildItem -Path $MyCollectedFiles -Force).Count -ge 1) {
Compress-Archive -Path $MyCollectedFiles -DestinationPath $ZipFileName -Update
Start-Sleep -Milliseconds 300
Write-Output "[*] Adding MyCollectedFiles to MyZIP folder."
}

else {
Start-Sleep -Milliseconds 300
Write-Output "[*] MyCollectedFiles is empty."
}

Write-Output "[*] Your ZIP file is ready!"

# Space
Write-Output ""

Write-Output "ZIP Path -> $ZipFileName"

# Space
Write-Output ""