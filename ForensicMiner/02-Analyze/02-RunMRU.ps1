#Check if "RunMRU-History" exists.
$folderPath = "C:\ForensicMiner\MyEvidence\02-RunMRU-History"
if (Test-Path $folderPath) {
  Remove-Item $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}

#Create the "RunMRU-History" folder.
New-Item -ItemType Directory -Force -Path "C:\ForensicMiner\MyEvidence\02-RunMRU-History" | Out-Null

#Define the variable path to RunMRU
$RunMRU = "Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"

# Define the variable path to NTUSER.DAT
$NTUSER = "\NTUSER.DAT"

# Define and exclude the relevant users for the foreach loop
$Users = Get-ChildItem C:\Users -Exclude ("Public","TEMP","Default") -Directory

# Use foreach loop to name the hives
foreach ($user in $Users) {

  # Define full NTUSER.DAT path for each user
  $NTUSER_PATH = Join-Path -Path $User.FullName -ChildPath $NTUSER

  # Name of each user on the system without the "Name" column
  $OnlyUserName = $user | Select-Object -Property Name | ForEach-Object { $_.Name }

  #Text $Outfile Veriable
  $OutFile = "C:\ForensicMiner\MyEvidence\02-RunMRU-History\RunMRU-History-of-$($OnlyUserName).txt"

  # Load the NTUSER.DAT of the user and capture the output
  $output = reg load HKLM\Offline-$OnlyUserName "$NTUSER_PATH" 2>&1

  # Check if the output contains the success message
  if ($output -like "The operation completed successfully.") {

    # Output of offline loaded users hives
    Write-Output "+-------------------------------------" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|User Type:     Offline" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|User Name:     $OnlyUserName" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|Which Hive:    NTUSER.DAT" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|Hive Status:   Registry Was Loaded!" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|Registry Path: HKLM\Offline-$OnlyUserName" | Tee-Object -FilePath $OutFile -Append
    Write-Output "+-------------------------------------" | Tee-Object -FilePath $OutFile -Append

    #The RunMRL List of offline Users
    $registryPath = "HKLM:\Offline-$OnlyUserName\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
    $runMRU = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue

    # Calculate the order of execution
    Write-Output "|User RunMRU List" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|----------------" | Tee-Object -FilePath $OutFile -Append
    $mruList = $runMRU.MRUList -split ''
    $orderedValues = @{}
    foreach ($valueName in $mruList) {
      $valueData = $runMRU | Select-Object -ExpandProperty $valueName -ErrorAction SilentlyContinue
      if ($valueData -and $valueName -match '^[a-z]$') {
        $orderedValues.Add($valueName,$valueData.TrimEnd('\1'))
      }
    }

    # Sort the values by the order of execution
    $sortedValues = $orderedValues.GetEnumerator() | Sort-Object { $mruList.IndexOf($_.Key) } -ErrorAction SilentlyContinue

    # Display the sorted results with MRUList first
    $index = 1
    try { Write-Output ("├#{0}. MRUList : {1}" -f $index,$runMRU.MRUList.TrimEnd('\1') | Tee-Object -FilePath $OutFile -Append) } catch {}
    $index++

    foreach ($entry in $sortedValues) {
      Write-Output ("├#{0}. {1} : {2}" -f $index,$entry.Key,$entry.Value) -ErrorAction SilentlyContinue | Tee-Object -FilePath $OutFile -Append
      $index++
    }

  }
  $Quiet = reg unload HKLM\Offline-$OnlyUserName 2>&1
  if ($output -like "The operation completed successfully.") {

  }
  else {
    # Output of online loaded users hives
    Write-Output "+-----------------------------------" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|User Type:     Online" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|User Name:     $OnlyUserName" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|Which Hive:    NTUSER.DAT" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|Registry Path: HKEY_USERS" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|Hive Status:   Hive Already Loaded!" | Tee-Object -FilePath $OutFile -Append
    Write-Output "+-----------------------------------" | Tee-Object -FilePath $OutFile -Append

    # Retrieve the user SID using WMI query
    $SID = (Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath.EndsWith($OnlyUserName) }).SID

    #Get Full Registry Path to HKEY_USERS
    $FullRegPath = "Registry::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
    $runMRU = Get-ItemProperty -Path $FullRegPath

    # Calculate the order of execution
    Write-Output "|User RunMRU List" | Tee-Object -FilePath $OutFile -Append
    Write-Output "|----------------" | Tee-Object -FilePath $OutFile -Append
    $mruList = $runMRU.MRUList -split ''
    $orderedValues = @{}
    foreach ($valueName in $mruList) {
      $valueData = $runMRU | Select-Object -ExpandProperty $valueName -ErrorAction SilentlyContinue
      if ($valueData -and $valueName -match '^[a-z]$') {
        $orderedValues.Add($valueName,$valueData.TrimEnd('\1'))
      }
    }

    # Sort the values by the order of execution
    $sortedValues = $orderedValues.GetEnumerator() | Sort-Object { $mruList.IndexOf($_.Key) } -ErrorAction SilentlyContinue

    # Display the sorted results with MRUList first
    $index = 1
    try { Write-Output ("├#{0}. MRUList : {1}" -f $index,$runMRU.MRUList.TrimEnd('\1') | Tee-Object -FilePath $OutFile -Append) } catch {}
    $index++

    foreach ($entry in $sortedValues) {
      Write-Output ("├#{0}. {1} : {2}" -f $index,$entry.Key,$entry.Value) -ErrorAction SilentlyContinue | Tee-Object -FilePath $OutFile -Append
      $index++
    }
    Write-Output "" | Tee-Object -FilePath $OutFile -Append
    Write-Output "" | Tee-Object -FilePath $OutFile -Append

  }
}
Write-Output ""
Write-Output ""
Write-Output "+-------------------------------------------------------------+"
Write-Output "|The record of this forensic evidence is saved on this machine|"
Write-Output "+-------------------------------------------------------------+"
Write-Output '|    Path - "C:\ForensicMiner\MyEvidence\02-RunMRU-History"   |'
Write-Output "+-------------------------------------------------------------+"
Write-Output ""
