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
    /*Query fields with nested objects or arrays
        Note here we are using JSON_QUERY first , 
            not JSON_VALUE because we are working with nested objects.
        After we have queried the complex object, 
            we can use JSON_VALUE to extract a scalar value from the nested object.
        The key difference between JSON_VALUE and JSON_QUERY is that JSON_VALUE 
            returns a scalar value, while JSON_QUERY returns an object or an array.
    */
    , JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values') AS [attribute_with_nested_values]
    , JSON_VALUE(
        JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values')
        , '$.nested_columne_one'
      ) AS [attribute_with_nested_values-nested_columne_one]
    , JSON_VALUE(
        JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values')
        , '$.nested_columne_two'
      ) AS [attribute_with_nested_values-nested_columne_two]
    , JSON_VALUE(
        JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values')
        , '$.nested_columne_three'
      ) AS [attribute_with_nested_values-nested_columne_three]
    /*Alternate method to extract scalar attributs from single level nested objects
        using dot notation*/
    , JSON_VALUE([result].[JSONDocument], '$.attribute_with_nested_values.nested_columne_one') AS [attribute_with_nested_values-nested_columne_one-dotnotation]
FROM
    OPENROWSET(
        BULK 'https://mydatalakename.dfs.core.windows.net/rawdata/MockCSVFiles/CSVWithJsonColumnMockData_NestedAttributesSample.csv',
        FORMAT = 'CSV',
        PARSER_VERSION='2.0',
        HEADER_ROW = true
    ) AS [result]