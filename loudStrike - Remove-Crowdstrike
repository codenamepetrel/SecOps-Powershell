#############################################################################################
#                                                                                           #
#      CrowdStrike - LoudStrike Uninstall and Reinstall - Pete Lenhart - 12/22/2019         # 
#                               Pete's Powershell DevSecOps                                 # 
#   *Removed Fireeye uninstaller functions to new file - See Fireeye remover                #
#   *Removed locations of files - change to your location                                   #
#   *Removed unique CID - Get your own                                                      #
#                                                                                           #
#                                                                                           #
#############################################################################################

Write-Host "Goodbye my loooove......." -ForegroundColor Yellow
Write-Host "Begin....." -ForegroundColor Cyan

# BEGIN  SETTING UP VARIABLES

#Get Crowdstrike Product ID
$getCSProdIDSensorPlatform = get-wmiobject Win32_Product  | Where-Object -FilterScript {$_.Name -eq "CrowdStrike Sensor Platform"}
#Put CS ID Number into new variable
$ID = $getCSProdIDSensorPlatform.IdentifyingNumber
#Get ID from DisplayName
$checkCrowdStrikeInstall= (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$ID").DisplayName -contains "CrowdStrike Sensor Platform"
#Get OS Version
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
#Get CID
$cid=[System.BitConverter]::ToString( ((Get-ItemProperty 'HKLM:\SYSTEM\CrowdStrike\X\Default' -Name CU).CU)).ToLower() -replace '-',''
$csAgentIDFolder = $getCSProdIDSensorPlatform.IdentifyingNumber
#Get CrowdStrike Version Number
$csVersion = $getCSProdIDSensorPlatform.Version
#Get Falcon Service
$getFalconService = Get-Service -Name CSFalconService
#Check status of service
$csServiceRunningCheck = $getFalconService.Status
#Set minimum version number
$minVersion = "4.26.8904.0"
#Get date
$getDate = Get-Date


#Make a folder for logs - Change to whatever you want
$makeCSlog = Test-Path c:\cslog
    if ($makeCSlog) {
          Write-Host "cslog Folder already exists"  
    } else {
        Write-Host "Creating c:\cslog directory."
        New-Item -Path c:\cslog -ItemType Directory -Force
     }

#function to check if KB is installed on OS.  Sometime CS install fails with out it.  
function installKB{
Write-Host "Quick test to see if KB is installed"
        $kb = Get-HotFix -Id KB3033929
            if ($kb) {
                Write-Host "Some Win 7 hosts need this KB to install CrowdStrike"
                Write-Host "Looks like it is there"
            } else {
                Write-Host "Install might fail if this hasn't been patched with this KB"
                    $SourceFolder = "c:\"
                    $KBArrayList = New-Object -TypeName System.Collections.ArrayList
                    $KBArrayList.AddRange(@("KB3033929",""))

                foreach ($KB in $KBArrayList) {
                    if (-not(Get-Hotfix -Id $KB)) {
                        Start-Process -FilePath "wusa.exe" -ArgumentList "$SourceFolder$KB.msu /quiet /norestart" -Wait
                }
                Get-HotFix -Id KB3033929
                Write-Host "Installing this KB real quick. Wait a sec......" -foregroundcolor green
                    }                                      
            }
}
#Begin setting up Crowdstrike
function installCSv5{
#Write-Host "Sleeping for one minute so host can finish operations."
#Start-Sleep 60s
Write-Verbose -Verbose "Ready to install. Let's go"
Write-Verbose -Verbose "Installing CrowdStrike to version 5.23.10503."
Write-Host "Setting directory location to run files." -ForegroundColor Yellow
Set-Location c:\LOCATION
Write-Host "Copying CrowdStrike installer version 5.23.10503 to c:\LOCATION. Please wait." -ForegroundColor Yellow
   
       
            Write-Verbose -Verbose "Now installing CrowdStrike..."
            try
            {
            #Invoke-Command -scriptblock {& cmd /c .\s5_23_10503.exe /install /quiet /norestart /log C:\cslog\crowdstrike.log CID=<CID>} -ErrorAction stop
                Invoke-Command -scriptblock {& cmd /c .\s5_23_10503.exe /install /quiet /norestart CID=<CID> /log C:\cslog\crowdstrike.log}
            }
            catch
            {
            Write-Error "Fail. An unknown error occured. Stopping script."
                $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                        $ErrorMessage | Out-File -Append C:\cslog\installerror.log
                            $FailedItem | Out-File -Append C:\cslog\failerror.log
            Break
            }
            #OLD CHECK FOR FIREEYE

            <#Write-Verbose -verbose "Finished installing CrowdStrike. Checking..."
            #    if ($csServiceRunningCheck -ne "Running") {
            #        Write-Host "Running FireEye check."
                    fireEyeRemove
                } elseif ($csServiceRunningCheck -eq "Running") {
                    Write-Host "CrowdStrike service is running. $env:ComputerName" -ForegroundColor Green
                    Write-Host "Running FireEye check."
                    fireEyeRemove
                   
                } else {
                    Write-Host "Service is in another state besides Running"
                }                
            #>
        #} else {                      
            #Write-Error 'Cannot reach X to get the installer. Aborting script.' -ErrorAction Stop
     }
 
