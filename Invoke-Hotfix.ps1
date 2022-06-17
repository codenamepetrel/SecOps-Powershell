<#
    Pete Lenhart - Push the patch
    If you need to patch someone's computer through the powershell, do this.
    You need to have psexec installed and be an admin.
#>


#path to the patches
$RootHotfixPath = 'C:\tools\Patches\' 

#hot fix name
$Hotfixes = @('kb4103712-x86.msu')

#List of servers or computers
$Servers = Get-Content 'C:\tools\MachineList.txt'

foreach ($Server in $Servers) {
    Write-Host "Processing $Server..."

    $needsReboot = $False
    $remotePath = "\\$Server\c$\Temp\Patches\"
    
    if ( ! (Test-Connection $Server -Count 1 -Quiet)) {
        Write-Warning "$Server is not accessible"
        continue
    }

    if (!(Test-Path $remotePath)) {
        New-Item -ItemType Directory -Force -Path $remotePath | Out-Null
    }
    
    foreach ($Hotfix in $Hotfixes) {
        Write-Host "`thotfix: $Hotfix"
        $HotfixPath = "$RootHotfixPath$Hotfix"

        Copy-Item $Hotfixpath $remotePath
        # Run command as SYSTEM via PsExec (-s switch)
        & C:\Windows\PsExec -s \\$Server wusa C:\Temp\Patches\$Hotfix /quiet /norestart
        write-host "& C:\Windows\PsExec -s \\$Server wusa C:\Temp\Patches\$Hotfix /quiet /norestart"
        if ($LastExitCode -eq 3010) {
            $needsReboot = $true
        }
    }

    # Delete local copy of update packages
    Remove-Item $remotePath -Force -Recurse

    if ($needsReboot) {
        Write-Host "Restarting $Server..."
        Restart-Computer -ComputerName $Server -Force -Confirm
    }
}
