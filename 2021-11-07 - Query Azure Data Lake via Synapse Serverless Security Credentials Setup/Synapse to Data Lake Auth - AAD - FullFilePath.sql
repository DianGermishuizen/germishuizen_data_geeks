SELECT TOP 1000 *
FROM OPENROWSET (
    BULK 'https://<storage_account>.dfs.core.windows.net/<container>/<directory>/<filename>.parquet'
) AS [table];