#Crowdstrike has a tool to remove it if it doesnt remove
     function uninstallCSv4FailSafe {
   
    $uninstallTool = Test-Path C:\exe
    if ($uninstallTool) {
            Set-Location c:\
            Get-Location
            Write-Host "UninstallTool exists. Trying to uninstall old CrowdStrike." -ForegroundColor Green
                try {
                        Invoke-Command -scriptblock {& cmd /c .\u.exe /quiet /log c:\cslog\u.log} -ErrorAction Stop
                        Write-Host "Done"
                        Write-Host "Testing to see if it uninstalled or if it is stubborn..."                  
                       
                } 
                catch {

                        Write-Error "Fail. An unknown error occured. Stopping script."
                            $ErrorMessage = $_.Exception.Message
                                $FailedItem = $_.Exception.ItemName
                                    $ErrorMessage | Out-File -Append c:\cslog\cs4serrormsg.log
                                        $FailedItem | Out-File -Append c:\cslog\cs4sfailmsg.log
                Break
                }

                if ($checkCrowdStrikeInstall -eq $FALSE) {            
                    Write-Host "Done uninstalling." -ForegroundColor green
                    #installCSv5
                        $checkAgain = (gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).displayname -contains "CrowdStrike Sensor Platform"
                    Write-Host "Checking..."
                    Write-Host "Uninstalled? $checkAgain"
                        Start-Sleep 60
             
                    } elseif ($checkCrowdStrikeInstall) {
                    Write-Host "It didn't uninstall for some reason"
                    Write-Host "Sleeping for 60 seconds to see if the machine can catch up"
                        Start-Sleep 60
                    Write-Host "Checking again..."
                        $check = get-wmiobject Win32_Product  | Where-Object -FilterScript {$_.Name -eq "CrowdStrike Sensor Platform"} #| Format-Table IdentifyingNumber, Name
                            $csVersionAgain = $check.Version
                    Write-Host "Is CrowdStrike still there? $checkAgain. Which version? $csVersion"
                    $cs4 = '4.16.7903.0'
                        if ($csVersionAgain -eq $cs4) {
                            #fireEyeRemove
                            #Restart-Computer -Force
                        } else {
                            #fireEyeRemove
                        }
                    } else { Write-Host "Something is wrong if you read this" }
                                 
                            }
                      }
