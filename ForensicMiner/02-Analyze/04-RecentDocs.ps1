    #Check if "RecentDocs" exist.
    $folderPath = "C:\ForensicMiner\MyEvidence\04-RecentDocs"
    if (Test-Path $folderPath) {
      Remove-Item $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    # Create the "RecentDocs" folder.
    New-Item -ItemType Directory -Force -Path "C:\ForensicMiner\MyEvidence\04-RecentDocs" | Out-Null

    # Text $Outfile Veriable
    $OutFile = "C:\ForensicMiner\MyEvidence\04-RecentDocs\RecentDocs-History.txt"

    # Define the variable path to RecentDocs
    $RecentDocs = "Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"

    # Define the variable path to NTUSER.DAT
    $NTUSER = "\NTUSER.DAT"

    # Define and exclude the relevant users for the foreach loop
    $Users = Get-ChildItem C:\Users -Exclude ("Public","TEMP","Default") -Directory

    # Use foreach loop to load offline users hive
    foreach ($user in $Users) {

      # Define full NTUSER.DAT path for each user
      $NTUSER_PATH = Join-Path -Path $User.FullName -ChildPath $NTUSER

      # Name of each user on the system without the "Name" column
      $OnlyUserName = $user | Select-Object -Property Name | ForEach-Object { $_.Name }

      # Load the NTUSER.DAT of the user and capture the output
      $output = reg load HKLM\Offline-$OnlyUserName "$NTUSER_PATH" 2>&1

      # Check if the output contains the success message
      if ($output -like "The operation completed successfully.") {

        # Online Username
        Write-Output "" | Tee-Object -FilePath $OutFile -Append
        Write-Output "#################[Offline Users]#################" | Tee-Object -FilePath $OutFile -Append
        Write-Output "User Name:   $OnlyUserName" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Load Path:   HKLM:\Offline-$OnlyUserName" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Load Status: NTUSER.DAT was loaded to - [HKLM:]" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Hive Status: Hive will be unloaded at next reboot" | Tee-Object -FilePath $OutFile -Append
        Write-Output "#################################################" | Tee-Object -FilePath $OutFile -Append
        Write-Output "|" | Tee-Object -FilePath $OutFile -Append
        Write-Output "V" | Tee-Object -FilePath $OutFile -Append

        # The RecentDocs List of offline Users
        $FullRegPath = "HKLM:\Offline-$OnlyUserName\$RecentDocs"

        $PathToExclude = "HKEY_LOCAL_MACHINE\Offline-$OnlyUserName\$RecentDocs\"

        # Get the subkeys under the registry path
        $subkeys = Get-ChildItem -Path $FullRegPath | ForEach-Object { $_.Name }

        # Filter the subkeys based on the character count
        $filteredSubkeys = $subkeys | Where-Object { $_.Substring($_.LastIndexOf("\") + 1).Length -le 11 }

        # Display the filtered subkeys
        foreach ($filteredSubkey in $filteredSubkeys) {

          # Replacing variable to remove path and showing only the file extension
          $FileEx = $filteredSubkey -replace [regex]::Escape($PathToExclude),''

          # Removing the '.' from the $FileEx3 using regex
          $FileEx2 = $FileEx
          $FileEx3 = $FileEx2 -replace '\.',''


          Write-Output "" | Tee-Object -FilePath $OutFile -Append
          Write-Output "Filename Extension: ($FileEx3)" | Tee-Object -FilePath $OutFile -Append

          # Exclude not important properties
          $Properties = Get-ItemProperty -Path "Registry::$filteredSubkey" | ForEach-Object {
            $_.PSObject.Properties.Remove('PSPath'),
            $_.PSObject.Properties.Remove('PSParentPath')
            $_.PSObject.Properties.Remove('PSChildName')
            $_.PSObject.Properties.Remove('PSProvider')
            $_
          }

          $MRUListEx = $Properties.MRUListEx | ForEach-Object { "{0:X2}" -f $_ }
          $FormattedResult = $MRUListEx -join '-'
          $MRU = $FormattedResult -replace "-","," -replace ",FF,FF,FF,FF","" -replace ",00,00,00",""
          $MRU = $MRU -split ',' | ForEach-Object { [Convert]::ToInt32($_,16) }

          Write-Output "Order Of Execution: ($MRU)" | Tee-Object -FilePath $OutFile -Append
          Write-Output "+----[History]----+" | Tee-Object -FilePath $OutFile -Append

          $propertiesToExclude = @("MRUListEx")
          $orderedVariables = @()

          # Convert byte arrays to hexadecimal strings and display the values
          $Properties | ForEach-Object {
            $_.PSObject.Properties | Where-Object { $propertiesToExclude -notcontains $_.Name } | ForEach-Object {
              $name = $_.Name
              if ($name -ne "MRUListEx") { # Skip processing "MRUListEx" property
                $hexValue = [BitConverter]::ToString($_.Value).Replace("-","").Replace("00","")
                $bytes = [byte[]]::new($hexValue.Length / 2)
                for ($i = 0; $i -lt $hexValue.Length; $i += 2) {
                  $bytes[$i / 2] = [System.Convert]::ToByte($hexValue.Substring($i,2),16)
                }
                $textValue = [System.Text.Encoding]::ASCII.GetString($bytes)
                $index = $textValue.IndexOf('?')
                if ($index -ge 0) {
                  $textValue = $textValue.Substring(0,$index)
                }

                $orderedVariables += New-Object PSObject -Property @{
                  Name = $name
                  TextValue = $textValue -replace ('.lnk.*','')
                }
              }
            }
          }

          # Convert the $MRU array to a string array
          $MRUStrings = $MRU | ForEach-Object { "$_" }

          # Sort the variables based on their MRU order
          $orderedVariables = $orderedVariables | Sort-Object @{ Expression = { $MRUStrings.IndexOf($_.Name) } }

          # Remove double file names using regex
          $FileEx1 = "$FileEx.*"

          $orderedVariables | ForEach-Object {
            Write-Output "($($_.Name)) $($_.TextValue -replace "$FileEx1","$FileEx")" | Tee-Object -FilePath $OutFile -Append


          }
          Write-Output " " | Tee-Object -FilePath $OutFile -Append
        }
      }
            $Quiet = reg unload HKLM\Offline-$OnlyUserName 2>&1 
            if ($output -like "The operation completed successfully.") {

            }

      else {

        # Online Username
        Write-Output "" | Tee-Object -FilePath $OutFile -Append
        Write-Output "#######[Online Users]########" | Tee-Object -FilePath $OutFile -Append
        Write-Output "User Name:   $OnlyUserName" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Which Hive:  NT_USERS" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Hive Status: Hive is Live" | Tee-Object -FilePath $OutFile -Append
        Write-Output "#############################" | Tee-Object -FilePath $OutFile -Append
        Write-Output " " | Tee-Object -FilePath $OutFile -Append
        Write-Output " " | Tee-Object -FilePath $OutFile -Append

        # Retrieve the user SID using WMI query
        $SID = (Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath.EndsWith($OnlyUserName) }).SID

        # Get Full Registry Path to HKEY_USERS
        $FullRegPath = "Registry::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"

        # Variable for exclusion using -replace
        $PathToExclude = "HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs\"

        # Get the subkeys under the registry path
        $subkeys = Get-ChildItem -Path $FullRegPath | ForEach-Object { $_.Name }

        # Filter the subkeys based on the character count
        $filteredSubkeys = $subkeys | Where-Object { $_.Substring($_.LastIndexOf("\") + 1).Length -le 11 }

        # Display the filtered subkeys
        foreach ($filteredSubkey in $filteredSubkeys) {

          # Replacing variable to remove path and showing only the file extension
          $FileEx = $filteredSubkey -replace [regex]::Escape($PathToExclude),''

          # Removing the '.' from the $FileEx3 using regex
          $FileEx2 = $FileEx
          $FileEx3 = $FileEx2 -replace '\.',''


          Write-Output "" | Tee-Object -FilePath $OutFile -Append
          Write-Output "Filename Extension: ($FileEx3)" | Tee-Object -FilePath $OutFile -Append

          # Exclude not important properties
          $Properties = Get-ItemProperty -Path "Registry::$filteredSubkey" | ForEach-Object {
            $_.PSObject.Properties.Remove('PSPath'),
            $_.PSObject.Properties.Remove('PSParentPath')
            $_.PSObject.Properties.Remove('PSChildName')
            $_.PSObject.Properties.Remove('PSProvider')
            $_
          }

          $MRUListEx = $Properties.MRUListEx | ForEach-Object { "{0:X2}" -f $_ }
          $FormattedResult = $MRUListEx -join '-'
          $MRU = $FormattedResult -replace "-","," -replace ",FF,FF,FF,FF","" -replace ",00,00,00",""
          $MRU = $MRU -split ',' | ForEach-Object { [Convert]::ToInt32($_,16) }

          Write-Output "Order Of Execution: ($MRU)" | Tee-Object -FilePath $OutFile -Append
          Write-Output "+----[History]----+" | Tee-Object -FilePath $OutFile -Append

          $propertiesToExclude = @("MRUListEx")
          $orderedVariables = @()

          # Convert byte arrays to hexadecimal strings and display the values
          $Properties | ForEach-Object {
            $_.PSObject.Properties | Where-Object { $propertiesToExclude -notcontains $_.Name } | ForEach-Object {
              $name = $_.Name
              if ($name -ne "MRUListEx") { # Skip processing "MRUListEx" property
                $hexValue = [BitConverter]::ToString($_.Value).Replace("-","").Replace("00","")
                $bytes = [byte[]]::new($hexValue.Length / 2)
                for ($i = 0; $i -lt $hexValue.Length; $i += 2) {
                  $bytes[$i / 2] = [System.Convert]::ToByte($hexValue.Substring($i,2),16)
                }
                $textValue = [System.Text.Encoding]::ASCII.GetString($bytes)
                $index = $textValue.IndexOf('?')
                if ($index -ge 0) {
                  $textValue = $textValue.Substring(0,$index)
                }

                $orderedVariables += New-Object PSObject -Property @{
                  Name = $name
                  TextValue = $textValue -replace ('.lnk.*','')
                }
              }
            }
          }

          # Convert the $MRU array to a string array
          $MRUStrings = $MRU | ForEach-Object { "$_" }

          # Sort the variables based on their MRU order
          $orderedVariables = $orderedVariables | Sort-Object @{ Expression = { $MRUStrings.IndexOf($_.Name) } }

          # Remove double file names using regex
          $FileEx1 = "$FileEx.*"

          $orderedVariables | ForEach-Object {
            Write-Output "($($_.Name)) $($_.TextValue -replace "$FileEx1","$FileEx")" | Tee-Object -FilePath $OutFile -Append


          }
          Write-Output "" | Tee-Object -FilePath $OutFile -Append
        }
      }
    }
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '|      Path - "C:\ForensicMiner\MyEvidence\04-RecentDocs"     |'
    Write-Output "+-------------------------------------------------------------+"
    Write-Output ""