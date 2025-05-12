-- ##### ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimensionProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension] AS RETURN 1')
END
GO

ALTER PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension]
AS
BEGIN
  SET NOCOUNT ON

  IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME ='vProcessDim'  AND TABLE_SCHEMA = 'ProcessMonitoring') AND
   EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='ProcessDim'  AND TABLE_SCHEMA = 'ProcessMonitoring') 
  BEGIN
      SELECT DISTINCT
     	     ProcessName       
	        ,[Description]       
	        ,UserDescription   
     FROM
     ProcessMonitoring.vProcessDim

  END
END
GO

GRANT EXECUTE ON [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension] TO OpsMgrReader
GO
