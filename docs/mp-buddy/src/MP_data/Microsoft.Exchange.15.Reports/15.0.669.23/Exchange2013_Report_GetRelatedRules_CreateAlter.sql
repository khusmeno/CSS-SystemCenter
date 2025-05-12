-- ##### Exchange2013_Report_GetRelatedRules_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Exchange2013_Report_GetRelatedRules' AND uid = SCHEMA_ID('dbo'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [dbo].[Exchange2013_Report_GetRelatedRules] AS RETURN 1')
END
GO

ALTER PROCEDURE [dbo].[Exchange2013_Report_GetRelatedRules]
	@rules XML,
	@lang NVARCHAR(3) = 'ENU'
AS
BEGIN
	BEGIN TRY
		DECLARE @r TABLE (RuleSystemName NVARCHAR(1024))
		
		INSERT INTO @r
		(
			RuleSystemName
		)
		SELECT
			r.n.value('.','nvarchar(1024)')
		FROM
			@rules.nodes('/Rules/Rule') AS r(n)
			
		IF NOT EXISTS (SELECT * FROM @r)
		BEGIN
			INSERT INTO @r
			(
				RuleSystemName
			)
			SELECT
				vr.RuleSystemName
			FROM
				vRule vr
				INNER JOIN vManagementPack vmp ON vmp.ManagementPackRowId = vr.ManagementPackRowId
				INNER JOIN vPerformanceRule vpr ON vpr.RuleRowId = vr.RuleRowId
			WHERE
				vmp.ManagementPackSystemName='Microsoft.Exchange.15'
		END
		
		IF EXISTS
 
		(
		
			
			SELECT
			
				
				vr.RuleGuid,
			
				
				vr.RuleSystemName,
			
				
				DisplayName = ISNULL(vds.Name,vr.RuleDefaultName)
		
			
			FROM
			
				
				@r r
			
				
				INNER JOIN vRule vr ON vr.RuleSystemName = r.RuleSystemName
			
				
				INNER JOIN vDisplayString vds ON vds.ElementGuid=vr.RuleGuid AND vds.LanguageCode=@lang
		
		
		)
		
		
		BEGIN
		
		
		SELECT
			
			
			vr.RuleGuid,
			
			
			vr.RuleSystemName,
			
			
			DisplayName = ISNULL(vds.Name,vr.RuleDefaultName)
		
		
		FROM
			
			
			@r r
			
			
			INNER JOIN vRule vr ON vr.RuleSystemName = r.RuleSystemName
			
			
			INNER JOIN vDisplayString vds ON vds.ElementGuid=vr.RuleGuid AND vds.LanguageCode=@lang
		
		
		ORDER BY DisplayName
		
		
		END
		
		
		ELSE
		
		
		BEGIN
		
		
		SELECT
			
			
			vr.RuleGuid,
			
			
			vr.RuleSystemName,
			
			
			DisplayName = ISNULL(vds.Name,vr.RuleDefaultName)
		
		
		FROM
			
			
			@r r
			
			
			INNER JOIN vRule vr ON vr.RuleSystemName = r.RuleSystemName
			
			
			INNER JOIN vDisplayString vds ON vds.ElementGuid=vr.RuleGuid AND vds.LanguageCode=N'ENU'
		
		
		ORDER BY DisplayName
		
		
		END
		
	END TRY
	BEGIN CATCH
		DECLARE @errMsg VARCHAR(1024)
		SET @errMsg = ERROR_MESSAGE()
		
		RAISERROR(@errMsg, 16, 1)
	END CATCH
END
GO

GRANT EXECUTE ON [dbo].[Exchange2013_Report_GetRelatedRules] TO OpsMgrReader
GO
