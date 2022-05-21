-- Optional: Create MASTER KEY if not exists in database:
-- CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<Very Strong Password>
CREATE DATABASE SCOPED CREDENTIAL [SynapseIdentity]
WITH IDENTITY = 'Managed Identity';
GO

CREATE EXTERNAL DATA SOURCE [MyDataSource]
WITH (    
    LOCATION   = 'https://<storage_account>.dfs.core.windows.net/<container>/<directory>',
    CREDENTIAL = [SynapseIdentity]
)
GO

SELECT TOP 1000 *
FROM OPENROWSET(
    BULK '<directory>/<filename>.parquet'
    , DATA_SOURCE = 'MyDataSource' 
) AS [table];