#Uninstall Crwodstrike Version 4 - I broke this changing the variable to $X
function uninstallCSv4 {

if ($getCSProdIDSensorPlatform) {

    Write-Host "Checking..."
    Write-Host "CrowdStrike is installed."
    $gName = (gp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$X}').DisplayName -contains "CrowdStrike Sensor Platform"
    Write-Host "$gName"
    $g64Version = (gp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$X}').DisplayVersion -contains "4.16.7903.0"
    Write-Host "$g64Version"
    $g86Version = (gp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$X}').DisplayVersion -contains "4.16.7903.0"
    Write-Host "$g86Version"
    $g36Version = (gp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$X}').DisplayVersion -contains "3.6.5703.0"
    Write-Host "$g36Version"          

        if ($g64Version) {

        try{

        Write-Host "Removing 4.16.7903.0 x64 Version of CrowdStrike..."
        $param = @(
           "/x"
           "{X}"
           "/q"
           #"/norestart"
           "/L*V C:\cslog\CS4uninstall.log"
            )
            $removeCS = start-process msiexec.exe -ArgumentList $param -wait -PassThru
            }
            catch
            {
            Write-Host "There was an error trying to remove CS 4.16."
            }
            $e = $removeCS.ExitCode
            if ($e -eq 0) {
            installCSv5
            } else {}


        } elseif ($g86Version) {

        try{

        Write-Host "Removing 4.16.7903.0 x86 Version of CrowdStrike..."
        $param = @(
           "/x"
           "{X}"
           "/q"
                #"/norestart"
                "/L*V C:\cslog\CS4uninstall.log"
                )
        $remove86CS = start-process msiexec.exe -ArgumentList $param -wait -PassThru
            }
            catch
            {
            Write-Host "There was an error trying to remove CS 4.16."
            }
            $f = $remove86CS.ExitCode
            if ($f -eq 0) {
            installCSv5
            } else {$f}

        } elseif ($g36Version) {

        try{

        Write-Host "Removing 3.6.5703.0 Version of CrowdStrike..."
        $param = @(
           "/x"
           "{X}"
           "/q"
                #"/norestart"
                "/L*V C:\CS4uninstall.log"
                )
        $remove36CS = start-process msiexec.exe -ArgumentList $param -wait -PassThru
            }
            catch
            {
            Write-Host "There was an error trying to remove CS 3.6."
            }
            $g = $remove36CS.ExitCode
            if ($g -eq 0) {
            installCSv5
            } else {$g}        
       
        } else {
       
            Write-Host "Unknown version. Trying to use uninstall tool."
            uninstallCSv4FailSafe    
       
        }
    }

}

