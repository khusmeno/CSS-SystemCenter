IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_DB_Version' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version (
		[CurrentVersion] [int] NOT NULL,
	) ON [PRIMARY]')
	
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_DB_Version TO OpsMgrReader
GO

IF NOT EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version)
BEGIN
	INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_DB_Version VALUES(7)
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_UpdateTablesList' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_UpdateTablesList AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetInstanceViewData' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetInstanceViewData AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_UpdateLastValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_UpdateLastValues AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetResolvedGUIDs' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetResolvedGUIDs AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastPerfValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues (
		[ManagedEntityRowId] [int] NOT NULL,
		[PerformanceRuleInstanceRowId] [int] NOT NULL,
		[DateTime] [DateTime] NOT NULL,
		[SampleValue] [float] NULL,
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_LastPerfValues] PRIMARY KEY CLUSTERED (
			[ManagedEntityRowId] ASC, [PerformanceRuleInstanceRowId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]')
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastPerfValues] TO OpsMgrReader
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastMonitorValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues (
		[ManagedEntityRowId] [int] NOT NULL,
		[MonitorRowId] [int] NOT NULL,
		[DateTime] [DateTime] NOT NULL,
		[HealthState] [tinyint] NULL,
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_LastMonitorValues] PRIMARY KEY CLUSTERED (
			[ManagedEntityRowId] ASC, [MonitorRowId] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]')
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastMonitorValues] TO OpsMgrReader
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastAlertValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues (
		[AlertGuid] [uniqueidentifier] NOT NULL,
		[ManagedEntityRowId] [int] NOT NULL,
		[DateTime] [DateTime] NOT NULL,
		[Severity] [tinyint] NOT NULL,
		[ResolutionState] [tinyint] NULL,
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_LastAlertValues] PRIMARY KEY CLUSTERED (
			[AlertGuid] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]')

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX IX_Microsoft_SQLServer_Visualization_Library_LastAlertValues_ManagedEntityRowId_ResolutionState
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastAlertValues] ([ManagedEntityRowId],[ResolutionState])
	')
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastAlertValues] TO OpsMgrReader
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Tables' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_Tables (
		[TableId] [bigint] IDENTITY(1,1) NOT NULL,
		[Name] [sysname] NOT NULL,
		[Type] [tinyint] NOT NULL,
		[LastProcessedId] [bigint] NOT NULL,
		[FirstDate] [DateTime] NOT NULL,
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_PerfTables] PRIMARY KEY CLUSTERED (
			[TableId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]')
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_Tables TO OpsMgrReader
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Table_Batches' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches (
		[BatchId] [bigint] IDENTITY(1,1) NOT NULL,
		[TableId] [bigint]  NOT NULL,
		[FirstId] [bigint] NOT NULL,
		[LastId] [bigint] NOT NULL,
		[CreateDate] [DateTime] NOT NULL,
		[StartDate] [DateTime] NULL,
		[FinishDate] [DateTime] NULL,
		[Tries] [int] NOT NULL,
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_Table_Batches] PRIMARY KEY CLUSTERED (
			[BatchId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]')
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_Table_Batches TO OpsMgrReader
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetGroups' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetGroups AS RETURN 1')
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetClasses' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetClasses AS RETURN 1')
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetGroupClassMetadata' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetGroupClassMetadata AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_UpdateHierarchy' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_UpdateHierarchy AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_RethrowError' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE ('CREATE PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_RethrowError AS RETURN 1')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy (
		[Parent] [int] NOT NULL,
		[Child] [int] NOT NULL
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy] PRIMARY KEY CLUSTERED (
			[Parent] ASC, [Child] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]');

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX [IX_Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy_Child]
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy] ([Child], [Parent])
	');
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy TO OpsMgrReader
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy (
		[IsGroup] [int] NOT NULL,
		[RelationshipManagementPackRowId] [int] NOT NULL,
		[Parent] [int] NOT NULL,
		[Child] [int] NOT NULL
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy] PRIMARY KEY CLUSTERED (
			[IsGroup] ASC, [RelationshipManagementPackRowId] ASC, [Parent] ASC, [Child] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]');

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX IX_Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy_Parent
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy] ([Parent], [Child])
	')

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX [IX_Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy_Child]
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy] ([Child], [Parent])
	')
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy TO OpsMgrReader
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_OpsManagerSettings' AND UID = SCHEMA_ID('sdk'))
BEGIN
    EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings (
		[ManagementGroupGuid] [uniqueidentifier] NOT NULL,
		[Name] nvarchar(50) NOT NULL,
		[Value] [int] NULL
	) ON [PRIMARY]');
END
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_OpsManagerSettings TO OpsMgrReader
GO

-- UPDATE script. 
IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 1)
BEGIN
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 1
END
GO

-- UPDATE script. 
IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 2)
BEGIN
	EXECUTE (N'DROP INDEX [<Name of Missing Index, sysname,>] ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastMonitorValues]');

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX IX_Microsoft_SQLServer_Visualization_Library_LastMonitorValues_ManagedEntityRowId_MonitorRowId
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastMonitorValues] ([ManagedEntityRowId],[MonitorRowId])
		INCLUDE ([LastMonitorValueId],[DateTime],[ManagedEntityMonitorRowId],[HealthState])
	')

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX IX_Microsoft_SQLServer_Visualization_Library_LastMonitorValues_ManagedEntityMonitorRowId
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastMonitorValues] ([ManagedEntityMonitorRowId])
		INCLUDE ([LastMonitorValueId],[DateTime],[HealthState])
	')

	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 2
END
GO

IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 3)
BEGIN
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables;
	ALTER TABLE sdk.Microsoft_SQLServer_Visualization_Library_Tables ADD [FirstDate] [DateTime] NOT NULL
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 3
END
GO

IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 4)
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetTablesList' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetTablesList');
	END

	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 4
END
GO

IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 5)
BEGIN

	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetTablesList' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetTablesList');
	END

	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy');
	END

	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy');
	END

	EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy (
		[IsGroup] [int] NOT NULL,
		[RelationshipManagementPackRowId] [int] NOT NULL,
		[Parent] [int] NOT NULL,
		[Child] [int] NOT NULL
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy] PRIMARY KEY CLUSTERED (
			[IsGroup] ASC, [RelationshipManagementPackRowId] ASC, [Parent] ASC, [Child] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]');

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX IX_Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy_Parent
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy] ([Parent], [IsGroup], [Child])
	');

	EXECUTE (N'
		CREATE NONCLUSTERED INDEX [IX_Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy_Child]
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy] ([Child], [IsGroup], [Parent])
	');

	EXECUTE (N'GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy TO OpsMgrReader')

	EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy (
		[Parent] [int] NOT NULL,
		[Child] [int] NOT NULL
		CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy] PRIMARY KEY CLUSTERED (
			[Parent] ASC, [Child] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]');
	
	EXECUTE (N'
		CREATE NONCLUSTERED INDEX [IX_Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy_Child]
		ON [sdk].[Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy] ([Child], [Parent])
	');

	EXECUTE (N'GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy TO OpsMgrReader');

	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables;
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches;

	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 5
END
GO

IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 6)
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastPerfValues' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues');
	END

	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastMonitorValues' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues');
	END

	IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastAlertValues' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues');
	END

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastPerfValues' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues (
			[ManagedEntityRowId] [int] NOT NULL,
			[PerformanceRuleInstanceRowId] [int] NOT NULL,
			[DateTime] [DateTime] NOT NULL,
			[SampleValue] [float] NULL,
			CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_LastPerfValues] PRIMARY KEY CLUSTERED (
				[ManagedEntityRowId] ASC, [PerformanceRuleInstanceRowId] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]')
	END
	EXECUTE (N'GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastPerfValues] TO OpsMgrReader')

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastMonitorValues' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues (
			[ManagedEntityRowId] [int] NOT NULL,
			[MonitorRowId] [int] NOT NULL,
			[DateTime] [DateTime] NOT NULL,
			[HealthState] [tinyint] NULL,
			CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_LastMonitorValues] PRIMARY KEY CLUSTERED (
				[ManagedEntityRowId] ASC, [MonitorRowId] ASC
			) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]')
	END
	EXECUTE (N'GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastMonitorValues] TO OpsMgrReader')

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastAlertValues' AND UID = SCHEMA_ID('sdk'))
	BEGIN
		EXECUTE (N'CREATE TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues (
			[AlertGuid] [uniqueidentifier] NOT NULL,
			[ManagedEntityRowId] [int] NOT NULL,
			[DateTime] [DateTime] NOT NULL,
			[Severity] [tinyint] NOT NULL,
			[ResolutionState] [tinyint] NULL,
			CONSTRAINT [PK_Microsoft_SQLServer_Visualization_Library_LastAlertValues] PRIMARY KEY CLUSTERED (
				[AlertGuid] ASC
			) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]')

		EXECUTE (N'
			CREATE NONCLUSTERED INDEX IX_Microsoft_SQLServer_Visualization_Library_LastAlertValues_ManagedEntityRowId_ResolutionState
			ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastAlertValues] ([ManagedEntityRowId],[ResolutionState])
		')
	END
	EXECUTE (N'GRANT SELECT, INSERT, UPDATE, DELETE ON [sdk].[Microsoft_SQLServer_Visualization_Library_LastAlertValues] TO OpsMgrReader')


	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables;
	DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches;

	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 6
END
GO

IF EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_DB_Version WHERE CurrentVersion < 7)
BEGIN
	UPDATE tb
	SET  StartDate = NULL , FinishDate = NULL
	FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches tb
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON t.TableId = tb.TableId
	WHERE t.[Type] IN (5,6);
	
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version SET CurrentVersion = 7;
END
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_GetGroupClassMetadata]
(
	@LANGUAGE_CODE varchar(10),
	@MANAGEMENT_GROUP_GUID uniqueidentifier,
	@XML_DATA XML
)
AS
BEGIN

DECLARE @ManagementGroupRowId int;
SELECT @ManagementGroupRowId = mg.ManagementGroupRowId FROM dbo.vManagementGroup mg WHERE mg.ManagementGroupGuid = @MANAGEMENT_GROUP_GUID

DECLARE @GROUP_GUID uniqueidentifier, @GROUP_ID nvarchar(2000);

SELECT TOP 1 @GROUP_GUID = ParamValues.x.value('@Id','uniqueidentifier'), @GROUP_ID = ParamValues.x.value('@InstanceId','nvarchar(2000)') FROM @XML_DATA.nodes('/DatacenterGroupPerformanceRulesQuery/DatacenterGroup') AS ParamValues(x)

DECLARE @GroupRowId int;
IF @GROUP_GUID is not null 
	SELECT @GroupRowId = me.ManagedEntityRowId 
	FROM dbo.vManagedEntity me WITH (NOLOCK) 
	WHERE me.ManagedEntityGuid = @GROUP_GUID;
ELSE 
	SELECT @GroupRowId = me.ManagedEntityRowId 
	FROM dbo.vManagedEntity me WITH (NOLOCK)
	INNER JOIN dbo.[ManagedEntityType] mt WITH (NOLOCK) 
		ON LOWER(SUBSTRING(@GROUP_ID, CHARINDEX('!', @GROUP_ID) + 1, 2000)) = LOWER(mt.ManagedEntityTypeSystemName)
		AND me.ManagedEntityTypeRowId = mt.ManagedEntityTypeRowId
	INNER JOIN dbo.[ManagementPack] mp WITH (NOLOCK) 
		ON mp.ManagementPackRowId = mt.ManagementPackRowId AND LOWER(SUBSTRING(@GROUP_ID, 1, CHARINDEX('!', @GROUP_ID) - 1)) = LOWER(mp.ManagementPackSystemName);

DECLARE @LatestMpVersions TABLE (
	ManagementPackRowId int NOT NULL,
	ManagementPackVersionRowId int NOT NULL
	UNIQUE CLUSTERED (ManagementPackVersionRowId, ManagementPackRowId)
);

INSERT INTO @LatestMpVersions 
SELECT mpv2.ManagementPackRowId, max(mpv2.ManagementPackVersionRowId) AS ManagementPackVersionRowId
FROM dbo.vManagementPackVersion mpv2 (NOLOCK)
INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv (NOLOCK) ON mgmpv.ManagementPackVersionRowId = mgmpv.ManagementPackVersionRowId
WHERE mgmpv.DeletedDateTime IS NULL
group by mpv2.ManagementPackRowId
order by ManagementPackVersionRowId, ManagementPackRowId;

CREATE TABLE #FilteredRT (
	RelationshipTypeRowId int PRIMARY KEY
);

; WITH parentRT AS (
	SELECT TOP 1 rt.RelationshipTypeRowId
		FROM dbo.vRelationshipType rt WITH (NOLOCK)
		WHERE rt.RelationshipTypeSystemName = 'System.Containment'			
),
			
FilteredRT AS (
	SELECT RelationshipTypeRowId 
		FROM parentRT
	UNION ALL
	SELECT rth.Child AS RelationshipTypeRowId
		FROM parentRT rt WITH (NOLOCK)
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy rth WITH (NOLOCK) ON rt.RelationshipTypeRowId = rth.Parent
)

INSERT INTO #FilteredRT
SELECT * FROM FilteredRT;

CREATE TABLE #groupClasses (
  ManagedEntityTypeRowId int
)

; WITH configuredClasses AS (
	SELECT ParamValues.x.value('@Id','nvarchar(2000)') AS Id
	FROM @XML_DATA.nodes('/DatacenterGroupPerformanceRulesQuery/DatacenterGroup/ClassType') AS ParamValues(x)
),
classes AS (
SELECT mt.ManagedEntityTypeRowId
FROM configuredClasses cc
INNER JOIN dbo.[ManagedEntityType] mt WITH (NOLOCK) 
	ON LOWER(SUBSTRING(cc.Id, CHARINDEX('!', cc.Id) + 1, 2000)) = LOWER(mt.ManagedEntityTypeSystemName)
INNER JOIN dbo.[ManagementPack] mp WITH (NOLOCK) 
	ON mp.ManagementPackRowId = mt.ManagementPackRowId AND LOWER(SUBSTRING(cc.Id, 1, CHARINDEX('!', cc.Id) - 1)) = LOWER(mp.ManagementPackSystemName)
INNER JOIN @LatestMpVersions lmv ON lmv.ManagementPackRowId = mp.ManagementPackRowId
WHERE CHARINDEX('!', cc.Id) > 0
),
DerivedTree (RowId,Abstract, Level) AS (
  SELECT c.ManagedEntityTypeRowId as RowId, mev.AbstractInd as Abstract, 0 as Level 
  FROM classes c 
  INNER JOIN dbo.vManagedEntityTypeManagementPackVersion mev WITH (NOLOCK) ON (c.ManagedEntityTypeRowId = mev.ManagedEntityTypeRowId)
  INNER JOIN dbo.vManagementPackVersion mpv WITH (NOLOCK) ON mev.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
  INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) ON (mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId AND  mgmpv.DeletedDateTime IS NULL)  
  WHERE mgmpv.ManagementGroupRowId = @ManagementGroupRowId  
UNION ALL
  SELECT mev.ManagedEntityTypeRowId as RowId, mev.AbstractInd as Abstract,dt.Level +1 as Level
  FROM dbo.vManagedEntityTypeManagementPackVersion mev WITH (NOLOCK)
  INNER JOIN dbo.vManagementPackVersion mpv WITH (NOLOCK) ON mev.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
  INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) ON (mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId AND  mgmpv.DeletedDateTime IS NULL)
  INNER JOIN DerivedTree dt ON (dt.RowId = mev.BaseManagedEntityTypeRowId And dt.Abstract = 1)  
  WHERE dt.Level < 31 AND mgmpv.ManagementGroupRowId = @ManagementGroupRowId
)
INSERT INTO #groupClasses
SELECT dt.RowId FROM DerivedTree dt
WHERE Abstract = 0

DECLARE @head_me TABLE (
	ManagedEntityRowId int NOT NULL,
	[Level] int NOT NULL,
	UNIQUE CLUSTERED (ManagedEntityRowId, [Level])
);

;WITH data_seed AS (
SELECT TOP 1 me.ManagedEntityRowId, 0 AS [Level] 
FROM dbo.vManagedEntity me WITH (NOLOCK)
INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) ON me.ManagedEntityRowId = memg.ManagedEntityRowId
WHERE me.ManagedEntityRowId = @GroupRowId and memg.ToDateTime is null
UNION ALL
SELECT DISTINCT tme.ManagedEntityRowId, 1 AS [Level] 
FROM dbo.vTypedManagedEntity tme WITH (NOLOCK) 
INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) ON tme.ManagedEntityRowId = memg.ManagedEntityRowId
INNER JOIN #groupClasses cc ON tme.ManagedEntityTypeRowId = cc.ManagedEntityTypeRowId
WHERE memg.ToDateTime is null
)

INSERT INTO @head_me
SELECT * FROM data_seed;

DECLARE @seed TABLE (
	ManagedEntityRowId int NOT NULL,
	ManagedEntityTypeRowId int NOT NULL,
	[Level] int NOT NULL
	UNIQUE CLUSTERED (ManagedEntityRowId, ManagedEntityTypeRowId, [Level])
);

;WITH data AS (
SELECT * from @head_me
UNION ALL
SELECT 
	rhg.Child AS ManagedEntityRowId,
	s.Level + CASE WHEN s.Level = 2 THEN 0 ELSE 1 END AS [Level]
FROM data s
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.ManagedEntityRowId = rhg.Parent
),

updated_data AS (
	SELECT DISTINCT d.ManagedEntityRowId, vme.ManagedEntityTypeRowId, d.Level
	FROM data d
	INNER JOIN dbo.vManagedEntity vme WITH (NOLOCK) ON d.ManagedEntityRowId = vme.ManagedEntityRowId
	INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) ON vme.ManagedEntityRowId = memg.ManagedEntityRowId
	WHERE memg.ToDateTime is NULL AND d.Level > 0 
)

INSERT INTO @seed
SELECT * FROM updated_data
order by ManagedEntityRowId, ManagedEntityTypeRowId, Level;

INSERT INTO @seed
SELECT DISTINCT -1 AS ManagedEntityRowId, rtmpv.TargetManagedEntityTypeRowId AS ManagedEntityTypeRowId, hm.[Level] + 1 AS [Level] 
FROM @head_me hm
INNER JOIN dbo.vManagedEntity me on hm.ManagedEntityRowId = me.ManagedEntityRowId
INNER JOIN dbo.vRelationshipTypeManagementPackVersion rtmpv WITH (NOLOCK) ON rtmpv.SourceManagedEntityTypeRowId = me.ManagedEntityTypeRowId 
INNER JOIN vManagementPackVersion mpv WITH (NOLOCK) ON rtmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
WHERE EXISTS (SELECT NULL FROM @LatestMpVersions lm WHERE rtmpv.ManagementPackVersionRowId = lm.ManagementPackVersionRowId AND mpv.ManagementPackRowId = lm.ManagementPackRowId)
  AND EXISTS (SELECT NULL FROM #FilteredRT frt WHERE frt.RelationshipTypeRowId = rtmpv.RelationshipTypeRowId) ;

; WITH seed AS (
SELECT s.Level, s.ManagedEntityRowId, t.TypedManagedEntityRowId, t.ManagedEntityTypeRowId AS TypedManagedEntityTypeRowId, s.ManagedEntityTypeRowId AS ManagedEntityTypeRowId FROM @seed s
left JOIN dbo.TypedManagedEntity t (NOLOCK) ON s.ManagedEntityRowId = t.ManagedEntityRowId
),

 typeIds AS (
SELECT DISTINCT TypedManagedEntityTypeRowId AS TypeRowId FROM seed 
),

depthToAbstractRaw AS (
SELECT TypeRowId, TypeRowId AS currentTypeRowId, 0 AS depth FROM typeIds
UNION ALL
SELECT TypeRowId, t.BaseManagedEntityTypeRowId, d.depth + 1 AS depth FROM depthToAbstractRaw d
INNER JOIN vManagedEntityTypeManagementPackVersion t (NOLOCK) ON d.currentTypeRowId = t.ManagedEntityTypeRowId
INNER JOIN vManagementPackVersion mpv WITH (NOLOCK) ON t.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
WHERE t.AbstractInd = 0 
  AND EXISTS (SELECT NULL FROM @LatestMpVersions lm WHERE t.ManagementPackVersionRowId = lm.ManagementPackVersionRowId AND mpv.ManagementPackRowId = lm.ManagementPackRowId)
),

depthToAbstract AS (
SELECT TypeRowId, max(depth) AS depth FROM depthToAbstractRaw group by TypeRowId
),

seedWithDepth AS (
SELECT s.Level, s.ManagedEntityRowId, s.ManagedEntityTypeRowId, s.TypedManagedEntityRowId, s.TypedManagedEntityTypeRowId, d.depth FROM seed s
left JOIN depthToAbstract d ON s.TypedManagedEntityTypeRowId = d.TypeRowId
),

updatedSeed AS (
SELECT s1.Level, s1.ManagedEntityRowId, COALESCE(t.TypedManagedEntityTypeRowId, s1.ManagedEntityTypeRowId) AS ManagedEntityTypeRowId FROM @seed s1
CROSS APPLY (
	SELECT TOP 1 s2.TypedManagedEntityTypeRowId 
	FROM seedWithDepth s2 
	WHERE s2.ManagedEntityRowId = s1.ManagedEntityRowId 
	order by s2.depth desc, s2.TypedManagedEntityRowId desc
  ) t
WHERE s1.ManagedEntityRowId >= 0
)

UPDATE @seed
SET ManagedEntityTypeRowId = U.ManagedEntityTypeRowId
FROM @seed s 
INNER JOIN updatedSeed U ON s.Level = U.Level AND s.ManagedEntityRowId = U.ManagedEntityRowId
 
 DECLARE @classes TABLE (
	ClassName nvarchar(2000),
	DisplayName nvarchar(2000),
	ManagedEntityTypeRowId int,
	[Level] int
);

; WITH filteredTypes AS (
SELECT ManagedEntityTypeRowId, MIN([Level]) AS [Level] FROM @seed group by ManagedEntityTypeRowId
)

INSERT INTO @classes
SELECT 
	mpGroup.ManagementPackSystemName + '!' + metGroup.ManagedEntityTypeSystemName AS ClassName,
	COALESCE(ds.Name, metGroup.ManagedEntityTypeDefaultName) AS DisplayName,
	ft.ManagedEntityTypeRowId,
	ft.[Level]
FROM filteredTypes ft
INNER JOIN dbo.vManagedEntityType metGroup WITH (NOLOCK) ON ft.ManagedEntityTypeRowId = metGroup.ManagedEntityTypeRowId
INNER JOIN dbo.vManagementPack mpGroup WITH (NOLOCK) ON metGroup.ManagementPackRowId = mpGroup.ManagementPackRowId
left JOIN dbo.vDisplayString ds WITH (NOLOCK) ON metGroup.ManagedEntityTypeGuid = ds.ElementGuid AND ds.LanguageCode = @LANGUAGE_CODE

DECLARE @ClassMapping TABLE (
	GroupTypeRowId int,
	ManagedEntityTypeRowId int
	UNIQUE CLUSTERED (GroupTypeRowId, ManagedEntityTypeRowId)
);

;WITH fullTypeSpectre AS
(
SELECT DISTINCT
s.ManagedEntityTypeRowId AS GroupTypeRowId,
COALESCE(tme.ManagedEntityTypeRowId,s.ManagedEntityTypeRowId) AS ManagedEntityTypeRowId 
FROM dbo.vTypedManagedEntity tme WITH (NOLOCK)
right JOIN @seed s ON tme.ManagedEntityRowId = s.ManagedEntityRowId
UNION ALL
SELECT fts.GroupTypeRowId, metmpv.BaseManagedEntityTypeRowId FROM fullTypeSpectre fts
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion metmpv WITH (NOLOCK) ON fts.ManagedEntityTypeRowId = metmpv.ManagedEntityTypeRowId
INNER JOIN vManagementPackVersion mpv WITH (NOLOCK) ON metmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
WHERE EXISTS (SELECT NULL FROM @LatestMpVersions lm WHERE metmpv.ManagementPackVersionRowId = lm.ManagementPackVersionRowId AND mpv.ManagementPackRowId = lm.ManagementPackRowId)
)

INSERT INTO @ClassMapping
SELECT DISTINCT GroupTypeRowId, ManagedEntityTypeRowId 
FROM fullTypeSpectre
order by GroupTypeRowId, ManagedEntityTypeRowId;

--SELECT * FROM @ClassMapping

DECLARE @Monitors TABLE (
	GroupTypeRowId int,
	"Item!4!MpSystemName" nvarchar(256),
	"Item!4!MonitorSystemName" nvarchar(256),
	"Item!4!MonitorDefaultName" nvarchar(1000),
	"Item!4!MonitorName" nvarchar(1000)
);

INSERT INTO @Monitors
SELECT 
	cm.GroupTypeRowId AS GroupTypeRowId,
	mp.ManagementPackSystemName AS "Item!4!MpSystemName",
	m.MonitorSystemName AS "Item!4!MonitorSystemName",
	m.MonitorDefaultName AS "Item!4!MonitorDefaultName",
	ds.Name AS "Item!4!MonitorName"
FROM @ClassMapping cm 
	JOIN dbo.vMonitorManagementPackVersion mmpv  WITH (NOLOCK) ON cm.ManagedEntityTypeRowId = mmpv.TargetManagedEntityTypeRowId
	JOIN dbo.vMonitor m  WITH (NOLOCK) ON m.MonitorRowId = mmpv.MonitorRowId
	INNER JOIN vManagementPackVersion mpv WITH (NOLOCK) ON mmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
	JOIN @LatestMpVersions lmv  ON lmv.ManagementPackVersionRowId = mmpv.ManagementPackVersionRowId AND lmv.ManagementPackRowId = mpv.ManagementPackRowId
	JOIN dbo.vManagementPack mp WITH (NOLOCK) ON mp.ManagementPackRowId = lmv.ManagementPackRowId
	left JOIN dbo.vDisplayString ds  WITH (NOLOCK) ON ds.ElementGuid = m.MonitorGuid AND ds.LanguageCode = @LANGUAGE_CODE


DECLARE @Rules TABLE (
	GroupTypeRowId int,
	"Item!5!MpSystemName" nvarchar(256),
	"Item!5!RuleSystemName" nvarchar(256),
	"Item!5!RuleDefaultName" nvarchar(1000),
	"Item!5!RuleName" nvarchar(1000)
);

INSERT INTO @Rules
SELECT 
	cm.GroupTypeRowId AS GroupTypeRowId,
	mp.ManagementPackSystemName AS "Item!5!MpSystemName",
	r.RuleSystemName AS "Item!5!RuleSystemName",
	r.RuleDefaultName AS "Item!5!RuleDefaultName",
	ds.Name AS "Item!5!RuleName"
FROM @ClassMapping cm 
	JOIN dbo.vRuleManagementPackVersion rmpv  WITH (NOLOCK) ON cm.ManagedEntityTypeRowId = rmpv.TargetManagedEntityTypeRowId
	JOIN dbo.vWorkflowCategory wc WITH (NOLOCK) ON rmpv.WorkflowCategoryRowId = wc.WorkflowCategoryRowId
	JOIN dbo.vRule r  WITH (NOLOCK) ON r.RuleRowId = rmpv.RuleRowId
	INNER JOIN vManagementPackVersion mpv WITH (NOLOCK) ON rmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
	JOIN @LatestMpVersions lmv ON lmv.ManagementPackVersionRowId = rmpv.ManagementPackVersionRowId AND lmv.ManagementPackRowId = mpv.ManagementPackRowId
	JOIN dbo.vManagementPack mp WITH (NOLOCK) ON mp.ManagementPackRowId = lmv.ManagementPackRowId
	left JOIN dbo.vDisplayString ds WITH (NOLOCK) ON ds.ElementGuid = r.RuleGuid AND ds.LanguageCode = @LANGUAGE_CODE
WHERE wc.WorkflowCategorySystemName = 'PerformanceCollection'

SELECT 
	999 AS TAG, 
	NULL AS Parent, 
	'' AS [ArrayOfMetadata!999],
	NULL AS [Metadata!1!Level],
	NULL AS [Metadata!1!ClassName],
	NULL AS [Metadata!1!DisplayName],
	NULL AS [Monitors!2],
	NULL AS [Rules!3],
	NULL AS "Item!4!MpSystemName",
	NULL AS "Item!4!MonitorSystemName",
	NULL AS "Item!4!MonitorDefaultName",
	NULL AS "Item!4!MonitorName",
	NULL AS "Item!5!MpSystemName",
	NULL AS "Item!5!RuleSystemName",
	NULL AS "Item!5!RuleDefaultName",
	NULL AS "Item!5!RuleName"
UNION ALL
SELECT 
	1 AS TAG, 
	999 AS Parent, 
	'' AS [ArrayOfMetadata!999],
	c.[Level] AS [Metadata!1!Level],
	c.ClassName AS [Metadata!1!ClassName],
	c.DisplayName AS [Metadata!1!DisplayName],
	NULL AS [Monitors!2],
	NULL AS [Rules!3],
	NULL AS "Item!4!MpSystemName",
	NULL AS "Item!4!MonitorSystemName",
	NULL AS "Item!4!MonitorDefaultName",
	NULL AS "Item!4!MonitorName",
	NULL AS "Item!5!MpSystemName",
	NULL AS "Item!5!RuleSystemName",
	NULL AS "Item!5!RuleDefaultName",
	NULL AS "Item!5!RuleName"
FROM @classes c
UNION ALL
SELECT 
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfMetadata!999],
	c.[Level] AS [Metadata!1!Level],
	c.ClassName AS [Metadata!1!ClassName],
	c.DisplayName AS [Metadata!1!DisplayName],
	'' AS [Monitors!2],
	NULL AS [Rules!3],
	NULL AS "Item!4!MpSystemName",
	NULL AS "Item!4!MonitorSystemName",
	NULL AS "Item!4!MonitorDefaultName",
	NULL AS "Item!4!MonitorName",
	NULL AS "Item!5!MpSystemName",
	NULL AS "Item!5!RuleSystemName",
	NULL AS "Item!5!RuleDefaultName",
	NULL AS "Item!5!RuleName"
FROM @classes c
UNION ALL
SELECT 
	4 AS TAG, 
	2 AS Parent, 
	'' AS [ArrayOfMetadata!999],
	c.[Level] AS [Metadata!1!Level],
	c.ClassName AS [Metadata!1!ClassName],
	c.DisplayName AS [Metadata!1!DisplayName],
	'' AS [Monitors!2],
	NULL AS [Rules!3],
	m.[Item!4!MpSystemName] AS "Item!4!MpSystemName",
	m.[Item!4!MonitorSystemName] AS "Item!4!MonitorSystemName",
	m.[Item!4!MonitorDefaultName] AS "Item!4!MonitorDefaultName",
	m.[Item!4!MonitorName] AS "Item!4!MonitorName",
	NULL AS "Item!5!MpSystemName",
	NULL AS "Item!5!RuleSystemName",
	NULL AS "Item!5!RuleDefaultName",
	NULL AS "Item!5!RuleName"
