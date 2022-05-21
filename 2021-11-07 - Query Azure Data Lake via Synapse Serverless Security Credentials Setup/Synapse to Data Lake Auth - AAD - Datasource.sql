CREATE EXTERNAL DATA SOURCE [MyDataSource]
WITH (    
    LOCATION = 'https://<storage_account>.dfs.core.windows.net/<container>/<directory>'
)
GO

SELECT TOP 1000 *
FROM OPENROWSET(
    BULK '<directory>/<filename>.parquet'
    , DATA_SOURCE = 'MyDataSource' 
) AS [table];