function uninstallCSv5 {
if ($getCSProdIDSensorPlatform) {

    Write-Host "Checking..."
    Write-Host "CrowdStrike is installed."
    Write-Verbose -Verbose "CrowdStrike Version installed is $csVersion "    

        if ($csServiceRunningCheck -eq "Running")
        {    
                Write-Host "csFalconService found" -ForegroundColor Green
                Write-Host "csFalconService is $csServiceRunningCheck" -ForegroundColor Yellow
        } else {
                Write-Host "csFalconService is NOT running." -ForegroundColor Red
        }
                ""
                Write-Host "CsAgent MSI is located in $csAgentIDFolder" -ForegroundColor Yellow
                ""
                get-childitem "C:\ProgramData\Package Cache" -recurse | where {$_.Name -eq "WindowsSensor.exe"} | % {
                #Write-Host $_.FullName
                $csInstallerLocation = $_.FullName    
                }

                        $parameters = @{
                        #ComputerName = (Get-Content Machines.txt)
                        # = $env:COMPUTERNAME
                        #ConfigurationName = 'MySession.PowerShell'
                        ScriptBlock = { & cmd /c .\WindowsSensor.exe /quiet /uninstall /log c:\cslog\csError$local.log }
                        }

                            $getParent = Split-Path -Path $csInstallerLocation -Parent
                            Set-Location $getParent
                            $getLocation = Get-Location
                            Write-Host "Changing locations to where WindowsSensor.exe lives at $getLocation" -ForegroundColor Green

        $tpExe = Test-Path -Path "$getParent\WindowsSensor.exe" -PathType leaf
        Write-Verbose -verbose "Is WindowsSensor.exe there? "
        Write-Host "$tpExe" -ForegroundColor Green        ""

                if ($tpExe) {

                    Write-Verbose -Verbose "Windows Sensor EXE is there"
                    ""
                    Write-Host "See for yourself..."
                    ""
                    Dir
                    Write-Verbose -Verbose "Uninstalling CrowdStrike..."
                try {
                        Invoke-Command @parameters -ErrorAction Stop
                    }
                catch
                    {
                        Write-Error "Fail. An unknown error occured. Stopping script."
                        $ErrorMessage = $_.Exception.Message
                        $FailedItem = $_.Exception.ItemName
                        $ErrorMessage
                        $FailedItem
                        Break
                    }
                    Write-Verbose -Verbose "Done uninstalling, probably..."
                    ""
                    Write-Host "Lets check to see if it is gone." -ForegroundColor Yellow
                    $checkService = "csFalconService"
                    $timeOut = 51
                    $max = 50
                    Do
                    {
                     "Checking for csFalconService at $(get-date)"
                      $srv = Get-Service -Name csFalconService
                      start-sleep 2
                      #$srv++
                    }
                    While ($srv.Name -contains 'csFalconService')
                    Write-Host "When this loop breaks, CrowdStrike should be gone. Sometimes it takes a minute."
                    Write-Host "Run Get-Service -Name csFalconService if you want to check"
                    #Write-Host "Sleeping for a minute to let things clear out and catch up."
                    installCSv5                  
   
                    } else {    
                            Write-Host "CrowdStrike has been uninstalled"
                            $getCSProdIDSensorPlatform
                            $getFalconService
                    }

        } else {
                Write-Host "CrowdStrike is not installed" -ForegroundColor Red
                Write-Host "Running installer function. Go." -ForegroundColor Green
                installCSv5
         }

}
#Download new Crowdstrike agent from repository - Webserver
function downloadFilesCSv5 {
New-Item -Path c:\ -ItemType Directory -Force    
Set-Location c:\X
Get-Location
    Write-Host "Downloading CrowdStrike 5.23.10503 sensor from X." -foreground green
                $url = "X"
                #$url2 = "X"
                $output1 = "X.exe"
                #$output2 = "X"
                $start_time = Get-Date
                    $wc = New-Object System.Net.WebClient
                    $wc.DownloadFile($url, $output1)
                    #$wc.DownloadFile($url2, $output2)
                        Write-Host "Done downloading. Let's check this files to make sure they are there"
                        $tf1 = Test-Path $output1
                        #$tf2 = Test-Path $output2
                                if ($tf1) {Write-Host "CS Sensor is there"} else {Write-Host "Sensor is NOT there"}
                                #if ($tf2) {Write-Host "CS Uninstall Tool is there"} else {Write-Host "Uninstall tool is NOT there"}
                                    #testFunc
                $sensorHash = Get-FileHash -Path C:\exe -Algorithm MD5
                $sMD5 = $sensorHash.Hash
                Write-Host "Sensor hash should match this."
                Write-Host "X"
                    if ($sMD5 -eq "X"){
                        Write-Host "The MD5 matches. Installing CSv5." -ForegroundColor Green
                        installCSv5
                    } else {                    
                        Write-Host "File hash does not match.  Please check source."
                        Write-Host "Halting script" -ForegroundColor Red                    
                    }
        }
