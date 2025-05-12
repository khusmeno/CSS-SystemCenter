IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = ' Exchange2013_GetMbxCountPerMbxDb' AND UID = SCHEMA_ID('sdk'))
BEGIN
    DROP PROCEDURE sdk.Exchange2013_GetMbxCountPerMbxDb
END
GO