FROM @classes c
INNER JOIN @Monitors m ON c.ManagedEntityTypeRowId = m.GroupTypeRowId
UNION ALL
SELECT 
	3 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfMetadata!999],
	c.[Level] AS [Metadata!1!Level],
	c.ClassName AS [Metadata!1!ClassName],
	c.DisplayName AS [Metadata!1!DisplayName],
	NULL AS [Monitors!2],
	'' AS [Rules!3],
	NULL AS "Item!4!MpSystemName",
	NULL AS "Item!4!MonitorSystemName",
	NULL AS "Item!4!MonitorDefaultName",
	NULL AS "Item!4!MonitorName",
	NULL AS "Item!5!MpSystemName",
	NULL AS "Item!5!RuleSystemName",
	NULL AS "Item!5!RuleDefaultName",
	NULL AS "Item!5!RuleName"
FROM @classes c
UNION ALL
SELECT 
	5 AS TAG, 
	3 AS Parent, 
	'' AS [ArrayOfMetadata!999],
	c.[Level] AS [Metadata!1!Level],
	c.ClassName AS [Metadata!1!ClassName],
	c.DisplayName AS [Metadata!1!DisplayName],
	NULL AS [Monitors!2],
	'' AS [Rules!3],
	NULL AS "Item!4!MpSystemName",
	NULL AS "Item!4!MonitorSystemName",
	NULL AS "Item!4!MonitorDefaultName",
	NULL AS "Item!4!MonitorName",
	r.[Item!5!MpSystemName] AS "Item!5!MpSystemName",
	r.[Item!5!RuleSystemName] AS "Item!5!RuleSystemName",
	r.[Item!5!RuleDefaultName] AS "Item!5!RuleDefaultName",
	r.[Item!5!RuleName] AS "Item!5!RuleName"
FROM @classes c
INNER JOIN @Rules r ON c.ManagedEntityTypeRowId = r.GroupTypeRowId
order by [ArrayOfMetadata!999], 
		 [Metadata!1!Level],
		 [Metadata!1!ClassName],
		 [Metadata!1!DisplayName],
		 [Monitors!2],
		 [Item!4!MonitorName],
		 [Item!4!MonitorDefaultName],
		 [Item!4!MonitorSystemName],
		 [Rules!3],
		 [Item!5!RuleName],
		 [Item!5!RuleDefaultName],
		 [Item!5!RuleSystemName]
FOR XML EXPLICIT
END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_GetGroupClassMetadata] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_GetGroups]
(
	@LANGUAGE_CODE nvarchar(max),
	@MANAGEMENT_GROUP_GUID uniqueidentifier,
	@XML_DATA XML
)
AS
BEGIN

DECLARE @ManagementGroupRowId int;
SELECT @ManagementGroupRowId = mg.ManagementGroupRowId
FROM  dbo.vManagementGroup mg WITH (NOLOCK) 
WHERE mg.ManagementGroupGuid = @MANAGEMENT_GROUP_GUID;

DECLARE @allowedGroups TABLE (
	Id int PRIMARY KEY
);

;WITH allowedGroups AS (
	SELECT DISTINCT ParamValues.x.value('@ID','uniqueidentifier') AS [Guid] FROM @XML_DATA.nodes('/OpsManagerConfiguration/AllowedGroup') AS ParamValues(x)
)

INSERT INTO @allowedGroups
SELECT me.ManagedEntityRowId FROM allowedGroups a
INNER JOIN dbo.ManagedEntity me WITH (NOLOCK) ON a.[Guid] = me.ManagedEntityGuid
INNER JOIN dbo.ManagedEntityManagementGroup memg WITH (NOLOCK) ON me.ManagedEntityRowId = memg.ManagedEntityRowId
WHERE me.ManagementGroupRowId = @ManagementGroupRowId
  AND memg.ToDateTime is NULL;


;WITH libraryMp AS (
SELECT ManagementPackRowId 
FROM dbo.vManagementPack (NOLOCK)
WHERE ManagementPackSystemName = 'System.Library'
),

latestMpVersion AS
(SELECT mpv2.ManagementPackRowId, max(ManagementPackVersionRowId) AS ManagementPackVersionRowId
FROM dbo.vManagementPackVersion mpv2 (NOLOCK) 
group by mpv2.ManagementPackRowId),

met AS (
SELECT vmet.ManagedEntityTypeRowId, vmet.ManagedEntityTypeGuid, vmet.ManagedEntityTypeSystemName, mp.ManagementPackSystemName
FROM dbo.vManagedEntityType vmet (NOLOCK)
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion vmetmpv (NOLOCK) ON vmet.ManagedEntityTypeRowId = vmetmpv.ManagedEntityTypeRowId
INNER JOIN latestMpVersion ON latestMpVersion.ManagementPackVersionRowId = vmetmpv.ManagementPackVersionRowId
INNER JOIN libraryMp ON latestMpVersion.ManagementPackRowId = libraryMp.ManagementPackRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON latestMpVersion.ManagementPackRowId = mp.ManagementPackRowId
WHERE vmet.ManagedEntityTypeSystemName = 'System.Group' 
UNION ALL
SELECT vmet.ManagedEntityTypeRowId, vmet.ManagedEntityTypeGuid, vmet.ManagedEntityTypeSystemName, mp.ManagementPackSystemName
FROM dbo.vManagedEntityType vmet (NOLOCK)
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion vmetmpv (NOLOCK) ON vmet.ManagedEntityTypeRowId = vmetmpv.ManagedEntityTypeRowId
INNER JOIN latestMpVersion ON latestMpVersion.ManagementPackVersionRowId = vmetmpv.ManagementPackVersionRowId
INNER JOIN met ON met.ManagedEntityTypeRowId = vmetmpv.BaseManagedEntityTypeRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON latestMpVersion.ManagementPackRowId = mp.ManagementPackRowId
WHERE vmetmpv.Accessibility = 'Public'
),

loc AS (
SELECT 
	met.ManagedEntityTypeGuid, 
	met.ManagedEntityTypeSystemName,
	met.ManagementPackSystemName,
	vme.ManagedEntityGuid, 
	CASE 
		WHEN met.ManagedEntityTypeGuid != vme.ManagedEntityGuid 
		THEN REPLACE(REPLACE(REPLACE(vme.FullName, ';'+vme.DisplayName, ''), ':'+vme.DisplayName, ''), met.ManagedEntityTypeSystemName, vme.DisplayName) 
		ELSE COALESCE(vds_loc.Name, vds.Name, met.ManagedEntityTypeSystemName) 
	END AS DisplayName
FROM met 
INNER JOIN dbo.vManagedEntity vme (NOLOCK) ON vme.ManagedEntityTypeRowId = met.ManagedEntityTypeRowId
INNER JOIN @allowedGroups ag ON vme.ManagedEntityRowId = ag.Id
INNER JOIN dbo.vManagedEntityManagementGroup vmemg (NOLOCK) ON vme.ManagedEntityRowId = vmemg.ManagedEntityRowId
left JOIN dbo.vDisplayString vds (NOLOCK) ON met.ManagedEntityTypeGuid = vds.ElementGuid AND vds.LanguageCode = 'ENU'
left JOIN dbo.vDisplayString vds_loc (NOLOCK) ON met.ManagedEntityTypeGuid = vds_loc.ElementGuid AND vds_loc.LanguageCode = @LANGUAGE_CODE
WHERE vmemg.ToDateTime is NULL AND vme.ManagementGroupRowId = @ManagementGroupRowId
)

SELECT 
	999 AS TAG, 
	NULL AS Parent, 
	'' AS [GroupsListDataSourceResult!999],
	NULL AS [Group!1!Id],
	NULL AS [Group!1!Guid],
	NULL AS [Group!1!DisplayName],
	NULL AS [Group!1!IsSingletone]
UNION ALL
SELECT 
	1 AS TAG, 
	999 AS Parent, 
	'' AS [GroupsListDataSourceResult!999],
	loc.ManagementPackSystemName + '!' + loc.ManagedEntityTypeSystemName AS [Group!1!Id],
	loc.ManagedEntityGuid AS [Group!1!Guid],
	loc.DisplayName AS [Group!1!DisplayName],
	CASE WHEN loc.ManagedEntityGuid = loc.ManagedEntityTypeGuid THEN 1 ELSE 0 END AS [Group!1!IsSingletone]
FROM loc
order by [GroupsListDataSourceResult!999], [Group!1!DisplayName]
FOR XML EXPLICIT

END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_GetGroups] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_GetClasses]
(
	@LANGUAGE_CODE nvarchar(max),
	@MANAGEMENT_GROUP_GUID uniqueidentifier
)
AS
BEGIN

;WITH latestMpVersion AS
(SELECT mpv2.ManagementPackRowId, mpv2.ManagementPackVersionRowId as ManagementPackVersionRowId
FROM dbo.vManagementPackVersion mpv2 (NOLOCK) 
INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv (NOLOCK) ON mpv2.ManagementPackVersionRowId = mgmpv.ManagementPackVersionRowId
INNER JOIN dbo.vManagementGroup mg (NOLOCK) ON mgmpv.ManagementGroupRowId = mg.ManagementGroupRowId
WHERE mg.ManagementGroupGuid = @MANAGEMENT_GROUP_GUID AND mgmpv.DeletedDateTime is NULL
),

met AS (
SELECT vmet.ManagedEntityTypeRowId, vmet.ManagedEntityTypeGuid, vmet.ManagedEntityTypeSystemName, mp.ManagementPackSystemName
FROM dbo.vManagedEntityType vmet (NOLOCK)
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion vmetmpv (NOLOCK) ON vmet.ManagedEntityTypeRowId = vmetmpv.ManagedEntityTypeRowId
INNER JOIN latestMpVersion ON latestMpVersion.ManagementPackVersionRowId = vmetmpv.ManagementPackVersionRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON latestMpVersion.ManagementPackRowId = mp.ManagementPackRowId
WHERE vmetmpv.Accessibility = 'Public' 
  AND mp.ManagementPackSystemName NOT IN ('System.Library', 'System.Health.Library', 'System.Snmp.Library', 
									      'System.ApplicationLog.Library', 'System.Performance.Library', 
										  'System.AdminItem.Library', 'System.Software.Library', 
										  'System.BaseliningTasks.Library', 'System.Image.Library')
),

loc AS (
SELECT 
	met.ManagedEntityTypeSystemName,
	met.ManagementPackSystemName,
	COALESCE(vds_loc.Name, vds.Name, met.ManagedEntityTypeSystemName) AS DisplayName
FROM met 
left JOIN dbo.vDisplayString vds (NOLOCK) ON met.ManagedEntityTypeGuid = vds.ElementGuid AND vds.LanguageCode = 'ENU'
left JOIN dbo.vDisplayString vds_loc (NOLOCK) ON met.ManagedEntityTypeGuid = vds_loc.ElementGuid AND vds_loc.LanguageCode = @LANGUAGE_CODE
)

SELECT 
	999 AS TAG, 
	NULL AS Parent, 
	'' AS [ClassListDataSourceResult!999],
	NULL AS [Class!1!Id],
	NULL AS [Class!1!DisplayName]
UNION ALL
SELECT 
	1 AS TAG, 
	999 AS Parent, 
	'' AS [ClassListDataSourceResult!999],
	loc.ManagementPackSystemName + '!' + loc.ManagedEntityTypeSystemName AS [Class!1!Id],
	loc.DisplayName AS [Class!1!DisplayName]
FROM loc
order by [ClassListDataSourceResult!999], [Class!1!DisplayName]
FOR XML EXPLICIT

END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_GetClasses] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateTablesList]
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @hangOffset int = -180;

	DECLARE @tablesInternal TABLE (
		TableId bigint NULL,
		[Name] sysname NOT NULL,
		[Type] tinyint NOT NULL,
		LastId bigint NOT NULL,
		FirstDate DateTime NULL
	);

	INSERT INTO @tablesInternal ([Name], [Type], LastId)
	SELECT so.Name AS [Name], 1 AS [Type], -1 AS LastId FROM sysobjects so
	WHERE so.Type = 'U' AND so.Name LIKE 'PerfRaw_________________________________' AND so.UID = SCHEMA_ID('Perf')
	UNION ALL
	SELECT so.Name AS [Name], 2 AS [Type], -1 AS LastId FROM sysobjects so
	WHERE so.Type = 'U' AND so.Name LIKE 'StateRaw_________________________________' AND so.UID = SCHEMA_ID('State')
	UNION ALL
	SELECT so.Name AS [Name], 4 AS [Type], -1 AS LastId FROM sysobjects so
	WHERE so.Type = 'U' AND so.Name LIKE 'AlertResolutionState_________________________________' AND so.UID = SCHEMA_ID('Alert')
	UNION ALL
	SELECT so.Name AS [Name], 5 AS [Type], -1 AS LastId FROM sysobjects so
	WHERE so.Type = 'U' AND so.Name = 'ManagementPackVersion' AND so.UID = SCHEMA_ID('dbo')
	UNION ALL
	SELECT so.Name AS [Name], 6 AS [Type], -1 AS LastId FROM sysobjects so
	WHERE so.Type = 'U' AND so.Name = 'RelationshipManagementGroup' AND so.UID = SCHEMA_ID('dbo');

	UPDATE @tablesInternal
	SET TableId = t.TableId, FirstDate = t.FirstDate
	FROM @tablesInternal ti
	JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t (NOLOCK) ON t.Name = ti.Name AND t.[Type] = ti.[Type];

	DECLARE @query nvarchar(200), @tiName sysname, @tiDateTime DateTime, @tiLastId bigint
	DECLARE temp Cursor LOCAL FOR SELECT Name FROM @tablesInternal ti;
	Open temp;
		
	Fetch next FROM temp INTO @tiName;
	While @@Fetch_Status=0 BEGIN

	SET @tiDateTime = GETDATE()
	SET @tiLastId = -1;

	SET @query = CASE
	WHEN @tiName LIKE 'PerfRaw_________________________________' THEN N'SELECT TOP 1 @tiDateTime = [DateTime] FROM Perf.' + @tiName + ' WITH (NOLOCK) order by [PerfRawRowId] ASC'
	WHEN @tiName LIKE 'StateRaw_________________________________' THEN N'SELECT TOP 1 @tiDateTime = [DateTime] FROM State.' + @tiName + ' WITH (NOLOCK) order by [StateRawRowId] ASC'
	WHEN @tiName LIKE 'AlertResolutionState_________________________________' THEN N'SELECT TOP 1 @tiDateTime = [DWCreatedDateTime] FROM Alert.' + @tiName + ' WITH (NOLOCK) order by [AlertResolutionStateRowId] ASC'
	WHEN @tiName = 'ManagementPackVersion' THEN N'SELECT TOP 1 @tiDateTime = [DWCreatedDateTime] FROM dbo.' + @tiName + ' WITH (NOLOCK) order by [ManagementPackVersionRowId] ASC'
	WHEN @tiName = 'RelationshipManagementGroup' THEN N'SELECT TOP 1 @tiDateTime = [DWCreatedDateTime] FROM dbo.' + @tiName + ' WITH (NOLOCK) order by [RelationshipManagementGroupRowId] ASC'
	END;
		
	EXEC sp_executesql @query, 
                N'@tiDateTime DateTime OUTPUT', 
                @tiDateTime = @tiDateTime OUTPUT

	SET @query = CASE
	WHEN @tiName LIKE 'PerfRaw_________________________________' THEN N'SELECT TOP 1 @tiLastId = [PerfRawRowId] FROM Perf.' + @tiName + ' WITH (NOLOCK) order by [PerfRawRowId] desc'
	WHEN @tiName LIKE 'StateRaw_________________________________' THEN N'SELECT TOP 1 @tiLastId = [StateRawRowId] FROM State.' + @tiName + ' WITH (NOLOCK) order by [StateRawRowId] desc'
	WHEN @tiName LIKE 'AlertResolutionState_________________________________' THEN N'SELECT TOP 1 @tiLastId = [AlertResolutionStateRowId] FROM Alert.' + @tiName + ' WITH (NOLOCK) order by [AlertResolutionStateRowId] desc'
	WHEN @tiName = 'ManagementPackVersion' THEN N'SELECT TOP 1 @tiLastId = [ManagementPackVersionRowId] FROM dbo.' + @tiName + ' WITH (NOLOCK) order by [ManagementPackVersionRowId] desc'
	WHEN @tiName = 'RelationshipManagementGroup' THEN N'SELECT TOP 1 @tiLastId = [RelationshipManagementGroupRowId] FROM dbo.' + @tiName + ' WITH (NOLOCK) order by [RelationshipManagementGroupRowId] desc'
	END;
		
	EXEC sp_executesql @query, 
                N'@tiLastId int OUTPUT', 
                @tiLastId = @tiLastId OUTPUT

	UPDATE @tablesInternal
	SET FirstDate = @tiDateTime, LastId = @tiLastId
	WHERE Name = @tiName;
		
	Fetch next FROM temp INTO @tiName;
	END

	Close temp;
	Deallocate temp;

	BEGIN TRAN

		INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_Tables
		SELECT t.Name AS Name, t.[Type] AS [Type], t.LastId AS LastProcessedId, t.FirstDate FROM @tablesInternal t
		WHERE NOT EXISTS (
				SELECT NULL 
				FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables pt 
				WHERE t.Name = pt.Name AND t.[Type] = pt.[Type]);

		DELETE FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables
		WHERE Name IN (SELECT pt.Name FROM @tablesInternal t
		right JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables pt ON t.Name = pt.Name AND t.[Type] = pt.[Type]
		WHERE t.Name is NULL);

	COMMIT 

	-- remove batches FOR non-exist tables
	DELETE tb FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches tb
	left JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON tb.TableId = t.TableId 
	WHERE t.TableId is NULL;

	--load TABLE Ids FOR inserted tables
	UPDATE ti
	SET TableId = t.TableId
	FROM @tablesInternal ti
	JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t (NOLOCK) ON t.Name = ti.Name AND t.[Type] = ti.[Type]
	WHERE ti.TableId is NULL;

	DECLARE @step int = 50000;
	DECLARE @now DateTime = GetUtcDate();

	;WITH someRowsSeed AS (
	SELECT 1 AS Dummy
	UNION ALL
	SELECT 1
	UNION ALL
	SELECT 1
	UNION ALL
	SELECT 1
	UNION ALL
	SELECT 1
	UNION ALL
	SELECT 1),

	someRows AS (SELECT f1.Dummy FROM someRowsSeed f1
	CROSS JOIN someRowsSeed f2
	CROSS JOIN someRowsSeed f3
	CROSS JOIN someRowsSeed f4),

	tableList AS (
	SELECT pt.TableId, pt.LastId AS LastId, COALESCE(max(tb.LastId), -1) AS PreviousId FROM @tablesInternal pt
	left JOIN sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches tb WITH (NOLOCK) ON pt.TableId = tb.TableId
			group by pt.TableId, pt.LastId
	),

	diapazones AS (
	SELECT 
		t.TableId AS TableId,
		t.PreviousId + @step*(ROW_NUMBER() over (PARTITION by t.TableId order by P.Dummy) - 1) AS FirstId,
		CASE WHEN t.PreviousId + @step*(ROW_NUMBER() over (PARTITION by t.TableId order by P.Dummy)) < t.LastId THEN t.PreviousId + @step*(ROW_NUMBER() over (PARTITION by t.TableId order by P.Dummy)) ELSE t.LastId END AS LastId
	FROM someRows P
	CROSS JOIN tableList t 
	)

	INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches(TableId, FirstId, LastId, Tries, CreateDate)
	SELECT d.TableId, d.FirstId, d.LastId, 0, @now FROM diapazones d
	INNER JOIN tableList tl ON d.TableId = tl.TableId
	WHERE tl.LastId > d.FirstId

	--Retry hanging batches
	DECLARE @hangOffsetDate DateTime = DATEADD(s, @hangOffset, GetUtcDate());

	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches
	SET StartDate = NULL, Tries = Tries + 1
	WHERE StartDate is NOT NULL AND StartDate < @hangOffsetDate AND FinishDate is NULL;
END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateTablesList] TO OpsMgrReader
GO


ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateLastValues]
AS
BEGIN
SET NOCOUNT ON

/* ------------------------------ */

BEGIN TRY

	DECLARE @ExecError int

	EXEC @ExecError = sdk.Microsoft_SQLServer_Visualization_Library_UpdateTablesList

	DECLARE @batchSize int = 50000;
	DECLARE @maxDeadlockCount int = 5;

	DECLARE @FirstId bigint, @LastId bigint, @firstRun bit = 0, @deadlockRetries int, @testRowCount bigint = 0;
	
	DECLARE @tableName sysname;
	
	DECLARE @sql nvarchar(2000), @ptName sysname, @ptType tinyint, @quotedName nvarchar(2000), @ptPreviousId bigint, @ptLastId bigint;
	
	DECLARE @CurrentBatch TABLE (
	TableId bigint,
	BatchId bigint,
	FirstId bigint, 
	LastId bigint
	)

	DECLARE @delay int = 5;
	While (@delay > 0)
	BEGIN
		IF EXISTS (SELECT NULL 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NULL AND t.Type IN (1,2,4))
		BEGIN
			BREAK
		END

		IF EXISTS (SELECT NULL 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NOT NULL AND b.FinishDate is NULL AND t.Type IN (1,2,4))
		BEGIN
			WAITFOR delay '00:00:01'
		END
		SET @delay = @delay - 1;
	END

	-- Performance V2
	
	While (1=1)
	BEGIN
		UPDATE b
		SET StartDate = GetUtcDate()
		OUTPUT inserted.TableId, inserted.BatchId, inserted.FirstId, inserted.LastId INTO @CurrentBatch
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		WHERE b.BatchId = (SELECT TOP 1 b.BatchId FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NULL AND t.Type = 1
		order by t.FirstDate desc, b.BatchId desc)
	
		SELECT TOP 1 @FirstId = FirstId, @LastId = LastId FROM @CurrentBatch
		IF @@ROWCOUNT = 0
			BREAK	
	
		SELECT @quotedName = QUOTENAME(t.Name ,'"') 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables t
		INNER JOIN @CurrentBatch b ON b.TableId = t.TableId; 

		SET @sql = N';WITH latestPerf AS (
			SELECT 
				max(vpr.PerfRawRowId) AS maxPerfRawRowId,
				vpr.PerformanceRuleInstanceRowId, 
				vpr.ManagedEntityRowId
			FROM [Perf].' + @quotedName + N' vpr WITH (NOLOCK)
			WHERE vpr.PerfRawRowId > @FirstId AND vpr.PerfRawRowId <= @LastId
			group by vpr.PerformanceRuleInstanceRowId, vpr.ManagedEntityRowId
			),

			insertable AS (
			SELECT 
				vpr.PerfRawRowId,
				vpr.[DateTime],
				vpr.ManagedEntityRowId,
				vpr.PerformanceRuleInstanceRowId, 
				vpr.SampleValue,
				ROW_NUMBER() over (PARTITION by vpr.PerformanceRuleInstanceRowId, vpr.ManagedEntityRowId, vpr.[DateTime] order by vpr.PerfRawRowId desc) AS rn 
			FROM latestPerf m 
			INNER JOIN [Perf].' + @quotedName + N' vpr WITH (NOLOCK) 
			   ON m.PerformanceRuleInstanceRowId = vpr.PerformanceRuleInstanceRowId 
			  AND vpr.ManagedEntityRowId = m.ManagedEntityRowId 
			  AND vpr.PerfRawRowId = m.maxPerfRawRowId
			WHERE vpr.PerfRawRowId > @FirstId AND vpr.PerfRawRowId <= @LastId
			)
			  
			INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues (ManagedEntityRowId, PerformanceRuleInstanceRowId, [DateTime], SampleValue)
			SELECT fv.ManagedEntityRowId, fv.PerformanceRuleInstanceRowId, fv.[DateTime], fv.SampleValue FROM insertable fv 
			WHERE fv.rn = 1 
			order by fv.ManagedEntityRowId, fv.PerformanceRuleInstanceRowId; 
			';

		SET @deadlockRetries = @maxDeadlockCount;
		While (@deadlockRetries > 0) 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION	
					EXEC @ExecError = sp_executesql @sql, N'@FirstId bigint, @LastId bigint', @FirstId, @LastId;
				COMMIT TRANSACTION
				BREAK
			END TRY
			BEGIN CATCH 
				IF XACT_STATE() <> 0 
					ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
					SET @deadlockRetries = @deadlockRetries - 1 
				ELSE
					EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
			END CATCH 
		END;

		SET @sql = N';WITH latestPerf AS (
			SELECT 
				max(vpr.PerfRawRowId) AS maxPerfRawRowId,
				vpr.PerformanceRuleInstanceRowId, 
				vpr.ManagedEntityRowId
			FROM [Perf].' + @quotedName + N' vpr WITH (NOLOCK)
			WHERE vpr.PerfRawRowId > @FirstId AND vpr.PerfRawRowId <= @LastId
			group by vpr.PerformanceRuleInstanceRowId, vpr.ManagedEntityRowId
			),

			insertable AS (
			SELECT 
				vpr.PerfRawRowId,
				vpr.[DateTime],
				vpr.ManagedEntityRowId,
				vpr.PerformanceRuleInstanceRowId, 
				vpr.SampleValue,
				ROW_NUMBER() over (PARTITION by vpr.PerformanceRuleInstanceRowId, vpr.ManagedEntityRowId, vpr.[DateTime] order by vpr.PerfRawRowId desc) AS rn
			FROM latestPerf m 
			INNER JOIN [Perf].' + @quotedName + N' vpr WITH (NOLOCK) 
			   ON m.PerformanceRuleInstanceRowId = vpr.PerformanceRuleInstanceRowId 
			  AND vpr.ManagedEntityRowId = m.ManagedEntityRowId 
			  AND vpr.PerfRawRowId = m.maxPerfRawRowId
			WHERE vpr.PerfRawRowId > @FirstId AND vpr.PerfRawRowId <= @LastId
			)
			  
			UPDATE pt
			SET DateTime = fv.DateTime, 
			 SampleValue = fv.SampleValue
			FROM sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues pt
			INNER JOIN insertable fv 
			   ON pt.ManagedEntityRowId = fv.ManagedEntityRowId 
			  AND pt.PerformanceRuleInstanceRowId = fv.PerformanceRuleInstanceRowId		  
			WHERE fv.DateTime > pt.DateTime AND fv.rn = 1;';

		SET @deadlockRetries = @maxDeadlockCount;
		While (@deadlockRetries > 0) 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION	
					EXEC @ExecError = sp_executesql @sql, N'@FirstId bigint, @LastId bigint', @FirstId, @LastId;
				COMMIT TRANSACTION
				BREAK
			END TRY
			BEGIN CATCH 
				IF XACT_STATE() <> 0 
					ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
					SET @deadlockRetries = @deadlockRetries - 1 
				ELSE
					EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
			END CATCH 
		END;

		UPDATE b
		SET FinishDate = GetUtcDate()
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN @CurrentBatch cb ON b.BatchId = cb.BatchId;

		DELETE FROM @CurrentBatch;
	END; -- While (1=1)
	
	-- State V2

	While (1=1)
	BEGIN
		UPDATE b
		SET StartDate = GetUtcDate()
		OUTPUT inserted.TableId, inserted.BatchId, inserted.FirstId, inserted.LastId INTO @CurrentBatch
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		WHERE b.BatchId = (SELECT TOP 1 b.BatchId FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NULL AND t.Type = 2
		order by t.FirstDate desc, b.BatchId desc)
	
		SELECT TOP 1 @FirstId = FirstId, @LastId = LastId FROM @CurrentBatch
		IF @@ROWCOUNT = 0
			BREAK	
	
		SELECT @quotedName = QUOTENAME(t.Name ,'"') 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables t
		INNER JOIN @CurrentBatch b ON b.TableId = t.TableId; 

		SET @sql = N';WITH latestState AS (
		 SELECT 
			max(vsr.DateTime) AS maxDateTime,
			vsr.ManagedEntityMonitorRowId
		  FROM [State].' + @quotedName + N' vsr WITH (NOLOCK)
		  WHERE vsr.StateRawRowId > @FirstId AND vsr.StateRawRowId <= @LastId
		  group by vsr.ManagedEntityMonitorRowId
		  ),

		  insertable AS (
		  SELECT 
			vsr.StateRawRowId,
			vsr.[DateTime],
			vsr.ManagedEntityMonitorRowId,
			vsr.NewHealthState AS HealthState,
			ROW_NUMBER() over (PARTITION by vsr.ManagedEntityMonitorRowId, vsr.[DateTime] order by vsr.StateRawRowId desc) AS rn
		  FROM latestState m 
		  INNER JOIN [State].' + @quotedName + N' vsr WITH (NOLOCK) 
		     ON vsr.ManagedEntityMonitorRowId = m.ManagedEntityMonitorRowId 
		    AND vsr.DateTime = m.maxDateTime
		  WHERE vsr.StateRawRowId > @FirstId AND vsr.StateRawRowId <= @LastId
		  )
			  
		INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues (ManagedEntityRowId, MonitorRowId, [DateTime], [HealthState])
		 SELECT mem.ManagedEntityRowId, mem.MonitorRowId, fv.[DateTime], fv.[HealthState] FROM insertable fv 
		 INNER JOIN dbo.ManagedEntityMonitor mem ON mem.ManagedEntityMonitorRowId = fv.ManagedEntityMonitorRowId
		 WHERE fv.rn = 1
		 order by mem.ManagedEntityRowId, mem.MonitorRowId;
		 ';

		SET @deadlockRetries = @maxDeadlockCount;
		While (@deadlockRetries > 0) 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION	
					EXEC @ExecError = sp_executesql @sql, N'@FirstId bigint, @LastId bigint', @FirstId, @LastId;
				COMMIT TRANSACTION
				BREAK
			END TRY
			BEGIN CATCH 
				IF XACT_STATE() <> 0 
					ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
					SET @deadlockRetries = @deadlockRetries - 1 
				ELSE
					EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
			END CATCH 
		END;

		SET @sql = N';WITH latestState AS (
		 SELECT 
			max(vsr.DateTime) AS maxDateTime,
			vsr.ManagedEntityMonitorRowId
		  FROM [State].' + @quotedName + N' vsr WITH (NOLOCK)
		  WHERE vsr.StateRawRowId > @FirstId AND vsr.StateRawRowId <= @LastId
		  group by vsr.ManagedEntityMonitorRowId
		  ),

		  insertable AS (
		  SELECT 
			vsr.StateRawRowId,
			vsr.[DateTime],
			vsr.ManagedEntityMonitorRowId,
			vsr.NewHealthState AS HealthState,
			ROW_NUMBER() over (PARTITION by vsr.ManagedEntityMonitorRowId, vsr.[DateTime] order by vsr.StateRawRowId desc) AS rn
		  FROM latestState m 
		  INNER JOIN [State].' + @quotedName + N' vsr WITH (NOLOCK) 
		     ON vsr.ManagedEntityMonitorRowId = m.ManagedEntityMonitorRowId 
		    AND vsr.DateTime = m.maxDateTime
		  WHERE vsr.StateRawRowId > @FirstId AND vsr.StateRawRowId <= @LastId
		  )
			  
			UPDATE st
			SET DateTime = fv.DateTime, 
			 [HealthState] = fv.[HealthState]
			FROM sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues st
		    INNER JOIN dbo.ManagedEntityMonitor mem ON mem.ManagedEntityRowId = st.ManagedEntityRowId AND mem.MonitorRowId = st.MonitorRowId
			INNER JOIN insertable fv ON mem.[ManagedEntityMonitorRowId] = fv.[ManagedEntityMonitorRowId]		  
			WHERE fv.DateTime > st.DateTime AND fv.rn = 1;';

		SET @deadlockRetries = @maxDeadlockCount;
		While (@deadlockRetries > 0) 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION	
					EXEC @ExecError = sp_executesql @sql, N'@FirstId bigint, @LastId bigint', @FirstId, @LastId;
				COMMIT TRANSACTION
				BREAK
			END TRY
			BEGIN CATCH 
				IF XACT_STATE() <> 0 
					ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
					SET @deadlockRetries = @deadlockRetries - 1 
				ELSE
					EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
			END CATCH 
		END;

		UPDATE b
		SET FinishDate = GetUtcDate()
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN @CurrentBatch cb ON b.BatchId = cb.BatchId;

		DELETE FROM @CurrentBatch;
	END; -- While (1=1)

	-- Alert Resolution State V2

	While (1=1)
	BEGIN
		UPDATE b
		SET StartDate = GetUtcDate()
		OUTPUT inserted.TableId, inserted.BatchId, inserted.FirstId, inserted.LastId INTO @CurrentBatch
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		WHERE b.BatchId = (SELECT TOP 1 b.BatchId FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NULL AND t.Type = 4
		order by t.FirstDate desc, b.BatchId desc)
	
		SELECT TOP 1 @FirstId = FirstId, @LastId = LastId FROM @CurrentBatch
		IF @@ROWCOUNT = 0
			BREAK	
	
		SELECT @quotedName = QUOTENAME(t.Name ,'"') 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Tables t
		INNER JOIN @CurrentBatch b ON b.TableId = t.TableId; 

	   SET @sql = N';WITH latestResolutionState AS (
		 SELECT 
			max(vsr.StateSetDateTime) AS maxDateTime,
			vsr.[AlertGuid]
		  FROM [Alert].' + @quotedName + N' vsr WITH (NOLOCK)
		  WHERE vsr.AlertResolutionStateRowId > @FirstId AND vsr.AlertResolutionStateRowId <= @LastId
		  group by vsr.AlertGuid
		  ),

		  insertable AS (
		  SELECT 
			vsr.[AlertResolutionStateRowId],
			vsr.StateSetDateTime AS DateTime,
			vsr.[AlertGuid],
			vsr.[ResolutionState],
			ROW_NUMBER() over (PARTITION by vsr.AlertGuid, vsr.[StateSetDateTime] order by vsr.AlertResolutionStateRowId desc) AS rn
		  FROM latestResolutionState m 
		  INNER JOIN [Alert].' + @quotedName + N' vsr WITH (NOLOCK) 
		     ON m.AlertGuid = vsr.AlertGuid 
		    AND vsr.[StateSetDateTime] = m.maxDateTime
		  WHERE vsr.AlertResolutionStateRowId > @FirstId AND vsr.AlertResolutionStateRowId <= @LastId
		  )

		  INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues (AlertGuid, [ManagedEntityRowId], [DateTime], Severity, ResolutionState)
		 SELECT fv.AlertGuid, a.[ManagedEntityRowId], fv.[DateTime], a.Severity, fv.ResolutionState AS ResolutionState FROM insertable fv
		 INNER JOIN Alert.vAlert a ON fv.AlertGuid = a.AlertGuid  
		 WHERE fv.rn = 1 
		 order by fv.AlertGuid;
		 ';

		SET @deadlockRetries = @maxDeadlockCount;
		While (@deadlockRetries > 0) 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION	
					EXEC @ExecError = sp_executesql @sql, N'@FirstId bigint, @LastId bigint', @FirstId, @LastId;
				COMMIT TRANSACTION
				BREAK
			END TRY
			BEGIN CATCH 
				IF XACT_STATE() <> 0 
					ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
					SET @deadlockRetries = @deadlockRetries - 1 
				ELSE
					EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
			END CATCH 
		END;

	   SET @sql = N';WITH latestResolutionState AS (
		 SELECT 
			max(vsr.StateSetDateTime) AS maxDateTime,
			vsr.[AlertGuid]
		  FROM [Alert].' + @quotedName + N' vsr WITH (NOLOCK)
		  WHERE vsr.AlertResolutionStateRowId > @FirstId AND vsr.AlertResolutionStateRowId <= @LastId
		  group by vsr.AlertGuid
		  ),

		  insertable AS (
		  SELECT 
			vsr.[AlertResolutionStateRowId],
			vsr.StateSetDateTime AS DateTime,
			vsr.[AlertGuid],
			vsr.[ResolutionState],
			ROW_NUMBER() over (PARTITION by vsr.AlertGuid, vsr.[StateSetDateTime] order by vsr.AlertResolutionStateRowId desc) AS rn
		  FROM latestResolutionState m 
		  INNER JOIN [Alert].' + @quotedName + N' vsr WITH (NOLOCK) 
		     ON m.AlertGuid = vsr.AlertGuid 
		    AND vsr.[StateSetDateTime] = m.maxDateTime
		  WHERE vsr.AlertResolutionStateRowId > @FirstId AND vsr.AlertResolutionStateRowId <= @LastId
		  )

		  UPDATE avt
		 SET DateTime = fv.DateTime, 
			 [ResolutionState] = fv.[ResolutionState]
		 FROM sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues avt
		 INNER JOIN insertable fv 
			ON avt.AlertGuid = fv.AlertGuid
         WHERE fv.DateTime > avt.DateTime AND fv.rn = 1;';

		SET @deadlockRetries = @maxDeadlockCount;
		While (@deadlockRetries > 0) 
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION	
					EXEC @ExecError = sp_executesql @sql, N'@FirstId bigint, @LastId bigint', @FirstId, @LastId;
				COMMIT TRANSACTION
				BREAK
			END TRY
			BEGIN CATCH 
				IF XACT_STATE() <> 0 
					ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
					SET @deadlockRetries = @deadlockRetries - 1 
				ELSE
					EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
			END CATCH 
		END;

		UPDATE b
		SET FinishDate = GetUtcDate()
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN @CurrentBatch cb ON b.BatchId = cb.BatchId;

		DELETE FROM @CurrentBatch;
	END; -- While (1=1)

