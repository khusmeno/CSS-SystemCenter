IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring_Microsoft_Window_Server_GetPortState' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('DROP PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetPortState]')
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring.Microsoft_Window_Server_GetProcessMetricAndState' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('DROP PROCEDURE [sdk].[ProcessMonitoring.Microsoft_Window_Server_GetProcessMetricAndState]')
END

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring.ProcessMonitoring_Microsoft_Window_Server_GetTopNProcesses' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('DROP PROCEDURE [sdk].[ProcessMonitoring.ProcessMonitoring_Microsoft_Window_Server_GetTopNProcesses]')
END
GO