#Download old Crowdstike 4 - I dont remember why
function downloadFilesCSv4 {
New-Item -Path c:\quickinstall -ItemType Directory -Force    
Set-Location c:\quickinstall
Get-Location
    Write-Host "Downloading Uninstalltool and 5.23.10503 sensor from X to c:\X." -foreground green
                $url = "$.exe"
                $url2 = "$.exe"
                $url3 = "$.exe"
                $output1 = "c:\X.exe"
                $output2 = "c:\Y.exe"
                $output3 = "c:\Z.msu"
                $start_time = Get-Date
                    $wc = New-Object System.Net.WebClient
                    $wc.DownloadFile($url, $output1)
                    $wc.DownloadFile($url2, $output2)
                    $wc.DownloadFile($url3, $output3)
                        Write-Host "Done downloading. Let's check this files to make sure they are there"
                        $tf1 = Test-Path $output1
                        $tf2 = Test-Path $output2
                        $tf3 = Test-Path $output2
                                if ($tf1) {Write-Host "CS Sensor is there"} else {Write-Host "Sensor is NOT there"}
                                if ($tf2) {Write-Host "CS Uninstall Tool is there"} else {Write-Host "Uninstall tool is NOT there"}
                                if ($tf3) {Write-Host "KB hotfix is there"} else {Write-Host "KB Hotfix is NOT there"}
                                    #testFunc
                                    Write-Host "Files are there. Let's uninstall that pesky 4.16. Passing to function."
                                    $sensorHash = Get-FileHash -Path C:\exe -Algorithm MD5
                                    $sMD5 = $sensorHash.Hash
                                        Write-Host "Sensor hash should match this."
                                        Write-Host "X"
                                            if ($sMD5 -eq "X"){
                                                 Write-Host "The MD5 matches. Installing CSv5." -ForegroundColor Green
                                                 uninstallCSv4
                                            } else {                    
                                                Write-Host "File hash does not match.  Please check source."
                                                Write-Host "Halting script" -ForegroundColor Red                    
                                            }         
                                   
        }
#Check the version of Crowdstrike sensor. This is intentionally broke. I took out the prodID and CIDS
function checkVersion {

    if ([version]('{0}.{1}.{2}.{3}' -f $csVersion.split('.')) -lt [version]('{0}.{1}.{2}.{3}' -f $minVersion.split('.'))) {
               ""
               Write-Host "$csVersion is less than $minVersion" -foreground yellow
               Write-Host "We are going to try and uninstall this bad boy." -foreground yellow
               downloadFilesCSv4
    } elseif ([version]('{0}.{1}.{2}.{3}' -f $csVersion.split('.')) -gt [version]('{0}.{1}.{2}.{3}' -f $minVersion.split('.'))) {
               Write-Host "Checking your CID..."
               #downloadFilesCSv5
               $cid=[System.BitConverter]::ToString( ((Get-ItemProperty 'HKLM:\SYSTEM\CrowdStrike\{X}\{Y}\Default' -Name CU).CU)).ToLower() -replace '-',''
               $cid
               if ($cid -eq "X"){
                    Write-Host "Looks like you have the current CID with a recent CrowdStrike version. No action neccesary."
                    fireEyeRemove
                   
               } else {
                    Write-Host "It appears you have the wrong CID. We are going to uninstall your agent and reinstall with the correct CID."
                    Write-Host "Your CID is $cid"
                    downloadFilesCSv5
                    }
    } else {
        Write-Host "No version detected"
    }
}

Write-Host "Checking to see if CrowdStrike is installed" -foregroundcolor green


if ($checkCrowdStrikeInstall) {

    Write-Host "Let's run a few checks before we get started"
    Write-Host "Operating System: $OSVersion"
    Write-Host "CrowdStrike installed: True"
    Write-Host "CrowdStrike Version: $csVersion" -ForegroundColor Cyan
    #Write-Host "CrowdStrike CID: $cid"
    checkVersion    
} else {
    Write-Host "CrowdStrike is not installed"
    Write-Host "Will now install CrowdStrike newest version..."
    Write-Host "Running the CSv5 file downloader."
    downloadFilesCSv5
}
