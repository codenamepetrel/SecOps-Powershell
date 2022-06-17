#############################################################################################################
#                                                                                                           #
#                          Pete Lenhart - Scorched Earth - Fireeye Remover - 2018                           #
#                                                                                                           #
#                 *I nuked the product codes to make it work so fireeye wont be mad at me.                  #
#                                                                                                           #
#                           *ONLY USE FOR SYSTEM ADMINISTRATION TO FIX ISSUES                               #
#                                                                                                           #
#                                                                                                           #
#                                                                                                           #
#############################################################################################################


function ScorchedEarthv3 {

    clear
    Write-Host "Running - Fireeye - Scorched Earth" -ForegroundColor Cyan
    Write-Host "Let it burn"
    Write-Host "Begin..."
    Write-Host "........"
    Write-Host "Check for Running Services..."

    $sourceFile = "\\x.msi"

    $fireeyeLogs = "c:\fireeyeLogs"
    $fireeyeLogPath = Test-Path -Path $fireeyeLogs
    if ($fireeyeLogPath -eq $FALSE) {
        New-Item -Path $fireeyeLogs -type directory -Force
    }
    else { Write-Host "Folder exists" }

    $ErrorActionPreference = "silentlycontinue"
    $teagentService = 'TEAGENT'
    $tesvcService = 'TESVC'
    $xagtService = 'XAGT'
    $fekernService = 'FEKERN'

    $bDeleteEntries = "YES"
    $ProductVersion = "ALL"

    $fePath = "C:\Program Files (x86)\FireEye\xagt"
    $fePath32 = "C:\Program Files\FireEye\xagt"

    $getFireEyeProdID = get-wmiobject Win32_Product | Where-Object -FilterScript { $_.Name -eq "FireEye Endpoint Agent" } | Format-Table IdentifyingNumber, Name
    $getFireEyeProdID

    $getFireEyeProdID2 = get-wmiobject Win32_Product | Where-Object -FilterScript { $_.Name -eq "FireEye Endpoint Agent" } #| Format-Table IdentifyingNumber, Name
    $getFEID = $getFireEyeProdID2.IdentifyingNumber


    If (Get-Service $teagentService -ErrorAction SilentlyContinue) {
        If ((Get-Service $teagentService).Status -eq 'Running') {
            Write-Host "$teagentService exists" -ForegroundColor "yellow"
            Write-Host "Stopping $teagentService" -ForegroundColor "yellow"
            Stop-Service $teagentService -ForegroundColor "red"
        }
        Else {
            Write-Host "$teagentService found, but it's running." -ForegroundColor "yellow"
        }
    }
    Else {
        Write-Host "$teagentService not found" -ForegroundColor "yellow"
    }

    If (Get-Service $tesvcService -ErrorAction SilentlyContinue) {
        If ((Get-Service $tesvcService).Status -eq 'Running') {
            Write-Host "$tesvcService exists" -ForegroundColor "yellow"
            Write-Host "Stopping $tesvcService" -ForegroundColor "yellow"
            Stop-Service $tesvcService -ForegroundColor "red"
        }
        Else {
            Write-Host "$tesvcService found, but it is not running." -ForegroundColor "yellow"
        }
    }
    Else {
        Write-Host "$tesvcService not found" -ForegroundColor "yellow"
    }

    If (Get-Service $xagtService -ErrorAction SilentlyContinue) {
        If ((Get-Service $xagtService).Status -eq 'Running') {
            Write-Host "$xagtService exists" -ForegroundColor "green"
            Stop-Service $xagtService
            Write-Host "$xagtService is stopping"
        
        }
        Else {
            Write-Host "$xagtService found but it's not running." -ForegroundColor "yellow"
        }
    }
    Else {
        Write-Host "$xagtService not found" -ForegroundColor "red"
    }


    If (Get-Service $fekernService -ErrorAction SilentlyContinue) {
        If ((Get-Service $fekernService).Status -eq 'Running') {
            Write-Host "$fekernService exists" -ForegroundColor "green"
            Stop-Service $fekernService
            Write-Host "$fekernService is stopping"
        }
        Else {
            Write-Host "$fekernService found but it's not running." -ForegroundColor "yellow"
        }
    }
    Else {
        Write-Host "$fekernService not found" -ForegroundColor "red"
    }

    $computername = "localhost"

    $getDate = Get-Date
    $feDBPath = "c:\programdata\fireeye\xagt"

    foreach ($computer in $computername) {
        $fePath = "C:\Program Files (x86)\FireEye\xagt"
        $tp = Test-Path $fePath    
        if ($tp ) {
            Write-Host "$fePath found"
            foreach ($ID in $getFEID ) {
                Write-Host "$getFEID was found"
                ######ENCRYPTED PASSWORD - I HAVE CHANGED THE CODE SO ITS BROKEN - GET YA OWN PASSWORD!
                .( $SHeLLId[1] + $shELliD[13] + 'X')( "$(SeT 'ofs' '') " + [StRiNG]((7, 11 , 56, 33 , 37, 43 , 99, 28, 33 , 35 , 33, 47, 32, 42 , 23, 99, 29, 45 , 60 , 39 , 62, 58, 12, 34, 33, 45 , 37, 110, 53, 110, 104, 110, 45, 35, 42 , 110, 97 , 45, 110, 108, 35 , 61, 39, 43, 54 , 43, 45 , 96 , 43, 54 , 43 , 110, 97 , 54 , 110 , 108 , 106, 41 , 43, 58, 8 , 11, 7 , 10 , 110, 97, 63, 32 , 110, 27, 0, 7 , 0, 29 , 26 , 15 , 2 , 2, 17 , 30, 15, 29, 29 , 25 , 1 , 28, 10 , 115, 42 , 60 , 59, 58, 60, 59, 111, 43, 122 , 57 , 125 , 13 , 110, 51 , 110, 99 , 11, 60 , 60, 33, 60 , 15, 45 , 58, 39, 33, 32, 110 , 29 , 39 , 34, 43, 32 , 58 , 34 , 55, 13, 33, 32, 58, 39 , 32, 59, 43) | FOrEAcH { [cHAr]($_-bxOR'0x4e') }) + " $(Set-ITeM  'VaRiAbLe:Ofs'  ' ' ) ") 
                Write-Host "Fireeye has been uninstalled" -ForegroundColor "yellow"
            }         
            else { Write-Host "No ID found" }       

        }
        else {
            Write-Host "Not found"    
        }

    }
    Write-Host "Deleting $fePath"
    Remove-Item -Recurse -Force $fePath
    Write-Host "Deleting $fePath32"
    Remove-Item -Recurse -Force $fePath32
    Write-Host "Deleting $feDBPath"
    Remove-Item -Recurse -Force $feDBPath
    Write-Host "Deletion complete." -ForegroundColor Blue

    If (Get-Service $xagtService -ErrorAction SilentlyContinue) {
        If ((Get-Service $xagtService).Status -eq 'Running') {
            Write-Host "$xagtService still exists" -ForegroundColor "red"
            Stop-Service $xagtService
            Write-Host "$xagtService is stopping"
            Write-Host "Running sc delete xagt"
            Invoke-Command -ScriptBlock { & cmd /c "sc delete xagt" } -ErrorAction SilentlyContinue 
        
        }
        Else {
            Write-Host "$xagtService still found" -ForegroundColor "red"
            Write-Host "Running sc delete xagt"
            Invoke-Command -ScriptBlock { & cmd /c "sc delete xagt" } -ErrorAction SilentlyContinue
        
        }
    }
    Else {
        Write-Host "$xagtService not found" -ForegroundColor "green"
    }

    If (Get-Service $fekernService -ErrorAction SilentlyContinue) {
        If ((Get-Service $fekernService).Status -eq 'Running') {
            Write-Host "$fekernService still exists" -ForegroundColor "red"
            Stop-Service $fekernService
            Write-Host "$fekernService is stopping"
            Write-Host "Running sc delete fekern"
            Invoke-Command -ScriptBlock { & cmd /c "sc delete fekern" } -ErrorAction SilentlyContinue
        }
        Else {
            Write-Host "$fekernService found but it's not running." -ForegroundColor "red"
            Write-Host "Running sc delete fekern"
            Invoke-Command -ScriptBlock { & cmd /c "sc delete fekern" } -ErrorAction SilentlyContinue
        }
    }
    Else {
        Write-Host "$fekernService not found" -ForegroundColor "green"
    }

    Function CheckProductID {
        if ($ProductVersion.ToUpper() -eq "ALL") {
            return $false
        }    
        foreach ($ProductID in $global:ProductIDs) {
            if ($ProductID[0].contains($ProductVersion)) {
                $global:ProductVersion = $ProductID
                return $false
            }
        }
        Write-Host $global:ProductVersion "not found as a valid Product type"
        return $true
    }

    Function CheckValues($foundProductID) {
        if ($foundProductID) {
            Write-Host "Values: Checking Product ID" $foundProductID[0]
            $nCount = 0
            $valueCount = 0
            $kExists = $false
            $gKeyVal = $null
            foreach ($RegKey in $global:RegKeys) {
                [String[]] $sValResults = $null
                if ($nCount -eq 0) {
    			($sValResults = reg query $RegKey /f $foundProductID[1] /s) | Out-Null
                }
                else {
    			($sValResults = reg query $RegKey /f $foundProductID[2] /s) | Out-Null
                }
                if ($sValResults.Count -gt 2) {
                    for ($i = 0; $i -lt $sValResults.Length; $i++) {
                        if ($sValResults[$i].Length -ne 0 -and -not $sValResults[$i].Contains("End of search:")) {
                            [String[]] $sValEntries = $sValResults[$i].Split("  ", 3, [System.StringSplitOptions]::RemoveEmptyEntries)
                            if ($sValEntries.Count -eq 1) {
                                $gKeyVal = $sValResults[$i];
                                if ($sValResults[$i].Contains($foundProductID[1]) -or $sValResults[$i].Contains($foundProductID[2])) {
                                    $global:foundRegKeys.Add(("Key", $sValResults[$i], $true)) > $null
                                } 
                                else {
                                    $global:foundRegKeys.Add(("Key", $sValResults[$i], $false)) > $null
                                } 
                                $valueCount++
                   			
                            }
                            else {
                                $savedVal = $null
                                $valueCount++
                                foreach ($sValEntry in $sValEntries) {
                                    $savedVal += ($sValEntry + ", ")
                                }
                                $savedVal = $savedVal.TrimEnd(", ")
                                $global:foundRegKeys.Add(("Value", $gKeyVal, $savedVal)) > $null
                   			
                            }
                        }
                    }
                }
                $nCount++
            }
            $global:valueCount += $valueCount
            Write-Host $valueCount "Instances found"
        }
    }

    Function DiplayEntries() {
        Write-Host
        Write-Host "Total" $global:valueCount "Entries found"
    
        foreach ($foundRegKey in $global:foundRegKeys) {
            if ($foundRegKey[0].Equals("Key")) {
                Write-Host
                Write-Host $foundRegKey[0]":"$foundRegKey[1]
            }
            elseif ($foundRegKey[0].Equals("Value")) {
                Write-Host $foundRegKey[0]":`t"$foundRegKey[2]
            }
        }
        Write-Host
    }

    Function DeleteEntries {
        if ($global:Choice.contains("YES") -and $global:foundRegKeys.Count -gt 0) {
            $bKey = $false;
            #foreach($foundRegKeys in $global:foundRegKeys)
            for ($i = 0; $i -lt $global:foundRegKeys.Count; $i++) {
                $foundRegKeys = $global:foundRegKeys[$i]
                if ($foundRegKeys[0].Equals("Key")) {
                    if ($foundRegKeys[2]) {
                    ([String]$kdResults = reg delete $foundRegKeys[1] /f) | Out-Null
                        if ($kdResults.contains("The operation completed successfully.")) {
                            Write-Host $foundRegKeys[1] "deleted successfully!"
                        }
                        else {
                            Write-Host $foundRegKeys[1] "deletion error occurred!"
                        }
                        $bKey = $true;
                    }
                    else {
                        $bKey = $false;
                    }
                }
                elseif ($foundRegKeys[0].Equals("Value") -and !$bKey) {
                    [String[]] $sVals = $foundRegKeys[2].Split("  ", 3, [System.StringSplitOptions]::RemoveEmptyEntries)
                ([String]$kdResults = reg delete $foundRegKeys[1] /v $sVals[0].TrimEnd(",") /f) | Out-Null
                    if ($kdResults.contains("The operation completed successfully.")) {
                        Write-Host "Value" $sVals[0] "in" $foundRegKeys[1] "deleted successfully!"
                    }
                    else {
                        Write-Host "Value" $sVals[0] "in" $foundRegKeys[1] "deletion error occurred!"
                    }
                }            
            }
        }
    }

    $global:ProductIDs = @(
	
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),	
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X"),
	("vZ", "{Y}", "X")
    )
    $global:RegKeys = @(
	("HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"),
	("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"),
	("HKLM\SOFTWARE\Classes\Installer\Features"),
	("HKLM\SOFTWARE\Classes\Installer\Products"),
	("HKLM\SOFTWARE\Classes\Installer\UpgradeCodes")
    )
    $global:foundProductIDs = New-Object System.Collections.ArrayList
    $global:foundRegKeys = New-Object System.Collections.ArrayList
    $global:entryCount = 0
    $global:valueCount = 0
    $global:Choice = $bDeleteEntries.ToUpper()

    if (CheckProductID) {
        return
    }

    Write-Host $ProductVersion "version of the Agent will be queried"
    $global:Choice = $bDeleteEntries
    if ($global:Choice.contains("YES")) {
        Write-Host "Registry keys will be deleted"
        Write-Host 
    }
    else {
        Write-Host "Registry keys will not be deleted"
        Write-Host 
    }

    if ($ProductVersion -eq "ALL") {
        Write-Host "Checking All Product Versions"
        foreach ($ProductID in $ProductIDs) {
            CheckValues $ProductID
        }
        DiplayEntries
        DeleteEntries
    }
    else {
        CheckValues $global:ProductVersion
        DiplayEntries
        DeleteEntries
    }


    $getDate = Get-Date
    Invoke-Command -ScriptBlock { & cmd /c "msiexec.exe /i $sourceFile" /qn /L*V "c:\fireeyeLogs\fireeye_install.log" }

    If (Get-Service $teagentService -ErrorAction SilentlyContinue) {
        If ((Get-Service $teagentService).Status -eq 'Running') {
            Write-Host "$teagentService exists" -ForegroundColor "green"
            Write-Host "Starting $teagentService" -ForegroundColor "green"
            Start-Service $teagentService -ForegroundColor "green"
        }
        Else {
            Write-Host "$teagentService found, but it is not running." -ForegroundColor "red"
        }
    }
    Else {
        Write-Host "$teagentService not found" -ForegroundColor "red"
    }

    If (Get-Service $tesvcService -ErrorAction SilentlyContinue) {
        If ((Get-Service $tesvcService).Status -eq 'Running') {
            Write-Host "$tesvcService exists" -ForegroundColor "red"
            Write-Host "Starting $tesvcService" -ForegroundColor "red"
            Start-Service $tesvcService -ForegroundColor "red"
        }
        Else {
            Write-Host "$tesvcService found but it's not running." -ForegroundColor "red"
        }
    }
    Else {
        Write-Host "$tesvcService not found" -ForegroundColor "red"
    }

    Write-Host "...."
    Write-Host "I like this world."
    Write-Host "Complete."

}
ScorchedEarthv3