END TRY
BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRAN

	EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
END CATCH
END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateLastValues] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData]
	@ManagementGroupGuid uniqueidentifier,
    @XmlData XML,
	@profiling bit = 0
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

--	EXEC	[sdk].[Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData]
--		@ManagementGroupGuid = N'11C61275-6A83-BC2D-98FB-7457E9364340',
--		@XmlData = N'
--<DatacenterViewQuery xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" TimeRange="1440">
--  <OpsManagerConfiguration ResolvedAlertDaysToKeep="7" AutoResolveDays="30" AutoResolveHealthyObjDays="7" />
--  <DatacenterGroup Id="3e02a316-72f5-19bf-012d-da408822314b">
--    <MonitorMetrics>
--      <AggregatedMonitorMetric Id="755b6add-f4cc-4d33-b5aa-eecf1635f4df">
--        <ClassMonitorMapping ClassName="VIAcode.MPPerfTest!VIAcode.MPPerfTest.Object" MonitorId="f3dd67cd-1488-3a79-223c-de3b4b422024" />
--      </AggregatedMonitorMetric>
--    </MonitorMetrics>
--    <PerformanceMetrics>
--      <AggregatedPerformanceMetric Id="9a9e575b-7bb7-4482-a7cf-9b6de7f67724">
--        <ClassPerformanceCollectionRuleMapping ClassName="VIAcode.MPPerfTest!VIAcode.MPPerfTest.Object" PerformanceCollectionRuleId="39726668-d064-f717-9bbc-32f6fb4a9b30" />
--      </AggregatedPerformanceMetric>
--    </PerformanceMetrics>
--  </DatacenterGroup>
--  <DatacenterGroup InstanceId="Microsoft.SQLServer.2008.Discovery!Microsoft.SQLServer.2008.InstanceGroup">
--    <MonitorMetrics />
--    <PerformanceMetrics />
--  </DatacenterGroup>
--  <DatacenterGroup Id="fedfb352-3daa-35fb-8152-ad38a00a6337">
--    <MonitorMetrics>
--      <AggregatedMonitorMetric Id="585178d3-b6c2-466b-9867-b7dc70ead813">
--        <ClassMonitorMapping ClassName="VIAcode.MPPerfTest!VIAcode.MPPerfTest.Object" MonitorId="f3dd67cd-1488-3a79-223c-de3b4b422024" />
--      </AggregatedMonitorMetric>
--	</MonitorMetrics>
--    <PerformanceMetrics>
--      <AggregatedPerformanceMetric Id="fd6b74ad-3e00-4568-9106-f08f1b7ccce4">
--        <ClassPerformanceCollectionRuleMapping ClassName="VIAcode.MPPerfTest!VIAcode.MPPerfTest.Object" PerformanceCollectionRuleId="39726668-d064-f717-9bbc-32f6fb4a9b30" />
--      </AggregatedPerformanceMetric>
--      <AggregatedPerformanceMetric Id="62a4dfd8-d43c-4cdd-8240-0af5aabba4eb">
--        <ClassPerformanceCollectionRuleMapping ClassName="VIAcode.MPPerfTest!VIAcode.MPPerfTest.Object" PerformanceCollectionRuleId="39726668-d064-f717-9bbc-32f6fb4a9b30" />
--      </AggregatedPerformanceMetric>
--    </PerformanceMetrics>
--  </DatacenterGroup>
--</DatacenterViewQuery>'
/* ------------------------------ */

    BEGIN TRY

DECLARE @ExecError int;

IF @profiling = 1
BEGIN
    DECLARE @StartTime DateTime = getdate();
    DECLARE @StartTimeSegment DateTime = getdate();
    DECLARE @EndTimeSegment DateTime;
    
    create table #profilingdata 
    (
	    Name varchar(200),
	    length int
    );
END

EXEC @ExecError = [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateLastValues]

IF NOT @ExecError = 0
    RAISERROR('Text %s %d', 16, 1
        ,'ClassXml'
        ,@ExecError)

IF @profiling = 1
BEGIN
    SET @EndTimeSegment = getdate()

    INSERT INTO #profilingdata 
    VALUES ('UPDATE VALUES', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

    SET @StartTimeSegment = getdate()
END

EXEC	@ExecError = [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateHierarchy]

IF NOT @ExecError = 0
    RAISERROR('Text %s %d', 16, 1
        ,'ClassXml'
        ,@ExecError)

IF @profiling = 1
BEGIN
    SET @EndTimeSegment = getdate()

    INSERT INTO #profilingdata 
    VALUES ('UPDATE hierarchy', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

    SET @StartTimeSegment = getdate()
END

DECLARE @ManagementGroupRowId int;
DECLARE @TimeRange int;
SELECT @ManagementGroupRowId = mg.ManagementGroupRowId, @TimeRange = ParamValues.x.value('@TimeRange', 'int')
FROM @XmlData.nodes('/DatacenterViewQuery') AS ParamValues(x) 
INNER JOIN dbo.vManagementGroup mg WITH (NOLOCK) 
    ON mg.ManagementGroupGuid = @ManagementGroupGuid;

DECLARE @ResolvedAlertDaysToKeep int = NULL;
DECLARE @AutoResolveDays int = NULL;
DECLARE @AutoResolveHealthyObjDays int = NULL;
SELECT @ResolvedAlertDaysToKeep = ParamValues.x.value('@ResolvedAlertDaysToKeep', 'int'),
@AutoResolveDays = ParamValues.x.value('@AutoResolveDays', 'int'),
@AutoResolveHealthyObjDays = ParamValues.x.value('@AutoResolveHealthyObjDays', 'int')
FROM @XmlData.nodes('/DatacenterViewQuery/OpsManagerConfiguration') AS ParamValues(x) 

; WITH inserts AS 
(
	SELECT @ManagementGroupGuid AS ManagementGroupGuid, 'ResolvedAlertDaysToKeep' AS Name, NULL AS Value
	UNION ALL 
	SELECT @ManagementGroupGuid AS ManagementGroupGuid, 'AutoResolveDays' AS Name, NULL AS Value
	UNION ALL 
	SELECT @ManagementGroupGuid AS ManagementGroupGuid, 'AutoResolveHealthyObjDays' AS Name, NULL AS Value
)
INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
SELECT * 
FROM inserts i
WHERE NOT EXISTS 
(
	SELECT NULL 
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings oms 
	WHERE i.ManagementGroupGuid = oms.ManagementGroupGuid 
	  AND i.Name = oms.Name
)

IF @ResolvedAlertDaysToKeep is NOT NULL AND @AutoResolveDays is NOT NULL AND @AutoResolveHealthyObjDays is NOT NULL 
BEGIN
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
	SET Value = @ResolvedAlertDaysToKeep
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'ResolvedAlertDaysToKeep';
	
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
	SET Value = @AutoResolveDays
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveDays';
	
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
	SET Value = @AutoResolveHealthyObjDays
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveHealthyObjDays';
END
ELSE 
BEGIN
	SELECT @ResolvedAlertDaysToKeep = Value
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings WITH (NOLOCK)
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'ResolvedAlertDaysToKeep'

	IF @ResolvedAlertDaysToKeep is NULL
		SET @ResolvedAlertDaysToKeep = 7

	SELECT @AutoResolveDays = Value
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings WITH (NOLOCK)
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveDays'

	IF @AutoResolveDays is NULL
		SET @AutoResolveDays = 30

	SELECT @AutoResolveHealthyObjDays = Value
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings WITH (NOLOCK)
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveHealthyObjDays'

	IF @AutoResolveHealthyObjDays is NULL
		SET @AutoResolveHealthyObjDays = 7
END

DECLARE @launchDateTime DateTime = getdate();
DECLARE @firstDateTime DateTime = DATEADD(minute, -1*@TimeRange, @launchDateTime);

create table #configuredGroups (
	RowId int, 
	Id uniqueidentifier,
	InstanceId nvarchar(2000),
	IsVirtualGroup bit
	UNIQUE CLUSTERED (RowId, Id)
);

;WITH configuredGroups AS (
	SELECT DISTINCT ParamValues.x.value('@Id','uniqueidentifier') AS Id, ParamValues.x.value('@InstanceId','nvarchar(2000)') AS InstanceId 
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup') AS ParamValues(x)
),

virtual_groups AS (
	SELECT DISTINCT 
		TRY_CAST(ParamValues.x.value('../@Id','nvarchar(2000)') AS UNIQUEIDENTIFIER) AS Id
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/ClassType') AS ParamValues(x)
),

updated_groups AS (
	SELECT tme.ManagedEntityRowId as RowId, mt.ManagedEntityTypeGuid as Id, s.InstanceId, 0 as VirtualGroup FROM configuredGroups s
	INNER JOIN dbo.[vManagedEntityType] mt WITH (NOLOCK) ON LOWER(SUBSTRING(s.InstanceId, CHARINDEX('!', s.InstanceId) + 1, 2000)) = LOWER(mt.ManagedEntityTypeSystemName)
	INNER JOIN dbo.[vManagementPack] mp WITH (NOLOCK) ON mp.ManagementPackRowId = mt.ManagementPackRowId AND LOWER(SUBSTRING(s.InstanceId, 1, CHARINDEX('!', s.InstanceId) - 1)) = LOWER(mp.ManagementPackSystemName)
	INNER JOIN dbo.vTypedManagedEntity tme WITH (NOLOCK) ON mt.ManagedEntityTypeRowId = tme.ManagedEntityTypeRowId
	INNER JOIN dbo.vManagedEntity me WITH (NOLOCK) ON tme.ManagedEntityRowId = me.ManagedEntityRowId
	INNER JOIN dbo.vManagementGroup mg WITH (NOLOCK) ON me.ManagementGroupRowId = mg.ManagementGroupRowId
	WHERE s.Id is null and CHARINDEX('!', s.InstanceId) > 0 and mg.ManagementGroupGuid = @ManagementGroupGuid
	UNION ALL
	SELECT me.ManagedEntityRowId as RowId, s.Id, NULL AS InstanceId, CASE WHEN vg.Id IS NOT NULL THEN 1 ELSE 0 END as VirtualGroup FROM configuredGroups s
	LEFT OUTER JOIN dbo.vManagedEntity me WITH (NOLOCK) ON s.Id = me.ManagedEntityGuid
	LEFT OUTER JOIN virtual_groups vg ON vg.Id = s.Id
	WHERE s.Id IS NOT NULL
),

numbered_groups AS (
	SELECT 
		c.RowId, 
		c.Id, 
		c.InstanceId,
		c.VirtualGroup,
		ROW_NUMBER() OVER (PARTITION BY c.RowId, c.Id, c.VirtualGroup ORDER BY c.InstanceId DESC) AS rn 
	FROM updated_groups c
)

INSERT INTO #configuredGroups
SELECT 
	c.RowId, 
	c.Id, 
	c.InstanceId,
	c.VirtualGroup 
FROM numbered_groups c 
WHERE c.rn = 1;

-- select * from #configuredGroups

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	INSERT INTO #profilingdata 
	VALUES ('DECLARE @configuredGroups', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #groupClassTypes (
	GroupId uniqueidentifier, 
	ManagedEntityTypeRowId int,
	UNIQUE CLUSTERED (GroupId, ManagedEntityTypeRowId)
);

;WITH classTypes AS (
	SELECT DISTINCT 
		TRY_CAST(ParamValues.x.value('../@Id','nvarchar(2000)') AS UNIQUEIDENTIFIER) AS Id,
		ParamValues.x.value('../@InstanceId','nvarchar(2000)') AS InstanceId, 
		ParamValues.x.value('@Id','nvarchar(2000)') AS ClassTypeId 
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/ClassType') AS ParamValues(x)
)

INSERT INTO #groupClassTypes
SELECT cg.Id as GroupId, mt.ManagedEntityTypeRowId as ManagedEntityTypeRowId 
FROM classTypes s
INNER JOIN dbo.[ManagedEntityType] mt WITH (NOLOCK) 
	ON LOWER(SUBSTRING(s.ClassTypeId, CHARINDEX('!', s.ClassTypeId) + 1, 2000)) = LOWER(mt.ManagedEntityTypeSystemName)
INNER JOIN dbo.[ManagementPack] mp WITH (NOLOCK) 
	ON mp.ManagementPackRowId = mt.ManagementPackRowId 
	AND LOWER(SUBSTRING(s.ClassTypeId, 1, CHARINDEX('!', s.ClassTypeId) - 1)) = LOWER(mp.ManagementPackSystemName)
INNER JOIN #configuredGroups cg 
	ON s.Id = cg.Id or (s.Id is null and s.InstanceId = cg.InstanceId)
where CHARINDEX('!', s.ClassTypeId) > 0
order by GroupId, ManagedEntityTypeRowId

--Fill classes with first non-abstract descedant
;WITH DerivedTree (GroupId, RowId,Abstract, Level) AS (
  SELECT c.GroupId as GroupId, c.ManagedEntityTypeRowId as RowId, mev.AbstractInd as Abstract, 0 as Level 
  FROM #groupClassTypes c INNER JOIN 
  dbo.vManagedEntityTypeManagementPackVersion mev WITH (NOLOCK) ON (c.ManagedEntityTypeRowId = mev.ManagedEntityTypeRowId)
  INNER JOIN dbo.vManagementPackVersion mpv WITH (NOLOCK) ON mev.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
  INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) ON (mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId AND  mgmpv.DeletedDateTime IS NULL)  
  WHERE mgmpv.ManagementGroupRowId = @ManagementGroupRowId
  AND mev.AbstractInd = 1
UNION ALL
  SELECT dt.GroupId as GroupId, mev.ManagedEntityTypeRowId as RowId, mev.AbstractInd as Abstract,dt.Level +1 as Level
  FROM dbo.vManagedEntityTypeManagementPackVersion mev  WITH (NOLOCK)
  INNER JOIN dbo.vManagementPackVersion mpv WITH (NOLOCK) ON mev.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
  INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) ON (mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId AND  mgmpv.DeletedDateTime IS NULL)
  INNER JOIN DerivedTree dt ON (dt.RowId = mev.BaseManagedEntityTypeRowId And dt.Abstract = 1)  
  WHERE dt.Level < 31 AND mgmpv.ManagementGroupRowId = @ManagementGroupRowId
)
INSERT INTO #groupClassTypes
SELECT DISTINCT dt.GroupId as GroupId, dt.RowId as ManagedEntityTypeRowId From DerivedTree dt
WHERE Abstract = 0
  AND NOT EXISTS (SELECT NULL FROM #groupClassTypes gct WHERE dt.GroupId = gct.GroupId and dt.RowId = gct.ManagedEntityTypeRowId)

-- select * from #groupClassTypes

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('DECLARE @groupClassTypes', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #allowedGroups (
	RowId int PRIMARY KEY
);

;WITH allowedGroups AS (
	SELECT DISTINCT ParamValues.x.value('@ID','uniqueidentifier') AS [Guid] 
	FROM @XmlData.nodes('/DatacenterViewQuery/OpsManagerConfiguration/AllowedGroup') AS ParamValues(x)
)

INSERT INTO #allowedGroups
SELECT me.ManagedEntityRowId as RowId 
FROM allowedGroups a
INNER JOIN dbo.ManagedEntity me WITH (NOLOCK) 
	ON a.[Guid] = me.ManagedEntityGuid
INNER JOIN dbo.ManagedEntityManagementGroup memg WITH (NOLOCK) 
	ON me.ManagedEntityRowId = memg.ManagedEntityRowId
WHERE me.ManagementGroupRowId = @ManagementGroupRowId
  AND memg.ToDateTime is NULL;

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('DECLARE @allowedGroups', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #groups (
	RowId int,
	Id uniqueidentifier, 
	InstanceId nvarchar(2000),
	IsVirtualGroup bit
);

create unique clustered index ix_group_id on #groups (Id, RowId)

INSERT INTO #groups
SELECT c.* 
FROM #configuredGroups c
LEFT JOIN #allowedGroups a 
	on a.RowId = c.RowId
WHERE c.IsVirtualGroup = 1 OR a.RowId IS NOT NULL 

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('DECLARE @groups', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #LatestMpVersions (
	ManagementPackRowId int,
	ManagementPackVersionRowId int PRIMARY KEY
);

INSERT INTO #LatestMpVersions
SELECT mpv2.ManagementPackRowId, max(ManagementPackVersionRowId) AS ManagementPackVersionRowId
FROM dbo.vManagementPackVersion mpv2 (NOLOCK) 
group by mpv2.ManagementPackRowId
ORDER BY ManagementPackVersionRowId

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('INSERT @LatestMpVersions', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #FilteredRT (
	RelationshipTypeRowId int PRIMARY KEY
);

; WITH parentRT AS (
	SELECT TOP 1 rt.RelationshipTypeRowId
	FROM dbo.vRelationshipType rt WITH (NOLOCK)
	WHERE rt.RelationshipTypeSystemName = 'System.Containment'			
),			
FilteredRT AS (
	SELECT RelationshipTypeRowId 
	FROM parentRT
	UNION ALL
	SELECT rth.Child AS RelationshipTypeRowId
	FROM parentRT rt WITH (NOLOCK)
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy rth WITH (NOLOCK) 
		ON rt.RelationshipTypeRowId = rth.Parent
)
INSERT INTO #FilteredRT
SELECT DISTINCT * 
FROM FilteredRT;

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('INSERT @FilteredRT', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

-- 0 - statemetric
-- 1 - alertmetric
-- 2 - MonitorMetric
-- 3 - perfmetric
-- 4 - countmetric
-- 5 - perfaveragemetric
create table #Metrics (
	GroupId uniqueidentifier,
	Id uniqueidentifier,
	MetricType smallint,
	MonitorRowId int,
	UNIQUE CLUSTERED (Id, MetricType)
);

INSERT INTO #Metrics
SELECT DISTINCT 
	cg.Id AS GroupId, 
	cg.Id AS Id, 
	255 AS MetricType,
	CASE WHEN g.Id is NULL THEN 1 ELSE 2 END AS MonitorRowId
FROM #configuredGroups cg
LEFT OUTER JOIN #groups g 
	ON g.RowId = cg.RowId 
	OR (g.RowId IS NULL AND cg.RowId IS NULL AND g.Id = cg.Id)
UNION ALL 
SELECT DISTINCT 
	g.Id AS GroupId, 
	g.Id AS Id, 
	0 AS MetricType,
	mon.MonitorRowId AS MonitorRowId
FROM #groups g
INNER JOIN dbo.Monitor mon WITH (NOLOCK) 
	ON mon.MonitorSystemName = 'System.Health.EntityState'
UNION ALL 
SELECT DISTINCT
	g.Id AS GroupId, 
	g.Id AS Id, 
	1 AS MetricType,
	0 AS MonitorRowId
FROM #groups g
UNION ALL 
SELECT 
	g.Id AS GroupId, 
	x.value('@Id', 'uniqueidentifier') AS Id, 
	2 AS MetricType,
	0 AS MonitorRowId 
FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/MonitorMetrics/AggregatedMonitorMetric') AS ParamValues(x)
INNER JOIN #configuredGroups g 
	on x.value('../../@Id', 'uniqueidentifier') = g.Id or (x.value('../../@Id', 'uniqueidentifier') is null 
	and x.value('../../@InstanceId', 'nvarchar(2000)') = g.InstanceId)
UNION ALL 
SELECT 
	g.Id AS GroupId, 
	x.value('@Id', 'uniqueidentifier') AS Id, 
	3 AS MetricType,
	0 AS MonitorRowId 
FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/PerformanceMetrics/AggregatedPerformanceMetric') AS ParamValues(x)
INNER JOIN #configuredGroups g 
	on x.value('../../@Id', 'uniqueidentifier') = g.Id 
	or (
		x.value('../../@Id', 'uniqueidentifier') is null 
		and x.value('../../@InstanceId', 'nvarchar(2000)') = g.InstanceId
	)
UNION ALL 
SELECT 
	g.Id AS GroupId, 
	x.value('@Id', 'uniqueidentifier') AS Id, 
	4 AS MetricType,
	0 AS MonitorRowId 
FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/CountItemsMetrics/AggregatedCountItemsMetric') AS ParamValues(x)
INNER JOIN #configuredGroups g 
	on x.value('../../@Id', 'uniqueidentifier') = g.Id 
	or (
		x.value('../../@Id', 'uniqueidentifier') is null 
		and x.value('../../@InstanceId', 'nvarchar(2000)') = g.InstanceId
	)
UNION ALL 
SELECT 
	g.Id AS GroupId, 
	x.value('@Id', 'uniqueidentifier') AS Id, 
	5 AS MetricType,
	0 AS MonitorRowId 
FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/AveragePerformanceMetrics/AggregatedAveragePerformanceMetric') AS ParamValues(x)
INNER JOIN #configuredGroups g 
	on x.value('../../@Id', 'uniqueidentifier') = g.Id or 
	(
		x.value('../../@Id', 'uniqueidentifier') is null 
		and x.value('../../@InstanceId', 'nvarchar(2000)') = g.InstanceId
	);

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('DECLARE @Metrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #classMappings (
	MetricId uniqueidentifier,
	ManagedEntityTypeRowId int,
	RuleRowId int,
	MonitorRowId int,
	UNIQUE CLUSTERED (ManagedEntityTypeRowId, MetricId)
);

; WITH initial_cm AS 
(
	SELECT 
		TRY_CAST(x.value('../@Id', 'nvarchar(2000)') AS UNIQUEIDENTIFIER) AS MetricId,
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) - 1)) AS MpName, 
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) + 1, 2000)) AS ClassName, 
		0 AS RuleRowId,
		mon.MonitorRowId AS MonitorRowId
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/MonitorMetrics/AggregatedMonitorMetric/ClassMonitorMapping') AS ParamValues(x)
	INNER JOIN dbo.vMonitor mon WITH (NOLOCK) 
		ON mon.MonitorSystemName = LOWER(SUBSTRING(x.value('@MonitorSystemName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@MonitorSystemName', 'nvarchar(2000)')) + 1, 2000))
	INNER JOIN dbo.vMonitorManagementPackVersion mmpv WITH (NOLOCK) 
		ON mon.MonitorRowId = mmpv.MonitorRowId
	INNER JOIN #LatestMpVersions lmv 
		ON mmpv.ManagementPackVersionRowId = lmv.ManagementPackVersionRowId
	INNER JOIN dbo.vManagementPack mp 
		on lmv.ManagementPackRowId = mp.ManagementPackRowId 
		and mp.ManagementPackSystemName = LOWER(SUBSTRING(x.value('@MonitorSystemName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@MonitorSystemName', 'nvarchar(2000)')) - 1))
	UNION ALL
	SELECT 
		TRY_CAST(x.value('../@Id', 'nvarchar(2000)') AS UNIQUEIDENTIFIER) AS MetricId,
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) - 1)) AS MpName, 
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) + 1, 2000)) AS ClassName, 
		r.RuleRowId AS RuleRowId,
		0 AS MonitorRowId
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/PerformanceMetrics/AggregatedPerformanceMetric/ClassPerformanceCollectionRuleMapping') AS ParamValues(x)
	INNER JOIN dbo.vRule r WITH (NOLOCK) 
		ON r.RuleSystemName = LOWER(SUBSTRING(x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)')) + 1, 2000))
	INNER JOIN dbo.vRuleManagementPackVersion rmpv WITH (NOLOCK) 
		ON r.RuleRowId = rmpv.RuleRowId
	INNER JOIN #LatestMpVersions lmv 
		ON rmpv.ManagementPackVersionRowId = lmv.ManagementPackVersionRowId
	INNER JOIN dbo.vManagementPack mp 
		on lmv.ManagementPackRowId = mp.ManagementPackRowId 
		and mp.ManagementPackSystemName = LOWER(SUBSTRING(x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)')) - 1))
	UNION ALL
	SELECT 
		TRY_CAST(x.value('../@Id', 'nvarchar(2000)') AS UNIQUEIDENTIFIER) AS MetricId,
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) - 1)) AS MpName, 
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) + 1, 2000)) AS ClassName, 
		0 as RuleRowId,
		0 AS MonitorRowId
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/CountItemsMetrics/AggregatedCountItemsMetric/CountableItemMapping') AS ParamValues(x)
	UNION ALL
	SELECT 
		TRY_CAST(x.value('../@Id', 'nvarchar(2000)') AS UNIQUEIDENTIFIER) AS MetricId,
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) - 1)) AS MpName, 
		LOWER(SUBSTRING(x.value('@ClassName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@ClassName', 'nvarchar(2000)')) + 1, 2000)) AS ClassName, 
		r.RuleRowId AS RuleRowId,
		0 AS MonitorRowId
	FROM @XmlData.nodes('/DatacenterViewQuery/DatacenterGroup/AveragePerformanceMetrics/AggregatedAveragePerformanceMetric/ClassPerformanceCollectionRuleMapping') AS ParamValues(x)
	INNER JOIN dbo.vRule r WITH (NOLOCK) 
		ON r.RuleSystemName = LOWER(SUBSTRING(x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)'), CHARINDEX('!', x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)')) + 1, 2000))
	INNER JOIN dbo.vRuleManagementPackVersion rmpv WITH (NOLOCK) 
		ON r.RuleRowId = rmpv.RuleRowId
	INNER JOIN #LatestMpVersions lmv 
		ON rmpv.ManagementPackVersionRowId = lmv.ManagementPackVersionRowId
	INNER JOIN dbo.vManagementPack mp 
		on lmv.ManagementPackRowId = mp.ManagementPackRowId 
		and mp.ManagementPackSystemName = LOWER(SUBSTRING(x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)'), 1, CHARINDEX('!', x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)')) - 1))
	),
	updated_initial AS 
	(
		SELECT s.*, mt.ManagedEntityTypeRowId 
		FROM initial_cm s
		INNER JOIN dbo.[ManagedEntityType] mt WITH (NOLOCK) 
		ON s.ClassName = LOWER(mt.ManagedEntityTypeSystemName)
		INNER JOIN dbo.[ManagementPack] mp WITH (NOLOCK) 
			ON mp.ManagementPackRowId = mt.ManagementPackRowId 
			AND s.MpName = LOWER(mp.ManagementPackSystemName)
),
reverse_seed AS 
(
	SELECT U.MetricId, U.RuleRowId, U.MonitorRowId, U.ManagedEntityTypeRowId, 0 AS [Level] 
	FROM updated_initial U
	UNION ALL
	SELECT 
		s.MetricId, 
		s.RuleRowId,
		s.MonitorRowId,
		mt.ManagedEntityTypeRowId,
		s.[Level] + 1 AS [Level]
	FROM reverse_seed s
	INNER JOIN dbo.[ManagedEntityTypeManagementPackVersion] mtmpv WITH (NOLOCK) 
		ON mtmpv.BaseManagedEntityTypeRowId = s.ManagedEntityTypeRowId 
	INNER hash JOIN #LatestMpVersions mpv 
		ON mtmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
	INNER JOIN dbo.[ManagedEntityType] mt WITH (NOLOCK) 
		ON mtmpv.ManagedEntityTypeRowId = mt.ManagedEntityTypeRowId 
),
sorted_and_filtered AS 
(
	SELECT 
		rs.MetricId, 
		rs.ManagedEntityTypeRowId, 
		rs.RuleRowId, 
		rs.MonitorRowId,
		ROW_NUMBER() over (PARTITION by rs.MetricId, rs.ManagedEntityTypeRowId order by rs.RuleRowId desc, rs.MonitorRowId desc) AS rn
	FROM reverse_seed rs
	INNER JOIN 
	(
		SELECT 
			rsg.MetricId, 
			rsg.ManagedEntityTypeRowId, 
			MIN(rsg.[Level]) AS Level 
		FROM reverse_seed rsg 
		group by rsg.MetricId, rsg.ManagedEntityTypeRowId
	) rsm 
		ON rsm.MetricId = rs.MetricId 
		AND rsm.ManagedEntityTypeRowId = rs.ManagedEntityTypeRowId 
		AND rsm.Level = rs.Level
)
INSERT INTO #classMappings
SELECT 
	s.MetricId,
	s.ManagedEntityTypeRowId,
	s.RuleRowId,
	s.MonitorRowId
