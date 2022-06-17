####################################################################################
#                                                                                  # 
#                                                                                  #
#        Pete Lenhart - 2018 - Powershell into someone's computer PSSESSION        #
#                                                                                  # 
#                                                                                  # 
#                                                                                  # 
####################################################################################

#ADD YOUR COMPUTER NAME AT THE BOTTOM

#Example "autoLogin -h bobcomp1"

$EaPrefBefore = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

function autoLogin {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [Alias('h')]
        [string]$ComputerName, 
        [string]$ErrorLog = 'c:\loginFail.txt'  
    )
    BEGIN {    
        $h = [System.Net.Dns]::GetHostEntry($ComputerName)
        $hn = $h.HostName
        Write-Host "Attempting login to: $hn" -foregroundcolor "yellow"
        Write-Host "You are logging in from $env:ComputerName"
        Write-Host "Checking if machine is online..." -foregroundcolor "yellow"
    }
    PROCESS {
        $tc = Test-Connection $hn -Count 1
        If ($tc) {
            Write-Host "Machine is online." -foregroundcolor "green"
            Enter-PSSession -ComputerName $hn                                
        }
        else {    
            "$hn is not online. Please try again."


        }
    }   
    END { 
        "      ,,       "
        "  ___(  )___   "
        " /          \  "
        "/\/\/\||/\/\/\ "
        "      ^^       "
        "Fly away little bird"

    }
}
autoLogin -h <COMPUTERNAME>
