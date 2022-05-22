SELECT
    TOP 100 
    /*Normal Sacalar attributes at parent level in the document in the column*/
    JSON_VALUE([result].[JSONDocument], '$.id') AS [id]
    /*Query fields with multiple nested objects
        * Note here we are using JSON_QUERY, 
            not JSON_VALUE because we are working with nested objects.
        * The key difference between JSON_VALUE and JSON_QUERY is that 
            JSON_VALUE returns a scalar value, while JSON_QUERY returns an object or an array.
        * attribute_with_nested_values - attribute that has top level scalar attributes, 
            as well as another attribute with a nested complex object - this need to be queried using JSON_QUERY
        * levelone_nested_columne_three - nested attributes with top level scalar attributes, 
            as well as complex objects such as the array. 
            - If we want to extract one of the top level attributes, we can just use JSON_VALUE. 
            - If we were to want to extract the array, 
                we need JSON_QUERY or use index notation with JSON_VALUE to get a single element from the array
    */
    , JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values') AS [attribute_with_nested_values]
    , JSON_VALUE(
        JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values.levelone_nested_columne_three')
        , '$.leveltwo_nested_columne_one'
    ) AS [leveltwo_nested_columne_one]
    , JSON_VALUE(
        JSON_QUERY([result].[JSONDocument], '$.attribute_with_nested_values.levelone_nested_columne_three')
        , '$.leveltwo_nested_columne_three[0]'
    ) AS [leveltwo_nested_columne_three_0]
FROM
    OPENROWSET(
        BULK 'https://mydatalakename.dfs.core.windows.net/rawdata/MockCSVFiles/CSVWithJsonColumnMockData_NestedAttributesSample_MultiObject.csv',
        FORMAT = 'CSV',
        PARSER_VERSION='2.0',
        HEADER_ROW = true
    ) AS [result]