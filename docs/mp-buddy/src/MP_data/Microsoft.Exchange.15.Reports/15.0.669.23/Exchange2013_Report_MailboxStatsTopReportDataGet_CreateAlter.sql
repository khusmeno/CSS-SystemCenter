-- ##### Exchange2013_Report_MailboxStatsTopReportDataGet_CreateAlter.sql
IF NOT EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Exchange2013_Report_MailboxStatsTopReportDataGet' AND uid = SCHEMA_ID('dbo'))
BEGIN
	EXECUTE ('CREATE PROCEDURE [dbo].[Exchange2013_Report_MailboxStatsTopReportDataGet] AS RETURN 1')
END
GO

ALTER PROCEDURE [dbo].[Exchange2013_Report_MailboxStatsTopReportDataGet]
	@StartDate datetime,
  @EndDate datetime,
  @ObjectList XML,
  @ManagementGroup xml,
  @SortOrder int,
  @TopCount int,
  @OUFilter NVARCHAR(1024)=NULL,
  @Mode CHAR(2) = 'LS', -- LS - largerst size, GS - most growing, LI - largerst item count, GI - item count growth
  @LanguageCode varchar(3) = 'ENU'
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		SET @SortOrder = CASE WHEN @SortOrder < 0 THEN -1 ELSE 1 END

		IF OBJECT_ID('tempdb..#GroupList') IS NOT NULL DROP TABLE #GroupList 
		CREATE TABLE #GroupList (ManagementGroupGuid uniqueidentifier)
		
		IF OBJECT_ID('tempdb..#me') IS NOT NULL DROP TABLE #me
		CREATE TABLE #me (ManagedEntityRowId INT) 

		IF OBJECT_ID('tempdb..#mesrvdb') IS NOT NULL DROP TABLE #mesrvdb
		CREATE TABLE #mesrvdb 
		(
			ManagedEntityRowId INT,
			DBCopyManagedEntityRowId INT,
			Organization NVARCHAR(MAX),
			DatabaseCopyName NVARCHAR(MAX),
			DatabaseName NVARCHAR(MAX)
		) 

		IF OBJECT_ID('tempdb..#mbxfilter') IS NOT NULL DROP TABLE #mbxfilter
		CREATE TABLE #mbxfilter (
			ManagedEntityGuid UNIQUEIDENTIFIER,
			DatabaseName NVARCHAR(MAX)
		) 
		
		-- force containment - objects are also determined by selected rule, so we'll output all relevant targets regardless to 
		-- which button has been used.		
		DECLARE @ObjectListModified XML, @i INT, @attcnt INT
		SET @ObjectListModified = @ObjectList
		SET @i=1
		SET @attcnt = @ObjectListModified.value('count(/Data/Objects/Object/@Use)','int')
		
		WHILE @i<=@attcnt
		BEGIN
			SET @ObjectListModified.modify('
				replace value of ((/Data/Objects/Object/@Use)[position()=sql:variable("@i")])[1]
				with "Containment"
			')	
			SET @i+=1
		END
		
		INSERT INTO #me
		(
			ManagedEntityRowId
		)
		EXEC dbo.Microsoft_SystemCenter_DataWarehouse_Report_Library_ReportObjectListParse	@StartDate, @EndDate, @ObjectListModified
		
		INSERT INTO #GroupList (ManagementGroupGuid)
		SELECT GroupList.ManagementGroupGuid.value('.', 'uniqueidentifier')
		FROM @ManagementGroup.nodes('/Data/Value') AS GroupList(ManagementGroupGuid)
		
		--- fuzzy logics for scope:
		--- 1. Get all MDX DB Copies from user-defined scope
		--- 2. Get MDX DB Names
		--- 3. Get pairs MDX DB - Exchange Organizations
		--- 4. Get all servers which host selected MDX databases
		--- 5. filter mailboxes by server and database name
		
		DECLARE 
			@MetId_DB INT,
			@MetId_Server INT,
			@MetId_OrgContainer INT,
			@PropId_DBName UNIQUEIDENTIFIER,
			@PropId_OrgName UNIQUEIDENTIFIER,
			@RelId_SrvHostsDb INT,
			@RelId_OrgContainerContainsServer INT  
			
		SELECT @MetId_OrgContainer=vmet.ManagedEntityTypeRowId FROM vManagedEntityType vmet WHERE vmet.ManagedEntityTypeSystemName='Microsoft.Exchange.15.Organization.MbxServers.InstanceGroup'

		SELECT @MetId_DB=vmet.ManagedEntityTypeRowId FROM vManagedEntityType vmet WHERE vmet.ManagedEntityTypeSystemName='Microsoft.Exchange.15.MailboxDatabaseCopy'
		SELECT @PropId_DBName=vmetp.PropertyGuid FROM vManagedEntityTypeProperty vmetp WHERE vmetp.ManagedEntityTypeRowId=@MetId_DB AND vmetp.PropertySystemName='DatabaseName'
		
		SELECT @MetId_Server=vmet.ManagedEntityTypeRowId FROM vManagedEntityType vmet WHERE vmet.ManagedEntityTypeSystemName='Microsoft.Exchange.15.Server'
		SELECT @PropId_OrgName=vmetp.PropertyGuid FROM vManagedEntityTypeProperty vmetp WHERE vmetp.ManagedEntityTypeRowId=@MetId_Server AND vmetp.PropertySystemName='OrganizationName'
		
		SELECT @RelId_SrvHostsDb = vrt.RelationshipTypeRowId FROM vRelationshipType vrt WHERE vrt.RelationshipTypeSystemName='Microsoft.Exchange.15.Server.Hosts.Microsoft.Exchange.15.MailboxDatabaseCopy'
		SELECT @RelId_OrgContainerContainsServer = vrt.RelationshipTypeRowId FROM vRelationshipType vrt WHERE vrt.RelationshipTypeSystemName='Microsoft.Exchange.15.Organization.MbxServers.InstanceGroup.Contains.Microsoft.Exchange.15.Server'
		
		-- get all servers related to mbx database copies in the scope
		INSERT INTO #mesrvdb
		(
			ManagedEntityRowId,
			DBCopyManagedEntityRowId,
			Organization,
			DatabaseCopyName,
			DatabaseName
		)
		SELECT DISTINCT
			vmes.ManagedEntityRowId,
			vme.ManagedEntityRowId,
			vmeps.PropertyXml.value('(/Root/Property[@Guid[. = sql:variable("@PropId_OrgName")]]/text())[1]','nvarchar(max)'),
			vme.DisplayName,
			vmep.PropertyXml.value('(/Root/Property[@Guid[. = sql:variable("@PropId_DBName")]]/text())[1]','nvarchar(max)')
		FROM
			#me me
			INNER JOIN vManagedEntity vme ON vme.ManagedEntityRowId = me.ManagedEntityRowId
			INNER JOIN vRelationship vr ON vme.ManagedEntityRowId=vr.TargetManagedEntityRowId AND vr.RelationshipTypeRowId=@RelId_SrvHostsDb
			INNER JOIN vManagedEntity vmes ON vr.SourceManagedEntityRowId=vmes.ManagedEntityRowId
			INNER JOIN vManagedEntityProperty vmeps ON vmeps.ManagedEntityRowId = vmes.ManagedEntityRowId AND vmeps.ToDateTime IS NULL -- OrganizationName cannot change over time
			INNER JOIN vManagedEntityProperty vmep ON vme.ManagedEntityRowId=vmep.ManagedEntityRowId AND vmep.ToDateTime IS NULL
			INNER JOIN vManagementGroup vmg ON (vmg.ManagementGroupRowId = vme.ManagementGroupRowId)
			INNER JOIN #GroupList gl ON (gl.ManagementGroupGuid = vmg.ManagementGroupGuid)
		WHERE 
			vme.ManagedEntityTypeRowId=@MetId_DB
			
		INSERT INTO #mbxfilter
		(
			ManagedEntityGuid,
			DatabaseName
		)
		SELECT
			vme_srv.ManagedEntityGuid,
			d.DatabaseName
		FROM
			#mesrvdb d
			INNER JOIN vManagedEntity vme_oc ON d.Organization=vme_oc.[Path] 
			INNER JOIN vRelationship vr ON vr.RelationshipTypeRowId=@RelId_OrgContainerContainsServer
																		 AND vr.SourceManagedEntityRowId=vme_oc.ManagedEntityRowId
			INNER JOIN vManagedEntity vme_srv ON vr.TargetManagedEntityRowId=vme_srv.ManagedEntityRowId
		WHERE
			vme_oc.ManagedEntityTypeRowId=@MetId_OrgContainer
				
		;WITH mbxprop (MailboxRowId, RowNoAsc, RowNoDesc, ItemCount, DeletedItemCount, LastLogonTime, TotalDeletedItemSizeMB, TotalItemSizeMB)
		AS
		(
			-- we consider only latest configuration - we do not care where mailbox was before because this report is for tracking mailbox size only
			SELECT 
				m.MailboxRowId,
				RowNoAsc = ROW_NUMBER() OVER (PARTITION BY m.MailboxRowId ORDER BY vmsd.[DateTime] ASC), 
				RowNoDesc = ROW_NUMBER() OVER (PARTITION BY m.MailboxRowId ORDER BY vmsd.[DateTime] DESC),
				vmsd.ItemCount,
				vmsd.DeletedItemCount,
				vmsd.LastLogonTime,
				vmsd.TotalDeletedItemSizeMB,
				vmsd.TotalItemSizeMB
			FROM
				Exchange2013.vMailbox m
				INNER JOIN Exchange2013.vMailboxProperties vmp ON vmp.MailboxRowId = m.MailboxRowId AND m.LatestPropertySetGuid=vmp.PropertySetGuid 
				INNER JOIN #mbxfilter f ON f.ManagedEntityGuid = vmp.ManagedEntityGuid AND vmp.[Database]=f.DatabaseName
				INNER JOIN Exchange2013.vMailboxStatsDaily vmsd ON vmsd.MailboxRowId = vmp.MailboxRowId
			WHERE
			(vmsd.DateTime >= CONVERT(DATETIME,CONVERT(VARCHAR(8), @StartDate, 112)))
			AND	(vmsd.DateTime < DATEADD(hour,24,CONVERT(DATETIME,CONVERT(VARCHAR(8), @EndDate, 112))))
			AND ((vmp.OrganizationalUnit LIKE '%'+@OUFilter+'%') OR @OUFilter IS NULL)							
		)
		SELECT TOP (@TopCount) WITH TIES
			RowNo = DENSE_RANK() OVER (ORDER BY 			
																		( CASE WHEN @Mode='LS'THEN md.TotalItemSizeMB
																				 WHEN @Mode='GS'THEN (md.TotalItemSizeMB-ma.TotalItemSizeMB)
																				 WHEN @Mode='LI'THEN md.ItemCount
																				 WHEN @Mode='GI'THEN md.ItemCount-ma.ItemCount
																				 ELSE NULL						
																		END
																		)*@SortOrder
																),
			m.MailboxRowId,
			m.ExchangeGuid,
			md.ItemCount,
			md.DeletedItemCount,
			md.LastLogonTime,
			md.TotalDeletedItemSizeMB,
			TotalItemSizeMB = md.TotalItemSizeMB,
			ItemCountGrowth = md.ItemCount-ma.ItemCount,
			TotalItemSizeGrowthMB = md.TotalItemSizeMB-ma.TotalItemSizeMB,
			vmp.ServerName,
			vmp.[Database], 
			vmp.RecipientType,
			vmp.OrganizationalUnit, 
			vmp.Name, 
			vmp.UserPrincipalName,
			vmp.EmailAddresses,
			vmp.IsMailboxEnabled, 
			vmp.IsResource,
			vmp.IsShared
		FROM
			Exchange2013.vMailbox m 
			INNER JOIN mbxprop ma ON ma.MailboxRowId = m.MailboxRowId AND ma.RowNoAsc=1
			INNER JOIN mbxprop md ON m.MailboxRowId=md.MailboxRowId AND md.RowNoDesc=1
			INNER JOIN Exchange2013.vMailboxProperties vmp ON m.MailboxRowId=vmp.MailboxRowId AND m.LatestPropertySetGuid=vmp.PropertySetGuid
		ORDER BY
			(
				CASE WHEN @Mode='LS'THEN md.TotalItemSizeMB
						 WHEN @Mode='GS'THEN (md.TotalItemSizeMB-ma.TotalItemSizeMB)
						 WHEN @Mode='LI'THEN md.ItemCount
						 WHEN @Mode='GI'THEN md.ItemCount-ma.ItemCount
						 ELSE NULL						
				END
			)*@SortOrder
		
		IF OBJECT_ID('tempdb..#GroupList') IS NOT NULL DROP TABLE #GroupList 
		IF OBJECT_ID('tempdb..#me') IS NOT NULL DROP TABLE #me
		IF OBJECT_ID('tempdb..#mesrvdb') IS NOT NULL DROP TABLE #mesrvdb
		IF OBJECT_ID('tempdb..#mbxfilter') IS NOT NULL DROP TABLE #mbxfilter

  END TRY
	BEGIN CATCH
		IF OBJECT_ID('tempdb..#GroupList') IS NOT NULL DROP TABLE #GroupList 
		IF OBJECT_ID('tempdb..#me') IS NOT NULL DROP TABLE #me
		IF OBJECT_ID('tempdb..#mesrvdb') IS NOT NULL DROP TABLE #mesrvdb
		IF OBJECT_ID('tempdb..#mbxfilter') IS NOT NULL DROP TABLE #mbxfilter

		DECLARE @errMsg VARCHAR(1024)
		SET @errMsg = ERROR_MESSAGE()
		
		RAISERROR(@errMsg, 16, 1)
	END CATCH
END
GO

GRANT EXECUTE ON [dbo].[Exchange2013_Report_MailboxStatsTopReportDataGet] TO OpsMgrReader
GO
