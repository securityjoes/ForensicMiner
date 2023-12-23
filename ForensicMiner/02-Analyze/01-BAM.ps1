# Pre-Execution Validation title.
Write-Output ""
Write-Output "Pre-Execution Validation"
Write-Output "+----------------------+"

# check if $folderPath exist, delete if true.
$FolderPath = "C:\ForensicMiner\MyEvidence\01-Evidence-Of-Execution"
if (Test-Path -Path $FolderPath) {
  Start-Sleep -Milliseconds 500
  Write-Output "[*] Deleting old BAM evidence folder and creating a new empty one."
  Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
  New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
}

# if $FolderPath is missing, cretae it.
else {
  Start-Sleep -Milliseconds 500
  Write-Output "[*] Creating BAM evidence folder."
  New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
}

# variable for bam.sys full path.
$BamPath = Join-Path -Path $env:windir -ChildPath "system32\drivers\bam.sys"

# if statment to check if $bam_path exist on system.
if (Test-Path -Path $BamPath) {
  Start-Sleep -Milliseconds 500
  Write-Output "[*] bam.sys was found under $BamPath."

  # check if $UserSettings path is found under the registry.
  $UserSettingsPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*"
  if (Test-Path -Path $UserSettingsPath) {
    $UserSettingsFlag = "True"
    Start-Sleep -Milliseconds 500
    Write-Output "[*] ProfileList registry path was found."
  }
  else {
    $UserSettingsFlag = "False"
    Start-Sleep -Milliseconds 500
    Write-Output "[*] ProfileList registry path was NOT found."
  }

  # if statment to check if $BamRegistryPath exist.
  $BamRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings"
  if (Test-Path -Path $BamRegistryPath) {
    Start-Sleep -Milliseconds 500
    Write-Output "[*] bam registry path was found."
    Start-Sleep -Milliseconds 500
    Write-Output "[*] script can be start."
    Write-Output ""

    # this is the part of the actual script after the Pre-Execution Validation.
    $SIDsWithPath = Get-Item -Path "$BamRegistryPath\*" | Select-Object -ExpandProperty Name
    $SIDs = $SIDsWithPath -replace '.*\\UserSettings\\',''

    # foreach statment to separate SIDs to each SID
    foreach ($SID in $SIDs) {

      # if statment to show only $SID with more then 30 characters
      if ($SID.length -ge 30) {

        # create the log text file for each user
        $OutFile = "C:\ForensicMiner\MyEvidence\01-Evidence-Of-Execution\$($SID).txt"

        # conect the $BamRegistryPath with $SID
        $FullSIDRegistryPath = "$BamRegistryPath\$SID"

        # Get the values under the registry key
        $values = Get-ItemProperty -Path $FullSIDRegistryPath | Select-Object -Property *

        # Create an empty array to store the sorted results
        $sortedResults = @()

        # Loop through the values and add them to the array
        foreach ($valueName in $values.PSObject.Properties.Name) {
          if ($valueName -like '\Device\*') {
            $valueData = [BitConverter]::ToInt64($values.$valueName,0)
            $result = $valueName -replace '^\\Device\\HarddiskVolume\d+\\'
            $timestamp = if ($valueData -ne $null) {
              [datetime]::FromFileTime($valueData)
            } else {
              "Not available"
            }

            # Create an object with the properties
            $sortedResults += [pscustomobject]@{
              Software = $result
              Timestamp = $timestamp
            }
          }
        }

        # Sort the results based on the 'Timestamp' property in descending order
        $sortedResults = $sortedResults | Sort-Object -Property Timestamp -Descending

        # Display the sorted results
        Start-Sleep -Milliseconds 500
        Write-Output "┌---------------------------------------------------┐" | Tee-Object -FilePath $OutFile -Append

        # if statment to check if $UserSettingsFlag exist using a flag
        if ($UserSettingsFlag -eq "True") {
          
          # SIDS hash table.  
          $SID_HashTable = @{
            "SIDS" = @()
          }
          # cleaning the SIDS from the path
          $DirtySIDS = Get-ItemProperty -Path $UserSettingsPath | Select-Object -ExpandProperty PSChildName
          $US_SIDS = $DirtySIDS -replace '.bak',''

          # foreach statment to make SIDS to SID
          foreach ($US_SID in $US_SIDS) {
            if ($US_SID.length -ge 30) {
              $SID_HashTable["SIDS"] += $US_SID
            }
          }

          # check if the $SID_HashTable hashtable has $SID in it
          if ($SID_HashTable["SIDS"] -contains $SID) {
            $HalfProfileListPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
            $FullProfileListPath = Join-Path -Path $HalfProfileListPath -ChildPath $SID

            # if the SID exist, print the username
            if (Test-Path -Path $FullProfileListPath) {
              $UserProfilePath = Get-ItemProperty -Path $FullProfileListPath | Select-Object -ExpandProperty ProfileImagePath
              $CleanUserName = $UserProfilePath -replace '^[a-z,A-Z]{1}\:\\Users\\',''
              Write-Output "├User: $CleanUserName" | Tee-Object -FilePath $OutFile -Append
            }

            # if not, try to add to the end of the SID a .bak
            elseif (Test-Path -Path "$FullProfileListPath.bak") {
              $UserProfilePath = Get-ItemProperty -Path "$FullProfileListPath.bak" | Select-Object -ExpandProperty ProfileImagePath
              $CleanUserName = $UserProfilePath -replace '^[a-z,A-Z]{1}\:\\Users\\',''
              Write-Output "├User: $CleanUserName" | Tee-Object -FilePath $OutFile -Append
            }

            # if there is no SID, print this
            else {
              Write-Output "├User: Username not found." | Tee-Object -FilePath $OutFile -Append
            }

          }
          else {
            Write-Output "├User: Username not found." | Tee-Object -FilePath $OutFile -Append
          }

        }
        else {
        }

        Write-Output "├SID:  $SID" | Tee-Object -FilePath $OutFile -Append
        Write-Output "|" | Tee-Object -FilePath $OutFile -Append

        foreach ($result in $sortedResults) {
          Write-Output "├Software:  $($result.Software)" | Tee-Object -FilePath $OutFile -Append
          Write-Output "├Timestamp: $($result.Timestamp)" | Tee-Object -FilePath $OutFile -Append
          Write-Output "|" | Tee-Object -FilePath $OutFile -Append
        }

        Write-Output "└-> End-of-List" | Tee-Object -FilePath $OutFile -Append
        Write-Output "" | Tee-Object -FilePath $OutFile -Append



      }

      # execute this on SIDs with less then 30 characters
      else {
      }

      # end of the ($SID in $SIDS) foreach loop.
    }
    Write-Output ""
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '|Path - "C:\ForensicMiner\MyEvidence\01-Evidence-Of-Execution"|'
    Write-Output "+-------------------------------------------------------------+"
    Write-Output ""

  }

  # if $BamRegistryPath is not exist, execute this else.
  else {
    Start-Sleep -Milliseconds 500
    Write-Output "[!] bam registry path was not found."
    Start-Sleep -Milliseconds 500
    Write-Output '[!] Check if "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings" exist on registry.'
    Start-Sleep -Milliseconds 500
    Write-Output "[!] Script cannot continue, stopping script."
  }

}

# if $bam_path is not exist, execute this else.
else {
  Start-Sleep -Milliseconds 500
  Write-Output "[!] bam.sys was not found under $BamPath"
  Start-Sleep -Milliseconds 500
  Write-Output "[!] Script cannot continue, stopping script."
}

# space
Write-Output ""
