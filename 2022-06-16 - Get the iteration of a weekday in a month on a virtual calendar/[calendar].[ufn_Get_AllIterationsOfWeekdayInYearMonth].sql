CREATE OR ALTER FUNCTION [dbo].[ufn_Get_AllIterationsOfWeekdayInYearMonth]
(
    @pYear INT /*The year to investigate*/
    , @pMonth INT /*The month to investigate*/
    , @pWeekdayName VARCHAR(255) /*The week day to return e.g. Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday*/
)
RETURNS TABLE
AS
/*=====================================================================================================================================================
Author:			Dian Germishuizen
Description:	Procedures to get the 1st, 2nd, 3rd, 4th or 5th iteration of a given week day in a given month of a given year
Steps
1. For the given Year, For the given Month, generate a table with the dates and the days of the week
2. Filter the days to the required week day e.g. Monday, Tuesday etc. 
3. Add a row number of the records in ascending order
4. Return the record where the row number is the same as the Iteration parameter
If the given paramters dont result in a date, NULL is returned
-------------------------------------------------------------------------------------------------------------------------------------------------------
Changes Made:	
Date			Author					Description (What changes were made to this code on this day)
----------		------------------		---------------------------------------------------------------------------------------------------------------
2022-06-16		Dian Germishuizen		Created
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Test the procedure
SELECT * FROM [dbo].[ufn_Get_AllIterationsOfWeekdayInYearMonth] (2022, 1, 'Monday')
=====================================================================================================================================================*/
RETURN
    WITH [IterationsOfWeekdayCTE]
    AS
    (   /* 
            Generate a list of dates for the year and month provided, only the dates that fall on the weekday provided
            Add a row number to indicate the order they fall in
        */
        SELECT 
            1 AS [PivotPoint]
            , [Date]
            , [DayName]
            , ROW_NUMBER() OVER(
                ORDER BY [Date] ASC
            ) AS [RowNumber_Ascending]
        FROM [dbo].[utvf_Generate_VirtualDateTable] (DATEFROMPARTS(@pYear, @pMonth, 1), EOMONTH(DATEFROMPARTS(@pYear, @pMonth, 1)))
        WHERE [Year] = @pYear
            AND [Month] = @pMonth
            AND [DayName] = @pWeekdayName
    )
    SELECT
        MAX([PivotTable].[1]) AS [First]
        , MAX([PivotTable].[2]) AS [Second]
        , MAX([PivotTable].[3]) AS [Third]
        , MAX([PivotTable].[4]) AS [Fourth]
        , MAX([PivotTable].[5]) AS [Fifth]
        /* TO get the latest iteration, we need to do a max on all the dates that fall on the indicated weekday */
        , (
            SELECT MAX([Value])
            FROM 
            (
                SELECT MAX([PivotTable].[1]) AS [Value]
                UNION ALL 
                SELECT MAX([PivotTable].[2]) AS [Value]
                UNION ALL 
                SELECT MAX([PivotTable].[3]) AS [Value]
                UNION ALL 
                SELECT MAX([PivotTable].[4]) AS [Value]
                UNION ALL 
                SELECT MAX([PivotTable].[5]) AS [Value]
            ) AS [LastValueTable]
        ) AS [Last]
    FROM [IterationsOfWeekdayCTE]
    /* We need to pivot the date to get each date in a specific column */
    PIVOT
    (
        MAX([Date])
        FOR [RowNumber_Ascending] IN ([1], [2], [3], [4], [5])
    ) AS [PivotTable]
    GROUP BY [PivotPoint]
    