FROM sorted_and_filtered s
WHERE s.rn = 1
order by s.ManagedEntityTypeRowId, s.MetricId

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('DECLARE @classMappings', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

DECLARE @LagWindow int;
SET @LagWindow = -1;

create table #items (
	GroupId uniqueidentifier,
	RowId int,
	Unmonitored bit,
	Maintenance bit,
	PlannedMaintenance bit,
	LastPresencePeriodStarted DateTime
	UNIQUE CLUSTERED (RowId, GroupId)
);

-- TODO: ADD the check FOR management group AND FOR managemement pack versions

; with originalItems as 
(
	SELECT 
		g.Id AS GroupId, 
		Child.ManagedEntityRowId AS RowId,
		Child.ManagedEntityTypeRowId
	FROM #groups g
	INNER loop JOIN dbo.vManagedEntity Parent WITH (NOLOCK) 
		ON g.RowId = Parent.ManagedEntityRowId AND Parent.ManagementGroupRowId = @ManagementGroupRowId
	INNER JOIN dbo.vManagedEntityManagementGroup memg1 WITH (NOLOCK) 
		ON Parent.ManagedEntityRowId = memg1.ManagedEntityRowId
	INNER JOIN dbo.vRelationship rel WITH (NOLOCK) 
		ON Parent.ManagedEntityRowId = rel.SourceManagedEntityRowId 
		AND rel.ManagementGroupRowId = @ManagementGroupRowId
	INNER JOIN dbo.vRelationshipManagementGroup rmg WITH (NOLOCK) 
		ON rel.RelationshipRowId = rmg.RelationshipRowId
	INNER JOIN #FilteredRT frt 
		ON rel.RelationshipTypeRowId = frt.RelationshipTypeRowId
	INNER JOIN dbo.vManagedEntity Child WITH (NOLOCK) 
		ON rel.TargetManagedEntityRowId = Child.ManagedEntityRowId 
		AND Child.ManagementGroupRowId = @ManagementGroupRowId
	WHERE memg1.ToDateTime is NULL 
		AND rmg.ToDateTime is NULL
),
classTypeItemIds AS (
	SELECT DISTINCT
		tme.ManagedEntityRowId, tme.ManagedEntityRowId as Parent
	FROM #groupClassTypes gct
	INNER LOOP JOIN dbo.vTypedManagedEntity tme WITH (NOLOCK) ON gct.ManagedEntityTypeRowId = tme.ManagedEntityTypeRowId
	WHERE tme.ToDateTime IS NULL
),
getParents AS (
	SELECT ManagedEntityRowId, rhg.Parent AS Parent
	FROM classTypeItemIds c
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON c.ManagedEntityRowId = rhg.Child	
),
getParents2 AS (
	SELECT DISTINCT ManagedEntityRowId, rhg.Parent AS Parent
	FROM getParents	s		
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.Parent = rhg.Child	
),
getParents3 AS (
	SELECT DISTINCT ManagedEntityRowId, rhg.Parent AS Parent
	FROM getParents2	s		
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.Parent = rhg.Child	
),
getParents4 AS (
	SELECT DISTINCT ManagedEntityRowId, rhg.Parent AS Parent
	FROM getParents3	s		
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.Parent = rhg.Child	
),
getAllParents AS (
	SELECT * FROM getParents4 
	UNION ALL
	SELECT * FROM getParents3
	UNION ALL
	SELECT * FROM getParents2
	UNION ALL
	SELECT * FROM getParents
	UNION ALL
	SELECT * FROM classTypeItemIds
),
checkAllowance AS (
  SELECT DISTINCT ManagedEntityRowId FROM getAllParents ri
  INNER JOIN #allowedGroups ag ON ri.Parent = ag.RowId
),

classTypesItems as 
(
	SELECT 
		g.Id AS GroupId, 
		tme.ManagedEntityRowId AS RowId,
		tme.ManagedEntityTypeRowId
	FROM #groups g
	INNER JOIN #groupClassTypes gct 
		ON g.Id = gct.GroupId
	INNER JOIN dbo.vTypedManagedEntity tme WITH (NOLOCK) 
		ON gct.ManagedEntityTypeRowId = tme.ManagedEntityTypeRowId AND tme.ToDateTime IS NULL
	INNER JOIN dbo.vManagedEntity me WITH (NOLOCK) 
		ON tme.ManagedEntityRowId = me.ManagedEntityRowId	
	WHERE me.ManagementGroupRowId = @ManagementGroupRowId
	AND EXISTS(SELECT NULL FROM checkAllowance ai WHERE ai.ManagedEntityRowId = me.ManagedEntityRowId)		
),
both as 
(
	SELECT * FROM originalItems
	UNION ALL
	SELECT * FROM classTypesItems
)

INSERT INTO #items
SELECT 
	i.GroupId,
	i.RowId,
	0 AS Unmonitored, 
	max(CASE WHEN mm.MaintenanceModeRowId is NULL THEN 0 ELSE 1 END) AS Maintenance,
	max(isnull(cast(mm.PlannedMaintenanceInd AS int), 0)) AS PlannedMaintenance,
	DATEADD(HOUR, @LagWindow, max(memg2.FromDateTime)) AS LastPresencePeriodStarted
FROM both i
INNER JOIN dbo.vManagedEntityManagementGroup memg2 WITH (NOLOCK) 
	ON i.RowId = memg2.ManagedEntityRowId
LEFT JOIN dbo.vMaintenanceMode mm WITH (NOLOCK) 
	ON mm.ManagedEntityRowId = i.RowId 
	AND mm.EndDateTime is NULL
WHERE memg2.ToDateTime is NULL 
group by i.RowId, i.GroupId
order by RowId, GroupId;

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('DECLARE @items', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

UPDATE #items
	SET Unmonitored = 1
FROM #items as i
INNER JOIN dbo.vManagedEntity AS me WITH (NOLOCK) 
	ON i.RowId = me.ManagedEntityRowId
INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) 
	ON me.ManagedEntityRowId = memg.ManagedEntityRowId
INNER JOIN dbo.vRelationship AS r WITH (NOLOCK) 
	ON me.TopLevelHostManagedEntityRowId = r.TargetManagedEntityRowId
INNER JOIN dbo.vRelationshipType AS rt WITH (NOLOCK) 
	ON rt.RelationshipTypeRowId = r.RelationshipTypeRowId
INNER JOIN dbo.vRelationshipManagementGroup rmg WITH (NOLOCK) 
	ON r.RelationshipRowId = rmg.RelationshipRowId
INNER JOIN dbo.vHealthServiceOutage AS HSO WITH (NOLOCK) 
	ON HSO.ManagedEntityRowId = r.SourceManagedEntityRowId
WHERE rt.RelationshipTypeSystemName = 'Microsoft.SystemCenter.HealthServiceManagesEntity'
    AND rmg.ToDateTime is NULL
	AND memg.ToDateTime is NULL 
    AND HSO.EndDateTime is NULL
    AND NOT EXISTS
    (
		SELECT * 
		FROM dbo.vHealthServiceOutage AS HSO2 WITH (NOLOCK)
        WHERE HSO2.DWLastModifiedDateTime = HSO.DWLastModifiedDateTime
            AND HSO2.ManagedEntityRowId = HSO.ManagedEntityRowId
            AND HSO2.ReasonCode = HSO.ReasonCode
            AND HSO2.RootHealthServiceInd = HSO.RootHealthServiceInd
            AND HSO2.StartDateTime = HSO.StartDateTime
            AND HSO2.EndDateTime is NOT NULL
	)

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('UPDATE @items', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #hierarchicItems (
	GroupId uniqueidentifier,
	RowId int,
	LastPresencePeriodStarted DateTime,
	Unmonitored int,
	Maintenance int
);

create unique clustered index ix_rowid on #hierarchicItems (RowId, GroupId)

; WITH seed AS 
(
	SELECT 
		i.GroupId AS GroupId, 
		i.RowId AS RowId, 
		cast(Unmonitored AS int) AS Unmonitored
	FROM #items i 
),

--old rCTE variant, too slow.

--data AS (
--SELECT * FROM seed
--UNION ALL
--SELECT 
--	s.GroupId AS GroupId, 
--	rhg.Child AS RowId,
--	s.Unmonitored
--FROM data s
--INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.RowId = rhg.Parent
--),

data1 AS 
(
	SELECT 
		s.GroupId AS GroupId, 
		rhg.Child AS RowId,
		s.Unmonitored
	FROM seed s
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) 
		ON s.RowId = rhg.Parent
),
data2 AS 
(
	SELECT 
		s.GroupId AS GroupId, 
		rhg.Child AS RowId,
		s.Unmonitored
	FROM data1 s
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) 
		ON s.RowId = rhg.Parent
),
data3 AS 
(
	SELECT 
		s.GroupId AS GroupId, 
		rhg.Child AS RowId,
		s.Unmonitored
	FROM data2 s
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) 
		ON s.RowId = rhg.Parent
),
data4 AS 
(
	SELECT 
		s.GroupId AS GroupId, 
		rhg.Child AS RowId,
		s.Unmonitored
	FROM data3 s
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) 
		ON s.RowId = rhg.Parent
),
combinedData AS 
(
	SELECT * FROM seed
	UNION ALL
	SELECT * FROM data1
	UNION ALL
	SELECT * FROM data2
	UNION ALL
	SELECT * FROM data3
	UNION ALL
	SELECT * FROM data4
),
hItems AS 
(
	SELECT 
		GroupId, 
		RowId, 
		DATEADD(HOUR, @LagWindow, max(memg.FromDateTime)) AS LastPresencePeriodStarted, 
		max(Unmonitored) AS Unmonitored, 
		max(CASE WHEN mm.MaintenanceModeRowId is NOT NULL THEN 1 ELSE 0 END) AS Maintenance 
	FROM combinedData cd
	INNER JOIN dbo.vManagedEntity me WITH (NOLOCK) 
		ON cd.RowId = me.ManagedEntityRowId 
		AND me.ManagementGroupRowId = @ManagementGroupRowId
	INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) 
		ON me.ManagedEntityRowId = memg.ManagedEntityRowId
	left JOIN dbo.vMaintenanceMode mm WITH (NOLOCK) 
		ON mm.ManagedEntityRowId = me.ManagedEntityRowId 
		AND mm.EndDateTime is NULL
	WHERE memg.ToDateTime is NULL
	group by RowId, GroupId
)

-- code to get health for hierarchic items. Now it is not used, very slow.

--hItemsWithHealth AS(
--SELECT  
--	hItems.GroupId, 
--	hItems.RowId, 
--	hItems.LastPresencePeriodStarted, 
--	CASE WHEN s.HealthState = 1 THEN 1 ELSE 0 END AS IsHealthy, 
--	hItems.Unmonitored, 
--	hItems.Maintenance,
--	ROW_NUMBER() over (PARTITION by hItems.RowId, hItems.GroupId order by s.DateTime desc) AS rn
--FROM hItems
--INNER JOIN @groups g ON hItems.GroupId = g.Id
--INNER JOIN @Metrics m ON g.Id = m.GroupId AND m.MetricType = 0
--left JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues AS s  WITH (NOLOCK) ON s.ManagedEntityRowId = hItems.RowId AND s.MonitorRowId = m.MonitorRowId AND s.DateTime > hItems.LastPresencePeriodStarted
--)

INSERT INTO #hierarchicItems
SELECT 
	GroupId,
	RowId,
	LastPresencePeriodStarted,
	Unmonitored,
	Maintenance
FROM hItems
order by RowId, GroupId;

-- SELECT count(*) FROM @hierarchicItems;

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('INSERT @hierarchicItems', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #itemMappings (
	RowId int,
	ManagedEntityTypeRowId int
);

create unique clustered index ix_rowid on #itemmappings(Rowid, ManagedEntityTypeRowId)

INSERT INTO #itemMappings
SELECT DISTINCT t.ManagedEntityRowId AS RowId, t.ManagedEntityTypeRowId AS ManagedEntityTypeRowId
FROM dbo.vTypedManagedEntity t (NOLOCK)
WHERE EXISTS 
(
	SELECT NULL 
	FROM #hierarchicItems hi 
	WHERE hi.RowId = t.ManagedEntityRowId
)

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('INSERT @itemMappings', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
	
	SET @StartTimeSegment = getdate()
END

create table #metricValues (
	GroupId uniqueidentifier,
	MetricId uniqueidentifier,
	MetricType smallint,
	Name varchar(200),
	Value integer
);

-- State

-- check FROM opsmanager
--SELECT g.Id AS GroupId, m.Id AS MetricId, m.MetricType, s.HealthState AS Name, count(s.HealthState) AS Value
--  FROM [OperationsManager].[dbo].[State] s WITH (NOLOCK) 
--  INNER JOIN @items i ON s.BaseManagedEntityId = i.Id
--  INNER JOIN @groups g ON i.GroupId = g.Id
--  INNER JOIN @Metrics m ON m.GroupId = g.Id AND m.MetricType = 0
--  WHERE MonitorId = [OperationsManager].dbo.fn_ManagedTypeId_SystemHealthEntityState()
--  group by g.Id, m.Id, m.MetricType, s.HealthState;

INSERT INTO #metricValues
SELECT 
	g.Id AS GroupId, 
	m.Id AS MetricId, 
	m.MetricType, 
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1
	END AS Name, 
	count(i.RowId) AS Value
FROM #items i
INNER JOIN #groups g 
	ON i.GroupId = g.Id
INNER JOIN #Metrics m 
	ON g.Id = m.GroupId 
	AND m.MetricType = 0
LEFT JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues AS s  WITH (NOLOCK) 
	ON s.ManagedEntityRowId = i.RowId 
	AND s.MonitorRowId = m.MonitorRowId
WHERE s.DateTime IS NULL 
  or s.DateTime > i.LastPresencePeriodStarted
