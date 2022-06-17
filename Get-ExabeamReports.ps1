<#############################################################################################################################
#####################################      Pete Lenhart - 2021 - Powershell Exabeam  #########################################
                        Exabeam - Query the incidents and turn them into a PDF report for the boss
                                        *Needs Convert-PDF powershell module installed
    *There is a function to automate getting your username and password from keepass. You need to install that module as well.
                            *server URIs and username has been removed and will be broke til you fix them.
##############################################################################################################################
#> 
[CmdletBinding()]

param

(

    [Parameter(Mandatory = $false)]
    [ValidateSet("yes", "no")]
    [string]$reportable,
    [Parameter(Mandatory = $false)]
    #[ValidateNotNullOrEmpty()]
    [ValidateSet($true, $false, 0, 1)]
    [bool]$irpInitiated = 1,
    [Parameter(Mandatory = $false)]
    #[ValidateNotNullOrEmpty()]
    [ValidateSet("a", "b", "c")]
    [ValidatePattern("[a-zA-Z]+")]
    [string]$lob,
    [Parameter(Mandatory = $false)]
    [ValidatePattern("[sS][oO][cC]\-\d{7}")]
    [string]$SOCID,
    [Parameter(Mandatory = $false)]
    [string]$csvExportPath,
    [Parameter(Mandatory = $false)]
    [string]$reportableNotEquals,
    [Parameter(Mandatory = $false)]
    [datetime]$startDate,
    [datetime]$endDate,
    [PSCredential]$ExCreds,
    [object[]]$assignee 
)

