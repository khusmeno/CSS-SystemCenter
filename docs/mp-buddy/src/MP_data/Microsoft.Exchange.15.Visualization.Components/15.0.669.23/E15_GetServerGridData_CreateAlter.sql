IF NOT EXISTS (
        SELECT *
        FROM sysobjects
        WHERE type = 'P' AND NAME = 'Microsoft_Exchange_15_Visualization_Components_GetServerGridData' AND UID = SCHEMA_ID('SDK')
        )
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_Exchange_15_Visualization_Components_GetServerGridData AS RETURN 1')
END
GO

ALTER PROCEDURE [sdk].[Microsoft_Exchange_15_Visualization_Components_GetServerGridData]
    @ManagementGroup UNIQUEIDENTIFIER
   ,@OrganizationName nvarchar(256)
   ,@StartTime datetime
   ,@EndTime datetime
   
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
         @ErrorInd         bit
        ,@ErrorMessage     nvarchar(max)
        ,@ErrorNumber      int
        ,@ErrorSeverity    int
        ,@ErrorState       int
        ,@ErrorLine        int
        ,@ErrorProcedure   nvarchar(256)
        ,@ErrorMessageText nvarchar(max)

    SET @ErrorInd = 0

    if (OBJECT_ID('tempdb..#EntitiesTable') IS NOT NULL)
        DROP TABLE #EntitiesTable

    if (OBJECT_ID('tempdb..#ContainmentEnitities') IS NOT NULL)
        DROP TABLE #ContainmentEnitities

    if (OBJECT_ID('tempdb..#PerfDataTable') IS NOT NULL)
        DROP TABLE #PerfDataTable

    --
    BEGIN TRY

		DECLARE @OrgNameGuid uniqueidentifier		

	   -- min interval for mailbox statistic is 24 hour
		DECLARE @dbStartTime Datetime

		if (DATEDIFF(hh,@StartTime, @EndTime)<24) 
		  SET @dbStartTime = DATEADD(DAY,-1,@EndTime)
		else
		  SET @dbStartTime = @StartTime

        -- list of root entities in given management group
        CREATE TABLE #EntitiesTable (
            EntityGuid uniqueidentifier
            ,EntityRowId int
            ,InnerObjects nvarchar(max) default '<root></root>'
            ,MailboxCount int
            ,MbxDatabaseCount int
            ,MemoryUsage nvarchar(256)
            ,CpuUsage nvarchar (256)
            )

        -- Table for rainbow cell data. grouping by column and state.
        -- EntityType:
        -- -1  MailboxDatabases (need for count)
        -- 1 - NTService
        -- 2 - ServerResourcesHealthSet
        -- 3 - ServiceComponentsHealthSet
        -- 4 - CustomerTouchPointsHealthSet
        -- 5 - KeyDependenciesHealthSet
        -- Table for containers and 1 level children. (used in rainbow data)
        CREATE TABLE #ContainmentEnitities  (
            ParentEntityRowId int
            ,EntityRowId int
            ,EntityType int
        )

        -- Table for performance values
        -- PerfType:
        -- 1 - Cpu Usage (%)
        -- 2 - Private Memory Size (Mb)
        -- 3 - Total Memory Size (Mb)
        CREATE TABLE #PerfDataTable(
            EntityRowId int
            ,Value float
            ,PerfType int
            )
		
		SELECT @OrgNameGuid = metp.PropertyGuid
			FROM vManagedEntityTypeProperty metp 
			INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = metp.ManagedEntityTypeRowId)
			WHERE metp.PropertySystemName='OrganizationName'
			AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.Server'

        --Servers
        INSERT INTO #EntitiesTable (EntityGuid, EntityRowId)
            SELECT me.ManagedEntityGuid, me.ManagedEntityRowId
                FROM vManagedEntity me
                INNER JOIN vManagementGroup mg ON (mg.ManagementGroupRowId = me.ManagementGroupRowId)
                INNER JOIN vManagedEntityManagementGroup AS MEMG ON memg.ManagedEntityRowId = me.ManagedEntityRowId
                INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = me.ManagedEntityTypeRowId)
                INNER JOIN vManagedEntityProperty ps ON (ps.ManagedEntityRowId=me.ManagedEntityRowId)
                WHERE mg.ManagementGroupGuid = @ManagementGroup
                    AND memg.ToDateTime IS NULL
					AND ps.ToDateTime IS NULL
                    AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.Server'
                    AND (@OrganizationName='' OR ps.PropertyXml.value('(/Root/Property[@Guid=sql:variable("@OrgNameGuid")])[1]','nvarchar(256)') = @OrganizationName)

        -- EntityTypes:
        -- 0 - MailboxDatabaseCopy (for count)
        -- 1 - NTService
        -- 2 - ServerResourcesHealthSet
        -- 3 - ServiceComponentsHealthSet
        -- 4 - CustomerTouchPointsHealthSet
        -- 5 - KeyDependenciesHealthSet
        --Fill Direct Children
        INSERT INTO #ContainmentEnitities SELECT
            r.SourceManagedEntityRowId, r.TargetManagedEntityRowId as EntityRowId
            ,(CASE rt.RelationshipTypeSystemName
                WHEN 'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.NTService' THEN 1
                WHEN 'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.ServerResourcesHealthSet' THEN 2
                WHEN 'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.ServiceComponentsHealthSet' THEN 3
                WHEN 'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.CustomerTouchPointsHealthSet' THEN 4
                WHEN 'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.KeyDependenciesHealthSet' THEN 5
                ELSE 0 END
            ) as EntityType
            FROM vRelationship r
            INNER JOIN vRelationshipType rt ON (r.RelationshipTypeRowId=rt.RelationshipTypeRowId)
            INNER JOIN vRelationshipManagementGroup rtg ON (rtg.RelationshipRowId = r.RelationshipRowId)
            INNER JOIN #EntitiesTable et ON (et.EntityRowId = r.SourceManagedEntityRowId)
            WHERE rtg.ToDateTime IS NULL AND
                rt.RelationshipTypeSystemName IN (
                     'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.NTService'
                    ,'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.ServerResourcesHealthSet'
                    ,'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.ServiceComponentsHealthSet'
                    ,'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.CustomerTouchPointsHealthSet'
                    ,'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.KeyDependenciesHealthSet'
                    ,'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.MailboxDatabaseCopy');

        WITH PerfData AS (
            SELECT PPR.SampleValue as Value, PPR.DateTime as ValueDate, CET.EntityRowId as MEId, PR.CounterName as CounterName
                ,(RANK() OVER (
                    PARTITION BY CET.EntityRowId,PR.CounterName
                    ORDER BY PPR.DateTime DESC)) as Rank
            FROM #EntitiesTable CET
            INNER JOIN Perf.vPerfRaw PPR  ON (CET.EntityRowId = PPR.ManagedEntityRowId)
            INNER JOIN vPerformanceRuleInstance PRI ON (PRI.PerformanceRuleInstanceRowId=PPR.PerformanceRuleInstanceRowId)
            INNER JOIN vPerformanceRule PR ON (PR.RuleRowId=PRI.RuleRowId)
            WHERE PR.ObjectName = 'Exchange Server'
                AND PPR.DateTime BETWEEN @StartTime AND @EndTime
                AND PRI.InstanceName = '_total'
                AND PR.CounterName IN ('Cpu Usage (%)','Private Memory Size (MB)','Total Memory (MB)')
        ) INSERT INTO #PerfDataTable (EntityRowId, Value, PerfType)
             SELECT pd.MEId, pd.Value
                ,(CASE pd.CounterName
                    WHEN 'Cpu Usage (%)' THEN 1
                    WHEN 'Private Memory Size (MB)' THEN 2
                    WHEN 'Total Memory (MB)' THEN 3 END) as PerfType
              FROM PerfData pd WHERE pd.Rank = 1;

        -- Mailbox count
        WITH MailboxData as (
            SELECT Count(*) as mbxCount, me.ManagedEntityRowId as ManagedEntityRowId
                FROM Exchange2013.vMailbox m
                INNER JOIN Exchange2013.vMailboxProperties mp ON (mp.PropertySetGuid = m.LatestPropertySetGuid)
                INNER JOIN vManagedEntity me ON (me.ManagedEntityGuid = mp.ManagedEntityGuid)
                INNER JOIN vManagedEntityManagementGroup memg ON (me.ManagedEntityRowId = memg.ManagedEntityRowId)
                INNER JOIN vManagementGroup mg ON (mg.ManagementGroupRowId = me.ManagementGroupRowId)
                WHERE memg.ToDateTime IS NULL
				AND m.LastReceivedDateTime >= @dbStartTime
                GROUP BY me.ManagedEntityRowId
        ),-- Mailbox database count
         MbxDatabaseData as (
                SELECT Count(*) as dbCount,ce.ParentEntityRowId as RowId FROM #ContainmentEnitities ce
                    WHERE ce.EntityType=0
                    GROUP BY ce.ParentEntityRowId
        ) --Fill resultset
        UPDATE #EntitiesTable
            SET InnerObjects = (
                    SELECT me.ManagedEntityGuid as Id, ce.EntityType
                    FROM #ContainmentEnitities ce
                    INNER JOIN vManagedEntity me ON (me.ManagedEntityRowId = ce.EntityRowId)
                    WHERE et.EntityRowId = ce.ParentEntityRowId AND ce.EntityType>0
                    FOR XML RAW ('row'), ROOT ('root')
                )
                ,MailboxCount = ISNULL(md.mbxCount,0)
                ,MbxDatabaseCount = ISNULL(mdb.dbCount,0)
                ,CpuUsage = (
                    SELECT 0 as MinValue,cpu.Value as Value, 100 as MaxValue
                    FROM #PerfDataTable cpu
                    WHERE cpu.EntityRowId = et.EntityRowId
                        AND cpu.PerfType = 1
                    FOR XML RAW ('row')
                )
                ,MemoryUsage = (
                    SELECT 0 as MinValue,mu.Value as Value, mt.Value as MaxValue
                    FROM #PerfDataTable mu
                    INNER JOIN #PerfDataTable mt ON (mu.EntityRowId = mt.EntityRowId)
                    WHERE mu.PerfType = 2 AND mt.PerfType = 3 AND mu.EntityRowId = et.EntityRowId
                     FOR XML RAW ('row')
                     )
            FROM #EntitiesTable et            
            LEFT JOIN MailboxData md ON (md.ManagedEntityRowId = et.EntityRowId)
            LEFT JOIN MbxDatabaseData mdb ON (mdb.RowId = et.EntityRowId)

   SELECT * FROM #EntitiesTable;

