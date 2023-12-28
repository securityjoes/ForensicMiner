$EmpthSubkey_HT = @{}

#Check if "TypedPaths" folder exists.
$FolderPath = "C:\ForensicMiner\MyEvidence\08-TypedPaths"
if (Test-Path $FolderPath) {
  Remove-Item $FolderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}

#Create the "TypedPaths" folder.
New-Item -ItemType Directory -Force -Path $FolderPath | Out-Null

# create online folder
$OnlineFolder = "C:\ForensicMiner\MyEvidence\08-TypedPaths\01-Online-Users"
New-Item -ItemType Directory -Force -Path $OnlineFolder | Out-Null

# create offline folder
$OfflineFolder = "C:\ForensicMiner\MyEvidence\08-TypedPaths\02-Offline-Users"
New-Item -ItemType Directory -Force -Path $OfflineFolder | Out-Null

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

        # variable to store the number of propertie counts
        $OfflinePropertieCount = $OfflineRegistryProperties.PSObject.Properties.Name.Count

        if ($OfflinePropertieCount -ge 1) {

          # create the log text file for Offline users
          $OfflineOutFile = "C:\ForensicMiner\MyEvidence\08-TypedPaths\02-Offline-Users\$OnlyUserName.txt"

          Write-Output "+-------------------------------------" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|User Type:     Offline" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|User Name:     $OnlyUserName" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|Which Hive:    NTUSER.DAT" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|Hive Status:   Registry Was Loaded!" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|Registry Path: HKLM\Offline-$OnlyUserName" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "+-------------------------------------" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|User TypedPaths List" | Tee-Object -FilePath $OfflineOutFile -Append
          Write-Output "|--------------------" | Tee-Object -FilePath $OfflineOutFile -Append

          # Iterate through each property in the hashtable and print each line separately
          foreach ($property in $OfflineRegistryProperties.PSObject.Properties) {
            Write-Output "|#$($property.Name -replace 'url','') - $($property.Value)" | Tee-Object -FilePath $OfflineOutFile -Append
          }
        }

        else {
          $EmpthSubkey_HT[$OnlyUserName] = "[!] TypedPaths registry subkey is empty for user $OnlyUserName."
        }
      }

      # if statment for users who don't have this path $FullOnlineRegistryPath
      else {
      }

      # space
      Write-Output ""
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

          # variable to store the number of propertie counts
          $PropertieCount = $registryProperties.PSObject.Properties.Name.Count

          if ($PropertieCount -ge 1) {

            # create the log text file for Online users
            $OnlineOutFile = "C:\ForensicMiner\MyEvidence\08-TypedPaths\01-Online-Users\$OnlyUserName.txt"

            Write-Output "+-----------------------------------" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|User Type:     Online" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|User Name:     $OnlyUserName" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|Which Hive:    NTUSER.DAT" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|Registry Path: HKEY_USERS" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|Hive Status:   Hive Already Loaded!" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "+-----------------------------------" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|User TypedPaths List" | Tee-Object -FilePath $OnlineOutFile -Append
            Write-Output "|--------------------" | Tee-Object -FilePath $OnlineOutFile -Append

            foreach ($property in $registryProperties.PSObject.Properties) {
              Write-Output "|#$($property.Name -replace 'url','') - $($property.Value)" | Tee-Object -FilePath $OnlineOutFile -Append
            }
          }

          else {
            $EmpthSubkey_HT[$OnlyUserName] = "[!] TypedPaths registry subkey is empty for user $OnlyUserName."
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

$EmpthSubkeyCount = $EmpthSubkey_HT.Values.Count
if ($EmpthSubkeyCount -ge 1) {
  Write-Output "Empty TypedPaths User Table"
  Write-Output "+-------------------------+"
  $EmpthSubkey_HT.Values
}

else {
}

Write-Output ""
Write-Output "+-------------------------------------------------------------+"
Write-Output "|The record of this forensic evidence is saved on this machine|"
Write-Output "+-------------------------------------------------------------+"
Write-Output '|     Path - "C:\ForensicMiner\MyEvidence\08-TypedPaths"      |'
Write-Output "+-------------------------------------------------------------+"
Write-Output ""
