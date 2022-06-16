CREATE OR ALTER FUNCTION [dbo].[utvf_Generate_VirtualDateTable]
(
    @pStartDate AS DATE
    , @pEndDate AS DATE
) 
RETURNS TABLE
AS
/*=====================================================================================================================================================
Author:			Dian Germishuizen
Description:	Generate a list of numbers between the LowerLimit and the UpperLimit
Original Inspiration: https://www.itprotoday.com/sql-server/packing-intervals-priorities
-------------------------------------------------------------------------------------------------------------------------------------------------------
Changes Made:	
Date			Author					Description (What changes were made to this code on this day)
----------		------------------		---------------------------------------------------------------------------------------------------------------
2022-06-16		Dian Germishuizen		Created
-------------------------------------------------------------------------------------------------------------------------------------------------------
TODO: 
--Place code to test object here
SELECT *
FROM [dbo].[utvf_Generate_VirtualDateTable]('2022-01-01', '2022-01-10')
=====================================================================================================================================================*/
RETURN
WITH [Level1]
AS 
(   /* Generate a 2 row table that contains a 1 for each value */
    SELECT [Number] FROM (SELECT 1 AS [Number] UNION ALL SELECT 1 AS [Number]) AS [Table]
)
, [Level2] 
AS 
(   /* Cross join the previous level to itself to get the exponensial number of rows */
    SELECT 1 AS [Number] FROM [Level1] AS [One] CROSS JOIN [Level1] AS [Two]
)
, [Level3] 
AS 
(   /* Cross join the previous level to itself to get the exponensial number of rows */
    SELECT 1 AS [Number] FROM [Level2] AS [One] CROSS JOIN [Level2] AS [Two]
)
, [Level4] 
AS 
(   /* Cross join the previous level to itself to get the exponensial number of rows */
    SELECT 1 AS [Number] FROM [Level3] AS [One] CROSS JOIN [Level3] AS [Two]
)
, [Level5] 
AS 
(   /* Cross join the previous level to itself to get the exponensial number of rows */
    SELECT 1 AS [Number] FROM [Level4] AS [One] CROSS JOIN [Level4] AS [Two]
)
, [Level6] 
AS 
(   /* Cross join the previous level to itself to get the exponensial number of rows */
    SELECT 1 AS [Number] FROM [Level5] AS [One] CROSS JOIN [Level5] AS [Two]
)
, [Numbers] 
AS 
(   /* Cross join the previous level to itself to get the exponensial number of rows */
    SELECT ROW_NUMBER() OVER(ORDER BY [Number]) AS [RowNumber] FROM [Level6]
)
, [BaseListOfDates]
AS
(   /* 
        For the list of numbers generated, create a row number and form that a list of dates 
        starting at the @pStartDate value and ending at the @pEndDate value
    */
    SELECT TOP(DATEDIFF(DAY, @pStartDate, @pEndDate) + 1)
        [RowNumber]
        , DATEADD(DAY, ( [RowNumber] - 1 ), @pStartDate) AS [Date]
    FROM [Numbers] 
)
/* Apply additional calculations on the base date value */
SELECT 
    [RowNumber]
    , [Date]
    , CONVERT(VARCHAR, [Date], 112) AS [DateKey]
    , DATEPART(YEAR, [Date]) AS [Year] /*2019*/
    , DATEPART(QUARTER, [Date]) AS [Quarter] /*1*/
    , DATEPART(MONTH, [Date]) AS [Month] /*2*/
    , DATENAME(MONTH, [Date]) AS [MonthName] /*February*/
    , LEFT(DATENAME(MONTH, [Date]), 3) AS [MonthNameShort] /* Feb */
    , DATEPART(WEEK, [Date]) AS [Week] /*7*/
    , DATEPART(DAY, [Date]) AS [Day] /*14*/
    , DATENAME(WEEKDAY, [Date]) AS [DayName] /*Thursday*/
    , LEFT(DATENAME(WEEKDAY, [Date]), 3) AS [DayNameShort] /* Thu */
    , DATEPART(dw, [Date])  AS [DayNumberOfWeek] /* 4 */
FROM [BaseListOfDates]
GO
