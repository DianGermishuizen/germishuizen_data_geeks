SELECT
    TOP 100 
    /*Normal Sacalar attributes at parent level in the document in the column*/
    JSON_VALUE([result].[JSONDocument], '$.id') AS [id]
    , JSON_VALUE([result].[JSONDocument], '$.first_name') AS [first_name]
    , JSON_VALUE([result].[JSONDocument], '$.last_name') AS [last_name]
    , JSON_VALUE([result].[JSONDocument], '$.email') AS [email]
    , JSON_VALUE([result].[JSONDocument], '$.gender') AS [gender]
    , JSON_VALUE([result].[JSONDocument], '$.ip_address') AS [ip_address]
    , JSON_VALUE([result].[JSONDocument], '$.stores_purchased_at') AS [stores_purchased_at]
    /*NormalAttributes extracted from the nested array*/
    , [ArrayRecords].[nested_record_id]
FROM
    OPENROWSET(
        BULK 'https://mydatalakename.dfs.core.windows.net/rawdata/MockCSVFiles/CSVWithJsonColumnMockData_NestedArraySample.csv',
        FORMAT = 'CSV',
        PARSER_VERSION='2.0',
        HEADER_ROW = true
    ) AS [result]
/*Use CROSS APPLY to perform a calculation for each row in the [result] output table from source, and get one or more rows from the function back*/
CROSS APPLY OPENJSON 
    /*Use JSON_QUERY here because we are querying a nested array, so we cant use JSON_VALUE.
    We perform JSON_QUERY on the [result].[JSONDocument] field since that is the column with the full JSON Document we want to extract dat from. 
    The path to the attribute is using the normal path to the attribute name that contains the array */
    (JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_array'))
/*Here in the WITH clause of the OPENJSON we treat the attribute_with_nested_array attribute mentioend above as the top level of the document.
Since we simple return a field name, that field name from all records in the array is returned as distinct record. 
If we used the [0] array index notioan, we could have extracted specific rows as well*/
WITH(
    [nested_record_id] varchar(255) '$.nested_record_id'
) AS [ArrayRecords]