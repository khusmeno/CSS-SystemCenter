-- ##### Exchange2013_Report_PerformaceTopReportDataGet_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Exchange2013_Report_PerformaceTopReportDataGet' AND uid = SCHEMA_ID('dbo'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [dbo].[Exchange2013_Report_PerformaceTopReportDataGet] AS RETURN 1')
END
GO

ALTER PROCEDURE [dbo].[Exchange2013_Report_PerformaceTopReportDataGet]
  @StartDate datetime,
  @EndDate datetime,
  @ObjectList XML,
  @RuleId uniqueidentifier,
  @ManagementGroup xml,
  @InstanceFilter NVARCHAR(1024),
  @SortOrder int,
  @TopCount int,
  @LanguageCode varchar(3) = 'ENU'
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

			

		SET @SortOrder = CASE WHEN @SortOrder < 0 THEN -1 ELSE 1 END

		IF OBJECT_ID('tempdb..#GroupList') IS NOT NULL DROP TABLE #GroupList 
		CREATE TABLE #GroupList (ManagementGroupGuid uniqueidentifier)
		
		IF OBJECT_ID('tempdb..#me') IS NOT NULL DROP TABLE #me
		CREATE TABLE #me (ManagedEntityRowId INT) 

		-- force containment - objects are also determined by selected rule, so we'll output all relevant targets regardless to 
		-- which button has been used.		
		DECLARE @ObjectListModified XML, @i INT, @attcnt INT
		SET @ObjectListModified = @ObjectList
		SET @i=1
		SET @attcnt = @ObjectListModified.value('count(/Data/Objects/Object/@Use)','int')
		
		WHILE @i<=@attcnt
		BEGIN
			SET @ObjectListModified.modify('
				replace value of ((/Data/Objects/Object/@Use)[position()=sql:variable("@i")])[1]
				with "Containment"
			')	
			SET @i+=1
		END
		
		INSERT INTO #me
		(
			ManagedEntityRowId
		)
		EXEC dbo.Microsoft_SystemCenter_DataWarehouse_Report_Library_ReportObjectListParse	@StartDate, @EndDate, @ObjectListModified

		INSERT INTO #GroupList (ManagementGroupGuid)
		SELECT GroupList.ManagementGroupGuid.value('.', 'uniqueidentifier')
		FROM @ManagementGroup.nodes('/Data/Value') AS GroupList(ManagementGroupGuid)


		IF DATEDIFF(hour,@StartDate,@EndDate)>=48
		BEGIN
			SELECT TOP (@TopCount) WITH TIES
						vManagedEntity.ManagedEntityGuid,
						SUM(vPerf.SampleCount * vPerf.AverageValue) / SUM(vPerf.SampleCount) AS TotalAverageValue,
						SUM(vPerf.SampleCount) AS TotalSampleCount, MIN(vPerf.MinValue) AS TotalMinValue, 
						MAX(vPerf.MaxValue) AS TotalMaxValue,
						SQRT(SUM(vPerf.SampleCount * POWER(vPerf.StandardDeviation, 2)) / SUM(vPerf.SampleCount)) AS TotalStandardDeviation,
						vManagedEntity.
						ManagedEntityRowId, 
						vManagedEntity.ManagedEntityDefaultName, 
						vManagedEntity.Path,
						vRule.RuleGuid, 
						vRule.RuleDefaultName,
						vPerformanceRuleInstance.InstanceName, 
						vManagementGroup.ManagementGroupGuid, 
						vManagementGroup.ManagementGroupDefaultName, 
						ISNULL(vDisplayString.Name,vManagedEntityType.ManagedEntityTypeDefaultName) AS DisplayName,
						vManagedEntityTypeImage.Image,
						RowNo = DENSE_RANK() OVER (ORDER BY (SUM(vPerf.SampleCount * vPerf.AverageValue) / SUM(vPerf.SampleCount)) * @SortOrder)
			FROM  Perf.vPerfDaily As vPerf INNER JOIN
						vManagedEntity ON vPerf.ManagedEntityRowId = vManagedEntity.ManagedEntityRowId INNER JOIN
						#me me ON me.ManagedEntityRowId = vManagedEntity.ManagedEntityRowId INNER JOIN
						vManagementGroup ON vManagedEntity.ManagementGroupRowId = vManagementGroup.ManagementGroupRowId INNER JOIN
						#GroupList AS GroupList ON vManagementGroup.ManagementGroupGuid = GroupList.ManagementGroupGuid INNER JOIN
						vManagedEntityType ON vManagedEntity.ManagedEntityTypeRowId = vManagedEntityType.ManagedEntityTypeRowId INNER JOIN
						vPerformanceRuleInstance ON vPerf.PerformanceRuleInstanceRowId = vPerformanceRuleInstance.PerformanceRuleInstanceRowId INNER JOIN
						vRule ON vPerformanceRuleInstance.RuleRowId = vRule.RuleRowId LEFT OUTER JOIN
						vManagedEntityTypeImage ON vManagedEntity.ManagedEntityTypeRowId = vManagedEntityTypeImage.ManagedEntityTypeRowId AND 
						vManagedEntityTypeImage.ImageCategory = N'u16x16Icon' LEFT OUTER JOIN 
						vDisplayString ON vManagedEntityType.ManagedEntityTypeGuid = vDisplayString.ElementGuid AND 
						vDisplayString.LanguageCode = @LanguageCode
			WHERE (vPerf.DateTime >= DATEADD(hh, DATEPART(hh, @StartDate), convert(varchar(8), @StartDate, 112))) AND
						(vPerf.DateTime < DATEADD(hh, DATEPART(hh, @EndDate), convert(varchar(8), @EndDate, 112)))
						AND InstanceName LIKE '%'+@InstanceFilter+'%'
						AND RuleGuid=@RuleId
			GROUP BY 
				vManagedEntity.ManagedEntityGuid, 
				vManagedEntity.Path, 
				vManagedEntityTypeImage.Image, 
				vManagedEntity.ManagedEntityRowId, 
				vManagedEntity.ManagedEntityDefaultName, 
				vRule.RuleGuid, 
				vRule.RuleDefaultName, 
				vPerformanceRuleInstance.InstanceName, 
				vManagementGroup.ManagementGroupGuid, 
				vManagementGroup.ManagementGroupDefaultName, 
				vManagedEntityType.ManagedEntityTypeDefaultName, 
				vDisplayString.Name
			ORDER BY (SUM(vPerf.SampleCount * vPerf.AverageValue) / SUM(vPerf.SampleCount)) * @SortOrder
		END
		ELSE
		BEGIN
			SELECT TOP (@TopCount) WITH TIES
						vManagedEntity.ManagedEntityGuid,
						SUM(vPerf.SampleCount * vPerf.AverageValue) / SUM(vPerf.SampleCount) AS TotalAverageValue,
						SUM(vPerf.SampleCount) AS TotalSampleCount, MIN(vPerf.MinValue) AS TotalMinValue, 
						MAX(vPerf.MaxValue) AS TotalMaxValue,
						SQRT(SUM(vPerf.SampleCount * POWER(vPerf.StandardDeviation, 2)) / SUM(vPerf.SampleCount)) AS TotalStandardDeviation,
						vManagedEntity.
						ManagedEntityRowId, 
						vManagedEntity.ManagedEntityDefaultName, 
						vManagedEntity.Path,
						vRule.RuleGuid, 
						vRule.RuleDefaultName,
						vPerformanceRuleInstance.InstanceName, 
						vManagementGroup.ManagementGroupGuid, 
						vManagementGroup.ManagementGroupDefaultName, 
						ISNULL(vDisplayString.Name,vManagedEntityType.ManagedEntityTypeDefaultName) AS DisplayName,
						vManagedEntityTypeImage.Image,
						RowNo = DENSE_RANK() OVER (ORDER BY (SUM(vPerf.SampleCount * vPerf.AverageValue) / SUM(vPerf.SampleCount)) * @SortOrder)
			FROM  Perf.vPerfHourly As vPerf INNER JOIN
						vManagedEntity ON vPerf.ManagedEntityRowId = vManagedEntity.ManagedEntityRowId INNER JOIN
						#me me ON me.ManagedEntityRowId = vManagedEntity.ManagedEntityRowId INNER JOIN
						vManagementGroup ON vManagedEntity.ManagementGroupRowId = vManagementGroup.ManagementGroupRowId INNER JOIN
						#GroupList AS GroupList ON vManagementGroup.ManagementGroupGuid = GroupList.ManagementGroupGuid INNER JOIN
						vManagedEntityType ON vManagedEntity.ManagedEntityTypeRowId = vManagedEntityType.ManagedEntityTypeRowId INNER JOIN
						vPerformanceRuleInstance ON vPerf.PerformanceRuleInstanceRowId = vPerformanceRuleInstance.PerformanceRuleInstanceRowId INNER JOIN
						vRule ON vPerformanceRuleInstance.RuleRowId = vRule.RuleRowId LEFT OUTER JOIN
						vManagedEntityTypeImage ON vManagedEntity.ManagedEntityTypeRowId = vManagedEntityTypeImage.ManagedEntityTypeRowId AND 
						vManagedEntityTypeImage.ImageCategory = N'u16x16Icon' LEFT OUTER JOIN 
						vDisplayString ON vManagedEntityType.ManagedEntityTypeGuid = vDisplayString.ElementGuid AND 
						vDisplayString.LanguageCode = @LanguageCode
			WHERE (vPerf.DateTime >= DATEADD(hh, DATEPART(hh, @StartDate), convert(varchar(8), @StartDate, 112))) AND
						(vPerf.DateTime < DATEADD(hh, DATEPART(hh, @EndDate), convert(varchar(8), @EndDate, 112)))
						AND InstanceName LIKE '%'+@InstanceFilter+'%'
						AND RuleGuid=@RuleId
			GROUP BY 
				vManagedEntity.ManagedEntityGuid, 
				vManagedEntity.Path, 
				vManagedEntityTypeImage.Image, 
				vManagedEntity.ManagedEntityRowId, 
				vManagedEntity.ManagedEntityDefaultName, 
				vRule.RuleGuid, 
				vRule.RuleDefaultName, 
				vPerformanceRuleInstance.InstanceName, 
				vManagementGroup.ManagementGroupGuid, 
				vManagementGroup.ManagementGroupDefaultName, 
				vManagedEntityType.ManagedEntityTypeDefaultName, 
				vDisplayString.Name
			ORDER BY (SUM(vPerf.SampleCount * vPerf.AverageValue) / SUM(vPerf.SampleCount)) * @SortOrder			
		END 

		IF OBJECT_ID('tempdb..#GroupList') IS NOT NULL DROP TABLE #GroupList 
		IF OBJECT_ID('tempdb..#me') IS NOT NULL DROP TABLE #me
			
  END TRY
	BEGIN CATCH
		IF OBJECT_ID('tempdb..#GroupList') IS NOT NULL DROP TABLE #GroupList 
		IF OBJECT_ID('tempdb..#me') IS NOT NULL DROP TABLE #me

		DECLARE @errMsg VARCHAR(1024)
		SET @errMsg = ERROR_MESSAGE()
		
		RAISERROR(@errMsg, 16, 1)
	END CATCH
END
GO

GRANT EXECUTE ON [dbo].[Exchange2013_Report_PerformaceTopReportDataGet] TO OpsMgrReader
GO
