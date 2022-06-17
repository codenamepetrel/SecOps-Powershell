#Module Browser Begin
#Version: 1.0.0
#Add-Type -Path 'C:\Program Files (x86)\Microsoft Module Browser\ModuleBrowser.dll'
#$moduleBrowser = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Module Browser', [ModuleBrowser.Views.MainView], $true)
#$#psISE.CurrentPowerShellTab.VisibleVerticalAddOnTools.SelectedAddOnTool = $moduleBrowser
#Module Browser End

Set-StrictMode -Version 3

Set-Location C:\scripts

Set-Alias IH Invoke-History

Set-Alias = gci . -r | sort Length -desc | select fullname -f 10

function prompt {
    $id = 1
    $historyItem = Get-History -Count 1
    if ($historyItem)
    { $id = $historyItem.Id + 1 }

    Write-Host -ForegroundColor Green "`n[$(Get-Location)]"
    Write-Host -NoNewline "PS:$id > "
    $host.UI.RawUI.WindowTitle = "$(Get-Location)"
    "`b"
}

$ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction =
{
    param
            ( $CommandName, $CommandLookupEventArgs )
    if ($CommandName -match '^\.+$') {
        $CommandLookupEventArgs.CommandScriptBlock = {
            for ($counter = 0; $counter -lt $CommandName.Length - 1; $counter++) { Set-Location .. }
        }.GetNewClosure()
    }
    #THIS WILL DELETE A FILE VERBOSE STYLE IF YOU ADD A @ IN FRONT OF IT.
    $ExecutionContext.SessionState.InvokeCommand.PreCommandLookupAction = {
        param($CommandName, $CommandLookupEventArgs)
        if ($CommandName -match "\*") {
            $NewCommandName = $CommandName -replace '\*', ''
            $CommandLookupEventArgs.CommandScriptBlock = {
                & $NewCommandName @args -Verbose
            }.GetNewClosure()
        }
    }
}

$typeFile = (Join-Path (Split-Path $profile) "profile.ps1xml")
Update-TypeData -PrependPath $typeFile
