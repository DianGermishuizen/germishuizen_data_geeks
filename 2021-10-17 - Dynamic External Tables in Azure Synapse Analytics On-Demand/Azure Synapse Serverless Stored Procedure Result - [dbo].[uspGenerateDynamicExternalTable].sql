IF EXISTS 
(    
    /*Drop the pre-existing version of this table if it should already exist*/
    SELECT *
    FROM [sys].[external_tables]
    INNER JOIN [sys].[schemas]
        ON [external_tables].[schema_id] = [schemas].[schema_id]
    WHERE [schemas].[name] = 'dbo'
        AND [external_tables].[name] = 'DynamicExternalTableName'
) 
BEGIN
    DROP EXTERNAL TABLE [dbo].[DynamicExternalTableName]
END

/*CREATE conmmand that will generate the new object*/
CREATE EXTERNAL TABLE [dbo].[DynamicExternalTableName]
(
    [DateTimeField] DATETIME2(7)
    , [StringField] VARCHAR(8000)
    , [IntegerField] INT
    , [FloatField] FLOAT
)
WITH
(
    /*Note here, due to the wild card indicator, all files in the directory will be included with the applicable extention*/
    LOCATION = 'ParentDirectoryInsideTheContainer/SubDirectory/TableName/*.parquet'
    , DATA_SOURCE = [mystorageaccountname_mycontainername]
    , FILE_FORMAT = [SynapseParquetFileFormat]
) 