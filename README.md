# ForensicMiner
#### "ForensicMiner, Redefine DFIR Automations"
![Banner](https://github.com/YosfanEilay/ForensicMiner/assets/132997318/72d572fc-2f43-48dd-a16b-1b545eb6aad6)

## What is ForensicMiner ?
ForensicMiner, a PowerShell-based DFIR automation tool, revolutionizes the field of digital investigations.
Designed for efficiency, it automates artifact and evidence collection from Windows machines. Compatibility
with Flacon Crowdstrike RTR and Palo Alto Cortex XDR Live Terminal, along with its swift performance and 
user-friendly interface, makes ForensicMiner an indispensable asset for investigators navigating the complexities
of forensic analysis. Streamlined and effective, this tool sets a new standard in the realm of digital forensics.

## How To Install ?
![How To Install](https://github.com/YosfanEilay/ForensicMiner/assets/132997318/36c30bc3-c9f1-49f7-a3ac-b56c01e53dd1)

#### Know This Before Installation
* Always install ForensicMiner on "C:\" drive.
* Always run ForensicMiner as administrator, if not, some things may not work properly.
* Make sure your PowerShell Execution Policy is on Bypass, if not, scripts could not run on your system.
  * For more information use this PS Execution Policy Guide - https://www.youtube.com/watch?v=L0fgZ0FJIv0

#### Installation Process - Text Guide
1. From this GitHub repository press on "<> Code" and then press on "Download ZIP".
2. Then move "FM-Package.zip" and "FM-Extractor.ps1" to the "C:\" drive. 
3. Execute "FM-Extractor.ps1" with administrator privileges on "C:\" drive.
4. Thats it, you can now use ForensicMiner.

#### Installation Process - Video Guide
![Installation Process - Video Guide](https://github.com/YosfanEilay/ForensicMiner/assets/132997318/79e377d0-c7eb-47bb-8db2-3cb79d3737dc)

### How To Install On Falcon Crowdstrike ?
#### Installation Process On - Falcon Crowdstrike RTR - Video Guide
https://github.com/YosfanEilay/ForensicMiner/assets/132997318/0d9b0dd0-92e5-49db-9522-59e04ef02c6c

### How To Install On Palo Alto Cortex XDR ?
### Installation Process On - Palo Alto Cortex XDR - Video Guide
https://github.com/YosfanEilay/ForensicMiner/assets/132997318/d0efd2f4-f88d-43d0-a6a5-c1e428ae90ab

## Quick Start Guide - How To Use ForensicMiner ?
![Quick Start Guide](https://github.com/YosfanEilay/ForensicMiner/assets/132997318/8b9e4325-6c43-4a7a-994c-dc845f6ebabc)
After installing ForensicMiner on the machine using the execution of "FM-Extractor.ps1" <br>
A new folder should be created on the "C:\" drive, called "ForensicMiner". <br>
<br>
Navigate to This folder using the following command:
```
PS C:\> cd ForensicMiner
```
And now you can execute ForensicMiner menu page to view all available features and options using this command:
```
PS C:\ForensicMiner> .\ForensicMiner.ps1 -O Menu
```
#### Show Menu - Video Guide
https://github.com/YosfanEilay/ForensicMiner/assets/132997318/163c6656-cc14-439c-bc7a-f775d175dd73

### Running Feature Example - RunMRU
In this example you will see how ForensicMiner manage to collect all the Run.exe execution history <br>
of all the users (Online or Offline) in the machine and log them under "C:\ForensicMiner\MyEvidence"

https://github.com/YosfanEilay/ForensicMiner/assets/132997318/043674b4-20ca-45e2-9ca6-f2218350862a

## Credits Section
| Name                                 | Why is the credit ?                          |
| ------------------------------------ | -------------------------------------------- |
| Ido Naor, Security Joes CEO          | For supporting this project                  |
| Warren Frame (RamblingCookieMonster) | Using Warre's PSSQLite in ForensicMiner      |
| Jan Moronia & Felipe Duarte          | Helping to manage time spent on this project |
| Nir Avron                            | For letting me test on his machine           |

## Bug fix (Update Notes)
| Issue Number | Old Version        | New Fixed Version  | Description                | Status     | Credit To     | 
| ------------ | ------------------ | ------------------ | -------------------------- | ---------- | ------------- |
| #2           | ForensicMiner v1.0 | ForensicMiner v1.0 | BAM Feature causing errors | Fixed      | Nostramo-DFIR |         |
|              |                    |                    |                            |            |               |




