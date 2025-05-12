IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetDataCenterDashboardData
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_UpdateLastValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_UpdateLastValues
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetGroups' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetGroups
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetClasses' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetClasses
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetGroupClassMetadata' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetGroupClassMetadata
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_UpdateHierarchy' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_UpdateHierarchy
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_UpdateTablesList' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_UpdateTablesList
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_RethrowError' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_RethrowError
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'P' AND Name = 'Microsoft_SQLServer_Visualization_Library_GetResolvedGUIDs' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Microsoft_SQLServer_Visualization_Library_GetResolvedGUIDs
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastPerfValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastPerfValues
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastMonitorValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastMonitorValues
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_LastAlertValues' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_LastAlertValues
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Table_Batches' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_Table_Batches
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Tables' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_Tables
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_DB_Version' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_DB_Version
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_RelationshipType_Hierarchy
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_Relationship_Hierarchy
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE Type = 'U' AND Name = 'Microsoft_SQLServer_Visualization_Library_OpsManagerSettings' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP TABLE sdk.Microsoft_SQLServer_Visualization_Library_OpsManagerSettings
END
GO

