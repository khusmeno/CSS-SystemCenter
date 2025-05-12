-- ##### ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimensionProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring_Microsoft_Window_Server_GetPortState' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetPortState] AS RETURN 1')
END
GO

ALTER PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetPortState]
	@mgId uniqueidentifier
	,@meId uniqueidentifier
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @pcId int
  DECLARE @dt datetime

  SELECT 
  @pcId = c.ComputerRowId
  FROM 
  ProcessMonitoring.ComputerDim c
  JOIN
  dbo.ManagedEntity me with(NOLOCK)
  ON
  c.ManagementEntityRowId = me.ManagedEntityRowId
  JOIN
  dbo.vManagementGroup mg with(NOLOCK)
  ON
  mg.ManagementGroupRowId = me.ManagementGroupRowId
  WHERE
  mg.ManagementGroupGuid = @mgId
  AND
  me.ManagedEntityGuid = @meId

  IF @pcId IS NULL
  BEGIN
    goto Finish
  END



  SELECT @dt = MAX(p.DateTime)
  FROM
  ProcessMonitoring.vPortFactsRaw p WITH(NOLOCK)
  WHERE
  p.ComputerRowId = @pcId

  IF @dt IS NULL
  BEGIN
    goto Finish
  END

SELECT  p.[ComputerRowId]
      , p.[ProcessRowId]
      , p.[ProcessCmdRowId]
      , p.[UserRowId]
      , p.[PID]
      , p.[LocalAddressRowId]
      , p.[RemoteAddressRowId]
      , p.[PortType]
      , p.[LocalPort]
      , p.[RemotePort]
	  , p.PortState
	  , pd.ProcessName
	  , la.IpAddress as LocalAddress
	  , ra.IpAddress as RemoteAddress
	  , p.OldPortState
	  , p.TimeInOldState
	  , p.IPV6
FROM ProcessMonitoring.vPortFactsRaw p WITH(NOLOCK)
JOIN ProcessMonitoring.ComputerDim c
ON c.ComputerRowId = p.ComputerRowId
JOIN ProcessMonitoring.vProcessDim pd
ON pd.ProcessRowId = p.ProcessRowID
JOIN ProcessMonitoring.IpAddressDim la
ON la.IpAddressRowId = p.LocalAddressRowId
JOIN ProcessMonitoring.IpAddressDim ra
ON ra.IpAddressRowId = p.RemoteAddressRowId
WHERE c.ComputerRowId = @pcId
and
p.DateTime = @dt

	
Finish:
	END
GO

GRANT EXECUTE ON [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetPortState] TO OpsMgrReader
GO
