        #Check if "AppHistory(MUICache)" exist.
        $folderPath = "C:\ForensicMiner\MyEvidence\03-AppHistory(MUICache)"
        if (Test-Path $folderPath) {
          Remove-Item $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }

        # Create the "AppHistory(MUICache)" folder.
        New-Item -ItemType Directory -Force -Path "C:\ForensicMiner\MyEvidence\03-AppHistory(MUICache)" | Out-Null

        # Define the variable path to MuiCache ('Online' and 'Offline')
        $Online_MuiCache = "Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
        $Offline_MuiCache = "Local Settings\Software\Microsoft\Windows\Shell\MuiCache"

        # Define the variable path to NTUSER.DAT
        $UsrClass = "\AppData\Local\Microsoft\Windows\UsrClass.DAT"

        # Define and exclude the relevant users for the foreach loop
        $Users = Get-ChildItem C:\Users -Exclude ("Public","TEMP","Default") -Directory

        # Use foreach loop to load offline users hive
        foreach ($user in $Users) {
      
      # Define full NTUSER.DAT path for each user
      $UsrClass_PATH = Join-Path -Path $User.FullName -ChildPath $UsrClass
      
      # Name of each user on the system without the "Name" column
      $OnlyUserName = $user | Select-Object -Property Name | ForEach-Object { $_.Name }

      # Text $Outfile Veriable
      $OutFile = "C:\ForensicMiner\MyEvidence\03-AppHistory(MUICache)\AppHistory-Of-$OnlyUserName.txt"

      # Load the NTUSER.DAT of the user and capture the output
      $output = reg load HKLM\Offline-$OnlyUserName "$UsrClass_PATH" 2>&1
      
      # Check if the output contains the success message
      if ($output -like "The operation completed successfully.") {
         
         # RegPath to UsrClass.DAT on the Registry
         $FullRegPath = "HKLM:\Offline-$OnlyUserName\$Offline_MuiCache"
         
        # Offline Username
        Write-Output "" 
        Write-Output "#################[Offline Users]#################" | Tee-Object -FilePath $OutFile -Append
        Write-Output "User Name:   $OnlyUserName" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Load Path:   HKLM:\Offline-$OnlyUserName" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Load Status: UsrClass.DAT was loaded to - [HKLM:]" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Hive Status: Hive will be unloaded at next reboot" | Tee-Object -FilePath $OutFile -Append
        Write-Output "#################################################" | Tee-Object -FilePath $OutFile -Append

        # Create a variable for the usage of exclusion
        $Exclude = @("PSPath","PSParentPath","PSProvider","PSDrive","PSChildName","LangID")

        #Create a variable that retrieve the correct subkeys and exclude the unwanted subkeys
        $SubKeys = Get-ItemProperty -Path $FullRegPath | ForEach-Object {$_.PSObject.Properties.Name} | Where-Object { $_ -notin $Exclude }

        # Loop through the subkeys using foreach
        foreach ($SubKey in $SubKeys) {

            # Variable that cut the executable name from the  $Subkey var
            $PartKey = $SubKey -replace '.*\\([^\\]+\.exe)\..*', '$1'

            if ($SubKey -like "*.FriendlyAppName") {
        
                # Cretae the variable for the value of each subkey
                $Value = Get-ItemPropertyValue -Path $FullRegPath -Name $SubKey
        
                $Result = $SubKey -replace '.*\\([^\\]+\.exe)\..*', '$1'
                Write-Output "" | Tee-Object -FilePath $OutFile -Append
                Write-Output "" | Tee-Object -FilePath $OutFile -Append
                Write-Output "Application Name: $Result" | Tee-Object -FilePath $OutFile -Append
                Write-Output "Metadata File Description: $Value" | Tee-Object -FilePath $OutFile -Append

            }

            elseif ($SubKey -like "*.ApplicationCompany") {
        
                # Create a var for $subkey without ".app*"
                $NewSubkey = $SubKey -replace ('\.ApplicationCompany$','') | Tee-Object -FilePath $OutFile -Append

                Write-Output "Metadata Company Name: $Value" | Tee-Object -FilePath $OutFile -Append
                Write-Output "Application Path: $NewSubkey" | Tee-Object -FilePath $OutFile -Append

                # Check if app is still there.
                $Check = Test-Path -Path $NewSubkey
                Write-Output "Application Still There? - $Check" | Tee-Object -FilePath $OutFile -Append
        
        
                }
            }
            $Quiet = reg unload HKLM\Offline-$OnlyUserName 2>&1 
            if ($output -like "The operation completed successfully.") {

            }
    }
    
    else {
        # Online Username
        Write-Output ""
        Write-Output "#######[Online Users]########" | Tee-Object -FilePath $OutFile -Append
        Write-Output "User Name:   $OnlyUserName" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Which Hive:  HKEY_USERS" | Tee-Object -FilePath $OutFile -Append
        Write-Output "Hive Status: Hive is Live" | Tee-Object -FilePath $OutFile -Append
        Write-Output "#############################" | Tee-Object -FilePath $OutFile -Append

        # Retrieve the user SID using WMI query
        $SID = (Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath.EndsWith($OnlyUserName) }).SID

        # Create a variable for the usage of exclusion
        $Exclude = @("PSPath","PSParentPath","PSProvider","PSDrive","PSChildName","LangID")

        # Get Full Registry Path to HKEY_USERS
        $FullRegPath = "Registry::HKEY_USERS\$SID\$Online_MuiCache"

        #Create a variable that retrieve the correct subkeys and exclude the unwanted subkeys
        $SubKeys = Get-ItemProperty -Path $FullRegPath | ForEach-Object {$_.PSObject.Properties.Name} | Where-Object { $_ -notin $Exclude }

        # Loop through the subkeys using foreach
        foreach ($SubKey in $SubKeys) {

            # Variable that cut the executable name from the  $Subkey var
            $PartKey = $SubKey -replace '.*\\([^\\]+\.exe)\..*', '$1'

            if ($SubKey -like "*.FriendlyAppName") {
        
                # Cretae the variable for the value of each subkey
                $Value = Get-ItemPropertyValue -Path $FullRegPath -Name $SubKey
        
                $Result = $SubKey -replace '.*\\([^\\]+\.exe)\..*', '$1'
        
        
                Write-Output "" | Tee-Object -FilePath $OutFile -Append
                Write-Output "" | Tee-Object -FilePath $OutFile -Append
                Write-Output "Application Name: $Result" | Tee-Object -FilePath $OutFile -Append
                Write-Output "Metadata File Description: $Value" | Tee-Object -FilePath $OutFile -Append

            }

            elseif ($SubKey -like "*.ApplicationCompany") {
        
                # Create a var for $subkey without ".app*"
                $NewSubkey = $SubKey -replace ('\.ApplicationCompany$','')

                Write-Output "Metadata Company Name: $Value" | Tee-Object -FilePath $OutFile -Append
                Write-Output "Application Path: $NewSubkey" | Tee-Object -FilePath $OutFile -Append

                # Check if app is still there.
                $Check = Test-Path -Path $NewSubkey
                Write-Output "Application Still There? - $Check" | Tee-Object -FilePath $OutFile -Append
        
        
                }
            }
        Write-Output ""
    
    }
}
Write-Output ""
Write-Output ""
    Write-Output "+-------------------------------------------------------------+"
    Write-Output "|The record of this forensic evidence is saved on this machine|"
    Write-Output "+-------------------------------------------------------------+"
    Write-Output '| Path - "C:\ForensicMiner\MyEvidence\03-AppHistory(MUICache)"|'
    Write-Output "+-------------------------------------------------------------+"
    Write-Output ""