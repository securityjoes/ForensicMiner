#Check if "WiFiHistory" exist.
    $folderPath = "C:\ForensicMiner\MyEvidence\06-WiFiHistory"
    if (Test-Path $folderPath) {
      Remove-Item $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    $Hostname2 = hostname
    $outputFilePath = "C:\ForensicMiner\MyEvidence\06-WiFiHistory\WiFiHistory-of-$Hostname2.txt"
    New-Item -ItemType Directory -Force -Path "C:\ForensicMiner\MyEvidence\06-WiFiHistory" | Out-Null
    Write-Output "#################### Wi-Fi Security Details ####################" | Tee-Object -FilePath $outputFilePath -Append
    Write-Output "" | Tee-Object -FilePath $outputFilePath -Append
    $profiles = netsh wlan show profiles | Select-String "All User Profile\s+:\s+(.+)"

    foreach ($profile in $profiles) {
      $wifiName = $profile.Matches.Groups[1].Value

      Write-Output "Wi-Fi Name(SSID): $wifiName" | Tee-Object -FilePath $outputFilePath -Append

      $profileInfo1 = netsh wlan show profile name="$wifiName" key=clear | Select-String "Key Content\s+:\s+(.+)"
      $profileInfo2 = netsh wlan show profile name="$wifiName" key=clear | Select-String "Authentication\s+:\s+(.+)"

      if ($profileInfo1) {
        $keyContent = $profileInfo1.Matches.Groups[1].Value
        Write-Output "Wi-Fi password: $keyContent" | Tee-Object -FilePath $outputFilePath -Append
      } else {
        Write-Output "Wi-Fi password: No Password" | Tee-Object -FilePath $outputFilePath -Append
      }

      if ($profileInfo2) {
        $authentication = $profileInfo2.Matches.Groups[1].Value
        Write-Output "Wi-Fi security protocol: $authentication" | Tee-Object -FilePath $outputFilePath -Append
      } else {
        Write-Output "Wi-Fi security protocol: No Security Protocol" | Tee-Object -FilePath $outputFilePath -Append
      }

      Write-Output "" | Tee-Object -FilePath $outputFilePath -Append
    }

    Write-Output "#################### Last Wi-Fi Connection ####################" | Tee-Object -FilePath $outputFilePath -Append
    Write-Output "" | Tee-Object -FilePath $outputFilePath -Append
    # Specify the parent registry path and value names
    $parentPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"
    $dateLastConnectedValueName = "DateLastConnected"
    $profileNameValueName = "ProfileName"

    # Get all subkeys under the parent path
    $subkeys = Get-ChildItem -Path $parentPath

    # Function to swap the position of every 2 hexadecimal characters within a 4-character block
    function SwapHexChars ($hexValue) {
      $swappedValue = ""
      $hexArray = $hexValue -split " "

      foreach ($block in $hexArray) {
        $swappedBlock = ""
        for ($i = 0; $i -lt $block.Length; $i += 4) {
          $swappedChars = $block.Substring($i + 2,2) + $block.Substring($i,2)
          $swappedBlock += $swappedChars
        }
        $swappedValue += $swappedBlock + " "
      }

      return $swappedValue.Trim()
    }

    # Iterate through each subkey and retrieve the values of the specified properties
    foreach ($subkey in $subkeys) {
      $dateLastConnectedValue = Get-ItemPropertyValue -Path $subkey.PSPath -Name $dateLastConnectedValueName
      $profileNameValue = Get-ItemPropertyValue -Path $subkey.PSPath -Name $profileNameValueName

      $hexValue = [System.BitConverter]::ToString($dateLastConnectedValue).Replace("-","")

      $formattedHexValue = ""
      for ($i = 0; $i -lt $hexValue.Length; $i += 4) {
        if ($i -gt 0) {
          $formattedHexValue += " "
        }
        $formattedHexValue += $hexValue.Substring($i,4)
      }

      $formattedHexValue = SwapHexChars $formattedHexValue

      $hexValue = $formattedHexValue

      # Split the hex value into individual parts
      $hexParts = $hexValue -split ' '

      # Convert each hex part to decimal
      $decimalParts = foreach ($part in $hexParts) {
        $decimal = [convert]::ToInt32($part,16)
        $decimal
      }

      # Extract the date and time components
      $year = $decimalParts[0]
      $month = $decimalParts[1]
      $dayOfWeek = $decimalParts[2]
      $dayOfMonth = $decimalParts[3]
      $hour = $decimalParts[4]
      $minutes = $decimalParts[5]
      $seconds = $decimalParts[6]
      $thousandths = $decimalParts[7]

      # Create a DateTime object using the extracted components
      $date = Get-Date -Year $year -Month $month -Day $dayOfMonth -Hour $hour -Minute $minutes -Second $seconds

      # Format the final complete date including the time
      $finalDate = $date.ToString("dd/MM/yyyy HH:mm:ss")

      # Print the final complete date
      Write-Output "Wi-Fi Name (SSID): $profileNameValue" | Tee-Object -FilePath $outputFilePath -Append
      Write-Output "Last Wi-Fi Connection: $finalDate" | Tee-Object -FilePath $outputFilePath -Append
      Write-Output "" | Tee-Object -FilePath $outputFilePath -Append

    }
    Write-Output "#################### End of Wi-Fi History ####################" | Tee-Object -FilePath $outputFilePath -Append
    Write-Output ""
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '|     Path - "C:\ForensicMiner\MyEvidence\06-WiFiHistory"     |'
    Write-Output "+-------------------------------------------------------------+"