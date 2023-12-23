# Module Install Section.
# Related Variables.
$ModulePath = "C:\Program Files\WindowsPowerShell\Modules"
$ModuleZIPPath = "C:\ForensicMiner\Modules\PSSQlite.zip"

# First Main Title.
Write-Output ""
Write-Output "PSQLite Install Process"
Write-Output "-----------------------"

# Module install error handling.
if (Test-Path -Path "$ModulePath\PSSQLite"){
Start-Sleep -Milliseconds 500 
# Path "C:\Program Files\WindowsPowerShell\Modules"
Write-Output "[*] PSSQLite already exist in this system."
Start-Sleep -Milliseconds 500 
Write-Output "[*] PSSQLite install process was successfully done."
}
else {
# Check if PSSQLite ZIP exist in root ForensicMiner folder.
if (Test-Path -Path $ModuleZIPPath){
Start-Sleep -Milliseconds 500
Write-Output "[*] PSSQLite module was found in root ForensicMiner folder."
Start-Sleep -Milliseconds 500
Write-Output "[*] Extracting PSSQLite module in to the system."
Expand-Archive -Path $ModuleZIPPath -DestinationPath $ModulePath | Out-Null
if (Test-Path -Path "$ModulePath\PSSQLite"){
Start-Sleep -Milliseconds 500
Write-Output "[*] PSSQLite was successfully extracted in to the system."
Start-Sleep -Milliseconds 500
Write-Output "[*] Importing PSSQLite in to the system."
Import-Module PSSQLite
if (Get-Command Invoke-SqliteQuery) {
Start-Sleep -Milliseconds 500
Write-Output "[*] PSSQLite was successfully imported in to the system."
Start-Sleep -Milliseconds 500
Write-Output "[*] PSSQLite install process was successfully done."
Start-Sleep -Milliseconds 500 
}
else {
Start-Sleep -Milliseconds 500
Write-Output "[!] There was a problem importing PSSQLite in to the system."
Start-Sleep -Milliseconds 500
Write-Output "[!] Script has been canceled."
exit
}
}
else {
Start-Sleep -Milliseconds 500
Write-Output "[!] There was a problem extracting PSSQLite in to the system."
Start-Sleep -Milliseconds 500
Write-Output "[!] Script has been canceled."
exit
}
}
else {
Start-Sleep -Milliseconds 500
Write-Output "[!] PSSQLite was not found in root ForensicMiner folder."
Start-Sleep -Milliseconds 500
Write-Output "[!] Script has been canceled."
exit
}
}

# First text output
Write-Output ""
Write-Output "Browser Analysis Process"
Write-Output "------------------------"

# Variable to store C:\Users output.
$Names = Get-ChildItem -Path "C:\Users"