group by g.Id, m.Id, m.MetricType, 	
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1
	END;	

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('Aggregate State', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

-- count items (Type 4)

INSERT INTO #metricValues
SELECT 
	g.Id AS GroupId, 
	m.Id AS MetricId, 
	m.MetricType, 
	'1' AS Name, 
	count(DISTINCT i.RowId) AS Value
FROM #hierarchicItems i
INNER JOIN #groups g 
	ON i.GroupId = g.Id
INNER JOIN #Metrics m 
	ON g.Id = m.GroupId 
	AND m.MetricType = 4
INNER JOIN #itemMappings im 
	ON i.RowId = im.RowId
INNER JOIN #classMappings cm 
	ON cm.ManagedEntityTypeRowId = im.ManagedEntityTypeRowId 
	AND cm.MetricId = m.Id 
group by g.Id, m.Id, m.MetricType;

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('Aggregate count items', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END
-- Alert

DECLARE @DayOffset int;
SET @DayOffset = -1 * (@AutoResolveDays + @ResolvedAlertDaysToKeep + 1);

DECLARE @DateStart datetime;
Set @DateStart = DATEADD(DAY, @DayOffset, @launchDateTime);

INSERT INTO #metricValues
SELECT g.Id AS GroupId, m.Id AS MetricId, m.MetricType, a.Severity AS Name, count(a.Severity) AS Value
FROM #hierarchicItems i
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues AS a WITH (NOLOCK) 
	ON a.ManagedEntityRowId = i.RowId
INNER JOIN #groups g 
	ON i.GroupId = g.Id
INNER JOIN #Metrics m 
	ON g.Id = m.GroupId 
	AND m.MetricType = 1
WHERE a.ResolutionState <> 255
-- filtering by instance presence
	AND a.DateTime > CASE WHEN i.LastPresencePeriodStarted > @DateStart THEN i.LastPresencePeriodStarted ELSE @DateStart END
-- Save some time by assuming the instance is always not healthy.
--AND a.DateTime > DATEADD(DAY, -1 * (CASE 
--	WHEN i.IsHealthy = 1 
--	THEN @AutoResolveHealthyObjDays 
--	ELSE @AutoResolveDays 
group by g.Id, m.Id, m.MetricType, a.Severity;	

; WITH PossibleAlertStates AS 
(
	SELECT 0 AS State
	UNION ALL
	SELECT 1
	UNION ALL
	SELECT 2
),
PossibleHealthStates AS 
(
	SELECT 1 AS State
	UNION ALL
	SELECT 2
	UNION ALL
	SELECT 3
	UNION ALL
	SELECT 4
	UNION ALL
	SELECT 5
	UNION ALL 
	SELECT 6
),
PossibleCountStates AS 
(
	SELECT 1 AS State
),
FullSet AS 
(
	SELECT m.GroupId, m.Id AS MetricId, m.MetricType, ps.State AS Name, 0 AS Value 
	FROM PossibleAlertStates ps
	full JOIN #Metrics m 
        ON 1=1
	WHERE m.MetricType = 1
	UNION ALL 
	SELECT m.GroupId, m.Id AS MetricId, m.MetricType, ps.State AS Name, 0 AS Value 
	FROM PossibleHealthStates ps
	full JOIN #Metrics m 
        ON 1=1
	WHERE m.MetricType = 0
	UNION ALL 
	SELECT m.GroupId, m.Id AS MetricId, m.MetricType, ps.State AS Name, 0 AS Value 
	FROM PossibleCountStates ps
	full JOIN #Metrics m 
        ON 1=1
	WHERE m.MetricType = 4
)
INSERT INTO #metricValues
SELECT fs.* 
FROM FullSet fs 
left JOIN #metricValues mv 
	ON fs.GroupId = mv.GroupId 
	AND fs.MetricId = mv.MetricId 
	AND fs.MetricType = mv.MetricType 
	AND fs.Name = mv.Name
WHERE mv.Name is NULL

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()

	INSERT INTO #profilingdata 
	VALUES ('Aggregate Alert', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

-- Monitors

INSERT INTO #metricValues
SELECT 
	g.Id AS GroupId, 
	m.Id AS MetricId, 
	m.MetricType, 
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1 
	END AS Name, 
	count(DISTINCT i.RowId) AS Value
FROM #hierarchicItems i
INNER JOIN #groups g 
	ON i.GroupId = g.Id
INNER JOIN #Metrics m 
	ON g.Id = m.GroupId AND m.MetricType = 2
INNER JOIN #itemMappings im 
	ON i.RowId = im.RowId
INNER JOIN #classMappings cm 
	ON cm.ManagedEntityTypeRowId = im.ManagedEntityTypeRowId AND cm.MetricId = m.Id
LEFT JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues AS s WITH (NOLOCK) 
	ON s.ManagedEntityRowId = i.RowId 
	AND s.MonitorRowId = cm.MonitorRowId
WHERE s.DateTime IS NULL or s.DateTime > i.LastPresencePeriodStarted
group by g.Id, m.Id, m.MetricType, 	
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1 
	END;	

IF @profiling = 1
BEGIN
	SET @EndTimeSegment = getdate()
	
	INSERT INTO #profilingdata 
	VALUES ('Aggregate Monitors', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

	SET @StartTimeSegment = getdate()
END

create table #floatMetricValues (
	GroupId uniqueidentifier,
	MetricId uniqueidentifier,
	MetricType smallint,
	Name varchar(200),
	Value float
);

-- average Performance (Type 5)

INSERT INTO #floatMetricValues
SELECT 
	GroupId,
	MetricId,
	MetricType,
	Name,
	avg(Value) AS Value
FROM 
(
	SELECT 
		g.Id AS GroupId, 
		m.Id AS MetricId, 
		m.MetricType, 
		'1' AS Name, 
		i.RowId AS RowId,
		avg(vpr.SampleValue) AS Value
	FROM #hierarchicItems i 
	INNER JOIN #groups g 
		ON i.GroupId = g.Id
	INNER JOIN #Metrics m 
		ON m.GroupId = g.Id 
		AND m.MetricType = 5
	INNER JOIN #itemMappings im 
		ON i.RowId = im.RowId
	INNER JOIN #classMappings cm 
		ON cm.ManagedEntityTypeRowId = im.ManagedEntityTypeRowId 
		AND cm.MetricId = m.Id
	INNER JOIN dbo.[Rule] r WITH (NOLOCK) 
		ON r.RuleRowId = cm.RuleRowId
	INNER JOIN dbo.PerformanceRuleInstance pri WITH (NOLOCK) 
		ON pri.RuleRowId = r.RuleRowId
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues vpr WITH (NOLOCK) 
		ON pri.PerformanceRuleInstanceRowId = vpr.PerformanceRuleInstanceRowId 
		AND vpr.ManagedEntityRowId = i.RowId
	WHERE vpr.DateTime >= @firstDateTime 
	  AND vpr.DateTime > i.LastPresencePeriodStarted
	group by g.Id, m.Id, m.MetricType, i.RowId
) a
group by GroupId, MetricId, MetricType, Name;

IF @profiling = 1
BEGIN
    SET @EndTimeSegment = getdate()

    INSERT INTO #profilingdata 
    VALUES ('Aggregate average Performance', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

    SET @StartTimeSegment = getdate()
END


-- SELECT * FROM @metricValues

-- Performance 
DECLARE @float10 float = 10;
DECLARE @replacement char(2) = 'xx';
create table #perfRuleValues 
(
	GroupId uniqueidentifier,
	MetricId uniqueidentifier,
	part varchar(200),
	value1 float, 
	value2 float, 
	value3 float, 
	value4 float, 
	value5 float, 
	value6 float, 
	value1_text varchar(4),
	value2_text varchar(4),
	value3_text varchar(4),
	value4_text varchar(4),
	value5_text varchar(4),
	value6_text varchar(4),
	count1 integer,
	count2 integer,
	count3 integer,
	count4 integer,
	count5 integer
);

DECLARE @BarCount integer = 5;
DECLARE @MinimalSpread float = 0.5;

    SELECT 
        g.Id AS GroupId,
        m.Id AS MetricId, 
        i.RowId,
        --vpr.SampleValue * CASE WHEN vpr.SampleValue > 50 THEN -100000000 ELSE 100000 END AS SampleValue
        avg(vpr.SampleValue) AS SampleValue
    into #perfValues
    FROM #hierarchicItems i 
    INNER JOIN #groups g 
        ON i.GroupId = g.Id
    INNER JOIN #Metrics m 
        ON m.GroupId = g.Id 
        AND m.MetricType = 3
    INNER JOIN #itemMappings im 
        ON i.RowId = im.RowId
    INNER JOIN #classMappings cm 
        ON cm.ManagedEntityTypeRowId = im.ManagedEntityTypeRowId 
        AND cm.MetricId = m.Id
    INNER JOIN dbo.[Rule] r WITH (NOLOCK) 
        ON r.RuleRowId = cm.RuleRowId
    INNER JOIN dbo.PerformanceRuleInstance pri WITH (NOLOCK) 
        ON pri.RuleRowId = r.RuleRowId
    INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues vpr WITH (NOLOCK) 
        ON pri.PerformanceRuleInstanceRowId = vpr.PerformanceRuleInstanceRowId 
        AND vpr.ManagedEntityRowId = i.RowId
    WHERE vpr.DateTime >= @firstDateTime 
      AND vpr.DateTime > i.LastPresencePeriodStarted
    group by g.Id, m.Id, i.RowId
    option(recompile)

    --create clustered index ix_perfValues on #perfValues (groupid, metricid)

    SELECT 
        GroupId AS GroupId,
	    MetricId AS MetricId, 
	    MIN(SampleValue) AS minValue, 
	    max(SampleValue) AS maxValue,
	    count(DISTINCT SampleValue) AS countValues
    into #limits
    FROM #perfValues 
    group by GroupId, MetricId

    --create clustered index ix_limits on #limits (groupId, metricId)


;WITH calc_e AS 
  (
      SELECT 
	    GroupId,
	    MetricId,
	    minValue,
	    maxValue,
	    CONVERT(integer, SUBSTRING(CONVERT(varchar, CASE WHEN ABS(maxValue) > ABS(minValue) THEN ABS(maxValue) ELSE ABS(minValue) END, 2), 19, 4)) AS e
      FROM #limits
  ),
  catch_one AS 
  (
    SELECT 
        GroupId,
        MetricId,
        minValue,
        maxValue,
        CASE WHEN e = 1 THEN 0 ELSE e END AS e
    FROM calc_e
  ),
  expand_minmax AS 
  (
    SELECT 
        GroupId,
        MetricId,
        minValue,
        CASE WHEN (maxValue - minValue)/power(@float10, e) < @MinimalSpread THEN maxValue + @MinimalSpread*power(@float10, e) ELSE maxValue END AS maxValue,
        e
    FROM catch_one
  ),
  recalc_limits AS 
  (
    SELECT 
        GroupId,
        MetricId,
        FLOOR(minValue/power(@float10, e - 1))*power(@float10, e - 1) AS minValue,
        CEILING(maxValue/power(@float10, e - 1))*power(@float10, e - 1) AS maxValue,
        (CEILING(maxValue/power(@float10, e - 1)) - FLOOR(minValue/power(@float10, e - 1))) AS diff,
        (CEILING(maxValue/power(@float10, e - 1)) - FLOOR(minValue/power(@float10, e - 1))) / @BarCount AS step,
        ((CEILING(maxValue/power(@float10, e - 1)) - FLOOR(minValue/power(@float10, e - 1))) / @BarCount) * power(@float10, e - 1) AS actualStep,
        CASE WHEN e = 0 THEN '' ELSE '10^'+cast(e AS varchar) END AS part,
        e AS e
    FROM expand_minmax
  ),
  intervals AS 
  (
      SELECT
        GroupId,
        MetricId, 
	    minValue AS value1, 
	    minValue + actualStep * 1 AS value2,
	    minValue + actualStep * 2 AS value3,
	    minValue + actualStep * 3 AS value4,
	    minValue + actualStep * 4 AS value5,
	    maxValue AS value6
      FROM recalc_limits
  ), 
  recalc_intervals AS 
  (
      SELECT
        i.GroupId, 
	    i.MetricId, 
	    i.value1, 
	    i.value2, 
	    i.value3, 
	    i.value4, 
	    i.value5, 
	    i.value6, 
	    l.part, 
	    l.e,
	    LTRIM(STR(ROUND(ROUND(ABS(i.value1) - FLOOR(ABS(i.value1)/power(@float10, l.e + 2))*power(@float10, l.e + 2), - (l.e - 1)) * SIGN(i.value1) / power(@float10, l.e), 1), 4, 1)) AS value1_text,
	    LTRIM(STR(ROUND(ROUND(ABS(i.value2) - FLOOR(ABS(i.value2)/power(@float10, l.e + 2))*power(@float10, l.e + 2), - (l.e - 1)) * SIGN(i.value2) / power(@float10, l.e), 1), 4, 1)) AS value2_text,
	    LTRIM(STR(ROUND(ROUND(ABS(i.value3) - FLOOR(ABS(i.value3)/power(@float10, l.e + 2))*power(@float10, l.e + 2), - (l.e - 1)) * SIGN(i.value3) / power(@float10, l.e), 1), 4, 1)) AS value3_text,
	    LTRIM(STR(ROUND(ROUND(ABS(i.value4) - FLOOR(ABS(i.value4)/power(@float10, l.e + 2))*power(@float10, l.e + 2), - (l.e - 1)) * SIGN(i.value4) / power(@float10, l.e), 1), 4, 1)) AS value4_text,
	    LTRIM(STR(ROUND(ROUND(ABS(i.value5) - FLOOR(ABS(i.value5)/power(@float10, l.e + 2))*power(@float10, l.e + 2), - (l.e - 1)) * SIGN(i.value5) / power(@float10, l.e), 1), 4, 1)) AS value5_text,
	    LTRIM(STR(ROUND(ROUND(ABS(i.value6) - FLOOR(ABS(i.value6)/power(@float10, l.e + 2))*power(@float10, l.e + 2), - (l.e - 1)) * SIGN(i.value6) / power(@float10, l.e), 1), 4, 1)) AS value6_text
      FROM intervals i
      INNER JOIN recalc_limits l 
        ON i.GroupId = l.GroupId 
        AND i.MetricId = l.MetricId
  )
  SELECT * INTO #recalc_intervals FROM recalc_intervals

  ;WITH count_intervals AS 
  (
      SELECT 
	    i.GroupId, 
	    i.MetricId, 
	    count(CASE WHEN P.SampleValue >= i.value1 AND P.SampleValue < i.value2 THEN 1 ELSE NULL END) AS count1,
	    count(CASE WHEN P.SampleValue >= i.value2 AND P.SampleValue < i.value3 THEN 1 ELSE NULL END) AS count2,
	    count(CASE WHEN P.SampleValue >= i.value3 AND P.SampleValue < i.value4 THEN 1 ELSE NULL END) AS count3,
	    count(CASE WHEN P.SampleValue >= i.value4 AND P.SampleValue < i.value5 THEN 1 ELSE NULL END) AS count4,
	    count(CASE WHEN P.SampleValue >= i.value5 AND P.SampleValue <= i.value6 THEN 1 ELSE NULL END) AS count5
      FROM #recalc_intervals i 
      INNER JOIN #perfValues P 
        ON P.GroupId = i.GroupId 
        AND P.MetricId = i.MetricId
      group by i.GroupId, i.MetricId
  )
  INSERT INTO #perfRuleValues
  SELECT 
	ci.GroupId, 
	ci.MetricId AS MetricId, 
	i.part, 
	ROUND(i.value1, - (e - 1)), 
	ROUND(i.value2, - (e - 1)), 
	ROUND(i.value3, - (e - 1)), 
	ROUND(i.value4, - (e - 1)), 
	ROUND(i.value5, - (e - 1)), 
	ROUND(i.value6, - (e - 1)), 
	i.value1_text, 
	i.value2_text, 
	i.value3_text, 
	i.value4_text, 
	i.value5_text, 
	i.value6_text, 
	ci.count1,
	ci.count2,
	ci.count3,
	ci.count4,
	ci.count5
  FROM count_intervals ci
  INNER JOIN #recalc_intervals i 
    ON ci.MetricId = i.MetricId 
    AND ci.GroupId = i.GroupId;
  
IF @profiling = 1
BEGIN
    SET @EndTimeSegment = getdate()

    INSERT INTO #profilingdata 
    VALUES ('Aggregate Performance', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

    SET @StartTimeSegment = getdate()
END;

  ---------- XML generation
;SELECT          
	999 AS TAG, 
	NULL AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	NULL AS [AggregatedData!1!GroupId],
	NULL AS [AggregatedData!1!MetricId],
	NULL AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	NULL AS [DataPointType!2!IndependentValue],
	NULL AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
UNION ALL
SELECT          
	3 AS TAG, 
	999 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	NULL AS [AggregatedData!1!GroupId],
	NULL AS [AggregatedData!1!MetricId],
	NULL AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	NULL AS [DataPointType!2!IndependentValue],
	NULL AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	'' AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
UNION ALL
SELECT          
	4 AS TAG, 
	3 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	NULL AS [AggregatedData!1!GroupId],
	NULL AS [AggregatedData!1!MetricId],
	NULL AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	NULL AS [DataPointType!2!IndependentValue],
	NULL AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	'' AS [Groups!3],
	g.Id AS [Group!4!Guid],
	g.InstanceId AS [Group!4!Id]	
FROM #groups g	
UNION ALL
SELECT          
	1 AS TAG, 
	999 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	CASE WHEN m.MetricType IN (0,1,255) THEN NULL ELSE m.Id END AS [AggregatedData!1!MetricId],
	CASE 
		WHEN m.MetricType = 0 THEN 'State' 
		WHEN m.MetricType = 1 THEN 'Alerts' 
		WHEN m.MetricType IN (2,4,5) THEN 'Metric' 
		WHEN m.MetricType = 255 AND m.MonitorRowId = 1 THEN 'Forbidden'
		WHEN m.MetricType = 255 AND m.MonitorRowId = 2 THEN 'Allowed'
	END AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	NULL AS [DataPointType!2!IndependentValue],
	NULL AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #Metrics m
WHERE m.MetricType IN (0,1,2,4,5,255)
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	CASE WHEN m.MetricType IN (0,1) THEN NULL ELSE m.Id END AS [AggregatedData!1!MetricId],
	CASE 
		WHEN m.MetricType = 0 THEN 'State' 
		WHEN m.MetricType = 1 THEN 'Alerts' 
		WHEN m.MetricType IN (2,4,5) THEN 'Metric' 
	END AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	mv.Name AS [DataPointType!2!IndependentValue],
	mv.Value AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #Metrics m
INNER JOIN #metricValues mv 
    ON m.Id = mv.MetricId 
    AND m.GroupId = mv.GroupId 
    AND m.MetricType = mv.MetricType
WHERE m.MetricType IN (0,1,2,4)
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	CASE WHEN m.MetricType IN (0,1) THEN NULL ELSE m.Id END AS [AggregatedData!1!MetricId],
	CASE 
		WHEN m.MetricType = 0 THEN 'State' 
		WHEN m.MetricType = 1 THEN 'Alerts' 
		WHEN m.MetricType IN (2,4,5) THEN 'Metric' 
	END AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	mv.Value AS [DataPointType!2!IndependentValue],
	mv.Name AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #Metrics m
INNER JOIN #floatMetricValues mv 
    ON m.Id = mv.MetricId 
    AND m.GroupId = mv.GroupId 
    AND m.MetricType = mv.MetricType
WHERE m.MetricType IN (5)
UNION ALL
SELECT          
	1 AS TAG, 
	999 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.Id AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	NULL AS [AggregatedData!1!AdditionalData],
	NULL AS [DataPointType!2!IndependentValue],
	NULL AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues prv
right JOIN #Metrics m 
    ON prv.GroupId = m.GroupId 
    AND prv.MetricId = m.Id
WHERE prv.MetricId is NULL 
  AND m.MetricType = 3
UNION ALL
SELECT          
	1 AS TAG, 
	999 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.MetricId AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	m.part AS [AggregatedData!1!AdditionalData],
	NULL AS [DataPointType!2!IndependentValue],
	NULL AS [DataPointType!2!DependentValue],
	NULL AS [DataPointType!2!IndependentEndValue],
	NULL AS [DataPointType!2!DependentValueDesc],
	NULL AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues m
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.MetricId AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	m.part AS [AggregatedData!1!AdditionalData],
	m.value1 AS [DataPointType!2!IndependentValue],
	m.count1 AS [DataPointType!2!DependentValue],
	m.value2 AS [DataPointType!2!IndependentEndValue],
	m.value1_text AS [DataPointType!2!DependentValueDesc],
	m.value2_text AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues m
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.MetricId AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	m.part AS [AggregatedData!1!AdditionalData],
	m.value2 AS [DataPointType!2!IndependentValue],
	m.count2 AS [DataPointType!2!DependentValue],
	m.value3 AS [DataPointType!2!IndependentEndValue],
	m.value2_text AS [DataPointType!2!DependentValueDesc],
	m.value3_text AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues m
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.MetricId AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	m.part AS [AggregatedData!1!AdditionalData],
	m.value3 AS [DataPointType!2!IndependentValue],
	m.count3 AS [DataPointType!2!DependentValue],
	m.value4 AS [DataPointType!2!IndependentEndValue],
	m.value3_text AS [DataPointType!2!DependentValueDesc],
	m.value4_text AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues m
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.MetricId AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	m.part AS [AggregatedData!1!AdditionalData],
	m.value4 AS [DataPointType!2!IndependentValue],
	m.count4 AS [DataPointType!2!DependentValue],
	m.value5 AS [DataPointType!2!IndependentEndValue],
	m.value4_text AS [DataPointType!2!DependentValueDesc],
	m.value5_text AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues m
UNION ALL
SELECT          
	2 AS TAG, 
	1 AS Parent, 
	'' AS [ArrayOfAggregatedData!999],
	m.GroupId AS [AggregatedData!1!GroupId],
	m.MetricId AS [AggregatedData!1!MetricId],
	'Metric' AS [AggregatedData!1!DataTypeName],
	m.part AS [AggregatedData!1!AdditionalData],
	m.value5 AS [DataPointType!2!IndependentValue],
	m.count5 AS [DataPointType!2!DependentValue],
	m.value6 AS [DataPointType!2!IndependentEndValue],
	m.value5_text AS [DataPointType!2!DependentValueDesc],
	m.value6_text AS [DataPointType!2!IndependentValueDesc],
	NULL AS [Groups!3],
	NULL AS [Group!4!Guid],
	NULL AS [Group!4!Id]	
FROM #perfRuleValues m
order by 
	[ArrayOfAggregatedData!999],
	[AggregatedData!1!GroupId],
	[AggregatedData!1!MetricId],
	[AggregatedData!1!DataTypeName],
	[AggregatedData!1!AdditionalData],
	[DataPointType!2!IndependentValue],
	[DataPointType!2!IndependentEndValue],
	[DataPointType!2!DependentValueDesc],
	[DataPointType!2!IndependentValueDesc],
	[DataPointType!2!DependentValue],
	[Groups!3],
	[Group!4!Guid],
	[Group!4!Id]	
FOR XML EXPLICIT

IF @profiling = 1
BEGIN
    SET @EndTimeSegment = getdate()

    INSERT INTO #profilingdata 
    VALUES ('Produce OUTPUT', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))

    DECLARE @EndTime DateTime = getdate();

    INSERT INTO #profilingdata 
    VALUES ('Total time', DATEDIFF(MILLISECOND, @StartTime, @EndTime))

    SELECT * 
    FROM #profilingdata
END

    END TRY
    BEGIN CATCH
        IF (@@TRANCOUNT > 0)
            ROLLBACK TRAN

        SELECT
             @ErrorNumber = ERROR_NUMBER(),
             @ErrorSeverity = ERROR_SEVERITY(),
             @ErrorState = ERROR_STATE(),
             @ErrorLine = ERROR_LINE(),
             @ErrorProcedure = isnull(ERROR_PROCEDURE(), '-'),
             @ErrorMessageText = ERROR_MESSAGE()

        SET @ErrorInd = 1
    END CATCH

    -- report error IF any
    IF (@ErrorInd = 1)
    BEGIN
        DECLARE @AdjustedErrorSeverity int

        SET @AdjustedErrorSeverity = CASE
                                         WHEN @ErrorSeverity > 18 THEN 18
                                         ELSE @ErrorSeverity
                                     END

        RAISERROR ('error. Number: %d. Severity: %d. State: %d. PROCEDURE: %s. Line: %d. MessageText: %s.', @AdjustedErrorSeverity, 1
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

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_GetInstanceViewData]
	@ManagementGroupGuid uniqueidentifier,
    @XmlData XML,
	@profiling bit = 0
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

--	EXEC	[sdk].[Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData]
--		@ManagementGroupGuid = N'11C61275-6A83-BC2D-98FB-7457E9364340',
--		@XmlData = N'
	--<Data  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" ShowAlertsFromDescendants="false">
	--	<SelectedParent Id = "3e02a316-72f5-19bf-012d-da408822314b">
	--	<SelectedChild Id = "3e02a316-72f5-19bf-012d-da408822314b">
	--	<Interval Value="360">
	--  <Filter Value="ff">
	--	<DatacenterGroup Id="3e02a316-72f5-19bf-012d-da408822314b">
	--		<DataCenterClasses>
	--			<DataCenterClass ClassName="VIAcode.MPPerfTest!VIAcode.MPPerfTest.Object">
					
	--				<MonitorMetrics>
	--					<MonitorMetric MonitorId="f3dd67cd-1488-3a79-223c-de3b4b422024" MetricId = "Guid"/>
	--				</MonitorMetrics>
					
	--				<PerformanceMetrics>
	--					<PerformanceMetric PerformanceCollectionRuleId="39726668-d064-f717-9bbc-32f6fb4a9b30" MetricId="Guid"/>
	--				</PerformanceMetrics>
					
	--				lastvalue only
					
	--				<SmallPerformanceMetrics>
	--					<SmallPerformanceMetric PerformanceCollectionRuleId="39726668-d064-f717-9bbc-32f6fb4a9b30" MetricId="Guid"/>
	--				</SmallPerformanceMetrics>
	--			</DataCenterClass>
	--		</DataCenterClasses>
	--	</DatacenterGroup>
	--</Data>
/* ------------------------------ */

BEGIN TRY

DECLARE @ExecError int;
DECLARE @launchDateTime DateTime = getdate();

IF @profiling = 1
BEGIN
DECLARE @StartTime DateTime = getdate();
DECLARE @StartTimeSegment DateTime = getdate();
DECLARE @EndTimeSegment DateTime;
CREATE TABLE #profilingdata (
	Name varchar(200),
	length int
);
END

EXEC	@ExecError = [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateLastValues]

IF NOT @ExecError = 0
    RAISERROR('Text %s %d', 16, 1
        ,'ClassXml'
        ,@ExecError)

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('UPDATE VALUES', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

EXEC	@ExecError = [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateHierarchy]

IF NOT @ExecError = 0
    RAISERROR('Text %s %d', 16, 1
        ,'ClassXml'
        ,@ExecError)

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('UPDATE hierarchy', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END;

DECLARE @parentGuid uniqueidentifier;
DECLARE @parentSystemName nvarchar(2000);
SELECT @parentGuid = ParamValues.x.value('@Id[1]','uniqueidentifier'), @parentSystemName = ParamValues.x.value('@SystemName[1]','nvarchar(2000)')  FROM @XmlData.nodes('/Data/SelectedParent') AS ParamValues(x);

IF @parentGuid is null AND CHARINDEX('!', @parentSystemName) > 0
BEGIN
	SELECT @parentGuid = mt.ManagedEntityTypeGuid FROM dbo.[ManagedEntityType] mt WITH (NOLOCK) 
	INNER JOIN dbo.[ManagementPack] mp WITH (NOLOCK) ON mp.ManagementPackRowId = mt.ManagementPackRowId AND LOWER(SUBSTRING(@parentSystemName, 1, CHARINDEX('!', @parentSystemName) - 1)) = LOWER(mp.ManagementPackSystemName)
	WHERE LOWER(SUBSTRING(@parentSystemName, CHARINDEX('!', @parentSystemName) + 1, 2000)) = LOWER(mt.ManagedEntityTypeSystemName)
END;

DECLARE @parentRowId int;
SELECT @parentRowId = me.ManagedEntityRowId
FROM dbo.vManagedEntity me WITH (NOLOCK)
INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) on me.ManagedEntityRowId = memg.ManagedEntityRowId
WHERE me.ManagedEntityGuid = @parentGuid 
  AND memg.ToDateTime IS NULL

DECLARE @ManagementGroupRowId int;
SELECT @ManagementGroupRowId = mg.ManagementGroupRowId
FROM dbo.vManagementGroup mg 
WHERE mg.ManagementGroupGuid = @ManagementGroupGuid

CREATE TABLE #LatestMpVersions (
	ManagementPackRowId int,
	ManagementPackVersionRowId int
);

INSERT INTO #LatestMpVersions
	SELECT mpv.[ManagementPackRowId], MAX(mpv.[ManagementPackVersionRowId]) AS ManagementPackVersionRowId
	FROM  [dbo].[ManagementPackVersion] mpv (NOLOCK)
	JOIN [dbo].[ManagementGroupManagementPackVersion] mgmpv (NOLOCK) ON mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
	WHERE mgmpv.DeletedDateTime IS NULL AND mgmpv.ManagementGroupRowId = @ManagementGroupRowId
	GROUP BY mpv.[ManagementPackRowId]


CREATE TABLE #groupClassTypes (
	ManagedEntityTypeRowId int
	UNIQUE CLUSTERED (ManagedEntityTypeRowId)
);

;WITH classTypes AS (
	SELECT DISTINCT 
		ParamValues.x.value('@Id','nvarchar(2000)') AS ClassTypeId 
	FROM @XmlData.nodes('/Data/DatacenterGroup/ClassType') AS ParamValues(x)
)

INSERT INTO #groupClassTypes
SELECT 
	mt.ManagedEntityTypeRowId AS ManagedEntityTypeRowId
FROM classTypes s
INNER JOIN dbo.[ManagedEntityType] mt WITH (NOLOCK) ON LOWER(SUBSTRING(s.ClassTypeId, CHARINDEX('!', s.ClassTypeId) + 1, 2000)) = LOWER(mt.ManagedEntityTypeSystemName)
INNER JOIN dbo.[ManagementPack] mp WITH (NOLOCK) ON mp.ManagementPackRowId = mt.ManagementPackRowId AND LOWER(SUBSTRING(s.ClassTypeId, 1, CHARINDEX('!', s.ClassTypeId) - 1)) = LOWER(mp.ManagementPackSystemName)
WHERE CHARINDEX('!', s.ClassTypeId) > 0
ORDER by ManagedEntityTypeRowId

--Fill classes with first non-abstract descedant
;WITH DerivedTree (RowId,Abstract, Level) AS (
  SELECT c.ManagedEntityTypeRowId as RowId, mev.AbstractInd as Abstract, 0 as Level 
  FROM #groupClassTypes c 
  INNER JOIN dbo.vManagedEntityTypeManagementPackVersion mev WITH (NOLOCK) ON (c.ManagedEntityTypeRowId = mev.ManagedEntityTypeRowId)
  INNER JOIN dbo.vManagementPackVersion mpv WITH (NOLOCK) ON mev.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
  INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) ON (mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId AND  mgmpv.DeletedDateTime IS NULL)  
  WHERE mgmpv.ManagementGroupRowId = @ManagementGroupRowId
  AND mev.AbstractInd = 1
UNION ALL
  SELECT mev.ManagedEntityTypeRowId as RowId, mev.AbstractInd as Abstract,dt.Level +1 as Level
  FROM dbo.vManagedEntityTypeManagementPackVersion mev WITH (NOLOCK)
  INNER JOIN dbo.vManagementPackVersion mpv WITH (NOLOCK) ON mev.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
  INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) ON (mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId AND  mgmpv.DeletedDateTime IS NULL)
  INNER JOIN DerivedTree dt ON (dt.RowId = mev.BaseManagedEntityTypeRowId And dt.Abstract = 1)  
  WHERE dt.Level < 31 AND mgmpv.ManagementGroupRowId = @ManagementGroupRowId
)
INSERT INTO #groupClassTypes
SELECT DISTINCT dt.RowId as ManagedEntityTypeRowId From DerivedTree dt
WHERE Abstract = 0
  AND NOT EXISTS (SELECT NULL FROM #groupClassTypes gct WHERE dt.RowId = gct.ManagedEntityTypeRowId)

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('DECLARE #groupClassTypes', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

DECLARE @Filter varchar(1000);
SELECT @Filter = '%' + ParamValues.x.value('@Value','varchar(1000)') + '%' FROM @XmlData.nodes('/Data/Filter') AS ParamValues(x);


DECLARE @ShowAlertsFromDescendants int;
SELECT 
	@ShowAlertsFromDescendants = CASE WHEN LOWER(ParamValues.x.value('@ShowAlertsFromDescendants','varchar(5)')) = 'true' THEN 1 ELSE 0 END
 FROM @XmlData.nodes('/Data') AS ParamValues(x);

DECLARE @Interval int;
SELECT @Interval = ParamValues.x.value('@Value','int') FROM @XmlData.nodes('/Data/Interval') AS ParamValues(x);

DECLARE @LanguageCode varchar(10);
SELECT @LanguageCode = ParamValues.x.value('@Value','varchar(10)') FROM @XmlData.nodes('/Data/LanguageCode') AS ParamValues(x);

DECLARE @LanguageCodeENU varchar(10);
SELECT @LanguageCodeENU = 'ENU';

DECLARE @ResolvedAlertDaysToKeep int = NULL;
DECLARE @AutoResolveDays int = NULL;
DECLARE @AutoResolveHealthyObjDays int = NULL;
SELECT @ResolvedAlertDaysToKeep = ParamValues.x.value('@ResolvedAlertDaysToKeep', 'int'),
@AutoResolveDays = ParamValues.x.value('@AutoResolveDays', 'int'),
@AutoResolveHealthyObjDays = ParamValues.x.value('@AutoResolveHealthyObjDays', 'int')
FROM @XmlData.nodes('/DatacenterViewQuery/OpsManagerConfiguration') AS ParamValues(x) 

; WITH inserts AS (
SELECT @ManagementGroupGuid AS ManagementGroupGuid, 'ResolvedAlertDaysToKeep' AS Name, NULL AS Value
UNION ALL 
SELECT @ManagementGroupGuid AS ManagementGroupGuid, 'AutoResolveDays' AS Name, NULL AS Value
UNION ALL 
SELECT @ManagementGroupGuid AS ManagementGroupGuid, 'AutoResolveHealthyObjDays' AS Name, NULL AS Value
)

INSERT INTO sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
SELECT * FROM inserts i
WHERE NOT EXISTS (
	SELECT NULL 
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings oms 
	WHERE i.ManagementGroupGuid = oms.ManagementGroupGuid 
	  AND i.Name = oms.Name
)

IF @ResolvedAlertDaysToKeep is NOT NULL AND @AutoResolveDays is NOT NULL AND @AutoResolveHealthyObjDays is NOT NULL 
BEGIN
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
	SET Value = @ResolvedAlertDaysToKeep
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'ResolvedAlertDaysToKeep';
	
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
	SET Value = @AutoResolveDays
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveDays';
	
	UPDATE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
	SET Value = @AutoResolveHealthyObjDays
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveHealthyObjDays';
END
ELSE 
BEGIN
	SELECT @ResolvedAlertDaysToKeep = Value
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings WITH (NOLOCK)
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'ResolvedAlertDaysToKeep'

	IF @ResolvedAlertDaysToKeep is NULL
		SET @ResolvedAlertDaysToKeep = 7

	SELECT @AutoResolveDays = Value
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings WITH (NOLOCK)
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveDays'

	IF @AutoResolveDays is NULL
		SET @AutoResolveDays = 30

	SELECT @AutoResolveHealthyObjDays = Value
	FROM sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings WITH (NOLOCK)
	WHERE ManagementGroupGuid = @ManagementGroupGuid 
	  AND Name = 'AutoResolveHealthyObjDays'

	IF @AutoResolveHealthyObjDays is NULL
		SET @AutoResolveHealthyObjDays = 7
END

CREATE TABLE #allowedGroups (
	Id int PRIMARY KEY
);

;WITH allowedGroups AS (
	SELECT DISTINCT ParamValues.x.value('@ID','uniqueidentifier') AS [Guid] FROM @XmlData.nodes('/Data/OpsManagerConfiguration/AllowedGroup') AS ParamValues(x)
)

INSERT INTO #allowedGroups
SELECT me.ManagedEntityRowId FROM allowedGroups a
INNER JOIN dbo.ManagedEntity me WITH (NOLOCK) ON a.[Guid] = me.ManagedEntityGuid
INNER JOIN dbo.ManagedEntityManagementGroup memg WITH (NOLOCK) ON me.ManagedEntityRowId = memg.ManagedEntityRowId
WHERE me.ManagementGroupRowId = @ManagementGroupRowId
  AND memg.ToDateTime IS NULL;

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('load parameters', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

CREATE TABLE #FilteredRT (
	RelationshipTypeRowId int PRIMARY KEY
);

; WITH parentRT AS (
	SELECT TOP 1 rt.RelationshipTypeRowId
		FROM dbo.vRelationshipType rt WITH (NOLOCK)
		WHERE rt.RelationshipTypeSystemName = 'System.Containment'			
),
			
FilteredRT AS (
	SELECT RelationshipTypeRowId 
		FROM parentRT
	UNION ALL
	SELECT rth.Child AS RelationshipTypeRowId
		FROM parentRT rt WITH (NOLOCK)
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy rth WITH (NOLOCK) ON rt.RelationshipTypeRowId = rth.Parent
)

INSERT INTO #FilteredRT
SELECT DISTINCT * FROM FilteredRT;

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Insert #FilteredRT', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

CREATE TABLE #items (
	ManagedEntityGuid uniqueidentifier,
	RowId int,
	Unmonitored bit,
	Maintenance bit,
	PlannedMaintenance bit,
	HealthState int,
	FullPath nvarchar(2000),
	DisplayName nvarchar(2000),
	ManagedEntityTypeRowId int,
	HasChildren int
	UNIQUE CLUSTERED (RowId)
);

DECLARE @TypeDelimiter varchar(1) = ':';

DECLARE @AllowedParentId int;

; WITH requestedItems AS (
	SELECT @parentRowId AS Id
	UNION ALL
	SELECT 
		rhg.Parent AS Id
	FROM requestedItems s
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.Id = rhg.Child
	WHERE s.Id IS NOT NULL
)

SELECT TOP 1 @AllowedParentId = @parentRowId FROM requestedItems ri
INNER JOIN #allowedGroups ag ON ri.Id = ag.Id;

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Check access rights (@AllowedParentId)', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

; WITH originalItems AS (
	SELECT 
		Child.ManagedEntityGuid AS ManagedEntityGuid,
		Child.ManagedEntityRowId AS RowId, 
		Child.Path AS FullPath,
		Child.DisplayName AS DisplayName,
		Child.ManagedEntityTypeRowId
	FROM dbo.vManagedEntityManagementGroup memg1 WITH (NOLOCK)
	INNER JOIN dbo.vRelationship rel WITH (NOLOCK) ON memg1.ManagedEntityRowId = rel.SourceManagedEntityRowId AND rel.ManagementGroupRowId = @ManagementGroupRowId
	INNER JOIN dbo.vRelationshipManagementGroup rmg WITH (NOLOCK) ON rel.RelationshipRowId = rmg.RelationshipRowId
	INNER JOIN #FilteredRT frt ON rel.RelationshipTypeRowId = frt.RelationshipTypeRowId
	INNER JOIN dbo.vManagedEntity Child WITH (NOLOCK) ON rel.TargetManagedEntityRowId = Child.ManagedEntityRowId AND Child.ManagementGroupRowId = @ManagementGroupRowId
	WHERE memg1.ManagedEntityRowId = @AllowedParentId
		AND memg1.ToDateTime is NULL 
		AND rmg.ToDateTime is NULL
),

classTypeItemIds AS (
	SELECT DISTINCT
		tme.ManagedEntityRowId
	FROM #groupClassTypes gct
	INNER LOOP JOIN dbo.vTypedManagedEntity tme WITH (NOLOCK) ON gct.ManagedEntityTypeRowId = tme.ManagedEntityTypeRowId 
	WHERE @parentRowId IS NULL
	AND tme.ToDateTime IS NULL
),

getParents AS (
	SELECT ManagedEntityRowId, ManagedEntityRowId AS Parent
	FROM classTypeItemIds
	UNION ALL
	SELECT 
		s.ManagedEntityRowId,
		rhg.Parent
	FROM getParents s
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.Parent = rhg.Child
),

checkAllowance AS (
	SELECT DISTINCT ManagedEntityRowId
	FROM getParents ri
	INNER JOIN #allowedGroups ag ON ri.Parent = ag.Id
),

classTypesItems AS (
	SELECT 
		me.ManagedEntityGuid AS ManagedEntityGuid,
		me.ManagedEntityRowId AS RowId, 
		me.Path AS FullPath,
		me.DisplayName AS DisplayName,
		me.ManagedEntityTypeRowId
	FROM checkAllowance ai
	INNER JOIN dbo.vManagedEntity me WITH (NOLOCK) ON ai.ManagedEntityRowId = me.ManagedEntityRowId
	WHERE me.ManagementGroupRowId = @ManagementGroupRowId
),

both AS (
	SELECT * FROM originalItems
	UNION ALL
	SELECT * FROM classTypesItems
)

INSERT INTO #items
SELECT 
	both.ManagedEntityGuid,
	both.RowId, 
	0 AS Unmonitored, 
	MAX(CASE WHEN mm.MaintenanceModeRowId is NULL THEN 0 ELSE 1 END) AS Maintenance,
	MAX(isnull(CAST(mm.PlannedMaintenanceInd as int), 0)) AS PlannedMaintenance, 
	0 AS HealthState,
	MAX(both.FullPath),
	MAX(both.DisplayName),
	MAX(both.ManagedEntityTypeRowId),
	0 AS HasChildren
FROM both
INNER JOIN dbo.vManagedEntityManagementGroup memg2 WITH (NOLOCK) ON both.RowId = memg2.ManagedEntityRowId
left JOIN dbo.vMaintenanceMode mm WITH (NOLOCK) ON mm.ManagedEntityRowId = both.RowId AND mm.EndDateTime is NULL
WHERE memg2.ToDateTime is NULL 
GROUP BY both.RowId, both.ManagedEntityGuid
order by RowId
;

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('INSERT items', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

UPDATE #items
SET HasChildren = 1
FROM #items i
WHERE EXISTS (SELECT NULL FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy WHERE Parent = i.RowId)

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Calculate HasChildren', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

DECLARE @HealthServiceManagesEntityRTRowId int;
SELECT 
	@HealthServiceManagesEntityRTRowId = rt.RelationshipTypeRowId
FROM dbo.vRelationshipType AS rt WITH (NOLOCK)
WHERE rt.RelationshipTypeSystemName = 'Microsoft.SystemCenter.HealthServiceManagesEntity'

; WITH source AS (
	SELECT 
		i.RowId,
		HSO.EndDateTime,
		ROW_NUMBER() over (PARTITION by i.RowId, HSO.DWLastModifiedDateTime, HSO.ManagedEntityRowId, HSO.ReasonCode, HSO.RootHealthServiceInd, HSO.StartDateTime order by HSO.EndDateTime desc) AS rn
	FROM #items as i
INNER JOIN dbo.vManagedEntity AS me WITH (NOLOCK) ON i.RowId = me.ManagedEntityRowId
INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) ON me.ManagedEntityRowId = memg.ManagedEntityRowId
INNER JOIN dbo.vRelationship AS r WITH (NOLOCK) ON me.TopLevelHostManagedEntityRowId = r.TargetManagedEntityRowId
INNER JOIN dbo.vRelationshipManagementGroup rmg WITH (NOLOCK) ON r.RelationshipRowId = rmg.RelationshipRowId
INNER JOIN dbo.vHealthServiceOutage AS HSO WITH (NOLOCK) ON HSO.ManagedEntityRowId = r.SourceManagedEntityRowId	
WHERE r.RelationshipTypeRowId = @HealthServiceManagesEntityRTRowId
    AND rmg.ToDateTime is NULL
	AND memg.ToDateTime is NULL 
    AND HSO.EndDateTime is NULL
)

UPDATE #items
SET Unmonitored = 1
FROM #items as i
INNER JOIN source AS s ON s.RowId = i.RowId
WHERE s.EndDateTime is NULL
  AND s.rn = 1

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('UPDATE Unmonitored items', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

DECLARE @EntityStateMonitorRowId int;
SELECT @EntityStateMonitorRowId = m.MonitorRowId FROM dbo.vMonitor m WITH (NOLOCK) WHERE m.MonitorSystemName = 'System.Health.EntityState'

UPDATE #items
SET HealthState = 
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1 
	END
FROM #items i 
	LEFT JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues s ON i.RowId = s.ManagedEntityRowId AND s.MonitorRowId = @EntityStateMonitorRowId

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('UPDATE Health FOR items', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

; WITH seedTypes AS (
SELECT s.RowId, COALESCE(t.ManagedEntityTypeRowId, s.ManagedEntityTypeRowId) AS TypedManagedEntityTypeRowId FROM #items s
left JOIN vTypedManagedEntity t (NOLOCK) ON s.RowId = t.ManagedEntityRowId
WHERE t.ToDateTime IS NULL
),
depthToAbstractRaw AS (
SELECT DISTINCT s.TypedManagedEntityTypeRowId, s.TypedManagedEntityTypeRowId as currentTypeRowId, 0 AS depth FROM seedTypes s
UNION ALL
SELECT d.TypedManagedEntityTypeRowId, t.BaseManagedEntityTypeRowId, d.depth + 1 AS depth FROM depthToAbstractRaw d
INNER JOIN vManagedEntityTypeManagementPackVersion t (NOLOCK) ON d.currentTypeRowId = t.ManagedEntityTypeRowId
INNER JOIN #LatestMpVersions lm ON t.ManagementPackVersionRowId = lm.ManagementPackVersionRowId
WHERE t.AbstractInd = 0 
),
seedWithDepth AS (
SELECT 
	s.RowId,
	s.TypedManagedEntityTypeRowId,		
	ROW_NUMBER() over (PARTITION by s.RowId order by d.depth desc, s.TypedManagedEntityTypeRowId desc) as rn
FROM depthToAbstractRaw d
INNER JOIN seedTypes s ON (d.TypedManagedEntityTypeRowId = s.TypedManagedEntityTypeRowId)
)

UPDATE #items
SET ManagedEntityTypeRowId = U.TypedManagedEntityTypeRowId
FROM #items s 
INNER JOIN seedWithDepth U ON s.RowId = U.RowId
WHERE U.rn = 1

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('UPDATE types FOR items new', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

--SELECT * FROM #items

CREATE TABLE #MetricDefinitions (
	MetricId uniqueidentifier,
	ManagedEntityTypeRowId int,
	MetricRowId int,
	MetricType smallint,
	ShowInGrid bit,
	[order] int 
);

--INSERT Monitors INTO #MetricDefinitions
;WITH wideXml AS (
	SELECT 
	x.value('@MetricId', 'uniqueidentifier') AS MetricId, 
	x.value('../../@ClassName', 'nvarchar(2000)') as className,
	x.value('@MonitorId', 'nvarchar(2000)') as MonitorId,				
	x.value('@ShowInGrid', 'bit') AS ShowInGrid,
	x.value('@Order', 'int') AS [order]
	FROM @XmlData.nodes('/Data/DatacenterGroup/DataCenterClasses/DataCenterClass/MonitorMetrics/MonitorMetric') AS ParamValues(x)
),
xmlstrings AS (
	SELECT 
	x.MetricId, 
	LOWER(SUBSTRING(x.className, 1, CHARINDEX('!', x.className) - 1)) AS ClassMpName, 
	LOWER(SUBSTRING(x.className, CHARINDEX('!', x.className) + 1, 2000)) AS ClassName, 
	CASE WHEN CHARINDEX('!', x.MonitorId) = 0 THEN NULL ELSE LOWER(SUBSTRING(x.MonitorId, 1, CHARINDEX('!', x.MonitorId) - 1)) END AS MonitorMpName, 
	LOWER(SUBSTRING(x.MonitorId, CHARINDEX('!', x.MonitorId) + 1, 2000)) AS MonitorName,
	x.ShowInGrid AS ShowInGrid,
	x.[order] AS [order]
	FROM wideXml x
)

INSERT INTO #MetricDefinitions
SELECT 
	x.MetricId,
	met.ManagedEntityTypeRowId,
	m.MonitorRowId AS MetricRowId,
	2 AS MetricType,
	x.ShowInGrid,
	x.[order]
FROM xmlstrings AS x
JOIN vMonitor m  WITH (NOLOCK) ON m.MonitorSystemName = x.MonitorName
INNER JOIN dbo.vMonitorManagementPackVersion mmpv WITH (NOLOCK) ON m.MonitorRowId = mmpv.MonitorRowId
INNER JOIN #LatestMpVersions lmv ON mmpv.ManagementPackVersionRowId = lmv.ManagementPackVersionRowId
JOIN vManagementPack mpm  WITH (NOLOCK) ON mpm.ManagementPackRowId = m.ManagementPackRowId AND (mpm.ManagementPackSystemName = x.MonitorMpName or x.MonitorMpName is NULL)
JOIN vManagedEntityType met  WITH (NOLOCK) ON met.ManagedEntityTypeSystemName = x.ClassName
JOIN vManagementPack mpt  WITH (NOLOCK) ON mpt.ManagementPackRowId = met.ManagementPackRowId AND mpt.ManagementPackSystemName = x.ClassMpName;

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('INSERT #monitormetricdefinitions', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

-- INSERT Performance Metrics
;WITH wideXml AS (
	SELECT 
	x.value('@MetricId', 'uniqueidentifier') AS MetricId, 
	x.value('../../@ClassName', 'nvarchar(2000)') as className,
	x.value('@PerformanceCollectionRuleSystemName', 'nvarchar(2000)') as ruleName,
	(CASE WHEN x.value('fn:local-name(.)', 'nvarchar(50)') = 'PerformanceMetric' THEN 4
	ELSE 3 END
	 ) as MetricType,
	x.value('@ShowInGrid', 'bit') AS ShowInGrid,
	x.value('@Order', 'int') AS [order]
	FROM @XmlData.nodes('/Data/DatacenterGroup/DataCenterClasses/DataCenterClass/SmallPerformanceMetrics/SmallPerformanceMetric,/Data/DatacenterGroup/DataCenterClasses/DataCenterClass/PerformanceMetrics/PerformanceMetric') AS ParamValues(x)
),
 xmlstrings AS (	
	SELECT 
	x.MetricId AS MetricId, 
	r.RuleRowId AS RuleRowId,
	LOWER(SUBSTRING(x.className, 1, CHARINDEX('!', x.className) - 1)) AS ClassMpName, 
	LOWER(SUBSTRING(x.className, CHARINDEX('!', x.className) + 1, 2000)) AS ClassName,
	x.MetricType AS MetricType,
	x.ShowInGrid AS ShowInGrid,
	x.[order] AS [order]
	FROM wideXml x
	INNER JOIN dbo.vRule r WITH (NOLOCK) ON r.RuleSystemName = LOWER(SUBSTRING(x.ruleName, CHARINDEX('!', x.ruleName) + 1, 2000))
	INNER JOIN dbo.vRuleManagementPackVersion rmpv WITH (NOLOCK) ON r.RuleRowId = rmpv.RuleRowId
	INNER JOIN #LatestMpVersions lmv ON rmpv.ManagementPackVersionRowId = lmv.ManagementPackVersionRowId
	INNER JOIN dbo.vManagementPack mp WITH (NOLOCK) on r.ManagementPackRowId = mp.ManagementPackRowId and mp.ManagementPackSystemName = LOWER(SUBSTRING(x.ruleName, 1, CHARINDEX('!', x.ruleName) - 1))
)

INSERT INTO #MetricDefinitions
SELECT 
	x.MetricId,
	met.ManagedEntityTypeRowId,
	pri.PerformanceRuleInstanceRowId AS MetricRowId,
	x.MetricType AS MetricType,
	x.ShowInGrid,
	x.[order]
FROM xmlstrings AS x
JOIN vManagedEntityType met  WITH (NOLOCK) ON met.ManagedEntityTypeSystemName = x.ClassName
JOIN vManagementPack mpt  WITH (NOLOCK) ON mpt.ManagementPackRowId = met.ManagementPackRowId AND mpt.ManagementPackSystemName = x.ClassMpName
JOIN vPerformanceRuleInstance pri  WITH (NOLOCK) ON pri.RuleRowId = x.RuleRowId

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('INSERT #perfmetricdefinitions', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

--SELECT * FROM #MetricDefinitions

CREATE TABLE #ItemMonitorMetrics (
	ManagedEntityRowId int,
	MetricId uniqueidentifier,
	Unmonitored bit,
	Maintenance bit,
	PlannedMaintenance bit,
	HealthState int,
	LastTimeUpdate DateTime,
	[order] int
);

;WITH initialMonitorMetrics AS (
SELECT 
	me.RowId AS ManagedEntityRowId,
	md.MetricId AS MetricId, 
	me.Unmonitored AS Unmonitored,
	me.Maintenance AS Maintenance,
	me.PlannedMaintenance AS PlannedMaintenance,
	COALESCE(s.HealthState, 0) AS HealthState,
	s.[DateTime] AS LastTimeUpdate,
	md.[order] AS [order],
	ROW_NUMBER() over (PARTITION by me.RowId, md.MetricId, me.Unmonitored, me.Maintenance, me.PlannedMaintenance, md.[order] ORDER by s.[DateTime] desc) AS rn
FROM #items me  
	JOIN #MetricDefinitions md ON me.ManagedEntityTypeRowId = md.ManagedEntityTypeRowId
	left JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues s  WITH (NOLOCK) ON me.RowId = s.ManagedEntityRowId AND md.MetricRowId = s.MonitorRowId
WHERE md.ShowInGrid = 1 AND md.MetricType = 2
)

INSERT INTO #ItemMonitorMetrics
SELECT ManagedEntityRowId, MetricId, Unmonitored, Maintenance, PlannedMaintenance, HealthState, LastTimeUpdate, [order]
FROM initialMonitorMetrics
WHERE rn = 1;

-- SELECT * FROM #ItemMonitorMetrics

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get #ItemMonitorMetrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

DECLARE @selectedItemGuid uniqueidentifier;
DECLARE @selectedItemRowId int;
DECLARE @selectedItemTypeRowId int;
SELECT 
	@selectedItemGuid = ParamValues.x.value('@Id','uniqueidentifier')
FROM @XmlData.nodes('/Data/SelectedChild') AS ParamValues(x);

IF @selectedItemGuid is NULL 
BEGIN
	SELECT TOP 1 @selectedItemGuid = i.ManagedEntityGuid 
	FROM #items i 
	JOIN dbo.vManagedEntityType mt WITH (NOLOCK) ON i.ManagedEntityTypeRowId = mt.ManagedEntityTypeRowId
	WHERE @Filter is NULL or i.DisplayName LIKE @Filter or LOWER(mt.ManagedEntityTypeSystemName) LIKE @Filter
	ORDER by i.HealthState, i.DisplayName, i.ManagedEntityGuid;
END

SELECT 
       @selectedItemRowId = me.ManagedEntityRowId, 
       @selectedItemTypeRowId = i.ManagedEntityTypeRowId 
FROM dbo.vManagedEntity me
INNER JOIN #items i on me.ManagedEntityRowId = i.RowId
WHERE me.ManagementGroupRowId = @ManagementGroupRowId
  AND me.ManagedEntityGuid = @selectedItemGuid;

--SET @resDoc.modify('insert attribute Id {sql:variable("@selectedItemGuid")}
--into (/Data/SelectedChild)[1] ');

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Calculate  selected Child', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

-- SELECT * FROM @groups

-- 0 - statemetric
-- 1 - alertmetric
CREATE TABLE #relmetrics (
	Id uniqueidentifier,
	MetricType smallint,
	MonitorRowId int
);

INSERT INTO #relmetrics
SELECT DISTINCT 
	@selectedItemGuid AS Id, 
	0 AS MetricType,
	mon.MonitorRowId AS MonitorRowId
FROM dbo.Monitor mon 
  WHERE mon.MonitorSystemName = 'System.Health.EntityState'
UNION ALL 
SELECT DISTINCT
	@selectedItemGuid AS Id, 
	1 AS MetricType,
	0 AS MonitorRowId

--SELECT * FROM #relmetrics;
IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Prepare groups AND relmetrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

CREATE TABLE #relitems (
	RowId int,
	Unmonitored bit,
	Maintenance bit,
	PlannedMaintenance bit
	UNIQUE CLUSTERED (RowId)
);

INSERT INTO #relitems
SELECT 
	Child.ManagedEntityRowId AS RowId, 
	max(cast(i.Unmonitored AS int)) AS Unmonitored, 
	max(CASE WHEN mm.MaintenanceModeRowId is NULL THEN 0 ELSE 1 END) AS Maintenance,
	max(isnull(cast(mm.PlannedMaintenanceInd AS int), 0)) AS PlannedMaintenance
FROM #items i
INNER JOIN dbo.vManagedEntityManagementGroup memg1 WITH (NOLOCK) ON i.RowId = memg1.ManagedEntityRowId
INNER JOIN dbo.vRelationship rel WITH (NOLOCK) ON i.RowId = rel.SourceManagedEntityRowId AND rel.ManagementGroupRowId = @ManagementGroupRowId
INNER JOIN dbo.vRelationshipManagementGroup rmg WITH (NOLOCK) ON rel.RelationshipRowId = rmg.RelationshipRowId
INNER JOIN #FilteredRT frt ON rel.RelationshipTypeRowId = frt.RelationshipTypeRowId
INNER JOIN dbo.vManagedEntity Child WITH (NOLOCK) ON rel.TargetManagedEntityRowId = Child.ManagedEntityRowId AND Child.ManagementGroupRowId = @ManagementGroupRowId
INNER JOIN dbo.vManagedEntityManagementGroup memg2 WITH (NOLOCK) ON Child.ManagedEntityRowId = memg2.ManagedEntityRowId
left JOIN dbo.vMaintenanceMode mm WITH (NOLOCK) ON mm.ManagedEntityRowId = Child.ManagedEntityRowId AND mm.EndDateTime is NULL
WHERE i.RowId = @selectedItemRowId
  AND memg1.ToDateTime is NULL 
  AND memg2.ToDateTime is NULL 
  AND rmg.ToDateTime is NULL
  GROUP BY Child.ManagedEntityRowId
  ORDER by RowId;

--SELECT * FROM #relitems

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get relitems', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

CREATE TABLE #hierarchicRelItems (
	RowId int,
	LastPresencePeriodStarted DateTime
	--, IsHealthy bit
	UNIQUE CLUSTERED (RowId)
);

--; WITH data AS (
--SELECT @selectedItemRowId AS RowId
--UNION ALL
--SELECT 
--	rhg.Child AS RowId
--FROM data s
--INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.RowId = rhg.Parent
--),

; WITH data1 AS (
SELECT 
	rhg.Child AS RowId
FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) 
WHERE @selectedItemRowId = rhg.Parent
),

data2 AS (
SELECT 
	rhg.Child AS RowId
FROM data1 s
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.RowId = rhg.Parent
),

data3 AS (
SELECT 
	rhg.Child AS RowId
FROM data2 s
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.RowId = rhg.Parent
),

data4 AS (
SELECT 
	rhg.Child AS RowId
FROM data3 s
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rhg WITH (NOLOCK) ON s.RowId = rhg.Parent
),

combinedData AS (
SELECT @selectedItemRowId AS RowId
UNION ALL
SELECT RowId FROM data1
UNION ALL
SELECT RowId FROM data2
UNION ALL
SELECT RowId FROM data3
UNION ALL
SELECT RowId FROM data4
),

hItems AS (
SELECT RowId, memg.FromDateTime AS LastPresencePeriodStarted FROM combinedData d
INNER JOIN dbo.vManagedEntity me WITH (NOLOCK) ON d.RowId = me.ManagedEntityRowId AND me.ManagementGroupRowId = @ManagementGroupRowId
INNER JOIN dbo.vManagedEntityManagementGroup memg WITH (NOLOCK) ON me.ManagedEntityRowId = memg.ManagedEntityRowId
WHERE memg.ToDateTime is NULL
)
-- code to get health for hierarchic items. Now it is not used, very slow.

--hItemsWithHealth AS (
--SELECT DISTINCT 
--	hItems.GroupId, 
--	hItems.RowId, 
--	hItems.LastPresencePeriodStarted, 
--	CASE WHEN s.HealthState = 1 THEN 1 ELSE 0 END AS IsHealthy,
--	ROW_NUMBER() over (PARTITION by hItems.RowId, hItems.GroupId ORDER by s.DateTime desc) AS rn
--  FROM hItems
--INNER JOIN @groups g ON hItems.GroupId = g.Id
--INNER JOIN #relmetrics m ON g.Id = m.GroupId AND m.MetricType = 0
--left JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues AS s  WITH (NOLOCK) ON s.ManagedEntityRowId = hItems.RowId AND s.MonitorRowId = m.MonitorRowId AND s.DateTime > hItems.LastPresencePeriodStarted
--)

INSERT INTO #hierarchicRelItems
SELECT 
	RowId,
	MAX(LastPresencePeriodStarted)
FROM hItems
GROUP BY RowId
ORDER by RowId;
 
IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get hierarchicRelItems', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

--SELECT * FROM #hierarchicRelItems;

CREATE TABLE #relmetricValues (
	MetricId uniqueidentifier,
	MetricType smallint,
	Name varchar(200),
	Value integer
);

INSERT INTO #relmetricValues
SELECT 
	@selectedItemGuid AS MetricId, 
	0 AS MetricType, 
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1 
	END AS Name, 
	count(i.RowId) AS Value
FROM #relitems i
LEFT JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues AS s WITH (NOLOCK) ON s.ManagedEntityRowId = i.RowId AND s.MonitorRowId = @EntityStateMonitorRowId
GROUP BY 	
	CASE 
		WHEN i.Maintenance = 1 THEN 4 
		WHEN i.Unmonitored = 1 THEN 3 
		WHEN s.HealthState IS NULL OR s.HealthState = 0 THEN 5 
		WHEN s.HealthState = 1 THEN 6 
		WHEN s.HealthState = 2 THEN 2 
		WHEN s.HealthState = 3 THEN 1 
	END
;	

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get relmetricValues - Monitor', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

-- Alert

DECLARE @DayOffset int;
SET @DayOffset = -1 * (@AutoResolveDays + @ResolvedAlertDaysToKeep + 1);

DECLARE @DateStart datetime;
Set @DateStart = DATEADD(DAY, @DayOffset, @launchDateTime);

INSERT INTO #relmetricValues
SELECT @selectedItemGuid AS MetricId, 1, a.Severity AS Name, count(a.Severity) AS Value
FROM #hierarchicRelItems i
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues AS a WITH (NOLOCK) ON a.ManagedEntityRowId = i.RowId
WHERE a.ResolutionState < 255
-- filtering by instance presence
AND a.DateTime > CASE WHEN i.LastPresencePeriodStarted > @DateStart THEN i.LastPresencePeriodStarted ELSE @DateStart END
AND a.ManagedEntityRowId != @selectedItemRowId
--AND a.DateTime > DATEADD(DAY, -1 * (CASE 
--	WHEN i.IsHealthy = 1 
--	THEN @AutoResolveHealthyObjDays 
--	ELSE @AutoResolveDays 
--END + @ResolvedAlertDaysToKeep + 1), @launchDateTime)
GROUP BY a.Severity;	

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get relmetricValues - Alert', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

; WITH PossibleAlertStates AS (
SELECT 0 AS State
UNION ALL
SELECT 1
UNION ALL
SELECT 2
),

PossibleHealthStates AS (
SELECT 1 AS State
UNION ALL
SELECT 2
UNION ALL
SELECT 3
UNION ALL
SELECT 4
UNION ALL
SELECT 5
UNION ALL 
SELECT 6
),

PossibleCountStates AS (
SELECT 1 AS State
),

FullSet AS (
SELECT m.Id AS MetricId, m.MetricType, ps.State AS Name, 0 AS Value FROM PossibleAlertStates ps
full JOIN #relmetrics m ON 1=1
WHERE m.MetricType = 1
UNION ALL 
SELECT m.Id AS MetricId, m.MetricType, ps.State AS Name, 0 AS Value FROM PossibleHealthStates ps
full JOIN #relmetrics m ON 1=1
WHERE m.MetricType = 0
)

INSERT INTO #relmetricValues
SELECT fs.* FROM FullSet fs 
left JOIN #relmetricValues mv ON fs.MetricId = mv.MetricId AND fs.MetricType = mv.MetricType AND fs.Name = mv.Name
WHERE mv.Name is NULL

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('INSERT skipped relmetricValues', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END
--SELECT * FROM #relmetricValues

CREATE TABLE #entityProperties (
	PropertyDefaultName nvarchar(2000),
	PropertyType varchar(2000),
	PropertyLength varchar(2000),
	Value nvarchar(2000),
	Name nvarchar(2000)
);

CREATE TABLE #TypeList (
	ManagedEntityTypeRowId int
);