/* ------------------------------ */

    END TRY
    BEGIN CATCH
        IF (@@TRANCOUNT > 0)
            ROLLBACK TRAN

        SELECT
             @ErrorNumber = ERROR_NUMBER()
            ,@ErrorSeverity = ERROR_SEVERITY()
            ,@ErrorState = ERROR_STATE()
            ,@ErrorLine = ERROR_LINE()
            ,@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-')
            ,@ErrorMessageText = ERROR_MESSAGE()

        SET @ErrorInd = 1
    END CATCH

    -- Cleanup
    if (OBJECT_ID('tempdb..#EntitiesTable') IS NOT NULL)
        DROP TABLE #EntitiesTable

    if (OBJECT_ID('tempdb..#ContainmentEnitities') IS NOT NULL)
        DROP TABLE #ContainmentEnitities

    if (OBJECT_ID('tempdb..#PerfDataTable') IS NOT NULL)
        DROP TABLE #PerfDataTable

    -- report error if any
    IF (@ErrorInd = 1)
    BEGIN
        DECLARE @AdjustedErrorSeverity int

        SET @AdjustedErrorSeverity = CASE
                                         WHEN @ErrorSeverity > 18 THEN 18
                                         ELSE @ErrorSeverity
                                     END

        RAISERROR (777971002, @AdjustedErrorSeverity, 1
            ,@ErrorNumber
            ,@ErrorSeverity
            ,@ErrorState
            ,@ErrorProcedure
            ,@ErrorLine
            ,@ErrorMessageText
        )
    END
END
GO
GRANT EXECUTE
	ON [sdk].[Microsoft_Exchange_15_Visualization_Components_GetServerGridData] 
	TO OpsMgrReader
GO