begin {   

    #Variables n stuff...
    #$ErrorActionPreference = "SilentlyContinue"
    $scriptTools = "\\$server\includes"
    $global:q = 'X'
    $getDate = Get-Date -Format “MM-dd-yyyy-HH-mm"
    $dirPath = "\\<PATHTOPUTREPORTS>"
    #REPORTS WITH DATE
    $reportPath = "\\$SERVER\Reports\$getDate"
    $testReportPath = Test-Path -Path "$reportPath" -PathType Container 

    if ($testReportPath -ne $true) {
        $newReport = New-Item -Path "$dirPath\" -Name $getDate -ItemType Directory -Force
        $checkReportFolder = Test-Path -Path $reportPath -PathType Container 

        if ($checkReportFolder) {
            Write-Host "Making folders"
            New-Item -Path "$reportPath\" -Name "reportable-no" -ItemType Directory -Force
            New-Item -Path "$reportPath\" -Name "reportable-yes" -ItemType Directory -Force 
        }
        else {
            Write-Host "Not able to create folders. Breaking script." -ForegroundColor Red
            break
        }
    }
    else {
        Write-Host "$reportPath exists" -ForegroundColor Green
    } 
    #Init stuff
    try {
        . ("$scriptTools\HelpFunctions.ps1")
    }
    catch {
        Write-Host "Error while loading supporting Powershell scripts" -ForegroundColor Red
        break
    } 
    #GET KEYPASS USERNAME AND PASSWORD
    if ($null -eq $ExCreds) {

        $entry = Read-Host "Which username are you using?"   

        switch ($entry) {
            '<USERNAME>' {
                $username = Get-KeePassEntry -KeePassEntryGroupPath all/PASSWORDS -Title "<USERNAME>" -DatabaseProfileName "<KEYPASS FILE" #-AsPSCredential
                $ExCreds = New-Object System.Management.Automation.PSCredential("<USERNAME>", $<USERNAME>.Password)
                continue              
            }
            "<USERNAME>" {
                $ausername = Get-KeePassEntry -KeePassEntryGroupPath all/PASSWORDS -Title "<USERNAME>" -DatabaseProfileName "<USERNAME>" #-AsPSCredential
                $ExCreds = New-Object System.Management.Automation.PSCredential("a-username", $ausername.Password)
                continue
            }
        }
    }

    $IR = New-Object ir $ExCreds, '<IP of EXABEAM'
    $ir.disableSSLCheck()
    try
    {
        $ir.authenticate()
        Write-Host "Authenticated = $?"  
    }
    catch
    {
        Write-Error "Did not authenticate. Aborting."
        break
    } 

    $firstRun = $true
    $results = $ir.irQuery($startDate, $endDate, @("closed", "closedFalsePositive", "inprogress", "pending", "resolved"), 10000)
    $lastID = $results[-1].incidentId  

process
{   

    while ($results.count -gt 0 -and ($firstRun -or $lastID -gt $results[-1].incidentId))
    {

        $lastDate = $results[-1].baseFields.createdAt
        $formattedResults = [System.Collections.ArrayList]@()
        foreach ($incident in $results | where { $_.incidentId -ne $lastID })
        {
            $incident = $ir.getIncidentId($incident.incidentId)   
            #if( ($lob -eq '' -or $incident.fields.lobSelect -eq $lob) -and ($reportable -ne 'Yes' -or $reportable -eq $incident.fields.reportable) -and ($irpInitiated -eq $true -or $irpInitiated -eq $incident.fields.irpInitiated) )
            if ( $firstRun )
            {
                Write-Host $_   
                $activities = $ir.activitesForIncident($incident.incidentID)   
                $item = $incident | select incidentID, name,
                @{label = 'incidentType'; expression = { $_.fields.incidentType -join ', ' } },
                @{label = 'owner'; expression = { $_.fields.owner } },
                @{label = 'closedReason'; expression = { ( $activities | where { $_.newFieldMap.status -eq 'closed' } | select -first 1).newFieldMap."closed Reason" } },
                @{label = 'resolvedDate'; expression = { $ir.dateFromLocalEpoch(( $activities | where { $_.newFieldMap.status -eq 'resolved' } | select -first 1).timestamp) } },
                @{label = 'reportable'; expression = { $_.fields.reportable } },
                @{label = 'lobSelect'; expression = { $_.fields.lobSelect } },
                @{label = 'description'; expression = { $_.fields.description } },
                @{label = 'informTicket'; expression = { $_.fields.informTicket } }, 
                @{label = 'status'; expression = { $_.fields.status } },
                @{label = 'createdAt'; expression = { $ir.dateFromLocalEpoch($_.fields.createdAt) } },
                @{label = 'startedDate'; expression = { $ir.dateFromLocalEpoch($_.fields.startedDate) } },
                @{label = 'closedDate'; expression = { $ir.dateFromLocalEpoch(( $activities | where { $_.newFieldMap.status -eq 'closed' } | select -first 1).timestamp) } },
                @{label = 'formattedMessages'; expression = { ( $activities.formattedMessages -join "`n") } }
                $formattedResults.Add($item)

            }
            else { break }
        }   

        if ($firstRun)
        { 

            $incidentArray = [System.Collections.ArrayList]@()
            foreach ($i in $formattedResults)            {

                if ((($i.reportable -ne $null) -and ($i.reportable -ne '') -and ($i.reportable -eq "yes") ) -and (($i.irpInitiated -ne $null) -and ($i.irpInitiated -ne '') -and ($i.irpInitiated -eq $true)) -and (($i.lobSelect -ne $null) -and ($i.lobSelect -ne '')))
                {
                    $incidentID = $i.incidentID
                    $incidentType = $i.incidentType
                    $lobSelect = $i.lobSelect
                    $informTicket = $i.informTicket
                    $owner = $i.owner
                    $reportable = "yes"
                    
                    $status = $i.status
                    $closedDate = $i.closedDate
                    $createdAt = $i.createdAt
                    $description = $i.description
                    $closedReason = $i.closedReason
                    $formattedMessages = $i.formattedMessages
                    Write-Host "Found $incidentID" -ForegroundColor Green
                    $incidentArray.Add($incidentID)
                    ConvertTo-PDF -incidentID $incidentID -incidentType $incidentType -lobSelect $lobSelect -informTicket $informTicket -owner $owner -reportable $reportable -status $status -irpInitiated $irpInitiated -closedDate $closedDate -createdAt $createdAt -description $description -closedReason $closedReason -formattedMessages $formattedMessages
                }

                elseif ((($i.reportable -eq $null) -or ($i.reportable -eq '') -or ($i.reportable -eq "no") ) -and (($i.irpInitiated -ne $null) -and ($i.irpInitiated -ne '') -and ($i.irpInitiated -eq $true)) -and (($i.lobSelect -ne $null) -and ($i.lobSelect -ne '')))
                {  

                    $incidentID = $i.incidentID
                    $incidentType = $i.incidentType
                    $lobSelect = $i.lobSelect
                    $informTicket = $i.informTicket
                    $owner = $i.owner
                    $reportable = "no"
                    
                    $status = $i.status
                    $closedDate = $i.closedDate
                    $createdAt = $i.createdAt
                    $description = $i.description
                    $closedReason = $i.closedReason
                    $formattedMessages = $i.formattedMessages
                    Write-Host "Found $incidentID for event" -ForegroundColor Green
                    $incidentArray.Add($incidentID)
                    ConvertTo-PDF -incidentID $incidentID -incidentType $incidentType -lobSelect $lobSelect -informTicket $informTicket -owner $owner -reportable $reportable -status $status -irpInitiated $irpInitiated -closedDate $closedDate -createdAt $createdAt -description $description -closedReason $closedReason -formattedMessages $formattedMessages
           

                }

                elseif ((($i.reportable -eq $null) -or ($i.reportable -eq '') -or ($i.reportable -eq "no") ) -and (($i.irpInitiated -ne $null) -and ($i.irpInitiated -ne '') -and ($i.irpInitiated -eq $true)) -and (($i.lobSelect -ne $null) -and ($i.lobSelect -ne '') -and ($lob -eq $lobSelect)))
                {  

                    $incidentID = $i.incidentID
                    $incidentType = $i.incidentType
                    $lobSelect = $i.lobSelect
                    $informTicket = $i.informTicket
                    $owner = $i.owner
                    $reportable = "no"
                    
                    $status = $i.status
                    $closedDate = $i.closedDate
                    $createdAt = $i.createdAt
                    $description = $i.description
                    $closedReason = $i.closedReason
                    $formattedMessages = $i.formattedMessages
                    Write-Host "Found $incidentID for event" -ForegroundColor Green
                    $incidentArray.Add($incidentID)
                    ConvertTo-PDF -incidentID $incidentID -incidentType $incidentType -lobSelect $lobSelect -informTicket $informTicket -owner $owner -reportable $reportable -status $status -irpInitiated $irpInitiated -closedDate $closedDate -createdAt $createdAt -description $description -closedReason $closedReason -formattedMessages $formattedMessages
         

                }

                else

                {}                

            }
            $firstRun = $false   
        }
        else
        {
            Write-Host "Not first run"  
        }
    }
}
end { Write-Host "Have a nice day, love Pete" -ForegroundColor Green }
