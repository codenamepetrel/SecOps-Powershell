############################################
#
# Remove OneLaunch - PowerShell
#  8/9/2023
#
############################################

function oneLaunchSucks {

    $users = Get-ChildItem C:\Users
    #[array]::FindLast($users)
    foreach ($user in $users) {
    
        $folder = "C:\users\" + $user + "\AppData\Local\OneLaunch"
        $uninstallFile = "C:\users\" + $user + "\AppData\Local\OneLaunch\unins000.exe"
    
        $tp = Test-Path $folder
    
        if ($tp) {
    
            Write-Host "$user has the folder"
            Set-Location $folder
            invoke-command -scriptblock { & cmd /c "unins000.exe" /SILENT }
            cd \
            Remove-Item -path $folder -Recurse -Force 
            Write-Host "Command was successful on $user : $?"
            Write-Host "Moving on......"
    
        }
        else 
        {    
            Write-Host "$folder not found"    
        }
    }
}
oneLaunchSucks
