SELECT TOP 100
    /*Scalar attributes extraction using JSON_VALUE*/
      JSON_VALUE([jsonContent], '$.id') AS [id]
    , JSON_VALUE([jsonContent], '$.first_name') AS [first_name]
    , JSON_VALUE([jsonContent], '$.last_name') AS [last_name]
    , JSON_VALUE([jsonContent], '$.email') AS [email]
    , JSON_VALUE([jsonContent], '$.gender') AS [gender]
    , JSON_VALUE([jsonContent], '$.ip_address') AS [ip_address]
    , JSON_VALUE([jsonContent], '$.stores_purchased_at') AS [stores_purchased_at]
    /*Scalar attributes extraction from a nested array of objects via OPENJSON and JSON_QUERY*/
    , [NestedArray].[nested_record_id]
    , [NestedArray].[nested_record_Name]
FROM
    OPENROWSET(
        BULK 'https://mydatalakename.dfs.core.windows.net/rawdata/MockJSONData/MOCK_DATA-SingleObjectWithNestedArray.json',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        ROWTERMINATOR = '0x0b'
    )
    WITH(
        [jsonContent] varchar(MAX) /*This now contains the full JSON document from the file. Note the datatype is varchar(MAX).*/
    ) AS [result]
CROSS APPLY OPENJSON 
    /*Use JSON_QUERY here because we are querying a nested array, so we cant use JSON_VALUE.
    We perform JSON_QUERY on the [result].[JSONDocument] field since that is the column with the full JSON Document we want to extract dat from. 
    The path to the attribute is using the normal path to the attribute name that contains the array */
    (JSON_QUERY([jsonContent], '$.attribute_with_nested_array')) /*Note, if you want only the top most record from this array, replace this line with "(JSON_QUERY([jsonContent], '$.attribute_with_nested_array[0]'))"*/
WITH(
    [nested_record_id] varchar(255) '$.nested_record_id',
    [nested_record_Name] varchar(255) '$.nested_record_Name'
) AS [NestedArray]