<#
       Pete Lenhart - 2020
       Is a user ignoring you?  Reboot their computer.
#>

# Have a csv with computer names in collumn A
# 

$file = Import-CSV <PATHTOCSV>

foreach($remoteMachineName in $file.Hostname){

       Invoke-CimMethod -ClassName Win32_Operatingsystem -ComputerName $remoteMachineName -MethodName Win32Shutdown -Arguments @{ Flags = 4 } -Confirm
       Restart-Computer -Force
}
