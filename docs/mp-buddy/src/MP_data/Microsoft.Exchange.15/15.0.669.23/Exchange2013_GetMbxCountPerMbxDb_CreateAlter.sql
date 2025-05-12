
IF NOT EXISTS (
		SELECT *
		FROM sysobjects
		WHERE type = 'P' AND NAME = 'Exchange2013_GetMbxCountPerMbxDb' AND UID = SCHEMA_ID('sdk')
		)
BEGIN
	EXECUTE ('CREATE PROCEDURE sdk.Exchange2013_GetMbxCountPerMbxDb AS RETURN 1')
END
GO

ALTER PROCEDURE sdk.Exchange2013_GetMbxCountPerMbxDb 
	@ManagementGroup UNIQUEIDENTIFIER	
	,@StartTime datetime
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
	
	if (OBJECT_ID('tempdb..#OrgServers') IS NOT NULL)
        DROP TABLE #OrgServers  

	if (OBJECT_ID('tempdb..#Result') IS NOT NULL)
        DROP TABLE #Result  

    --
    BEGIN TRY
	
	    CREATE TABLE #OrgServers (
			OrgName nvarchar(256)
		    ,ServerGuid uniqueidentifier
			,ServerRowId int
	    )

		CREATE TABLE #Result (
		  OrgName nvarchar(256)
		  ,DatabaseName nvarchar(256)
		  ,MbxCount int default (0)
		)
	
		DECLARE @OrgNameGuid uniqueidentifier
		DECLARE @DbNameGuid uniqueidentifier

		SELECT @OrgNameGuid = metp.PropertyGuid
			FROM vManagedEntityTypeProperty metp 
			INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = metp.ManagedEntityTypeRowId)
			WHERE metp.PropertySystemName='OrganizationName'
			AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.Server'

		SELECT @DbNameGuid = metp.PropertyGuid
			FROM vManagedEntityTypeProperty metp 
			INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = metp.ManagedEntityTypeRowId)
			WHERE metp.PropertySystemName='DatabaseName'
			AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.MailboxDatabaseCopy'


		INSERT INTO #OrgServers(OrgName, ServerGuid, ServerRowId)
			SELECT mep.PropertyXml.value('(/Root/Property[@Guid=sql:variable("@OrgNameGuid")])[1]','nvarchar(256)') as OrgName, 
				me.ManagedEntityGuid as ServerGuid, me.ManagedEntityRowId as ServerRowId
			FROM vManagedEntity me
			INNER JOIN vManagedEntityManagementGroup memg ON (memg.ManagedEntityRowId = me.ManagedEntityRowId)
			INNER JOIN vManagementGroup mg ON (mg.ManagementGroupRowId = me.ManagementGroupRowId)
			INNER JOIN vManagedEntityProperty mep ON (mep.ManagedEntityRowId = me.ManagedEntityRowId)
			INNER JOIN vManagedEntityType met ON (met.ManagedEntityTypeRowId = me.ManagedEntityTypeRowId)
			WHERE mep.ToDateTime IS NULL
			AND memg.ToDateTime IS NULL
			AND mg.ManagementGroupGuid = @ManagementGroup
			AND met.ManagedEntityTypeSystemName = 'Microsoft.Exchange.15.Server'	
			

		INSERT INTO #Result (OrgName,DatabaseName)
			SELECT DISTINCT os.OrgName, mep.PropertyXml.value('(/Root/Property[@Guid=sql:variable("@DbNameGuid")]/text())[1]','nvarchar(256)') 
			FROM #OrgServers os
			INNER JOIN vRelationship vr ON (vr.SourceManagedEntityRowId = os.ServerRowId)
			INNER JOIN vRelationshipType vrt ON (vrt.RelationshipTypeRowId = vr.RelationshipTypeRowId)
			INNER JOIN vManagedEntity dbs ON (dbs.ManagedEntityRowId = vr.TargetManagedEntityRowId)
			INNER JOIN vManagedEntityProperty mep ON (mep.ManagedEntityRowId = dbs.ManagedEntityRowId)
			WHERE vrt.RelationshipTypeSystemName = 'Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.MailboxDatabaseCopy'				
			AND mep.ToDateTime IS NULL
		
		;WITH MbxData AS (
		SELECT Count(*) as MailboxCount, mp.[Database] as DbName, os.OrgName
			FROM Exchange2013.vMailbox m 
			INNER JOIN Exchange2013.vMailboxProperties mp ON (mp.PropertySetGuid = m.LatestPropertySetGuid)
			INNER JOIN #OrgServers os ON (os.ServerGuid = mp.ManagedEntityGuid)		
			WHERE m.LastReceivedDateTime >= @StartTime
			GROUP BY mp.[Database], os.OrgName
			)			
		UPDATE #Result SET MbxCount= md.MailboxCount 
		FROM #Result r 
		INNER JOIN MbxData md ON (r.DatabaseName=md.DbName AND r.OrgName=r.OrgName)

		SELECT * FROM #Result
                
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

	if (OBJECT_ID('tempdb..#OrgServers') IS NOT NULL)
        DROP TABLE #OrgServers  

	if (OBJECT_ID('tempdb..#Result') IS NOT NULL)
        DROP TABLE #Result 

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
	ON [sdk].[Exchange2013_GetMbxCountPerMbxDb]
	TO OpsMgrReader
GO
