Param($rootEntityId)

# this function is originally created by Sam Patton during 360 dashboard improvement
function GetManagedEntityAvailability($instance)
{
	$endTime = [DateTime]::UtcNow
	$timeDiff = [TimeSpan]::FromHours(1)
	$startTime = $endTime - $timeDiff

	$params = New-Object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameterCollection
	
	$param = New-Object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameter("StartTime", $startTime)
	$params.Add($param)
	$param = New-Object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameter("EndTime", $endTime)
	$params.Add($param)
	$param = New-Object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameter("ManagementGroup", $instance.ManagementGroup.Id)
	$params.Add($param)
	$param = New-Object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameter("ManagedEntityGuid", $instance.Id)
	$params.Add($param)
	$param = New-Object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameter("AggregationType", 20)
	$params.Add($param)

	$dw = $instance.ManagementGroup.GetDataWarehouse()

	$rs = $dw.GetDataWarehouseData("SDK.Microsoft_SystemCenter_Visualization_Library_GetManagedEntityAvailability", $params)

	#
	# 0 - IntervalDurationMilliseconds
	# 1 - InWhiteStateMilliseconds
	# 2 - InGreenStateMilliseconds
	# 3 - InYellowStateMilliseconds
	# 4 - InRedStateMilliseconds
	# 5 - InPlannedMaintenanceMilliseconds
	# 6 - InUnplannedMaintenanceMilliseconds
	# 7 - InDisabledStateMilliseconds
	# 8 - HealthServiceUnavailableMilliseconds
	#
	# 1, 2, 5, and 8 are 'available' for purposes of this calculation
	# 

	$goodTime = 0
	$totalTime = $rs.Results[0].Values[0]

	$goodTime += $rs.Results[0].Values[1]
	$goodTime += $rs.Results[0].Values[2]
	$goodTime += $rs.Results[0].Values[5]
	$goodTime += $rs.Results[0].Values[8]

	$percentage = (100.0 * $goodTime) / $totalTime

	return [Math]::Round($percentage, 2)
}

$instancesList = @()

# get the root managed entity instance and add into list
$rootInstance = Get-SCOMClassInstance -Id $rootEntityId
$instancesList += $rootInstance

# get all related function instances and add into list
$referenceRelationshipClass = Get-SCOMRelationship -Name Microsoft.SystemCenter.MicrosoftAzure.DA.ServiceDeployment.Contains.ClientPerspective
$clientPerspectiveInstance = Get-SCOMRelationshipInstance -SourceInstance $rootInstance | where {$_.RelationshipId -eq $referenceRelationshipClass.Id -and $_.IsDeleted -eq $false}

if($clientPerspectiveInstance -ne $null)
{
	$referenceFunctionCPRelationshipClass = Get-SCOMRelationship -Name Microsoft.SystemCenter.MicrosoftAzure.DA.ClientPerspective.Hosts.Function
	$functionAll = Get-SCOMRelationshipInstance -SourceInstance $clientPerspectiveInstance.TargetObject | where {$_.RelationshipId -eq $referenceFunctionCPRelationshipClass.Id}

	if($functionAll -ne $null)
	{
		$functionAllFuncRel = Get-SCOMRelationship -Name Microsoft.EnterpriseManagement.Manageability.Function.Contains.Test
		$instancesList += Get-SCOMClassInstance -Id $functionAll.TargetObject.Id
		$relationshipInstances = Get-SCOMRelationshipInstance -SourceInstance $functionAll.TargetObject | where {$_.RelationshipId -eq $functionAllFuncRel.Id}
		foreach ($relationshipInstance in $relationshipInstances)
		{
			$instancesList += Get-SCOMClassInstance -Id $relationshipInstance.TargetObject.Id
		}
	}
}

$newList = @()

foreach ($classInstance in $instancesList)
{
	  if($classInstance -ne $null)
	  {
		$instance = $ScriptContext.CreateFromObject($classInstance, "Id=Id,HealthState=HealthState,DisplayName=DisplayName", $null)
		$instance["Availability"] = GetManagedEntityAvailability($classInstance)
		$newList += $instance		
	  }	  
}

$ScriptContext.ReturnCollection.UpdateCollection($newList)