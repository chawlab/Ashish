<#
.SYNOPSIS
    Create a Logs Analytics Workspace and Adds a list of Windows Performance Counters to a Log Analytics workspace.
.DESCRIPTION
    This script adds a list of Windows Performance Counters to a Log Analytics workspace.
    
#>
Connect-AzAccount 

	$question = 'Do you wanted to crete a new Workspace ?'
	$choices  = '&Yes', '&No'
     
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
   
$LogWorkspaceName = Read-Host -Prompt 'Input your Log workspace name'

Write-Host "Choose a Azure Location name"
$AZLocation = Get-AzLocation | select -expandproperty DisplayName  
$AZL = $AZLocation | Out-GridView -Title "Choose a Location Name" -Passthru

Write-Host "Choose the Resource Group name"
$AZResource = Get-AzResourceGroup | Select -expandproperty ResourceGroupName
$AZR = $AZResource | Out-GridView -Title "Choose a Resource Group Name" -Passthru

}
Else
{
	Write-Host "Have a nice rest of the day"
	Exit
}


Try
{
Import-Module Az.OperationalInsights
	
    New-AzOperationalInsightsWorkspace -Location $AZL -Name $LogWorkspaceName -Sku Standard -ResourceGroupName $AZR
	Write-Host "Created new workspace $LogWorkspaceName"
}

catch
{
Write-Host "Created workspace $WorkspaceName"

}


$question = 'Do you want to creat the Window Performance Counter in your log Analytics Workspace ?'
	$choices  = '&Yes', '&No'
     $title = "Azure WVD Performance Counter Add-on Script"
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {


######## Variables ##########

# The Workspace Resource Group
$rg = $AZR

# The Workspace Name
$wsName = $LogWorkspaceName



$perfCounters = 'Terminal Services Session(*)\% Processor Time',
'Terminal Services(*)\Active Sessions',
'Terminal Services(*)\Inactive Sessions',
'Terminal Services(*)\Total Sessions',
'LogicalDisk(*)\% Free Space',
'LogicalDisk(*)\Avg. Disk sec/Read',
'LogicalDisk(*)\Avg. Disk sec/Write',
'LogicalDisk(*)\Current Disk Queue Length',
'LogicalDisk(*)\Disk Reads/sec',
'LogicalDisk(*)\Disk Transfers/sec',
'LogicalDisk(*)\Disk Writes/sec',
'LogicalDisk(*)\Free Megabytes',
'Processor(_Total)\% Processor Time',
'Memory(*)\% Committed Bytes In Use',
'Network Adapter(*)\Bytes Received/sec',
'Network Adapter(*)\Bytes Sent/sec',
#'Process(*)\% Processor Time',
#'Process(*)\% User Time',
#'Process(*)\IO Read Operations/sec',
#'Process(*)\IO Write Operations/sec',
#'Process(*)\Thread Count',
'Process(*)\Working Set',
'RemoteFX Graphics(*)\Average Encoding Time',
'RemoteFX Graphics(*)\Frames Skipped/Second - Insufficient Client Resources',
'RemoteFX Graphics(*)\Frames Skipped/Second - Insufficient Network Resources',
'RemoteFX Graphics(*)\Frames Skipped/Second - Insufficient Server Resources',
'RemoteFX Network(*)\Current TCP Bandwidth',
'RemoteFX Network(*)\Current TCP RTT',
'RemoteFX Network(*)\Current UDP Bandwidth',
'RemoteFX Network(*)\Current UDP RTT',
'PhysicalDisk(*)\Avg. Disk Bytes/Read',
'PhysicalDisk(*)\Avg. Disk Bytes/Write',
'PhysicalDisk(*)\Avg. Disk sec/Write',
'PhysicalDisk(*)\Avg. Disk sec/Read',
'PhysicalDisk(*)\Avg. Disk Bytes/Transfer',
'PhysicalDisk(*)\Avg. Disk sec/Transfer'


# Add perf counters to Log Analytics Workspace
foreach ($perfCounter in $perfCounters) {
    $perfArray = $perfCounter.split("\").split("(").split(")")
    $objectName = $perfArray[0]
    $instanceName = $perfArray[1]
    $counterName = $perfArray[3]
    $name = ("$objectName-$counterName") -replace "/", "Per" -replace "%", "Percent" 
    write-output $name
    try {
        New-AzOperationalInsightsWindowsPerformanceCounterDataSource -ErrorAction Stop -ResourceGroupName $rg `
            -WorkspaceName $wsName -ObjectName $objectName -InstanceName $instanceName -CounterName $counterName `
            -IntervalSeconds 60  -Name $name -Force
    }
    catch {
        $ErrorMessage = $_.Exception.message
        Write-Error ("Adding PerfCounter $name had the following error: " + $ErrorMessage)
    }
}

}
Else
{
	Write-Host " Please Add the Window Performance Counter Manual"
}