; WITH fullTypeSpectre AS
(
SELECT tme.ManagedEntityTypeRowId AS ManagedEntityTypeRowId 
FROM dbo.vTypedManagedEntity tme WITH (NOLOCK)
WHERE tme.ManagedEntityRowId = @selectedItemRowId AND tme.ToDateTime IS NULL
UNION ALL
SELECT met.ManagedEntityTypeRowId FROM fullTypeSpectre fts
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion metmpv ON fts.ManagedEntityTypeRowId = metmpv.ManagedEntityTypeRowId
INNER JOIN dbo.vManagedEntityType met WITH (NOLOCK) ON met.ManagedEntityTypeRowId = metmpv.BaseManagedEntityTypeRowId
INNER JOIN #LatestMpVersions lmv ON lmv.ManagementPackVersionRowId = metmpv.ManagementPackVersionRowId
)

INSERT INTO #TypeList
SELECT DISTINCT fts.ManagedEntityTypeRowId FROM fullTypeSpectre fts;

DECLARE @props XML
SELECT @props = PropertyXml
  FROM [dbo].[vManagedEntityProperty]  WITH (NOLOCK)
WHERE vManagedEntityProperty.ManagedEntityRowId = @selectedItemRowId AND ToDateTime is NULL;
			
INSERT INTO #entityProperties
SELECT 
	tp.PropertyDefaultName,
	mpv.PropertyType,
	mpv.PropertyLength,
	ParamValues.x.value('(.)[1]', 'varchar(2000)'),
	ds.Name
FROM #TypeList tl 
	JOIN [dbo].[vManagedEntityTypeProperty] tp ON tl.ManagedEntityTypeRowId = tp.ManagedEntityTypeRowId
	JOIN vManagedEntityTypePropertyManagementPackVersion mpv ON tp.ManagedEntityTypePropertyRowId = mpv.ManagedEntityTypePropertyRowId
	JOIN #LatestMpVersions lm ON lm.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
	left JOIN vDisplayString ds ON ds.ElementGuid = tp.PropertyGuid AND ds.LanguageCode = @LanguageCode
	left JOIN @props.nodes('/Root/Property') AS ParamValues(x) ON x.value('@Guid', 'uniqueidentifier') = tp.PropertyGuid
WHERE tp.PropertyDefaultName NOT IN ('Asset Status', 'Notes', 'Object Status')	
	ORDER by tp.ManagedEntityTypePropertyRowId;

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get entityProperties', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

CREATE TABLE #MonitorMetrics (
	ManagedEntityRowId int,
	MetricId uniqueidentifier,
	Unmonitored bit,
	Maintenance bit,
	PlannedMaintenance bit,
	HealthState int,
	LastTimeUpdate DateTime
);

-- Get Monitor data
;WITH initialMonitorMetrics AS (
SELECT 
	@selectedItemRowId AS ManagedEntityRowId,
	md.MetricId AS MetricId, 
	i.Unmonitored AS Unmonitored,
	i.Maintenance AS Maintenance,
	i.PlannedMaintenance AS PlannedMaintenance,
	COALESCE(s.HealthState, 0) AS HealthState,
	s.[DateTime] AS LastTimeUpdate,
	ROW_NUMBER() over (PARTITION by @selectedItemRowId, md.MetricId, i.Unmonitored, i.Maintenance, i.PlannedMaintenance ORDER by s.[DateTime] desc) AS rn
FROM #items i 
	JOIN #MetricDefinitions md ON md.ManagedEntityTypeRowId = i.ManagedEntityTypeRowId
	left JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues s  WITH (NOLOCK) ON md.MetricRowId = s.MonitorRowId AND i.RowId = s.ManagedEntityRowId
WHERE i.RowId = @selectedItemRowId
  AND md.MetricType = 2
  AND md.ManagedEntityTypeRowId = @selectedItemTypeRowId
)

INSERT INTO #MonitorMetrics
SELECT ManagedEntityRowId, MetricId, Unmonitored, Maintenance, PlannedMaintenance, HealthState, LastTimeUpdate
FROM initialMonitorMetrics
WHERE rn = 1;
  
IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get MonitorMetrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

DECLARE @StartDate DateTime
SET @StartDate = DATEADD(minute, -@Interval,GetUtcDate())


DECLARE @step float
SET @step = @Interval/50

CREATE TABLE #PerfMetricValues (
	MetricId uniqueidentifier,
	Dt DateTime,
	Value float
);

CREATE TABLE #someRows (
	Dummy bit
);

INSERT INTO #someRows
SELECT 1 
UNION ALL
SELECT 1
UNION ALL
SELECT 1
UNION ALL
SELECT 1;

INSERT INTO #someRows
SELECT f1.* FROM #someRows f1
CROSS JOIN #someRows f2
CROSS JOIN #someRows f3;

;WITH heads AS (SELECT * FROM #MetricDefinitions WHERE MetricType = 4 AND ManagedEntityTypeRowId = @selectedItemTypeRowId),

vals AS (
SELECT
	h.MetricId AS MetricId,
	P.[DateTime] AS "DateTime",  
	P.SampleValue AS "Value"
FROM Perf.vPerfRaw P  WITH (NOLOCK) 
INNER JOIN heads h ON P.PerformanceRuleInstanceRowId = h.MetricRowId
WHERE P.ManagedEntityRowId = @selectedItemRowId AND P.DateTime > @StartDate
),

dates AS (
SELECT TOP(49)
	DATEADD(minute, @step*(ROW_NUMBER() over (ORDER by P.Dummy) - 1),@StartDate) pr_dt,
	DATEADD(minute, @step*(ROW_NUMBER() over (ORDER by P.Dummy)),@StartDate) Dt
FROM
	#someRows P 
)

INSERT INTO #PerfMetricValues
SELECT 
	m.MetricId AS MetricId, 
	d.Dt AS Dt,
	avg(v.Value) AS Value
FROM heads m
CROSS JOIN dates d
INNER JOIN vals v ON m.MetricId = v.MetricId AND v.[DateTime] between d.pr_dt AND d.Dt
GROUP BY m.MetricId, d.Dt;

INSERT INTO #PerfMetricValues
SELECT 
	m.MetricId AS MetricId,
	v.DateTime AS Dt,
	v.SampleValue AS Value
FROM #MetricDefinitions m
INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues v ON m.MetricRowId = v.PerformanceRuleInstanceRowId
WHERE v.ManagedEntityRowId = @selectedItemRowId AND m.MetricType = 4 AND m.ManagedEntityTypeRowId = @selectedItemTypeRowId

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get perfMetrics new', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END;

CREATE TABLE #Monitors (
	"Item!1!MpSystemName" nvarchar(256),
	"Item!1!MonitorSystemName" nvarchar(256),
	"Item!1!MonitorDefaultName" nvarchar(1000),
	"Item!1!MonitorName" nvarchar(1000)
);

INSERT INTO #Monitors
SELECT 
	mp.ManagementPackSystemName AS "Item!1!MpSystemName",
	m.MonitorSystemName AS "Item!1!MonitorSystemName",
	m.MonitorDefaultName AS "Item!1!MonitorDefaultName",
	ds.Name AS "Item!1!MonitorName"
FROM #TypeList tme 
	JOIN vMonitorManagementPackVersion mmpv  WITH (NOLOCK) ON tme.ManagedEntityTypeRowId = mmpv.TargetManagedEntityTypeRowId
	JOIN vMonitor m  WITH (NOLOCK) ON m.MonitorRowId = mmpv.MonitorRowId
	JOIN #LatestMpVersions lmv  ON lmv.ManagementPackVersionRowId = mmpv.ManagementPackVersionRowId
	JOIN dbo.vManagementPack mp WITH (NOLOCK) ON mp.ManagementPackRowId = lmv.ManagementPackRowId
	left JOIN vDisplayString ds  WITH (NOLOCK) ON ds.ElementGuid = m.MonitorGuid AND ds.LanguageCode = @LanguageCode

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get Monitor List', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

CREATE TABLE #Rules (
	"Item!1!MpSystemName" nvarchar(256),
	"Item!1!RuleSystemName" nvarchar(256),
	"Item!1!RuleDefaultName" nvarchar(1000),
	"Item!1!RuleName" nvarchar(1000)
);

INSERT INTO #Rules
SELECT 
	mp.ManagementPackSystemName AS "Item!1!MpSystemName",
	r.RuleSystemName AS "Item!1!RuleSystemName",
	r.RuleDefaultName AS "Item!1!RuleDefaultName",
	ds.Name AS "Item!1!RuleName"
FROM #TypeList tme 
	JOIN vRuleManagementPackVersion rmpv  WITH (NOLOCK) ON tme.ManagedEntityTypeRowId = rmpv.TargetManagedEntityTypeRowId
	JOIN vWorkflowCategory wc WITH (NOLOCK) ON rmpv.WorkflowCategoryRowId = wc.WorkflowCategoryRowId
	JOIN vRule r  WITH (NOLOCK) ON r.RuleRowId = rmpv.RuleRowId
	JOIN #LatestMpVersions lmv ON lmv.ManagementPackVersionRowId = rmpv.ManagementPackVersionRowId
	JOIN dbo.vManagementPack mp WITH (NOLOCK) ON mp.ManagementPackRowId = lmv.ManagementPackRowId
	left JOIN vDisplayString ds WITH (NOLOCK) ON ds.ElementGuid = r.RuleGuid AND ds.LanguageCode = @LanguageCode
WHERE wc.WorkflowCategorySystemName = 'PerformanceCollection';

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Get Rule List', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
SET @StartTimeSegment = getdate()
END

