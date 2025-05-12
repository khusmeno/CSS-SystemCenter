-- ##### Exchange2013_Report_PerformaceReportDataGet_Drop.sql
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Exchange2013_Report_PerformaceReportDataGet' AND uid = SCHEMA_ID('dbo'))
BEGIN
	EXECUTE ('DROP PROCEDURE [dbo].[Exchange2013_Report_PerformaceReportDataGet]')
END
GO
