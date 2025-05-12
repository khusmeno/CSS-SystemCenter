IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = ' Microsoft_Exchange_15_Visualization_Components_GetOrganizationGridData' AND UID = SCHEMA_ID('SDK'))
BEGIN
    DROP PROCEDURE [sdk].Microsoft_Exchange_15_Visualization_Components_GetOrganizationGridData
END
GO