Create Table #ResultUniversalTable (
  [TAG] int NULL,
  [Parent] int NULL,
  [Data!1000] varchar (1) DEFAULT '',
  [Children!1100] varchar (1) NULL,
  [Item!1110!Id] uniqueidentifier NULL,
  [Item!1110!DisplayName] nvarchar (4000) NULL,
  [Item!1110!FullPath] nvarchar (4000) NULL,
  [Item!1110!HasChildren] int NULL,
  [Item!1110!HealthState] int NULL,
  [Item!1110!ClassName] nvarchar (1026) NULL,
  [Metric!1111!MetricId] uniqueidentifier NULL,
  [Metric!1111!MetricType] smallint NULL,
  [Metric!1111!Value] float NULL,
  [Metric!1111!LastTimeUpdate] datetime NULL,
  [Metric!1111!Order!hide] smallint NULL,
  [Images!1200] varchar (1) NULL,
  [Item!1210!ImageId] nvarchar (1026) NULL,
  [Item!1210!Image] varbinary(max) NULL,
  [Properties!1300] varchar (1) NULL,
  [Item!1310!PropertyDefaultName] nvarchar (4000) NULL,
  [Item!1310!PropertyType] varchar (2000) NULL,
  [Item!1310!Value] nvarchar (4000) NULL,
  [Item!1310!Name] nvarchar (4000) NULL,
  [Alerts!1400] varchar (1) NULL,
  [Item!1410!DateTime] datetime NULL,
  [Item!1410!AlertGuid] uniqueidentifier NULL,
  [Item!1410!Severity] tinyint NULL,
  [Item!1410!AlertName] nvarchar(max) NULL,
  [Item!1410!RepeatCount] int NULL,
  [Item!1410!ResolutionStateName] nvarchar (100) NULL,
  [Item!1410!MonitoringObjectGuid] uniqueidentifier NULL,
  [RelatedMetrics!1500] varchar (1) NULL,
  [Metric!1510!Type] smallint NULL,
  [Item!1511!Name] varchar (200) NULL,
  [Item!1511!Value] int NULL,
  [Metrics!6000] varchar (1) NULL,
  [MonitorMetrics!6100] varchar (1) NULL,
  [Item!6110!MetricId] uniqueidentifier NULL,
  [Item!6110!MetricType] int NULL,
  [Item!6110!Value] int NULL,
  [Item!6110!LastTimeUpdate] datetime NULL,
  [SmallPerformanceMetrics!6200] varchar (1) NULL,
  [Item!6210!MetricId] uniqueidentifier NULL,
  [Item!6210!Value] float NULL,
  [Item!6210!LastTimeUpdate] datetime NULL,
  [PerformanceMetrics!6300] varchar (1) NULL,
  [Metric!6310!MetricId] uniqueidentifier NULL,
  [Item!6311!DateTime] datetime NULL,
  [Item!6311!Value] float NULL,
  [Metadata!7000] varchar (1) NULL,
  [Monitors!7100] varchar (1) NULL,
  [Item!7110!MpSystemName] nvarchar (512) NULL,
  [Item!7110!MonitorSystemName] nvarchar (512) NULL,
  [Item!7110!MonitorDefaultName] nvarchar (512) NULL,
  [Item!7110!MonitorName] nvarchar (2000) NULL,
  [Rules!7200] varchar (1) NULL,
  [Item!7210!MpSystemName] nvarchar (512) NULL,
  [Item!7210!RuleSystemName] nvarchar (512) NULL,
  [Item!7210!RuleDefaultName] nvarchar (2000) NULL,
  [Item!7210!RuleName] nvarchar (2000) NULL,
  [SelectedChild!8000!Id] uniqueidentifier NULL,
  [SelectedChild!8000!TypeSystemName] nvarchar (1026) NULL,
  [SelectedChild!8000!TypeDefaultName] nvarchar (512) NULL,
  [SelectedChild!8000!TypeName] nvarchar (512) NULL)

  --Root nodes
