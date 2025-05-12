-- ##### Exchange2013_Report_PerformaceReportDataGet_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Exchange2013_Report_PerformaceReportDataGet' AND uid = SCHEMA_ID('dbo'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [dbo].[Exchange2013_Report_PerformaceReportDataGet] AS RETURN 1')
END
GO

ALTER PROCEDURE [dbo].[Exchange2013_Report_PerformaceReportDataGet]
	@StartDate datetime,
	@EndDate datetime,
	@OptionList xml,
	@Rules XML,
	@DataAggregation tinyint = 0,
  @LanguageCode varchar(3) = 'ENU'
AS
BEGIN
	BEGIN TRY
		DECLARE @OptionListModified XML
		
		SET @OptionListModified = @OptionList
		
		SET @OptionListModified = CAST (
		(
			SELECT
				[Data] = CAST((
					SELECT
						[Object/@Use] = 'Containment',
						[Object] = o.n.value('.','int'),
						[Rule] = r.n.value('.','uniqueidentifier'),
						[Color] = '63,63,255',
						[Type] = 'Line',
						[Scale] = 1
					FROM
						@OptionList.nodes('/Data/Objects/Object') AS o(n)
						CROSS APPLY
						@Rules.nodes('/Rules/Rule') AS r(n)
					FOR XML PATH('Value'), ROOT('Values')
				) AS XML)
			FOR XML	PATH('')
		) AS XML)
			
		EXEC dbo.Microsoft_SystemCenter_DataWarehouse_Report_Library_PerformaceReportDataGet 
			@StartDate, @EndDate, @OptionListModified, @DataAggregation, @LanguageCode
	END TRY
	BEGIN CATCH
		DECLARE @errMsg VARCHAR(1024)
		SET @errMsg = ERROR_MESSAGE()
		
		RAISERROR(@errMsg, 16, 1)
	END CATCH
END
GO

GRANT EXECUTE ON [dbo].[Exchange2013_Report_PerformaceReportDataGet] TO OpsMgrReader
GO