# foreach loop to make single user name at a time.
foreach ($Name in $Names) {
  
  # Full user name path.
  $Full_User_Path = Join-Path -Path C:\Users -ChildPath $Name


  # List of browser path.
  $BrowserPaths = @{
    "Chrome" = "\AppData\Local\Google\Chrome\User Data\Default\History"
    "Brave" = "AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\History"
    "Edge" = "AppData\Local\Microsoft\Edge\User Data\Default\History"
    #"Opera" = "AppData\Roaming\Opera Software\Opera Stable\Default\History"
    #"Firefox" = "AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite"
  }
 

  # foreach loop to make single search for each browser path.
  foreach ($browserName in $BrowserPaths.Keys) {

    # Full path to chech each user for each browser path
    $User_With_Browser_Path = Join-Path -Path $Full_User_Path -ChildPath $BrowserPaths[$browserName]

    # if the user have the browser path.
    if (Test-Path $User_With_Browser_Path) {

    # Create each user a record folder.
    New-Item -ItemType Directory -Force -Path "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record" | Out-Null

    New-Item -ItemType Directory -Force -Path "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName" | Out-Null

    # Copy and past browser hisotry file.
    Copy-Item -Path $User_With_Browser_Path -Destination "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName\$Name-$browserName-History-File.sqlite"

    # Analyzing part.
    # Path variables.
    $Out_URL_Analysis = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName\$Name-$browserName-URL-Analysis.txt"
    $Out_Keyword_Search_Terms_Analysis = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName\$Name-$browserName-Keyword-Search-Terms-Analysis.txt"
    $Out_Download_Analysis = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName\$Name-$browserName-Download-Analysis.txt"
    $DB = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName\$Name-$browserName-History-File.sqlite"    

    # variable related to the browser analysis process table
    $HisotryGrabPath = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\$browserName\$Name-$browserName-History-File.sqlite"

    # URL_Analysis Query
    Invoke-SqliteQuery -DataSource $DB -Query "SELECT datetime((last_visit_time / 1000000) - 11644473600, 'unixepoch') AS 'Visit Time UTC Form', substr(datetime((last_visit_time / 1000000) - 11644473600, 'unixepoch', '+3 hours'), 12, 8) AS 'GMT+3 IL', substr(datetime((last_visit_time / 1000000) - 11644473600, 'unixepoch', '+2 hours'), 12, 8) AS 'GMT+2 IL', visit_count AS 'Count', SUBSTR(title, 1, 90) AS 'URL Title', url AS 'Full URL' FROM urls ORDER BY last_visit_time DESC" | Select-Object 'Visit Time UTC Form', 'GMT+3 IL', 'GMT+2 IL' ,'Count', 'URL Title', 'Full URL' | Format-Table -AutoSize | Out-File -FilePath $Out_URL_Analysis -Width ([int]::MaxValue)

    # Keyword_Search_Terms_Analysis Query
    Invoke-SqliteQuery -DataSource $DB -Query "SELECT url_id AS 'Term ID', term AS 'Browser Keyword Search Term' FROM keyword_search_terms ORDER BY url_id DESC" | Select-Object 'Term ID', 'Browser Keyword Search Term' | Format-Table -AutoSize | Out-File -FilePath $Out_Keyword_Search_Terms_Analysis -Width ([int]::MaxValue)

    # Download_Analysis Query
    Invoke-SqliteQuery -DataSource $DB -Query "SELECT datetime((start_time / 1000000) - 11644473600, 'unixepoch') AS 'Download Start Time', strftime('%H:%M:S', (end_time / 1000000) - 11644473600, 'unixepoch') AS 'End Time', (ROUND(total_bytes / 1048576.0, 3) || ' MB') AS 'File Size', SUBSTR(mime_type, 1, 30) AS 'File Type', CASE WHEN opened = 1 THEN 'Yes' WHEN opened = 0 THEN 'No' ELSE opened END AS 'Opened From Browser?', current_path AS 'Path Of The Downloaded File', tab_url AS 'File Was Downloaded From This Link' FROM downloads ORDER BY start_time DESC" | Select-Object 'Download Start Time', 'End Time', 'File Size', 'File Type', 'Opened From Browser?', 'Path Of The Downloaded File', 'File Was Downloaded From This Link' | Format-Table -AutoSize | Out-File -FilePath $Out_Download_Analysis -Width ([int]::MaxValue)

    # if statment for the Success \ Failure table
    # grab history statment
    if (Test-Path -Path $HisotryGrabPath) {
    $HisGrb = "Success"
    }
    else {
    $HisGrb = "Failure" 
    }

    # URL analysis statment
    if (Test-Path -Path $Out_URL_Analysis) {
    $URLchk = "Success"
    }
    else {
    $URLchk = "Failure"
    }

    # Download Analysis statment
    if (Test-Path -Path $Out_Download_Analysis) {
    $dwnchk = "Success"
    }
    else {
    $dwnchk = "Failure"
    }

    # Keyword search term Analysis statment
    if (Test-Path -Path $Out_Keyword_Search_Terms_Analysis) {
    $serchk = "Success"
    }
    else {
    $serchk = "Failure"
    }

    # check if the $browserName is Edge or Chrom
    if ($browserName -like "Edge") {
    
    # edge related variables
    $EdgeUserPicPath = "C:\Users\$Name\AppData\Local\Microsoft\Edge\User Data\Default\Edge Profile Picture.png"
    $FMEdgeUserPicPath = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\Edge\$Name-Profile-Picture.png"

    if (Test-Path -Path $EdgeUserPicPath -PathType Leaf) {
    Copy-Item -Path $EdgeUserPicPath -Destination $FMEdgeUserPicPath
    if (Test-Path -Path $FMEdgeUserPicPath -PathType Leaf) {
    $edgpic = "Success"
    }
    else {
    $edgpic = "Missing"
    }
    }
    else {
    $edgpic = "Missing"
    }
    }

    elseif ($browserName -like "Chrome") {
        
    # chrome related variables
    $ChromeUserPicPath = "C:\Users\$Name\AppData\Local\Google\Chrome\User Data\Default\Google Profile Picture.png"
    $FMChromeUserPicPath = "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer\$Name-Browser-Record\Chrome\$Name-Profile-Picture.png"
    
    if (Test-Path -Path $ChromeUserPicPath -PathType Leaf) {
    Copy-Item -Path $ChromeUserPicPath -Destination $FMChromeUserPicPath
    if (Test-Path -Path $FMChromeUserPicPath -PathType Leaf) {
    $chrpic = "Success"
    }
    else {
    $chrpic = "Missing"
    }
    }
    else {
    $chrpic = "Missing"
    }
    }

    else {
    }
    

        # table of status for the browser analysis operation
        Write-Output "[*] Browser:  $browserName"
        Write-Output "[*] Username: $Name"
        Write-Output "+----------------------+-----------+"
        Write-Output "|      #OPERATION      |  #Status  |"
        Write-Output "+----------------------+-----------+"
        Write-Output "|   Grab Hisotry File  |  $HisGrb  |"
        Write-Output "+----------------------+-----------+"
        Write-Output "|     URL Analysis     |  $URLchk  |"
        Write-Output "+----------------------+-----------+"
        Write-Output "|  Download Analysis   |  $dwnchk  |"
        Write-Output "+----------------------+-----------+"
        Write-Output "| Search Term Analysis |  $serchk  |"
        Write-Output "+----------------------+-----------+"

        if ($browserName -like "Chrome") {
        if ($chrpic -like "Success") {
        Write-Output "| User Profile Picture |  $chrpic  | <- Found User Chrome Profile"
        Write-Output "+----------------------+-----------+"
        }
        else {
        Write-Output "| User Profile Picture |  $chrpic  | <- User Chrome Profile Not Found"
        Write-Output "+----------------------+-----------+"
        }
        }
        else{
        }

        if ($browserName -like "Edge") {
        if ($edgpic -like "Success") {
        Write-Output "| User Profile Picture |  $edgpic  | <- Found User Edge Profile"
        Write-Output "+----------------------+-----------+"
        }
        else {
        Write-Output "| User Profile Picture |  $edgpic  | <- User Edge Profile Not Found"
        Write-Output "+----------------------+-----------+"
        }
        }
        else{
        }
        Write-Output ""
        Start-Sleep -Milliseconds 500
    }
    # if the user does not have the browser path.
    else {
    }
  } # here the foreach loop is ending

}

      Write-Output ""
      Write-Output "+-------------------------------------------------------------+"
      Write-Output "|The record of this forensic evidence is saved on this machine|"
      Write-Output "+-------------------------------------------------------------+"
      Write-Output '|   Path - "C:\ForensicMiner\MyEvidence\07-BrowserAnalyzer"   |'
      Write-Output "+-------------------------------------------------------------+"
      Write-Output ""