IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'ProcessMonitoring_Microsoft_Window_Server_GetTopNProcesses' AND uid = SCHEMA_ID('sdk'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetTopNProcesses] AS RETURN 1')
END
GO

ALTER PROCEDURE [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetTopNProcesses]
	@cpuWeight float
	,@memoryWeight float
	,@handleCountWeight float
	,@threadCountWeight float
	,@pageFaultCountWeight float
	,@cpuTimeWeight float
	,@totalProcessTimeWeight float
	,@readPerSecondWeight float
	,@writePerSecondWeight float
	,@N int
	,@startDate datetime
	,@endDate datetime
AS
BEGIN
  SET NOCOUNT ON

	DECLARE @lastDate date = CONVERT(date, @endDate)
	DECLARE @today date = GETUTCDATE()

	IF @lastDate >= @today
		SET @lastDate = @today

	;WITH AggregeatedData
		AS
		(
			SELECT ComputerRowId, ProcessRowID, CpuUsageMaxValue AS CpuUsage, MemoryUsageMaxValue AS MemoryUsage, HandleCountMaxValue as HandleCount, ThreadCountMaxValue as ThreadCount, PageFaultMaxValue as PageFaultCount, CpuTimeMaxValue as CpuTime, TotalProcessTimeMaxValue as TotalProcessTime, IOReadPerSecondMaxValue as IOReadPerSecond, IOWritePerSecondMaxValue as IOWritePerSecond
			FROM ProcessMonitoring.vProcessMetricFactsDaily
			WHERE DateTime > CONVERT(date, @startDate) AND DateTime < @lastDate
			UNION ALL
			SELECT ComputerRowId, ProcessRowID, CpuUsageMaxValue AS CpuUsage, MemoryUsageMaxValue AS MemoryUsage, HandleCountMaxValue as HandleCount, ThreadCountMaxValue as ThreadCount, PageFaultMaxValue as PageFaultCount, CpuTimeMaxValue as CpuTime, TotalProcessTimeMaxValue as TotalProcessTime, IOReadPerSecondMaxValue as IOReadPerSecond, IOWritePerSecondMaxValue as IOWritePerSecond
			FROM ProcessMonitoring.vProcessMetricFactsHourly
			WHERE (DateTime >= @lastDate AND DateTime <= @endDate) OR (DateTime >= @startDate AND DateTime < CONVERT(date, @startDate))
		)
		,topn
		AS
		(
			SELECT TOP(@N)
				ComputerRowId, ProcessRowID, MAX(CpuUsage) AS CpuUsage, MAX(MemoryUsage) AS MemoryUsage, MAX(HandleCount) as HandleCount, MAX(ThreadCount) as ThreadCount, MAX(PageFaultCount) as PageFaultCount, MAX(CpuTime) as CpuTime, MAX(TotalProcessTime) as TotalProcessTime, MAX(IOReadPerSecond) as IOReadPerSecond, MAX(IOWritePerSecond) as IOWritePerSecond
			FROM AggregeatedData
			WHERE ProcessRowID <> 2

			GROUP BY ComputerRowId, ProcessRowID
			ORDER BY @cpuWeight * MAX(CpuUsage) + @memoryWeight * MAX(MemoryUsage)+@handleCountWeight*MAX(HandleCount)+@threadCountWeight*MAX(ThreadCount)+@pageFaultCountWeight*MAX(PageFaultCount)+@cpuTimeWeight*MAX(CpuTime)+@totalProcessTimeWeight*MAX(TotalProcessTime)+@readPerSecondWeight*MAX(IOReadPerSecond)+@writePerSecondWeight*MAX(IOWritePerSecond) DESC
		)
		SELECT cd.Name AS ComputerName, pd.ProcessName, topn.CpuUsage, topn.MemoryUsage , topn.HandleCount, topn.ThreadCount, topn.PageFaultCount, topn.CpuTime, topn.TotalProcessTime, topn.IOReadPerSecond, topn.IOWritePerSecond
		FROM topn 
		JOIN ProcessMonitoring.ComputerDim cd
			ON cd.ComputerRowId = topn.ComputerRowId
		JOIN ProcessMonitoring.ProcessDim pd
			ON pd.ProcessRowId = topn.ProcessRowId
END

GRANT EXECUTE ON [sdk].[ProcessMonitoring_Microsoft_Window_Server_GetTopNProcesses] TO OpsMgrReader
GO
