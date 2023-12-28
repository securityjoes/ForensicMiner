#Check if "TypedPaths" folder exists.
$FolderPath = "C:\ForensicMiner\MyEvidence\08-TypedPaths"
if (Test-Path $FolderPath) {
  Remove-Item $FolderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}

#Create the "TypedPaths" folder.
New-Item -ItemType Directory -Force -Path $FolderPath | Out-Null

# define the variable path to TypedPaths on registry
$HalfPathTypedPaths = "Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths"

# define the variable path to NTUSER.DAT
$NTUSER = "\NTUSER.DAT"

# Define and exclude the relevant users for the foreach loop
$Users = Get-ChildItem C:\Users -Exclude ("Public","TEMP","Default","*.NET*") -Directory

# Use foreach loop to name the hives
foreach ($user in $Users) {

  # define full NTUSER.DAT path for each user
  $NTUSER_PATH = Join-Path -Path $User.FullName -ChildPath $NTUSER

  # if statment to check if the not excluded usesr has NTUSER.DAT in his profile folder
  if (Test-Path -Path $NTUSER_PATH) {

    # Name of each user on the system without the "Name" column
    $OnlyUserName = $user | Select-Object -Property Name | ForEach-Object { $_.Name }

    # Load the NTUSER.DAT of the user and capture the output
    $output = reg load HKLM\Offline-$OnlyUserName "$NTUSER_PATH" 2>&1

    # if statment for offline users
    if ($output -like "The operation completed successfully.") {
        
        # full registry path with offline user hive to TypedPaths
        $FullOfflineRegistryPath = "Registry::HKEY_LOCAL_MACHINE\Offline-$OnlyUserName\$HalfPathTypedPaths"

        if (Test-Path -Path $FullOfflineRegistryPath) {
        
        # Get all properties of the registry path $FullRegTypedPath
        $OfflineRegistryProperties = Get-ItemProperty -Path $FullOfflineRegistryPath | Select-Object * -ExcludeProperty ("PSProvider","PSChildName","PSParentPath","PSPath")

        # Output of offline loaded users hives
        Write-Output "+-------------------------------------"
        Write-Output "|User Type:     Offline"
        Write-Output "|User Name:     $OnlyUserName"
        Write-Output "|Which Hive:    NTUSER.DAT"
        Write-Output "|Hive Status:   Registry Was Loaded!"
        Write-Output "|Registry Path: HKLM\Offline-$OnlyUserName"
        Write-Output "+-------------------------------------"
        Write-Output "|User TypedPaths List"
        Write-Output "|--------------------"

            # Iterate through each property in the hashtable and print each line separately
            foreach ($property in $OfflineRegistryProperties.PSObject.Properties) {
                Write-Host "|#$($property.Name -replace 'url','') - $($property.Value)"
          }
        
        }

        # if statment for users who don't have this path $FullOnlineRegistryPath
        else {
        }
        

    }

    # if statment for online users
    else {

      # Retrieve the user SID using WMI query
      $SID = (Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath.EndsWith($OnlyUserName) }).SID

      # if statment to check if $SID variable has a SID in it
      if ($SID -ge 30) {

        # full variable of the user path to "TypedPath"
        $FullRegTypedPath = "Registry::HKEY_USERS\$SID\$HalfPathTypedPaths"

        # if statement to check if $FullRegTypedPath exists
        if (Test-Path -Path $FullRegTypedPath) {

          # Get all properties of the registry path $FullRegTypedPath
          $registryProperties = Get-ItemProperty -Path $FullRegTypedPath | Select-Object * -ExcludeProperty ("PSProvider","PSChildName","PSParentPath","PSPath")

          Write-Output "+-----------------------------------"
          Write-Output "|User Type:     Online"
          Write-Output "|User Name:     $OnlyUserName"
          Write-Output "|Which Hive:    NTUSER.DAT"
          Write-Output "|Registry Path: HKEY_USERS"
          Write-Output "|Hive Status:   Hive Already Loaded!"
          Write-Output "+-----------------------------------"
          Write-Output "|User TypedPaths List"
          Write-Output "|--------------------"

          # Iterate through each property in the hashtable and print each line separately
          foreach ($property in $registryProperties.PSObject.Properties) {
            Write-Host "|#$($property.Name -replace 'url','') - $($property.Value)"
          }
        }
        # space
        Write-Output ""
      }

      else {
      }
    }
  }
}


#Text $Outfile Veriable
#$OutFile = "C:\ForensicMiner\MyEvidence\02-RunMRU-History\RunMRU-History-of-$($OnlyUserName).txt"
