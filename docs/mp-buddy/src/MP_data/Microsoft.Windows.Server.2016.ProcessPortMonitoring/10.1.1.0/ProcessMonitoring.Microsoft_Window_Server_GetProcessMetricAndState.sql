-- ##### ProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimensionProcessMonitoring_Microsoft_Window_Server_GetAllProcessDimension_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring_Microsoft_Window_Server_GetProcessMetricAndState' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetProcessMetricAndState] AS RETURN 1')
END
GO

ALTER PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetProcessMetricAndState]
	@mgId uniqueidentifier
	,@meId uniqueidentifier
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @pcId int
  DECLARE @dtH datetime
  DECLARE @dtM datetime

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

  SELECT @dtH = MAX(p.DateTime)
  FROM
	ProcessMonitoring.vProcessHealthFactsRaw p WITH(NOLOCK)
  WHERE
	p.ComputerRowId = @pcId

  IF @dtH IS NULL
  BEGIN
    goto Finish
  END

  SELECT @dtM = MAX(p.DateTime)
  FROM
	ProcessMonitoring.vProcessMetricFactsRaw p WITH(NOLOCK)
  WHERE
	p.ComputerRowId = @pcId

  IF @dtM IS NULL
  BEGIN
    goto Finish
  END

;WITH lastHealth AS
 (
	 SELECT
		ph.[ComputerRowId]
		,ph.[ProcessRowId]
		,ph.[ProcessCmdRowId]
		,ph.[UserRowId]
		,ph.[PID] 
		,AggregateHealthState
		,ph.CpuHealthState
		,ph.MemoryHealthState
		,ph.HandleCountHealthState
	 FROM ProcessMonitoring.vProcessHealthFactsRaw ph
	 JOIN ProcessMonitoring.ComputerDim c
		ON c.ComputerRowId = ph.ComputerRowId
	 JOIN dbo.ManagedEntity me
		ON me.ManagedEntityRowId = c.ManagementEntityRowId
	 JOIN dbo.ManagementGroup mg
		ON mg.ManagementGroupRowId = me.ManagementGroupRowId
	 WHERE me.ManagedEntityGuid = @meId
		AND mg.ManagementGroupGuid = @mgId
		AND ph.DateTime = @dtH
 ),
 lastMetrics AS
 (
	 SELECT
		pm.[ComputerRowId]
		,pm.[ProcessRowId]
		,pm.[ProcessCmdRowId]
		,pm.[UserRowId]
		,pm.[PID]
		,pm.CpuUsage
		,pm.MemoryUsage
		,pm.IOReadPerSecond
		,pm.IOWritePerSecond
		,pm.TotalProcessTime
		,pm.HandleCount
		,pm.ThreadCount
		,pm.CpuTime
	 FROM ProcessMonitoring.vProcessMetricFactsRaw pm
	 JOIN ProcessMonitoring.ComputerDim c
		ON c.ComputerRowId = pm.ComputerRowId
	 JOIN dbo.ManagedEntity me
		ON me.ManagedEntityRowId = c.ManagementEntityRowId
	 JOIN dbo.ManagementGroup mg
		ON mg.ManagementGroupRowId = me.ManagementGroupRowId
	 WHERE me.ManagedEntityGuid = @meId
		AND mg.ManagementGroupGuid = @mgId
		AND pm.DateTime = @dtM
 )
 SELECT 
	h.AggregateHealthState,
	pd.ProcessName,
	ISNULL(h.PID, m.PID) AS PID,
	m.CpuUsage,
	m.MemoryUsage,
	m.IOReadPerSecond,
	m.IOWritePerSecond,
	h.CpuHealthState,
	h.MemoryHealthState,
	h.HandleCountHealthState,
	m.TotalProcessTime,
	m.HandleCount,
	m.ThreadCount,
	m.CpuTime
 FROM lastHealth h
 FULL JOIN lastMetrics m
	ON  m.PID = h.PID
 JOIN ProcessMonitoring.ProcessDim pd
	ON pd.ProcessRowId = ISNULL(h.ProcessRowId, m.ProcessRowId)
	
Finish:
	END
GO

GRANT EXECUTE ON [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetProcessMetricAndState] TO OpsMgrReader
GO
