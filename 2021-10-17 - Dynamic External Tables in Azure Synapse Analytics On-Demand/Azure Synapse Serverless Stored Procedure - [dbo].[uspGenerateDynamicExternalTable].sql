CREATE OR ALTER PROCEDURE [dbo].[uspGenerateDynamicExternalTable]
(   
   /*External Table SCHEMA and TABLE name*/
     @pSQLSchema VARCHAR(255)
   , @pSQLTableName VARCHAR(255)
   /*COLUMN Structure*/
   , @pColumnDefinitions VARCHAR(MAX)
   /*LOCATION*/
   , @pBlobStorageDirectory VARCHAR(255)
   /*DATA_SOURCE*/
   , @pExternalDataSourceName VARCHAR(255)
   /*FILEFORMAT*/
   , @pFileExtention VARCHAR(255)
   , @pFileFormatName VARCHAR(255)
)
AS
/*=====================================================================================================================================================
Author:         Dian Germishuizen
Created Date:   2021-10-17
Description:    Stored Procedure that can generate a new external table in Azure Synapse Analytics Serverless on a dynamic location in a Data lake. 
-------------------------------------------------------------------------------------------------------------------------------------------------------
Test Code
-------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
    --External Table SCHEMA and TABLE name
      @pSQLSchema VARCHAR(255) = 'dbo'
    , @pSQLTableName VARCHAR(255) = 'DynamicExternalTableName'
    --COLUMN Structure
    , @pColumnDefinitions VARCHAR(MAX) = '[DateTimeField] DATETIME2(7),[StringField] VARCHAR(8000),[IntegerField] INT,[FloatField] FLOAT'
    --LOCATION
    , @pBlobStorageDirectory VARCHAR(255) = 'ParentDirectoryInsideTheContainer/SubDirectory/TableName'
    --DATA_SOURCE
    , @pExternalDataSourceName VARCHAR(255) = 'mystorageaccountname_mycontainername'
    --FILEFORMAT
    , @pFileExtention VARCHAR(255) = 'parquet'
    , @pFileFormatName VARCHAR(255) = 'SynapseParquetFileFormat'
    ;

--Execute the procedure with dummy values
EXEC [dbo].[uspGenerateDynamicExternalTable]
      @pSQLSchema
    , @pSQLTableName
    , @pColumnDefinitions
    , @pBlobStorageDirectory
    , @pExternalDataSourceName
    , @pFileExtention
    , @pFileFormatName
    ;
=====================================================================================================================================================*/
BEGIN
    /*======================================================================
    Declare a string variable to hold the dynamically generated SQL Code. 
    This string variable's contents will get executed later to actually generate the external table
    ======================================================================*/
    DECLARE @vSQL VARCHAR(MAX) =
    '
    IF EXISTS 
    (    
        /*Drop the pre-existing version of this table if it should already exist*/
        SELECT *
        FROM [sys].[external_tables]
        INNER JOIN [sys].[schemas]
            ON [external_tables].[schema_id] = [schemas].[schema_id]
        WHERE [schemas].[name] = ''' + @pSQLSchema + '''
            AND [external_tables].[name] = ''' + @pSQLTableName + '''
    ) 
    BEGIN
        DROP EXTERNAL TABLE [' + @pSQLSchema + '].[' + @pSQLTableName + ']
    END

    /*CREATE conmmand that will generate the new object*/
    CREATE EXTERNAL TABLE [' + @pSQLSchema + '].[' + @pSQLTableName + ']
    (
        ' + @pColumnDefinitions + '
    )
    WITH
    (
        /*Note here, due to the wild card indicator, all files in the directory will be included with the applicable extention*/
        LOCATION = ''' + @pBlobStorageDirectory + '/*.' + @pFileExtention + '''
        , DATA_SOURCE = [' + @pExternalDataSourceName + ']
        , FILE_FORMAT = [' + @pFileFormatName + ']
    ) ' ;

   /*======================================================================
   Execute the dynamic SQL that was generated
   ======================================================================*/
   PRINT( @vSQL ); /*Also printing the string value in order to inspect the contents for thoubleshooting purpouses*/   
   EXEC( @vSQL );

END