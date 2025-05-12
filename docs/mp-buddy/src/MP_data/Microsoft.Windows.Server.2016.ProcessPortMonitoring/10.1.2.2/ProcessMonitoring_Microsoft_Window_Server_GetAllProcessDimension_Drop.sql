-- ##### ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension_Drop.sql
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('DROP PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension]')
END
GO
