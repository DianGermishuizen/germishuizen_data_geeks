SELECT TOP 100
    jsonContent
FROM
    OPENROWSET(
        BULK 'https://mydatalakename.dfs.core.windows.net/rawdata/MockJSONData/MOCK_DATA.json',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]