INSERT INTO #ResultUniversalTable (TAG, Parent,[Children!1100],[Images!1200],[Properties!1300],[Alerts!1400],[RelatedMetrics!1500],[Metrics!6000],[MonitorMetrics!6100],[SmallPerformanceMetrics!6200],[PerformanceMetrics!6300], [Metadata!7000], [Monitors!7100], [Rules!7200])Values
 (1000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (1100,1000,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (1200,1000,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (1300,1000,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (1400,1000,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (1500,1000,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
 (6000,1000,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL),
 (6100,6000,NULL,NULL,NULL,NULL,NULL,'','',NULL,NULL,NULL,NULL,NULL),
 (6200,6000,NULL,NULL,NULL,NULL,NULL,'',NULL,'',NULL,NULL,NULL,NULL),
 (6300,6000,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,'',NULL,NULL,NULL),
 (7000,1000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL),
 (7100,7000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'','',NULL),
 (7200,7000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'',NULL,'')

--Fill Children
;WITH Children AS (
SELECT 	
	ManagedEntityGuid AS "Id",
	DisplayName AS  "DisplayName",
	FullPath AS  "FullPath",
	HasChildren AS "HasChildren",
	HealthState AS "HealthState",
	LOWER(mp.ManagementPackSystemName) + '!' + LOWER(mt.ManagedEntityTypeSystemName) AS  "ClassName",
	i.RowId
FROM #items i
INNER JOIN dbo.vManagedEntityType mt WITH (NOLOCK) ON i.ManagedEntityTypeRowId = mt.ManagedEntityTypeRowId
INNER JOIN dbo.vManagementPack mp WITH (NOLOCK) ON mt.ManagementPackRowId = mp.ManagementPackRowId
)
INSERT INTO #ResultUniversalTable (TAG, Parent, [Children!1100], [Item!1110!ClassName],[Item!1110!DisplayName],[Item!1110!FullPath],[Item!1110!HasChildren],[Item!1110!HealthState],[Item!1110!Id])
SELECT
    1110 as TAG,
	1100 AS Parent,
	'' as [Children!1100],	
	c.ClassName AS [Item!1110!ClassName],
	c.DisplayName AS [Item!1110!DisplayName],
	c.FullPath AS [Item!1110!FullPath],
	c.HasChildren AS [Item!1110!HasChildren],
	c.HealthState AS [Item!1110!HealthState],	
	c.Id AS [Item!1110!Id]
FROM Children c

;WITH Metrics AS (
  SELECT 	
	i.ManagedEntityGuid,		
	i.HealthState,
	i.DisplayName,
	imm.MetricId AS "MetricId",
	2 AS "MetricType",
	CASE 
		WHEN imm.Maintenance = 1 THEN 4 
		WHEN imm.Unmonitored = 1 THEN 3 
		WHEN imm.HealthState = 0 THEN 5 
		WHEN imm.HealthState = 1 THEN 6 
		WHEN imm.HealthState = 2 THEN 2 
		WHEN imm.HealthState = 3 THEN 1 
	END AS "Value",
	imm.LastTimeUpdate AS "LastTimeUpdate",
	imm.[order] AS "order"
FROM #ItemMonitorMetrics imm 
INNER JOIN #items i ON imm.ManagedEntityRowId = i.RowId
UNION ALL
SELECT
    me.ManagedEntityGuid,
	me.HealthState,
	me.DisplayName,
	md.MetricId AS MetricId, 
	md.MetricType MetricType,
	s.SampleValue AS "Value",
	s.[DateTime] AS "LastTimeUpdate",
	md.[order] AS "order"
FROM #items me 	
	JOIN #MetricDefinitions md ON me.ManagedEntityTypeRowId = md.ManagedEntityTypeRowId
	JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues s  WITH (NOLOCK) ON me.RowId = s.ManagedEntityRowId AND md.MetricRowId = s.PerformanceRuleInstanceRowId
WHERE md.ShowInGrid = 1 AND md.MetricType = 3
)
INSERT INTO #ResultUniversalTable(TAG, Parent, [Children!1100], [Item!1110!Id],[Item!1110!HealthState],[Item!1110!DisplayName], [Metric!1111!MetricId],[Metric!1111!MetricType],[Metric!1111!LastTimeUpdate],[Metric!1111!Value],[Metric!1111!Order!hide])
SELECT
    1111 as TAG,
	1110 AS Parent,
	'' as [Children!1100],
	m.ManagedEntityGuid AS [Item!1110!Id],
	m.HealthState AS [Item!1110!HealthState],
	m.DisplayName,
	m.MetricId AS [Metric!1111!MetricId],
	m.MetricType AS [Metric!1111!MetricType],
	m.LastTimeUpdate AS [Metric!1111!LastTimeUpdate],
	m.Value AS [Metric!1111!Value],
	m.[order] AS [Metric!1111!Order!hide]
FROM Metrics m

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill Children', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

-- Images
SELECT DISTINCT i.ManagedEntityTypeRowId INTO #itemtypes FROM #items i

;WITH Images AS (
  SELECT
	mp.ManagementPackSystemName + '!' + met.[ManagedEntityTypeSystemName] AS ImageId,
	meti.[Image] AS  Image
  FROM vManagedEntityTypeImage meti WITH(NOLOCK) 
	JOIN vManagedEntityType met WITH(NOLOCK) ON met.ManagedEntityTypeRowId = meti.ManagedEntityTypeRowId
	JOIN vManagementPack mp WITH (NOLOCK) ON mp.ManagementPackRowId = met.ManagementPackRowId
	WHERE EXISTS (SELECT NULL FROM #itemtypes t WHERE t.ManagedEntityTypeRowId = met.ManagedEntityTypeRowId)
	AND meti.ImageCategory = 'u16x16Icon'
)
INSERT INTO #ResultUniversalTable (TAG,Parent,[Images!1200],[Item!1210!Image],[Item!1210!ImageId])
SELECT
    1210 as TAG,
	1200 AS Parent,	
	'' AS [Images!1200],	
	i.[Image] AS [Item!1210!Image],
	i.ImageId AS [Item!1210!ImageId]
FROM Images i

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill Images', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

--Properties
INSERT INTO #ResultUniversalTable (TAG,Parent,[Properties!1300],[Item!1310!Name],[Item!1310!PropertyDefaultName],[Item!1310!PropertyType],[Item!1310!Value])
SELECT
    1310 as Tag,
	1300 as Parent,	
	'' AS [Properties!1300],	
	p.Name AS [Item!1310!Name],
	p.PropertyDefaultName AS [Item!1310!PropertyDefaultName],
	p.PropertyType AS [Item!1310!PropertyType],
	p.Value AS [Item!1310!Value]	
FROM #entityProperties p

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill Properties', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

-- Alerts
;WITH alerts AS (
SELECT 
	a.[DateTime] AS "DateTime",
	a.[AlertGuid] AS "AlertGuid",
	a.[Severity] AS "Severity",
	COALESCE(ds.[Name], al.[AlertName]) AS "AlertName",
	al.[RepeatCount] AS "RepeatCount",
	rs.ResolutionStateName AS "ResolutionStateName",
	me.ManagedEntityGuid AS "MonitoringObjectGuid",
	CASE WHEN CHARINDEX('{',COALESCE(ds.[Name], al.[AlertName])) > 0 THEN CAST (1 AS bit) ELSE CAST (0 AS bit) END AS NeedReplacement
FROM sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues AS a WITH (NOLOCK) 
INNER JOIN [Alert].[vAlert] al  WITH (NOLOCK) ON a.AlertGuid = al.AlertGuid
INNER JOIN [dbo].[vResolutionState] rs WITH (NOLOCK) ON a.[ResolutionState] = rs.[ResolutionStateId]
left JOIN vDisplayString ds WITH (NOLOCK) ON al.AlertStringGuid = ds.ElementGuid AND ds.LanguageCode = @LanguageCode
INNER JOIN dbo.vManagedEntity me WITH (NOLOCK) ON a.ManagedEntityRowId = me.ManagedEntityRowId
INNER JOIN (SELECT * FROM #hierarchicRelItems i WHERE @ShowAlertsFromDescendants = 1 or i.RowId = @selectedItemRowId) i ON me.ManagedEntityRowId = i.RowId
WHERE a.ResolutionState < 255
-- filtering by instance presence
AND a.DateTime > CASE WHEN i.LastPresencePeriodStarted > @DateStart THEN i.LastPresencePeriodStarted ELSE @DateStart END
--AND a.DateTime > DATEADD(DAY, -1 * (CASE 
--	WHEN i.IsHealthy = 1 
--	THEN @AutoResolveHealthyObjDays 
--	ELSE @AutoResolveDays 
--END + @ResolvedAlertDaysToKeep + 1), @launchDateTime
),
alertsReplacementPositions AS (
	SELECT 		
		a.[DateTime],
		a.[AlertGuid],
		a.[Severity],
		a.[AlertName],
		a.[RepeatCount],
		a.[ResolutionStateName],
		a.[MonitoringObjectGuid],
		CASE WHEN CHARINDEX('{0}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position1,
		CASE WHEN CHARINDEX('{1}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position2,
		CASE WHEN CHARINDEX('{2}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position3,
		CASE WHEN CHARINDEX('{3}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position4,
		CASE WHEN CHARINDEX('{4}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position5,
		CASE WHEN CHARINDEX('{5}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position6,
		CASE WHEN CHARINDEX('{6}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position7,
		CASE WHEN CHARINDEX('{7}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position8,
		CASE WHEN CHARINDEX('{8}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position9,
		CASE WHEN CHARINDEX('{9}', a."AlertName") > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS position10
	FROM alerts a
	WHERE a.NeedReplacement = 1
),

alertsReplaced AS (
	SELECT 
		arp.[DateTime],
		arp.[AlertGuid],
		arp.[Severity],
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		arp.[AlertName]
		,'{0}', COALESCE(a1.ParameterValue, ''))
		,'{1}', COALESCE(a2.ParameterValue, '')) 
		,'{2}', COALESCE(a3.ParameterValue, '')) 
		,'{3}', COALESCE(a4.ParameterValue, '')) 
		,'{4}', COALESCE(a5.ParameterValue, '')) 
		,'{5}', COALESCE(a6.ParameterValue, '')) 
		,'{6}', COALESCE(a7.ParameterValue, '')) 
		,'{7}', COALESCE(a8.ParameterValue, '')) 
		,'{8}', COALESCE(a9.ParameterValue, '')) 
		,'{9}', COALESCE(a10.ParameterValue, '')) 
		as [AlertName],
		arp.[RepeatCount],
		arp.[ResolutionStateName],
		arp.[MonitoringObjectGuid]
	FROM alertsReplacementPositions arp
	LEFT JOIN Alert.vAlertParameter a1 on arp.position1 = 1 and arp.[AlertGuid] = a1.AlertGuid and a1.ParameterIndex = 1
	LEFT JOIN Alert.vAlertParameter a2 on arp.position2 = 1 and arp.[AlertGuid] = a2.AlertGuid and a2.ParameterIndex = 2
	LEFT JOIN Alert.vAlertParameter a3 on arp.position3 = 1 and arp.[AlertGuid] = a3.AlertGuid and a3.ParameterIndex = 3
	LEFT JOIN Alert.vAlertParameter a4 on arp.position4 = 1 and arp.[AlertGuid] = a4.AlertGuid and a4.ParameterIndex = 4
	LEFT JOIN Alert.vAlertParameter a5 on arp.position5 = 1 and arp.[AlertGuid] = a5.AlertGuid and a5.ParameterIndex = 5
	LEFT JOIN Alert.vAlertParameter a6 on arp.position6 = 1 and arp.[AlertGuid] = a6.AlertGuid and a6.ParameterIndex = 6
	LEFT JOIN Alert.vAlertParameter a7 on arp.position7 = 1 and arp.[AlertGuid] = a7.AlertGuid and a7.ParameterIndex = 7
	LEFT JOIN Alert.vAlertParameter a8 on arp.position8 = 1 and arp.[AlertGuid] = a8.AlertGuid and a8.ParameterIndex = 8
	LEFT JOIN Alert.vAlertParameter a9 on arp.position9 = 1 and arp.[AlertGuid] = a9.AlertGuid and a9.ParameterIndex = 9
	LEFT JOIN Alert.vAlertParameter a10 on arp.position10 = 1 and arp.[AlertGuid] = a10.AlertGuid and a10.ParameterIndex = 10
),
totalAlerts AS (
	SELECT 		
		a.[DateTime],
		a.[AlertGuid],
		a.[Severity],
		a.[AlertName],
		a.[RepeatCount],
		a.[ResolutionStateName],
		a.[MonitoringObjectGuid]
	FROM alerts a
	WHERE a.NeedReplacement = 0
	UNION ALL
	SELECT 		
		a.[DateTime],
		a.[AlertGuid],
		a.[Severity],
		a.[AlertName],
		a.[RepeatCount],
		a.[ResolutionStateName],
		a.[MonitoringObjectGuid]
	FROM alertsReplaced a
)
INSERT INTO #ResultUniversalTable (TAG,Parent,[Alerts!1400],[Item!1410!DateTime],[Item!1410!AlertGuid],[Item!1410!Severity],[Item!1410!AlertName],[Item!1410!RepeatCount],[Item!1410!ResolutionStateName],[Item!1410!MonitoringObjectGuid])
SELECT
    1410 as TAG,
	1400 AS Parent,	
	'' AS [Alerts!1400],	
	a.DateTime AS [Item!1410!DateTime],	
	a.AlertGuid AS [Item!1410!AlertGuid],
	a.Severity AS [Item!1410!Severity],	
	a.AlertName AS [Item!1410!AlertName],
	a.RepeatCount AS [Item!1410!RepeatCount],
	a.ResolutionStateName AS [Item!1410!ResolutionStateName],
	a.MonitoringObjectGuid AS [Item!1410!MonitoringObjectGuid]		
 FROM totalAlerts a 

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill Alerts', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

--Related Metrics
INSERT INTO #ResultUniversalTable (TAG, Parent, [RelatedMetrics!1500], [Metric!1510!Type], [Item!1511!Name], [Item!1511!Value])
SELECT DISTINCT
	1510 as TAG,
	1500 AS Parent,
	'' AS [RelatedMetrics!1500],
	rmv.MetricType AS [Metric!1510!Type],NULL AS [Item!1511!Name],NULL AS [Item!1511!Value]
FROM #relmetricValues rmv
UNION ALL SELECT
	1511 as TAG,
	1510 AS Parent,	
	'' AS [RelatedMetrics!1500],
	rmv.MetricType AS [Metric!1510!Type],
	rmv.Name AS [Item!1511!Name],
	rmv.Value AS [Item!1511!Value]	
FROM #relmetricValues rmv

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill Related Metrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

--Fill monitor metrics
;WITH monitorMetrics AS (
  SELECT 	
	MetricId AS "MetricId",
	2 AS "MetricType",
	CASE 
		WHEN Maintenance = 1 THEN 4 
		WHEN Unmonitored = 1 THEN 3 
		WHEN HealthState = 0 THEN 5 
		WHEN HealthState = 1 THEN 6 
		WHEN HealthState = 2 THEN 2 
		WHEN HealthState = 3 THEN 1 
	END AS "Value",
	LastTimeUpdate AS "LastTimeUpdate"
  FROM #MonitorMetrics
)
INSERT INTO #ResultUniversalTable (TAG, Parent,[Metrics!6000],[MonitorMetrics!6100],[Item!6110!LastTimeUpdate],[Item!6110!MetricId],[Item!6110!MetricType],[Item!6110!Value])
SELECT
    6110 as TAG,
	6100 AS Parent,	
	'' AS [Metrics!6000],
	'' AS [MonitorMetrics!6100], 
	m.LastTimeUpdate AS [Item!6110!LastTimeUpdate],
	m.MetricId AS [Item!6110!MetricId], 
	m.MetricType AS [Item!6110!MetricType], 
	m.Value AS [Item!6110!Value]	
FROM monitorMetrics m

--small metrics
;WITH smallPerformanceMetrics AS (
    SELECT 
    	md.MetricId AS "MetricId", 
    	s.SampleValue AS "Value",
    	s.[DateTime] AS "LastTimeUpdate"
    FROM #MetricDefinitions md
    	JOIN sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues s  WITH (NOLOCK) ON s.PerformanceRuleInstanceRowId = md.MetricRowId
    	WHERE md.ManagedEntityTypeRowId = @selectedItemTypeRowId AND md.MetricType = 3 AND s.ManagedEntityRowId = @selectedItemRowId
    )
INSERT INTO #ResultUniversalTable (TAG,Parent,[Metrics!6000],[SmallPerformanceMetrics!6200],[Item!6210!LastTimeUpdate],[Item!6210!MetricId],[Item!6210!Value])
SELECT
    6210 as TAG,
	6200 AS Parent,	
	'' AS [Metrics!6000],	
	'' AS [SmallPerformanceMetrics!6200],
	s.LastTimeUpdate AS [Item!6210!LastTimeUpdate],
	s.MetricId AS [Item!6210!MetricId],
	s.Value AS [Item!6210!Value]	
FROM smallPerformanceMetrics s

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill monitor and small metrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

-- large performance metrics
;WITH performanceMetrics AS (
    SELECT DISTINCT
		MetricId AS MetricId			
		FROM #MetricDefinitions 
		WHERE MetricId IN (SELECT DISTINCT MetricId FROM #PerfMetricValues) AND MetricType = 4
)
INSERT INTO #ResultUniversalTable (TAG, Parent, [Metrics!6000], [PerformanceMetrics!6300], [Metric!6310!MetricId],[Item!6311!DateTime],[Item!6311!Value])
SELECT
    6310 as TAG,
	6300 AS Parent,	
	'' AS [Metrics!6000],	
	'' AS [PerformanceMetrics!6300],
	p.MetricId AS [Metric!6310!MetricId], NULL AS [Item!6311!DateTime], NULL AS [Item!6311!Value]
FROM performanceMetrics p
UNION ALL SELECT
    6311 as TAG,
	6310 AS Parent,	
	'' AS [Metrics!6000],	
	'' AS [PerformanceMetrics!6300],
	p.MetricId AS [Metric!6310!MetricId], 
	p.Dt AS [Item!6311!DateTime], 
	p.Value AS [Item!6311!Value]	
FROM #PerfMetricValues p

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill large performance Metrics', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

-- Metadata
INSERT INTO #ResultUniversalTable (Tag, Parent, [Metadata!7000], [Monitors!7100], [Item!7110!MonitorDefaultName], [Item!7110!MonitorName],[Item!7110!MonitorSystemName], [Item!7110!MpSystemName])
SELECT
    7110 as TAG,
	7100 AS Parent,	
	'' AS [Metadata!7000],
	'' AS [Monitors!7100],		
	m.[Item!1!MonitorDefaultName] AS [Item!7110!MonitorDefaultName],
	m.[Item!1!MonitorName] AS [Item!7110!MonitorName],
	m.[Item!1!MonitorSystemName] AS [Item!7110!MonitorSystemName],
	m.[Item!1!MpSystemName] AS [Item!7110!MpSystemName]
FROM #Monitors m

INSERT INTO #ResultUniversalTable (Tag, Parent, [Metadata!7000], [Rules!7200], [Item!7210!RuleDefaultName], [Item!7210!RuleName],[Item!7210!RuleSystemName], [Item!7210!MpSystemName])
SELECT
    7210 as TAG,
	7200 AS Parent,	
	'' AS [Metadata!7000],	
	'' AS [Rules!7200],	
	r.[Item!1!RuleDefaultName] AS [Item!7210!RuleDefaultName], 
	r.[Item!1!RuleName] AS [Item!7210!RuleName],
	r.[Item!1!RuleSystemName] AS [Item!7210!RuleSystemName], 
	r.[Item!1!MpSystemName] AS [Item!7210!MpSystemName]
FROM #Rules r

-- Selected Child
;WITH selectedChild AS (
    SELECT 
    	@selectedItemGuid AS "Id", 
    	mp.ManagementPackSystemName + '!' + met.ManagedEntityTypeSystemName AS "TypeSystemName",
    	COALESCE(met.ManagedEntityTypeDefaultName, met.ManagedEntityTypeSystemName) AS "TypeDefaultName",
    	COALESCE(ds.Name, dsENU.Name) AS "TypeName" 
    FROM vManagedEntityType met WITH (NOLOCK)
    	INNER JOIN dbo.vManagementPack mp ON met.ManagementPackRowId = mp.ManagementPackRowId
    	left JOIN vDisplayString dsENU WITH (NOLOCK) ON met.ManagedEntityTypeGuid = dsENU.ElementGuid AND dsENU.LanguageCode = @LanguageCodeENU
    	left JOIN vDisplayString ds WITH (NOLOCK) ON met.ManagedEntityTypeGuid = ds.ElementGuid AND ds.LanguageCode = @LanguageCode
    WHERE met.ManagedEntityTypeRowId = @selectedItemTypeRowId
)
INSERT INTO #ResultUniversalTable (Tag, Parent, [SelectedChild!8000!Id], [SelectedChild!8000!TypeDefaultName], [SelectedChild!8000!TypeName], [SelectedChild!8000!TypeSystemName])
 SELECT
    8000 as TAG,
	1000 AS Parent,	
	s.Id AS [SelectedChild!8000!Id], 
	s.TypeDefaultName AS [SelectedChild!8000!TypeDefaultName], 
	s.TypeName AS [SelectedChild!8000!TypeName],
	s.TypeSystemName AS [SelectedChild!8000!TypeSystemName]
FROM selectedChild s

IF @profiling = 1
BEGIN
  SET @EndTimeSegment = getdate()
  INSERT INTO #profilingdata VALUES ('Fill selected child and metadata', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
  SET @StartTimeSegment = getdate()
END

SELECT * FROM #ResultUniversalTable
ORDER BY 	
	[Data!1000],	
	[SelectedChild!8000!Id],
	[Metadata!7000],
	[Rules!7200],
	[Item!7210!MpSystemName],
	[Monitors!7100],
	[Item!7110!MpSystemName],
	[Metrics!6000],	
	[PerformanceMetrics!6300],	
	[Metric!6310!MetricId],
	[Item!6311!DateTime],
	[SmallPerformanceMetrics!6200],
	[Item!6210!MetricId],
	[MonitorMetrics!6100],
	[Item!6110!MetricId],
	[RelatedMetrics!1500],	
	[Metric!1510!Type],
	[Item!1511!Name],
	[Item!1511!Value],
	[Alerts!1400],
	[Item!1410!Severity],
	[Item!1410!DateTime],
	[Properties!1300],
	[Item!1310!PropertyDefaultName],
	[Images!1200],
	[Item!1210!ImageId],
	[Children!1100],		
    [Item!1110!HealthState],	
	[Item!1110!DisplayName],
	[Item!1110!Id],
	[Metric!1111!Order!hide]
	
FOR XML EXPLICIT, BINARY BASE64

IF @profiling = 1
BEGIN
SET @EndTimeSegment = getdate()
INSERT INTO #profilingdata VALUES ('Produce OUTPUT', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
DECLARE @EndTime DateTime = getdate();
INSERT INTO #profilingdata VALUES ('Total time', DATEDIFF(MILLISECOND, @StartTime, @EndTime))
SELECT * FROM #profilingdata
END

    END TRY
    BEGIN CATCH
        IF (@@TRANCOUNT > 0)
            ROLLBACK TRAN

        SELECT
             @ErrorNumber = ERROR_NUMBER()
            ,@ErrorSeverity = ERROR_SEVERITY()
            ,@ErrorState = ERROR_STATE()
            ,@ErrorLine = ERROR_LINE()
            ,@ErrorProcedure = isnull(ERROR_PROCEDURE(), '-')
            ,@ErrorMessageText = ERROR_MESSAGE()

        SET @ErrorInd = 1
    END CATCH

    -- report error IF any
    IF (@ErrorInd = 1)
    BEGIN
        DECLARE @AdjustedErrorSeverity int

        SET @AdjustedErrorSeverity = CASE
                                         WHEN @ErrorSeverity > 18 THEN 18
                                         ELSE @ErrorSeverity
                                     END

        RAISERROR ('error. Number: %d. Severity: %d. State: %d. PROCEDURE: %s. Line: %d. MessageText: %s.', @AdjustedErrorSeverity, 1
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

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_GetInstanceViewData] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateHierarchy]
(
	@profiling bit = 0
)
AS
BEGIN
    SET NOCOUNT ON
	DECLARE @ExecError int

	EXEC @ExecError = sdk.Microsoft_SQLServer_Visualization_Library_UpdateTablesList

	DECLARE @batchSize int = 50000;
	DECLARE @maxDeadlockCount int = 5;

	DECLARE @FirstId bigint, @LastId bigint, @firstRun bit = 0, @deadlockRetries int, @testRowCount bigint = 0, @batchTestRowCount int = 0;

	DECLARE @CurrentBatch TABLE (
	BatchId bigint,
	FirstId bigint, 
	LastId bigint
	)

	DECLARE @delay int = 5;
	While (@delay > 0)
	BEGIN
		IF EXISTS (SELECT NULL 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NULL AND t.Type IN (5,6))
		BEGIN
			BREAK
		END

		IF EXISTS (SELECT NULL 
		FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
		INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
		WHERE b.StartDate is NOT NULL AND b.FinishDate is NULL AND t.Type IN (5,6))
		BEGIN
			WAITFOR delay '00:00:01'
		END
		SET @delay = @delay - 1;
	END

	While (1=1)
	BEGIN
	UPDATE b
	SET StartDate = GetUtcDate()
	OUTPUT inserted.BatchId, inserted.FirstId, inserted.LastId INTO @CurrentBatch
	FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
	WHERE b.BatchId = (SELECT TOP 1 b.BatchId FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
	WHERE b.StartDate is NULL AND t.Type = 5
	order by b.BatchId desc)


	SELECT TOP 1 @FirstId = FirstId, @LastId = LastId FROM @CurrentBatch

	IF @@ROWCOUNT = 0
		BREAK

	DECLARE @updatedMPVersions TABLE (
		ManagementPackVersionRowId [int] NOT NULL,
		ManagementPackRowId [int] NOT NULL
	);

	INSERT INTO @updatedMPVersions
	SELECT max(mpv.ManagementPackVersionRowId) AS ManagementPackVersionRowId, mpv.ManagementPackRowId AS ManagementPackRowId
	FROM dbo.ManagementPackVersion mpv WITH (NOLOCK)
	WHERE mpv.ManagementPackVersionRowId > @FirstId AND mpv.ManagementPackVersionRowId <= @LastId
	group by mpv.ManagementPackRowId

	DECLARE @removedMPVersions TABLE (
		ManagementPackVersionRowId [int] NOT NULL
	);

	INSERT INTO @removedMPVersions
	SELECT mpv.ManagementPackVersionRowId
	FROM dbo.ManagementPackVersion mpv WITH (NOLOCK)
	WHERE ManagementPackRowId IN (SELECT DISTINCT ManagementPackRowId FROM @updatedMPVersions) 
	AND ManagementPackVersionRowId NOT IN (SELECT ManagementPackVersionRowId FROM @updatedMPVersions)

	-- DELETE outdated elements
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH RemovedIds AS (
				SELECT rtmpv.RelationshipTypeRowId
				FROM dbo.RelationshipTypeManagementPackVersion rtmpv WITH (NOLOCK)
				WHERE rtmpv.ManagementPackVersionRowId IN (SELECT ManagementPackVersionRowId FROM @removedMPVersions)
				)
				DELETE TOP(@batchSize) FROM sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy
				WHERE Child IN (SELECT RelationshipTypeRowId FROM RemovedIds) or Parent IN (SELECT RelationshipTypeRowId FROM RemovedIds)
				SET @testRowCount = @@ROWCOUNT
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
	END;

	DECLARE @updatedRTs TABLE (
		BaseRelationshipTypeRowId [int] NOT NULL,
		RelationshipTypeRowId [int] NOT NULL,
		UNIQUE CLUSTERED (BaseRelationshipTypeRowId, RelationshipTypeRowId)
	);

	INSERT INTO @updatedRTs
	SELECT DISTINCT rtmpv.BaseRelationshipTypeRowId, rtmpv.RelationshipTypeRowId
	FROM dbo.RelationshipTypeManagementPackVersion rtmpv WITH (NOLOCK)
	WHERE rtmpv.ManagementPackVersionRowId IN (SELECT ManagementPackVersionRowId FROM @updatedMPVersions)
	AND rtmpv.BaseRelationshipTypeRowId is NOT NULL
	order by BaseRelationshipTypeRowId, RelationshipTypeRowId;

	-- INSERT new elements
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy
				SELECT 
					u1.BaseRelationshipTypeRowId AS Parent,
					u1.RelationshipTypeRowId AS Child 
				FROM @updatedRTs u1
				SET @testRowCount = @@ROWCOUNT
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
	END;

	--parents branch
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH insertable AS (
					SELECT DISTINCT
						h.Parent AS Parent, 
						u2.RelationshipTypeRowId AS Child 
					FROM @updatedRTs u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h ON h.Child = u2.BaseRelationshipTypeRowId
					WHERE NOT EXISTS (
						SELECT NULL
						FROM sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h2
						WHERE h.Parent = h2.Parent
						  AND u2.RelationshipTypeRowId = h2.Child
					)
				)
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy
				SELECT i.Parent, i.Child FROM insertable i
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
	END;

	--Children branch
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH insertable AS (
					SELECT DISTINCT
						u2.BaseRelationshipTypeRowId AS Parent, 
						h.Child AS Child 
					FROM @updatedRTs u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h ON u2.RelationshipTypeRowId = h.Parent 
					WHERE NOT EXISTS (
						SELECT NULL
						FROM sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h2
						WHERE u2.BaseRelationshipTypeRowId = h2.Parent
						  AND h.Child = h2.Child
					)
				)
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy
				SELECT i.Parent, i.Child FROM insertable i
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
	END;

	--Children other parents branch
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH inserted AS (
					SELECT 
						u2.BaseRelationshipTypeRowId AS Parent, 
						h.Child AS Child 
					FROM @updatedRTs u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h ON u2.RelationshipTypeRowId = h.Parent 
				),
				insertable AS (
					SELECT DISTINCT
						h.Parent AS Parent, 
						u2.Child AS Child 
					FROM inserted u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h ON h.Child = u2.Parent
					WHERE NOT EXISTS (
						SELECT NULL
						FROM sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy h2
						WHERE h.Parent = h2.Parent
						  AND u2.Child = h2.Child
					)
				)
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy
				SELECT i.Parent, i.Child FROM insertable i
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
	END;

	DELETE FROM @updatedRTs;
	DELETE FROM @updatedMPVersions;
	DELETE FROM @removedMPVersions;

	UPDATE b
	SET FinishDate = GetUtcDate()
	FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
	INNER JOIN @CurrentBatch cb ON b.BatchId = cb.BatchId;

	DELETE FROM @CurrentBatch

	END

	-- Contained AND hosted objects hierarchy

	DECLARE @groupTypeId bigint;
	SELECT TOP 1 @groupTypeId = met.ManagedEntityTypeRowId 
	FROM dbo.ManagedEntityType met
	WHERE met.ManagedEntityTypeSystemName = 'System.Group'

	IF @profiling = 1
	BEGIN
	DECLARE @StartTime DateTime;
	DECLARE @StartTimeSegment DateTime = getdate();
	DECLARE @EndTimeSegment DateTime;
	DECLARE @profilingdata TABLE (
		Name varchar(200),
		length int
	);
	END
	While (1=1)

	BEGIN
	IF @profiling = 1
	BEGIN
	SET @StartTime = getdate()
	END
	UPDATE b
	SET StartDate = GetUtcDate()
	OUTPUT inserted.BatchId, inserted.FirstId, inserted.LastId INTO @CurrentBatch
	FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
	WHERE b.BatchId = (SELECT TOP 1 b.BatchId FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
	INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Tables t ON b.TableId = t.TableId
	WHERE b.StartDate is NULL AND t.Type = 6
	order by b.BatchId desc)

	SELECT TOP 1 @FirstId = FirstId, @LastId = LastId FROM @CurrentBatch
	SET @batchTestRowCount = @@ROWCOUNT

	IF @profiling = 1
	BEGIN
	SET @EndTimeSegment = getdate()
	INSERT INTO @profilingdata VALUES ('Get batch FROM ' + LTRIM(STR(@FirstId, 38, 0)) + ' TO ' +LTRIM(STR(@LastId, 38, 0)), DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
	SET @StartTimeSegment = getdate()
	END
	-- locate AND remove descendant references 
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount = @batchSize) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
			--	SET STATISTICS PROFILE ON
				SET @firstRun = 0;
				; WITH to_delete_rowIds AS (
					SELECT DISTINCT 
						rh.IsGroup,
						rh.RelationshipManagementPackRowId
					FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rh WITH (NOLOCK)
					INNER JOIN dbo.RelationshipManagementGroup rmg WITH (NOLOCK) 
						ON rh.RelationshipManagementPackRowId = rmg.RelationshipManagementGroupRowId
					WHERE rmg.ToDateTime is NOT NULL
				), 
				to_delete AS (
					SELECT
						rh.IsGroup,
						rh.RelationshipManagementPackRowId,
						rh.Parent,
						rh.Child
					FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rh WITH (NOLOCK)
					INNER JOIN to_delete_rowIds r ON rh.IsGroup = r.IsGroup AND rh.RelationshipManagementPackRowId = r.RelationshipManagementPackRowId
				),
				not_affected_links AS (
					SELECT 
						h.IsGroup,
						h.RelationshipManagementPackRowId, 
						h.Parent, 
						h.Child 
					FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h
					INNER JOIN to_delete d ON h.Parent = d.Parent AND h.Child = d.Child
					except
					SELECT * FROM to_delete
				),
				affected_links AS (
					SELECT Parent, Child FROM to_delete
					except
					SELECT Parent, Child FROM not_affected_links
				),
				affected_rowIds AS (
					SELECT DISTINCT h.IsGroup, h.RelationshipManagementPackRowId, l.Parent, h.Child
					FROM affected_links l
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h
						ON l.Child = h.Parent				
				)
				DELETE TOP(@batchSize) h 
				FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h
				INNER JOIN affected_rowIds r 
				   ON h.IsGroup = r.IsGroup 
				  AND h.RelationshipManagementPackRowId = r.RelationshipManagementPackRowId
				  AND h.Parent = r.Parent 
				  AND h.Child = r.Child;
				SET @testRowCount = @@ROWCOUNT;
			--	SET STATISTICS PROFILE OFF
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('remove '+LTRIM(STR(@testRowCount, 38, 0))+' descendants', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END
	END;

	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount = @batchSize) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				; WITH to_delete AS (
					SELECT DISTINCT 
						rh.IsGroup,
						rh.RelationshipManagementPackRowId 
					FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy rh WITH (NOLOCK)
					INNER JOIN dbo.RelationshipManagementGroup rmg WITH (NOLOCK) 
						ON rh.RelationshipManagementPackRowId = rmg.RelationshipManagementGroupRowId
					WHERE rmg.ToDateTime is NOT NULL
				)
				DELETE TOP(@batchSize) h FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h
				INNER JOIN to_delete d 
				   ON d.IsGroup = h.IsGroup 
				  AND d.RelationshipManagementPackRowId = h.RelationshipManagementPackRowId;
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('remove '+LTRIM(STR(@testRowCount, 38, 0))+' rows', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END
	END;

	IF @batchTestRowCount = 0
		BREAK

	DECLARE @insertedRelationships TABLE (
		[IsGroup] [bit] NOT NULL,
		[RelationshipManagementPackRowId] [int] NOT NULL,
		[Parent] [int] NOT NULL,
		[Child] [int] NOT NULL,
		UNIQUE CLUSTERED ([IsGroup], [RelationshipManagementPackRowId], [Parent], [Child])
	);

	; WITH parentRT AS (
		SELECT TOP 1 rt.RelationshipTypeRowId
			FROM dbo.vRelationshipType rt WITH (NOLOCK)
			WHERE rt.RelationshipTypeSystemName = 'System.Containment'			
	),
			
	FilteredRT AS (
		SELECT RelationshipTypeRowId 
			FROM parentRT
		UNION ALL
		SELECT rth.Child AS RelationshipTypeRowId
			FROM parentRT rt WITH (NOLOCK)
			INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy rth WITH (NOLOCK) ON rt.RelationshipTypeRowId = rth.Parent
	),

	groupTypeIDs AS (
		SELECT h.ManagedEntityTypeRowId AS TypeRowId
		FROM dbo.ManagedEntityDerivedTypeHierarchy(@groupTypeId, 0) h
	)

	INSERT INTO @insertedRelationships 
	SELECT DISTINCT
		CASE WHEN g.TypeRowId is NOT NULL THEN 1 ELSE 0 END AS IsGroup,
		rmg.RelationshipManagementGroupRowId AS RelationshipManagementGroupRowId,
		r.SourceManagedEntityRowId AS Parent,
		r.TargetManagedEntityRowId AS Child
	FROM dbo.RelationshipManagementGroup rmg WITH (NOLOCK)
	INNER JOIN dbo.Relationship r WITH (NOLOCK) ON rmg.RelationshipRowId = r.RelationshipRowId
	INNER JOIN dbo.ManagedEntity me WITH (NOLOCK) ON r.SourceManagedEntityRowId = me.ManagedEntityRowId
	left JOIN groupTypeIDs g ON me.ManagedEntityTypeRowId = g.TypeRowId
	WHERE rmg.RelationshipManagementGroupRowId between @FirstId AND @LastId
		AND rmg.ToDateTime is NULL
		AND EXISTS (SELECT NULL FROM FilteredRT rt WHERE rt.RelationshipTypeRowId = r.RelationshipTypeRowId) 
	order by IsGroup, RelationshipManagementGroupRowId, Parent, Child;      

		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('Get new rows', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END

	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy
				SELECT 
					u1.IsGroup AS IsGroup,
					u1.RelationshipManagementPackRowId AS RelationshipManagementPackRowId,
					u1.Parent AS Parent,
					u1.Child AS Child 
				FROM @insertedRelationships u1
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('INSERT '+LTRIM(STR(@testRowCount, 38, 0))+' rows', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END
	END;

	--parents branch
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH insertable AS (
					SELECT DISTINCT
						u2.IsGroup,
						u2.RelationshipManagementPackRowId AS RelationshipManagementPackRowId,
						h.Parent AS Parent, 
						u2.Child AS Child 
					FROM @insertedRelationships u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h ON h.Child = u2.Parent AND h.IsGroup = u2.IsGroup
					WHERE NOT EXISTS (
						SELECT NULL
						FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h2
						WHERE u2.IsGroup = h2.IsGroup
						  AND u2.RelationshipManagementPackRowId = h2.RelationshipManagementPackRowId
						  AND h.Parent = h2.Parent
						  AND u2.Child = h2.Child
					)
				)
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy
				SELECT i.IsGroup, i.RelationshipManagementPackRowId, i.Parent, i.Child FROM insertable i
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('INSERT '+LTRIM(STR(@testRowCount, 38, 0))+' parents', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END
	END;

	--Children branch
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH insertable AS (
					SELECT DISTINCT
						h.IsGroup,
						h.RelationshipManagementPackRowId AS RelationshipManagementPackRowId,
						u2.Parent AS Parent, 
						h.Child AS Child 
					FROM @insertedRelationships u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h ON u2.Child = h.Parent AND u2.IsGroup = h.IsGroup
					WHERE NOT EXISTS (
						SELECT NULL
						FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h2
						WHERE h.IsGroup = h2.IsGroup
						  AND h.RelationshipManagementPackRowId = h2.RelationshipManagementPackRowId
						  AND u2.Parent = h2.Parent
						  AND h.Child = h2.Child
					)
				)
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy
				SELECT i.IsGroup, i.RelationshipManagementPackRowId, i.Parent, i.Child FROM insertable i
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('INSERT '+LTRIM(STR(@testRowCount, 38, 0))+' Children', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END
	END;

	--Children other parents branch
	SET @firstRun = 1;
	SET @deadlockRetries = @maxDeadlockCount;
	While (@firstRun = 1 or @testRowCount > 0) 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION	
				SET @firstRun = 0;
				;WITH inserted AS (
					SELECT 
						h.IsGroup,
						h.RelationshipManagementPackRowId AS RelationshipManagementPackRowId,
						u2.Parent AS Parent, 
						h.Child AS Child 
					FROM @insertedRelationships u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h ON u2.Child = h.Parent AND u2.IsGroup = h.IsGroup
				),
				insertable AS (
					SELECT DISTINCT
						u2.IsGroup,
						u2.RelationshipManagementPackRowId AS RelationshipManagementPackRowId,
						h.Parent AS Parent, 
						u2.Child AS Child 
					FROM inserted u2
					INNER JOIN sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h ON h.Child = u2.Parent AND h.IsGroup = u2.IsGroup
					WHERE NOT EXISTS (
						SELECT NULL
						FROM sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy h2
						WHERE u2.IsGroup = h2.IsGroup
						  AND u2.RelationshipManagementPackRowId = h2.RelationshipManagementPackRowId
						  AND h.Parent = h2.Parent
						  AND u2.Child = h2.Child
					)
				)
				INSERT TOP(@batchSize) INTO sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy
				SELECT i.IsGroup, i.RelationshipManagementPackRowId, i.Parent, i.Child FROM insertable i
				SET @testRowCount = @@ROWCOUNT;
			COMMIT TRANSACTION
			SET @deadlockRetries = @maxDeadlockCount;
		END TRY
		BEGIN CATCH 
			IF XACT_STATE() <> 0 
				ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 AND @deadlockRetries > 0
				SET @deadlockRetries = @deadlockRetries - 1 
			ELSE
				EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError]  
		END CATCH 
		IF @profiling = 1
		BEGIN
		SET @EndTimeSegment = getdate()
		INSERT INTO @profilingdata VALUES ('INSERT '+LTRIM(STR(@testRowCount, 38, 0))+' other parents of Children', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
		SET @StartTimeSegment = getdate()
		END
	END;

	DELETE FROM @insertedRelationships;

	IF @profiling = 1
	BEGIN
	SET @EndTimeSegment = getdate()
	INSERT INTO @profilingdata VALUES ('Clean @insertedRelationships', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
	SET @StartTimeSegment = getdate()
	END

	UPDATE b
	SET FinishDate = GetUtcDate()
	FROM sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches b
	INNER JOIN @CurrentBatch cb ON b.BatchId = cb.BatchId;

	DELETE FROM @CurrentBatch;

	IF @profiling = 1
	BEGIN
	SET @EndTimeSegment = getdate()
	INSERT INTO @profilingdata VALUES ('UPDATE batch', DATEDIFF(MILLISECOND, @StartTimeSegment, @EndTimeSegment))
	DECLARE @EndTime DateTime = getdate();
	INSERT INTO @profilingdata VALUES ('Total time', DATEDIFF(MILLISECOND, @StartTime, @EndTime))
	SELECT * FROM @profilingdata
	DELETE FROM @profilingdata
	END

	END
END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateHierarchy] TO OpsMgrReader
GO

-- CREATE the stored PROCEDURE TO generate an error using 
-- RAISERROR. the original error information is used TO
-- construct the msg_str FOR RAISERROR.
ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError] AS
BEGIN
    -- RETURN IF there is no error information TO retrieve.
    IF ERROR_NUMBER() is NULL
        RETURN;

    DECLARE 
        @ErrorMessage    nvarchar(4000),
        @ErrorNumber     int,
        @ErrorSeverity   int,
        @ErrorState      int,
        @ErrorLine       int,
        @ErrorProcedure  nvarchar(200);

    -- Assign variables TO error-handling functions that 
    -- capture information FOR RAISERROR.
    SELECT 
        @ErrorNumber = ERROR_NUMBER(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE(),
        @ErrorLine = ERROR_LINE(),
        @ErrorProcedure = isnull(ERROR_PROCEDURE(), '-');

    -- Build the message string that will contain original
    -- error information.
    SELECT @ErrorMessage = 
        N'error %d, Level %d, State %d, PROCEDURE %s, Line %d, ' + 
            'message: '+ ERROR_MESSAGE();

    -- Raise an error: msg_str parameter of RAISERROR will contain
    -- the original error information.
    RAISERROR 
        (
        @ErrorMessage, 
        @ErrorSeverity, 
        1,               
        @ErrorNumber,    -- parameter: original error Number.
        @ErrorSeverity,  -- parameter: original error Severity.
        @ErrorState,     -- parameter: original error State.
        @ErrorProcedure, -- parameter: original error PROCEDURE Name.
        @ErrorLine       -- parameter: original error Line Number.
        );
END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_RethrowError] TO OpsMgrReader
GO

ALTER PROCEDURE [sdk].[Microsoft_SQLServer_Visualization_Library_GetResolvedGUIDs]
(
	@LANGUAGE_CODE nvarchar(max),
	@MANAGEMENT_GROUP_GUID uniqueidentifier,
	@XML_DATA XML
)
AS
BEGIN

DECLARE @ManagementGroupRowId int;
SELECT @ManagementGroupRowId = mg.ManagementGroupRowId
FROM  dbo.vManagementGroup mg WITH (NOLOCK) 
WHERE mg.ManagementGroupGuid = @MANAGEMENT_GROUP_GUID;

DECLARE @requestedGroups TABLE (
	Id int PRIMARY KEY
);

;WITH allowedGroups AS (
	SELECT DISTINCT ParamValues.x.value('@ID','uniqueidentifier') AS [Guid] FROM @XML_DATA.nodes('/ResolveGuidsDataSourceRequest/OpsManagerConfiguration/AllowedGroup') AS ParamValues(x)
),

requestedGroups AS (
	SELECT DISTINCT ParamValues.x.value('@Id','uniqueidentifier') AS [Guid], LOWER(ParamValues.x.value('@InstanceId','nvarchar(2000)')) AS [InstanceId] FROM @XML_DATA.nodes('/ResolveGuidsDataSourceRequest/DatacenterGroup') AS ParamValues(x)
),

updated_groups AS (
	SELECT mt.ManagedEntityTypeGuid as [Guid], s.InstanceId FROM requestedGroups s
	INNER JOIN dbo.[vManagedEntityType] mt WITH (NOLOCK) ON SUBSTRING(s.InstanceId, CHARINDEX('!', s.InstanceId) + 1, 2000) = LOWER(mt.ManagedEntityTypeSystemName)
	INNER JOIN dbo.[vManagementPack] mp WITH (NOLOCK) ON mp.ManagementPackRowId = mt.ManagementPackRowId AND SUBSTRING(s.InstanceId, 1, CHARINDEX('!', s.InstanceId) - 1) = LOWER(mp.ManagementPackSystemName)
	WHERE s.[Guid] is null and CHARINDEX('!', s.InstanceId) > 0
	UNION ALL
	SELECT s.[Guid], NULL AS InstanceId FROM requestedGroups s
	WHERE s.[Guid] is not null
)

INSERT INTO @requestedGroups
SELECT met.ManagedEntityTypeRowId FROM allowedGroups a
INNER JOIN updated_groups r on a.Guid = r.Guid
INNER JOIN dbo.vManagedEntityType met WITH (NOLOCK) on r.Guid = met.ManagedEntityTypeGuid;

;WITH latestMpVersion AS (
	SELECT mpv.[ManagementPackRowId], MAX(mpv.[ManagementPackVersionRowId]) AS ManagementPackVersionRowId
	FROM  [dbo].[ManagementPackVersion] mpv (NOLOCK)
	JOIN [dbo].[ManagementGroupManagementPackVersion] mgmpv (NOLOCK) ON mgmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
	WHERE mgmpv.DeletedDateTime IS NULL AND mgmpv.ManagementGroupRowId = @ManagementGroupRowId
	GROUP BY mpv.[ManagementPackRowId]
),

met AS (
SELECT vmet.ManagedEntityTypeRowId, vmet.ManagedEntityTypeGuid, vmet.ManagedEntityTypeSystemName, mp.ManagementPackSystemName
FROM dbo.vManagedEntityType vmet (NOLOCK)
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion vmetmpv (NOLOCK) ON vmet.ManagedEntityTypeRowId = vmetmpv.ManagedEntityTypeRowId
INNER JOIN latestMpVersion ON latestMpVersion.ManagementPackVersionRowId = vmetmpv.ManagementPackVersionRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON latestMpVersion.ManagementPackRowId = mp.ManagementPackRowId
WHERE vmet.ManagedEntityTypeSystemName = 'System.Group' and mp.ManagementPackSystemName = 'System.Library'
UNION ALL
SELECT vmet.ManagedEntityTypeRowId, vmet.ManagedEntityTypeGuid, vmet.ManagedEntityTypeSystemName, mp.ManagementPackSystemName
FROM dbo.vManagedEntityType vmet (NOLOCK)
INNER JOIN dbo.vManagedEntityTypeManagementPackVersion vmetmpv (NOLOCK) ON vmet.ManagedEntityTypeRowId = vmetmpv.ManagedEntityTypeRowId
INNER JOIN latestMpVersion ON latestMpVersion.ManagementPackVersionRowId = vmetmpv.ManagementPackVersionRowId
INNER JOIN met ON met.ManagedEntityTypeRowId = vmetmpv.BaseManagedEntityTypeRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON latestMpVersion.ManagementPackRowId = mp.ManagementPackRowId
WHERE vmetmpv.Accessibility = 'Public' 
),

loc AS (
SELECT 
	met.ManagedEntityTypeGuid, 
	met.ManagedEntityTypeSystemName,
	met.ManagementPackSystemName,
	vme.ManagedEntityGuid
FROM met 
INNER JOIN @requestedGroups r on met.ManagedEntityTypeRowId = r.Id
INNER JOIN dbo.vManagedEntity vme (NOLOCK) ON vme.ManagedEntityTypeRowId = met.ManagedEntityTypeRowId
INNER JOIN dbo.vManagedEntityManagementGroup vmemg (NOLOCK) ON vme.ManagedEntityRowId = vmemg.ManagedEntityRowId
WHERE vmemg.ToDateTime IS NULL AND vme.ManagementGroupRowId = @ManagementGroupRowId
),

requestedRules AS (
	SELECT DISTINCT ParamValues.x.value('@Id','uniqueidentifier') AS [Guid] FROM @XML_DATA.nodes('/ResolveGuidsDataSourceRequest/Rule') AS ParamValues(x)
), 

rules as (
SELECT 
	r.RuleGuid,
	r.RuleSystemName, 
	r.RuleDefaultName, 
	mp.ManagementPackSystemName 
FROM requestedRules rr
INNER JOIN dbo.vRule r WITH (NOLOCK) ON rr.[Guid] = r.RuleGuid
INNER JOIN dbo.vRuleManagementPackVersion rmpv WITH (NOLOCK) ON r.RuleRowId = rmpv.RuleRowId
INNER JOIN latestMpVersion lmpv WITH (NOLOCK) ON rmpv.ManagementPackVersionRowId = lmpv.ManagementPackVersionRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON lmpv.ManagementPackRowId = mp.ManagementPackRowId
INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) on rmpv.ManagementPackVersionRowId = mgmpv.ManagementPackVersionRowId
WHERE mgmpv.ManagementGroupRowId = @ManagementGroupRowId
),

requestedMonitors AS (
	SELECT DISTINCT ParamValues.x.value('@Id','uniqueidentifier') AS [Guid] FROM @XML_DATA.nodes('/ResolveGuidsDataSourceRequest/Monitor') AS ParamValues(x)
), 

monitors as (
SELECT 
	m.MonitorGuid,
	m.MonitorSystemName, 
	m.MonitorDefaultName, 
	mp.ManagementPackSystemName 
FROM requestedMonitors rm
INNER JOIN dbo.vMonitor m WITH (NOLOCK) ON rm.[Guid] = m.MonitorGuid
INNER JOIN dbo.vMonitorManagementPackVersion mmpv WITH (NOLOCK) ON m.MonitorRowId = mmpv.MonitorRowId
INNER JOIN latestMpVersion lmpv WITH (NOLOCK) ON mmpv.ManagementPackVersionRowId = lmpv.ManagementPackVersionRowId
INNER JOIN dbo.vManagementPack mp (NOLOCK) ON lmpv.ManagementPackRowId = mp.ManagementPackRowId
INNER JOIN dbo.vManagementGroupManagementPackVersion mgmpv WITH (NOLOCK) on mmpv.ManagementPackVersionRowId = mgmpv.ManagementPackVersionRowId
WHERE mgmpv.ManagementGroupRowId = @ManagementGroupRowId
),

reqMonCls AS(
	SELECT DISTINCT LOWER(ParamValues.x.value('@ClassId','nvarchar(2000)')) AS [ClassName], LOWER(ParamValues.x.value('@Name','nvarchar(2000)')) AS [MonitorName] FROM @XML_DATA.nodes('/ResolveGuidsDataSourceRequest/MonitorName') AS ParamValues(x)
),
monClassesHi AS(
	SELECT DISTINCT met.[ManagedEntityTypeRowId] typeId, ( mp.[ManagementPackSystemName] + '!' + met.[ManagedEntityTypeSystemName]) typeName, met.[ManagedEntityTypeRowId] baseTypeId
	FROM [dbo].[vManagedEntityType] met (NOLOCK)
	INNER JOIN [dbo].[vManagementPack] mp (NOLOCK) ON met.ManagementPackRowId = mp.ManagementPackRowId
	INNER JOIN latestMpVersion ON mp.ManagementPackRowId = latestMpVersion.ManagementPackRowId
	INNER JOIN reqMonCls ON reqMonCls.ClassName = mp.ManagementPackSystemName + '!' + met.ManagedEntityTypeSystemName
	UNION ALL
	SELECT monClassesHi.typeId, monClassesHi.typeName, metb.[ManagedEntityTypeRowId] baseTypeId
	FROM monClassesHi
	INNER JOIN [dbo].[vManagedEntityTypeManagementPackVersion] (NOLOCK) mtmpv ON monClassesHi.baseTypeId = mtmpv.ManagedEntityTypeRowId 
	INNER JOIN [dbo].[vManagedEntityType] metb (NOLOCK) ON mtmpv.BaseManagedEntityTypeRowId = metb.ManagedEntityTypeRowId 
	INNER JOIN latestMpVersion mpv ON mtmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
)

SELECT 
	999 AS TAG, 
	NULL AS Parent, 
	'' AS [ResolvedGUIDsDataSourceResult!999],
	NULL AS [Group!1!Id],
	NULL AS [Group!1!Guid],
	NULL AS [Group!1!IsSingletone],
	NULL AS [Rule!2!Id],
	NULL AS [Rule!2!DisplayName],
	NULL AS [Rule!2!Guid],
	NULL AS [Monitor!3!Id],
	NULL AS [Monitor!3!DisplayName],
	NULL AS [Monitor!3!Guid],
	NULL AS [MonitorName!4!Id],
	NULL AS [MonitorName!4!Guid],
	NULL AS [MonitorName!4!ClassId]
UNION ALL
SELECT 
	1 AS TAG, 
	999 AS Parent, 
	'' AS [ResolvedGUIDsDataSourceResult!999],
	loc.ManagementPackSystemName + '!' + loc.ManagedEntityTypeSystemName AS [Group!1!Id],
	loc.ManagedEntityGuid AS [Group!1!Guid],
	CASE WHEN loc.ManagedEntityGuid = loc.ManagedEntityTypeGuid THEN 1 ELSE 0 END AS [Group!1!IsSingletone],
	NULL AS [Rule!2!Id],
	NULL AS [Rule!2!DisplayName],
	NULL AS [Rule!2!Guid],
	NULL AS [Monitor!3!Id],
	NULL AS [Monitor!3!DisplayName],
	NULL AS [Monitor!3!Guid],
	NULL AS [MonitorName!4!Id],
	NULL AS [MonitorName!4!Guid],
	NULL AS [MonitorName!4!ClassId]
FROM loc
UNION ALL
SELECT 
	2 AS TAG, 
	999 AS Parent, 
	'' AS [ResolvedGUIDsDataSourceResult!999],
	NULL AS [Group!1!Id],
	NULL AS [Group!1!Guid],
	NULL AS [Group!1!IsSingletone],
	r.ManagementPackSystemName + '!' + r.RuleSystemName AS [Rule!2!Id],
	r.RuleDefaultName AS [Rule!2!DisplayName],
	r.RuleGuid AS [Rule!2!Guid],
	NULL AS [Monitor!3!Id],
	NULL AS [Monitor!3!DisplayName],
	NULL AS [Monitor!3!Guid],
	NULL AS [MonitorName!4!Id],
	NULL AS [MonitorName!4!Guid],
	NULL AS [MonitorName!4!ClassId]
FROM rules r
UNION ALL
SELECT 
	3 AS TAG, 
	999 AS Parent, 
	'' AS [ResolvedGUIDsDataSourceResult!999],
	NULL AS [Group!1!Id],
	NULL AS [Group!1!Guid],
	NULL AS [Group!1!IsSingletone],
	NULL AS [Rule!2!Id],
	NULL AS [Rule!2!DisplayName],
	NULL AS [Rule!2!Guid],
	m.ManagementPackSystemName + '!' + m.MonitorSystemName AS [Monitor!3!Id],
	m.MonitorDefaultName AS [Monitor!3!DisplayName],
	m.MonitorGuid AS [Monitor!3!Guid],
	NULL AS [MonitorName!4!Id],
	NULL AS [MonitorName!4!Guid],
	NULL AS [MonitorName!4!ClassId]
FROM monitors m
UNION ALL
SELECT
	4 AS TAG, 
	999 AS Parent,
	'' AS [ResolvedGUIDsDataSourceResult!999],
	NULL AS [Group!1!Id],
	NULL AS [Group!1!Guid],
	NULL AS [Group!1!IsSingletone],
	NULL AS [Rule!2!Id],
	NULL AS [Rule!2!DisplayName],
	NULL AS [Rule!2!Guid],
	NULL AS [Monitor!3!Id],
	NULL AS [Monitor!3!DisplayName],
	NULL AS [Monitor!3!Guid],
	(mmp.ManagementPackSystemName + '!' + m.MonitorSystemName) AS [MonitorName!4!Id],
	m.MonitorGuid AS [MonitorName!4!Guid],
	monClassesHi.typeName AS [MonitorName!4!ClassId]
FROM monClassesHi
INNER JOIN [dbo].[vMonitorManagementPackVersion] mmpv (NOLOCK) ON monClassesHi.baseTypeId = mmpv.TargetManagedEntityTypeRowId
INNER JOIN latestMpVersion mpv ON mmpv.ManagementPackVersionRowId = mpv.ManagementPackVersionRowId
INNER JOIN [dbo].[vMonitor] m (NOLOCK) ON m.MonitorRowId = mmpv.MonitorRowId
INNER JOIN [dbo].[vManagementPack] mmp (NOLOCK) ON m.ManagementPackRowId = mmp.ManagementPackRowId
INNER JOIN reqMonCls ON reqMonCls.ClassName = monClassesHi.typeName AND reqMonCls.MonitorName = m.MonitorSystemName

order by [ResolvedGUIDsDataSourceResult!999], [Group!1!Id], [Rule!2!Id], [Monitor!3!Id], [MonitorName!4!Id]
FOR XML EXPLICIT

END
GO

GRANT EXECUTE ON [sdk].[Microsoft_SQLServer_Visualization_Library_GetResolvedGUIDs] TO OpsMgrReader
GO


EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateLastValues]

EXEC [sdk].[Microsoft_SQLServer_Visualization_Library_UpdateHierarchy]
