Param($Entity, $ConfigurationGroupId, $DateRange)

function InitializeStartEndTimes($TimeInterval)
#-------------------------------------------------------
# This method sets the start and end times of the query
# using the passed in time interval object.  The time interval
# object is converted to XML, and passed to an instance of IntervalParserBase,
# which will do the processing of the time interval.
#
# Arguments:
#   $TimeInterval
#
# Returns:
#   n/a
#
# Side Effects:
#   The below script scope variables are set
#   $script:startDateTime
#   $script:endDateTime
#-------------------------------------------------------
{
    $startObj = $TimeInterval["StartPoint"]
    $startBase = $startObj["BaseDateTime"].ToString()
    $startOffsetType = $startObj["OffsetType"].ToString()
    $startOffset = $startObj["Offset"].ToString()

    $endObj = $TimeInterval["EndPoint"]
    $endBase = $endObj["BaseDateTime"].ToString()
    $endOffsetType = $endObj["OffsetType"].ToString()
    $endOffset = $endObj["Offset"].ToString()

    $intervalString = "<Interval><Title>CurrentInterval</Title>" + 
                      "<Start><Base>" + $startBase + "</Base>" + 
                      "<Offset Type='" + $startOffsetType + "'>" + $startOffset + "</Offset>" + 
                      "</Start>" + 
                      "<End><Base>" + $endBase + "</Base>" + 
                      "<Offset Type='" + $endOffsetType + "'>" + $endOffset + "</Offset>" + 
                      "</End>" +
                      "</Interval>"

    $intervalParser = new-object 'Microsoft.EnterpriseManagement.Presentation.Controls.IntervalParserBase'

    $intervalParser.Initialize($intervalString)

    $script:startDateTime = $intervalParser.GetIntervalStartDateTime().ToUniversalTime()
    $script:endDateTime = $intervalParser.GetIntervalEndDateTime().ToUniversalTime()
}

