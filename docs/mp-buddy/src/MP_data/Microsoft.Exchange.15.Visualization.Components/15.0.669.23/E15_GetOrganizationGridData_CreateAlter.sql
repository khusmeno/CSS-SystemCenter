IF NOT EXISTS (
		SELECT *
		FROM sysobjects
		WHERE type = 'P' AND NAME = 'Microsoft_Exchange_15_Visualization_Components_GetOrganizationGridData' AND UID = SCHEMA_ID('SDK')
		)
BEGIN
	EXECUTE ('CREATE PROCEDURE sdk.Microsoft_Exchange_15_Visualization_Components_GetOrganizationGridData AS RETURN 1')
END
GO

ALTER PROCEDURE [sdk].[Microsoft_Exchange_15_Visualization_Components_GetOrganizationGridData] 
	@ManagementGroup UNIQUEIDENTIFIER	
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

    if (OBJECT_ID('tempdb..#OrgEntitiesTable') IS NOT NULL)
        DROP TABLE #OrgEntitiesTable

    if (OBJECT_ID('tempdb..#OrgContainmentEnitities') IS NOT NULL)
        DROP TABLE #OrgContainmentEnitities

    --
    BEGIN TRY

		DECLARE @OrgNameGuid uniqueidentifier

		-- min interval for mailbox statistic is 24 hour
		DECLARE @dbStartTime Datetime

		if (DATEDIFF(hh,@StartTime, @EndTime)<24) 
		  SET @dbStartTime = DATEADD(DAY,-1,@EndTime)
		else
		  SET @dbStartTime = @StartTime

        -- list of organizations in given management group
        CREATE TABLE #OrgEntitiesTable (
            EntityGuid uniqueidentifier
            ,EntityRowId int
            --,Alerts int default (0)
            ,InnerObjects nvarchar(max) default '<root></root>'
			,OrgName nvarchar (max)
			,MailboxesCount int default (0)
			,MbxDbCount int default (0)
            )

        -- Table for rainbow cell data. grouping by column and state.
        -- EntityType:
        -- 1 - AD Sites
        -- 2 - DAGs
        -- 3 - CA Servers
        -- 4 - Mbx Servers 
		-- 5 - ET Servers       

        -- Table for containers and 1 level children. (used in rainbow data)
        CREATE TABLE #OrgContainmentEnitities  (
            OrgRowId int
            ,EntityRowId int
            ,EntityType int
        )

		SELECT @OrgNameGuid = metp.PropertyGuid
			FROM vManagedEntityTypeProperty metp 
			INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = metp.ManagedEntityTypeRowId)
			WHERE metp.PropertySystemName='Name'
			AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.Service'
     
        --Organizations
         INSERT INTO #OrgEntitiesTable (EntityGuid, EntityRowId,OrgName)
            SELECT me.ManagedEntityGuid, me.ManagedEntityRowId, mep.PropertyXml.value('(/Root/Property[@Guid=sql:variable("@OrgNameGuid")])[1]','nvarchar(256)') as OrgName					
				FROM vManagedEntity me
                INNER JOIN vManagementGroup mg ON (mg.ManagementGroupRowId = me.ManagementGroupRowId)
                INNER JOIN vManagedEntityManagementGroup AS MEMG ON memg.ManagedEntityRowId = me.ManagedEntityRowId
                INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = me.ManagedEntityTypeRowId)
				INNER JOIN vManagedEntityProperty mep ON (mep.ManagedEntityRowId= me.ManagedEntityRowId)
                WHERE mg.ManagementGroupGuid = @ManagementGroup					
                    AND memg.ToDateTime IS NULL
					AND mep.ToDateTime IS NULL
                    AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.Organization'
        
        --Fill Direct Children
        INSERT INTO #OrgContainmentEnitities SELECT
            r.SourceManagedEntityRowId, r.TargetManagedEntityRowId as EntityRowId
            ,(CASE rt.RelationshipTypeSystemName
                WHEN 'Microsoft.Exchange.15.Organization.Contains.Microsoft.Exchange.15.ActiveDirectorySite' THEN 1
                WHEN 'Microsoft.Exchange.15.Organization.Contains.Microsoft.Exchange.15.DatabaseAvailabilityGroup' THEN 2
                ELSE 0 END
            ) as EntityType
            FROM vRelationship r
            INNER JOIN vRelationshipType rt ON (r.RelationshipTypeRowId=rt.RelationshipTypeRowId)
            INNER JOIN vRelationshipManagementGroup rtg ON (rtg.RelationshipRowId = r.RelationshipRowId)
            INNER JOIN #OrgEntitiesTable oet ON (oet.EntityRowId = r.SourceManagedEntityRowId)
            WHERE rtg.ToDateTime IS NULL AND
                rt.RelationshipTypeSystemName IN (
                    'Microsoft.Exchange.15.Organization.Contains.Microsoft.Exchange.15.ActiveDirectorySite'
                    ,'Microsoft.Exchange.15.Organization.Contains.Microsoft.Exchange.15.DatabaseAvailabilityGroup'
                    ,'Microsoft.Exchange.15.Organization.Hosts.Microsoft.Exchange.15.Organization.CAServers.InstanceGroup'
                    ,'Microsoft.Exchange.15.Organization.Hosts.Microsoft.Exchange.15.Organization.MbxServers.InstanceGroup'
					,'Microsoft.Exchange.15.Organization.Hosts.Microsoft.Exchange.15.Organization.ETServers.InstanceGroup')

        -- Fill Children from containers
        INSERT INTO #OrgContainmentEnitities
            SELECT
            oec.OrgRowId, r.TargetManagedEntityRowId
            ,(CASE rt.RelationshipTypeSystemName
                WHEN 'Microsoft.Exchange.15.Organization.CAServers.InstanceGroup.Contains.Microsoft.Exchange.15.Server' THEN 3
                WHEN 'Microsoft.Exchange.15.Organization.MbxServers.InstanceGroup.Contains.Microsoft.Exchange.15.Server' THEN 4
				WHEN 'Microsoft.Exchange.15.Organization.ETServers.InstanceGroup.Contains.Microsoft.Exchange.15.Server' THEN 5				
                ELSE 0 END) As EntityType
            FROM vRelationship r
            INNER JOIN vRelationshipType rt ON (r.RelationshipTypeRowId=rt.RelationshipTypeRowId)
            INNER JOIN vRelationshipManagementGroup rtg ON (rtg.RelationshipRowId = r.RelationshipRowId)
            INNER JOIN #OrgContainmentEnitities oec ON (oec.EntityRowId = r.SourceManagedEntityRowId)
            WHERE rtg.ToDateTime IS NULL AND
                oec.EntityType = 0

        UPDATE #OrgEntitiesTable
            SET InnerObjects = (
                    SELECT me.ManagedEntityGuid as Id, oce.EntityType
                    FROM #OrgContainmentEnitities oce 
                    INNER JOIN vManagedEntity me ON (me.ManagedEntityRowId = oce.EntityRowId)
                    WHERE oet.EntityRowId = oce.OrgRowId AND oce.EntityType>0
					FOR XML RAW ('row'), ROOT ('root')
                )
            FROM #OrgEntitiesTable oet;
    
    DECLARE 
    	@exchMbxDbTypeRowId INT,
    	@exchMbxDbNamePropertyGuid UNIQUEIDENTIFIER
    	
    SELECT @exchMbxDbTypeRowId = vmet.ManagedEntityTypeRowId FROM vManagedEntityType vmet WHERE vmet.ManagedEntityTypeSystemName='Microsoft.Exchange.15.MailboxDatabaseCopy'
    SELECT @exchMbxDbNamePropertyGuid=vmetp.PropertyGuid FROM vManagedEntityTypeProperty vmetp WHERE vmetp.ManagedEntityTypeRowId=@exchMbxDbTypeRowId AND vmetp.PropertySystemName='DatabaseName'
    
		;WITH MbxData as (
			SELECT count(*) as mbxCount, oce.OrgRowId as OrgRowId
				FROM Exchange2013.vMailbox m 
				INNER JOIN Exchange2013.vMailboxProperties mp ON (mp.PropertySetGuid = m.LatestPropertySetGuid)
				INNER JOIN vManagedEntity me ON (me.ManagedEntityGuid = mp.ManagedEntityGuid)
				INNER JOIN vManagedEntityManagementGroup memg ON (me.ManagedEntityRowId = memg.ManagedEntityRowId)
				INNER JOIN vManagementGroup mg ON (mg.ManagementGroupRowId = me.ManagementGroupRowId)
				INNER JOIN #OrgContainmentEnitities oce ON (oce.EntityRowId = me.ManagedEntityRowId)
				WHERE memg.ToDateTime IS NULL		
				AND oce.EntityType = 4
				AND m.LastReceivedDateTime >= @dbStartTime
				GROUP BY oce.OrgRowId
		) UPDATE #OrgEntitiesTable SET MailboxesCount = md.mbxCount
		FROM #OrgEntitiesTable oet INNER JOIN MbxData md ON (md.OrgRowId=oet.EntityRowId)

		;With MbxDb as (
			SELECT
				oc.OrgRowId, 
				dbCount = count(distinct vmep.PropertyXml.value('(/Root/Property[@Guid[. = sql:variable("@exchMbxDbNamePropertyGuid")]]/text())[1]','nvarchar(max)'))
			FROM
				#OrgContainmentEnitities oc
				INNER JOIN vRelationship vr ON vr.SourceManagedEntityRowId=oc.EntityRowId
				INNER JOIN vManagedEntity vme ON vr.TargetManagedEntityRowId=vme.ManagedEntityRowId AND vme.ManagedEntityTypeRowId=@exchMbxDbTypeRowId
				INNER JOIN vManagedEntityProperty vmep ON vmep.ManagedEntityRowId = vme.ManagedEntityRowId AND vmep.ToDateTime IS NULL
			GROUP BY oc.OrgRowId
		) UPDATE #OrgEntitiesTable SET MbxDbCount = md.dbCount
		FROM #OrgEntitiesTable oet INNER JOIN MbxDb md ON oet.EntityRowId=md.OrgRowId
            
        SELECT * FROM #OrgEntitiesTable
                    
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
	-- cleanup

	if (OBJECT_ID('tempdb..#OrgEntitiesTable') IS NOT NULL)
        DROP TABLE #OrgEntitiesTable

    if (OBJECT_ID('tempdb..#OrgContainmentEnitities') IS NOT NULL)
        DROP TABLE #OrgContainmentEnitities


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
	ON [sdk].[Microsoft_Exchange_15_Visualization_Components_GetOrganizationGridData] 
	TO OpsMgrReader
GO
