# Stop watch.
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# File names and path.
$ZIP = "FM-Package.zip"
$ZIPPath = "$PSScriptRoot\$ZIP"
$FMfile = "C:\ForensicMiner"
$ForensicMinerFolder = "$PSScriptRoot\ForensicMiner"
$FMPackageZIP = "$PSScriptRoot\FM-Package.zip"

# Spacing and Title
Write-Output ""
Write-Output "    Extracror Status"
Write-Output "    ----------------"
Start-Sleep -Milliseconds 500
Write-Output "[*] Executing Extractor Script.."
Start-Sleep -Milliseconds 500

# check if the folder "ForensicMiner" was found?
if (Test-Path -Path $ForensicMinerFolder) {
Start-Sleep -Milliseconds 500
Write-Output "[*] ForensicMiner folder was found."
# create the FM-Package.zip and move ForensicMiner folder to FM-Package.zip
Compress-Archive -Path $ForensicMinerFolder -DestinationPath $FMPackageZIP
}
else {
Write-Output "[!] ForensicMiner folder was not found under $ForensicMinerFolder."
}

# Check if FM-Package.zip exist to start the script
if (Test-Path -Path $PSScriptRoot\$ZIP) {
Write-Output "[*] $ZIP was found."
Start-Sleep -Milliseconds 500
}

else {
Start-Sleep -Milliseconds 500
Write-Output "[!] $ZIP was not found in the same path as FM-Extractor.ps1."
Start-Sleep -Milliseconds 500
Write-Output "[!] Script was canceled."
Write-Output ""
Write-Output "    Help Center"
Write-Output "    -----------"
Start-Sleep -Milliseconds 500
Write-Output "[1] Verify that $ZIP is located in the same path as FM-Extractor.ps1."
Start-Sleep -Milliseconds 500
Write-Output "[2] Only then you can run FM-Extractor.ps1 whitout errors"
exit
}

# Check if FM-Package.zip already exist in C:\.
if (Test-Path -Path "C:\$ZIP") {
Start-Sleep -Milliseconds 500
Write-Output "[*] Old $ZIP will be replaced with new one in C:\."
}

# Check if ForensicMiner folder already exist in C:\.
if (Test-Path -Path "$FMfile") {
Start-Sleep -Milliseconds 500
Remove-Item -Path "$FMfile" -Recurse
Write-Output "[*] Old ForensicMiner folder was deleted from C:\."
}

# Move ForensicMiner to C:\.
Move-Item -Path $ZIPPath -Destination "C:\" -Force
if (Test-Path -Path "C:\$ZIP") {
Start-Sleep -Milliseconds 500
Write-Output "[*] $ZIP was move to: C:\"

}
else {
Start-Sleep -Milliseconds 500
Write-Output "[!] $ZIP was failed moving to C:\"
Start-Sleep -Milliseconds 500
Write-Output "[!] Script was canceled."
exit
}

# Extract ForensicMiner folder from FM-Package.zip.
Expand-Archive -Path "C:\$ZIP" -DestinationPath "C:\" -ErrorAction SilentlyContinue
if (Test-Path -Path "$FMfile"){
Start-Sleep -Milliseconds 500
Write-Output "[*] ForensicMiner folder was extracted from $ZIP"
Start-Sleep -Milliseconds 500
Write-Output "[*] Extractor was done running successfully."
Start-Sleep -Milliseconds 500
Write-Output "[*] You may use ForensicMiner tool now."
}

else {
Start-Sleep -Milliseconds 500
Write-Output "[!] ForensicMiner folder failed to be extracted from $ZIP"
Start-Sleep -Milliseconds 500
Write-Output "[!] Script was canceled."
exit
}

# Stop the watch
$stopwatch.Stop()
# Access the execution time using the stopwatch
$elapsedTime = $stopwatch.Elapsed
# Show the time.
Write-Output ""
Start-Sleep -Milliseconds 500
Write-Output "Done After: $($elapsedTime.Seconds) seconds"