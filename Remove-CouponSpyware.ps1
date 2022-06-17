<#
Pete Lenhart 2018
Function to kill the coupons spyware
#>

function CouponKiller {

$path86 = "C:\Program Files\Coupons\uninstall.exe"
$path64 = "C:\Program Files (x86)\Coupons\uninstall.exe"
$uninstallXMLx64 = "C:\Program Files (x86)\Coupons\Uninstall\uninstall.xml"
$uninstallXMLx86 = "C:\Program Files\Coupons\Uninstall\uninstall.xml"
$XML86Test = [System.IO.File]::Exists($uninstallXMLx86)
$XML64Test = [System.IO.File]::Exists($uninstallXMLx64)
$86test = [System.IO.File]::Exists($path86)
$64test = [System.IO.File]::Exists($path64)

if ($XML86Test -eq $false){
    Write-Host "$uninstallXMLx86 does not exist. Machine is x64."
} elseif ($XML64Test -eq $false){
    Write-Host "$uninstallXMLx64 does not exist. Machine is x86."
} else { Write-Host "Else"
}

If ($86test){
    cd "C:\Program Files\Coupons\"
    invoke-command -scriptblock { & cmd /c "uninstall.exe" "/U:C:\Program Files\Coupons\Uninstall\uninstall.xml" /S  }
    $?
} elseif ($64test){
    cd "C:\Program Files (x86)\Coupons\"
    invoke-command -scriptblock { & cmd /c "uninstall.exe" "/U:C:\Program Files (x86)\Coupons\Uninstall\uninstall.xml" /S  }
    $?
} else {
    Write-Host "Coupons not found"
    $?
}
}