function GetSLADetails($SLA, $ManagedEntityGuid)
#-------------------------------------------------------
# This method gets the compliance level for the given
# SLA and sets it in it's properties.
# It also retrieves the SLOs for this SLA.
# The data is retrieved using datawarehouse SPROC calls.
#
# Arguments:
#   $SLA
#
# Returns:
#   n/a
#-------------------------------------------------------
{
	$datawarehouse = $ScriptContext.ManagementGroup.GetDataWarehouse()

	$serviceLevelXml = '<Data>' +
                       '<ServiceLevelAgreements>' +
					   '<ServiceLevelAgreement ManagementGroupGuid="' + $ScriptContext.ManagementGroup.Id + '"' + ' ServiceLevelAgreementGuid="' + $SLA["Id"].ToString() + '"/>' +
					   '</ServiceLevelAgreements>' +
					   '</Data>'

    $languageCode = [System.Globalization.CultureInfo]::CurrentCulture.ThreeLetterWindowsLanguageName

	$span = $script:endDateTime - $script:startDateTime

	if ($span.TotalHours -gt 48)
	{
		$aggregationTypeId = 30
	}
	else
	{
		$aggregationTypeId = 20
	}

	# Set up the parameters for the GetServiceLevelInformationData call.
	$params = new-object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameterCollection
	$params.Add("StartDate", $script:startDateTime)
	$params.Add("EndDate", $script:endDateTime)
    $params.Add("ServiceLevelAgreementXml", $serviceLevelXml)
	$params.Add("AggregationTypeId", $aggregationTypeId)
	$params.Add("ManagementGroupId", $ScriptContext.ManagementGroup.Id)
	$params.Add("LanguageCode", $languageCode)

	$SLAInformationRS = $datawarehouse.GetDataWarehouseData("SDK.GetServiceLevelInformationData", $params, $null, 0)

	if ($SLAInformationRS -eq $null)
	{
		return
	}

	# Set up the column name hash
	$SLAInformationColumns = @{}
	$index = 0
	foreach ($col in $SLAInformationRS.ColumnDefinitions)
	{
		$SLAInformationColumns.Add($col.ColumnName, $index)
		$index ++
	}

	# Default to health state 'Unmonitored'
	$SLA["Compliance"] = 0
	
	# Set up the parameters for the GetServiceLevelMetaData call.
	$params = new-object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameterCollection
	$params.Add("StartDate", $script:startDateTime)
	$params.Add("EndDate", $script:endDateTime)
    $params.Add("ServiceLevelAgreementXml", $serviceLevelXml)
	$params.Add("ManagementGroupId", $ScriptContext.ManagementGroup.Id)
	$params.Add("LanguageCode", $languageCode)

	$SLAMetaInformationRS = $datawarehouse.GetDataWarehouseData("sdk.GetServiceLevelMetaData", $params, $null, 0)

	if ($SLAMetaInformationRS -eq $null)
	{
		return
	}

	# Set up the column name hash
	$SLAMetaInformationColumns = @{}
	$index = 0
	foreach ($col in $SLAMetaInformationRS.ColumnDefinitions)
	{
		$SLAMetaInformationColumns.Add($col.ColumnName, $index)
		$index ++
	}

	# Go through the SLAMeta results and pull out the rows that apply to my managed entity
	$mySLAMetaInformation = @()
	$serviceLevelAgreementManagedEntityRowId = -1

	foreach ($result in $SLAMetaInformationRS.Results)
	{
		if ($result[$SLAMetaInformationColumns["ServiceLevelAgreementManagedEntityGuid"]] -eq $ManagedEntityGuid)
		{
			$mySLAMetaInformation += $result
			$serviceLevelAgreementManagedEntityRowId = $result[$SLAMetaInformationColumns["ServiceLevelAgreementManagedEntityRowId"]]
		}
	}

	if ($serviceLevelAgreementManagedEntityRowId -eq -1)
	{
		# My managed entity has no information
		return
	}

	$SLOCollection = $ScriptContext.CreateCollection()
	$SLA["SLOCollection"] = $SLOCollection

	# loop through my MetaInformation and get the SLOs
	foreach ($result in $mySLAMetaInformation)
	{
		# Set up the parameters for the ServiceLevelObjectiveDetailReportDataGet call.
		# This is used to fetch the details for the given SLO
		$params = new-object Microsoft.EnterpriseManagement.Warehouse.StoredProcedureParameterCollection
		$params.Add("StartDate", $script:startDateTime)
		$params.Add("EndDate", $script:endDateTime)
		$params.Add("ServiceLevelAgreementManagedEntityRowId", $serviceLevelAgreementManagedEntityRowId)
		$params.Add("ServiceLevelObjectiveGuid", $result[$SLAMetaInformationColumns["ServiceLevelObjectiveGuid"]])
		$params.Add("AggregationTypeId", $aggregationTypeId)
		$params.Add("LanguageCode", $languageCode)

		$SLODetailRS = $datawarehouse.GetDataWarehouseData("sdk.ServiceLevelObjectiveDetailReportDataGet", $params, $null, 0)

		$aggregatedValueSum = 0
		$aggregatedValueCount = 0

		$firstDetail = $true

		foreach ($detailResult in $SLODetailRS.Results)
		{
			if ($firstDetail)
			{
				# Set up the column name hash
				$SLODetailRSColumns = @{}
				$index = 0
				foreach ($col in $SLODetailRS.ColumnDefinitions)
				{
					$SLODetailRSColumns.Add($col.ColumnName, $index)
					$index ++
				}

				$firstDetail = $false
			}

			$SLO = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.ServiceLevelComponents!ServiceLevelDataTypes/ServiceLevelObjectiveME")
			$SLO["Id"] = $result[$SLAMetaInformationColumns["ServiceLevelObjectiveGuid"]].ToString() + "-" + $detailResult[$SLODetailRSColumns["ManagedEntityRowId"]].ToString()
			$SLO["ServiceLevelObjectiveMEName"] = $result[$SLAMetaInformationColumns["ServiceLevelObjectiveDisplayName"]].ToString() + " - " + $detailResult[$SLODetailRSColumns["ManagedEntityDisplayName"]].ToString() + " " + $detailResult[$SLODetailRSColumns["ManagedEntityPath"]].ToString()
			$SLO["ServiceLevelObjectiveMEGoal"] = $detailResult[$SLODetailRSColumns["Goal"]]
			$SLO["ServiceLevelObjectiveMEDesiredObjective"] = $detailResult[$SLODetailRSColumns["DesiredObjective"]]
			$SLO["AggregatedValue"] = [Math]::Round($detailResult[$SLODetailRSColumns["AggregatedValue"]], 4)
			$desiredObjectiveUnder = [String]::Equals($SLO["ServiceLevelObjectiveMEDesiredObjective"], "under", [StringComparison]::Ordinal)

			if ($SLO["ServiceLevelObjectiveMEGoal"] -lt 0 -or $SLO["AggregatedValue"] -lt 0)
			{
				$SLO["MinValue"] = [Convert]::ToDouble([Math]::Min($SLO["ServiceLevelObjectiveMEGoal"], $SLO["AggregatedValue"]))
			}
			else
			{
				$SLO["MinValue"] = [Double]0.0
			}

			# Get the max value
			$maxValue = [Math]::Max([Math]::Ceiling($SLO["ServiceLevelObjectiveMEGoal"]), [Math]::Ceiling($SLO["AggregatedValue"]))

			# Round up to nearest 10
			if ($maxValue % 10 -ne 0)
			{
				$SLO["MaxValue"] = [Convert]::ToDouble([Math]::Ceiling(($maxValue + 1) / 10) * 10)
			}
			else
			{
				$SLO["MaxValue"] = [Convert]::ToDouble($maxValue)
			}

			# Default to "Healthy" if there are any SLO's
			if ($SLA["Compliance"] -eq 0)
			{
				$SLA["Compliance"] = 1
			}

			# Check if this SLO is achieved and adjust the $SLA["Compliance"] accordingly
			if ($desiredObjectiveUnder)
			{
			    if ($SLO["AggregatedValue"] -ge $SLO["ServiceLevelObjectiveMEGoal"])
				{
					# set to critical
					$SLA["Compliance"] = 3
				}
			}
			else
			{
			    if ($SLO["AggregatedValue"] -le $SLO["ServiceLevelObjectiveMEGoal"])
				{
					# set to critical
					$SLA["Compliance"] = 3
				}
			}

			$SLOCollection.Add($SLO)
		}
	}
}

InitializeStartEndTimes($DateRange)

$newList = @()

if ($Entity -ne $null)
{
	$id = New-Object Guid($Entity["Id"].ToString())

	$entityInstance = Get-SCOMClassInstance -Id $id

	$slas = $ScriptContext.ManagementGroup.ServiceLevelAgreements.GetConfigurationGroups()

	foreach ($sla in $slas)
	{
		$targetClass = Get-SCOMClass -Id $sla.Target.Id

		if ($entityInstance.IsInstanceOf($targetClass))
		{
			if ($sla.Name -eq $ConfigurationGroupId.Trim())
			{
				$slaInstance = $ScriptContext.CreateInstance("mpschema://Microsoft.EnterpriseManagement.Configuration.ManagementPackConfigurationGroup")

				$slaInstance["Id"] = $sla.Id.ToString()
				$slaInstance["DisplayName"] = $sla.DisplayName
				$slaInstance["This"] = $slaInstance

				GetSLADetails $slaInstance $id

				$newList += $slaInstance
			}
		}
	}
}

$ScriptContext.ReturnCollection.UpdateCollection($newList)