IF NOT EXISTS (SELECT * FROM sys.objects WHERE [schema_id] = SCHEMA_ID('sdk') AND [type] = 'P' AND [name] = 'Microsoft_SQLServer_2017_Windows_Views_GetDBFilesForecastData')
BEGIN
	EXECUTE ('CREATE PROCEDURE [sdk].[Microsoft_SQLServer_2017_Windows_Views_GetDBFilesForecastData] AS RETURN 1')
END
GO