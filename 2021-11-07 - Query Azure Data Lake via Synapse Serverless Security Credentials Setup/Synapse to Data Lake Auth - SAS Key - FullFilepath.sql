CREATE CREDENTIAL [https://<storageaccount>.dfs.core.windows.net/<container>]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE'
, SECRET = '<secret>';
GO

SELECT TOP 1000 *
FROM OPENROWSET(
    BULK 'https://<storageaccount>.dfs.core.windows.net/<container>/<directory>/<filename>.parquet'
) AS [table];