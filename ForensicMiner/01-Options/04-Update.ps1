# making sure
Remove-Item "C:\ForensicMiner-main" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "C:\ForensicMiner.zip" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# process title
Write-Output "ForensicMiner Update Process"
Write-Output "+--------------------------+"
Start-Sleep -Milliseconds 300
Write-Output "[*] Checking connection to GitHub."

# GitHub domain variable
$GitHub = "GitHub.com"

# test conection to GitHub domain
$ConnectionStatus = Test-Connection -ComputerName $GitHub -Count 2 -ErrorAction SilentlyContinue | Select-Object -Property *

# statment to check if the there is connection to GitHub or not
if ($ConnectionStatus) {
Start-Sleep -Milliseconds 300
Write-Output "[*] GitHub is reachable."
}

# execute this if connection to GitHub is NOT reachable
else {
Start-Sleep -Milliseconds 150
Write-Output "[!] GitHub is NOT reachable."
Start-Sleep -Milliseconds 150
Write-Output "[!] Please check your internet connection."
Start-Sleep -Milliseconds 150
Write-Output "[!] Update failed."
exit
}

# write that ForensicMiner-main.zip is now downloading
Start-Sleep -Milliseconds 300
Write-Output "[*] Downloading the latest ForensicMiner."

# invoke a web request to download the latest ForensicMiner ZIP file
Invoke-WebRequest https://github.com/YosfanEilay/ForensicMiner/archive/main/ForensicMiner.zip -OutFile C:\ForensicMiner.zip

# if statment to check if download completed successfully
if (Test-Path -Path "C:\ForensicMiner.zip"){
Start-Sleep -Milliseconds 300
Write-Output "[*] Download completed successfully."
}

# new file was not found after download under C:\ drive.
else {
Start-Sleep -Milliseconds 150
Write-Output "[!] New ForensicMiner was not found under C:\ drive."
Start-Sleep -Milliseconds 150
Write-Output "[!] Update failed."
exit
}

# ForensicMiner root folder path variable
$RootForensicMienr = "C:\ForensicMiner"

# check if ForensicMiner root folder is under C:\ForensicMiner
if (Test-Path -Path $RootForensicMienr) {
Write-Output "[*] Old ForensicMiner was found under C:\ drive."
}

# if ForensicMiner root folder is NOT under C:\ForensicMiner
else {
Start-Sleep -Milliseconds 150
Write-Output "[!] Old ForensicMiner was NOT found under C:\ drive."
Start-Sleep -Milliseconds 150
Write-Output "[!] ForensicMiner has to be installed under C:\ drive."
Start-Sleep -Milliseconds 150
Write-Output "[!] Update failed."
exit
}

# move back 1 time to be able to remove ForensicMiner root folder
cd ..

# delete ForensicMiner root folder
Start-Sleep -Milliseconds 300
Write-Output "[*] Removing old ForensicMiner"
Remove-Item $RootForensicMienr -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

# check if deletion was complete successfully
if (Test-Path -Path $RootForensicMienr) {
Start-Sleep -Milliseconds 150
Write-Output "[!] Failed to remove old ForensicMiner."
Start-Sleep -Milliseconds 150
Write-Output "[!] Update failed."
exit
}

# if remove was successfull execute this else.
else {
Start-Sleep -Milliseconds 300
Write-Output "[*] Remove completed successfully."
}

# extract relevent folder from the ZIP
Expand-Archive -Path "C:\ForensicMiner.zip" -DestinationPath "C:\"

if (Test-Path -Path "C:\ForensicMiner-main") {
Start-Sleep -Milliseconds 300
Write-Output "[*] Extracting new ForensicMiner completed successfully."
}

else {
Start-Sleep -Milliseconds 150
Write-Output "[!] Failed to extract new ForensicMiner."
Start-Sleep -Milliseconds 150
Write-Output "[!] Update failed."
exit
}

# move new forensicminer to c:\ from ForensicMiner-main
Move-Item -Path "C:\ForensicMiner-main\ForensicMiner" -Destination "C:\" -Force

if (Test-Path -Path "C:\ForensicMiner") {
Start-Sleep -Milliseconds 300
Write-Output "[*] New ForensicMiner are in place."
Start-Sleep -Milliseconds 300
Write-Output "[*] Update completed successfully."
cd "C:\ForensicMiner"
}

else {
Write-Output "[!] New ForensicMiner root folder not found."
Start-Sleep -Milliseconds 150
Write-Output "[!] Update failed."
exit
}

# remove package from C:\
Remove-Item "C:\ForensicMiner-main" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "C:\ForensicMiner.zip" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Write-Output ""