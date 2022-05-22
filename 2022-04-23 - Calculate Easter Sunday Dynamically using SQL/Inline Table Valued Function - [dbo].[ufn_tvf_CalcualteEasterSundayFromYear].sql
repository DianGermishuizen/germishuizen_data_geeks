CREATE OR ALTER FUNCTION [dbo].[ufn_tvf_CalcualteEasterSundayFromYear]
(
    @pYear SMALLINT
)
RETURNS TABLE
AS
/*=====================================================================================================================================================
Description:	Calculates the date of easter sunday for a given year, using the Meeus-Jones-Butcher algorithm.
Source: 		http://en.wikipedia.org/wiki/Computus
                The formula calculates the number of days from january 1 for a specific year, using a number of variables.
-------------------------------------------------------------------------------------------------------------------------------------------------------
Output Structure
    Table with the following schema
    [EasterSundayDate] DATE
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Place code to test object here
SELECT *
FROM [dbo].[ufn_tvf_CalcualteEasterSundayFromYear] (2022)
=====================================================================================================================================================*/
RETURN

    WITH [CTE1]
    AS
    (
        SELECT 
              varA = @pYear % 19
            , varB = FLOOR(1.0 * @pYear / 100)
            , varC = @pYear % 100
    )
    , [CTE2]
    AS
    (
        SELECT 
            /*Previous step fields*/
             varA
            , varB
            , varC
            /*New fields*/
            , varD = FLOOR(1.0 * varB / 4)
            , varE = varB % 4
            , varF = FLOOR((8.0 + varB) / 25)
        FROM [CTE1]
    )
    , [CTE3]
    AS
    (
        SELECT 
            /*Previous step fields*/
              varA
            , varB
            , varC
            , varD
            , varE
            , varF
            /*New fields*/
            , varG = FLOOR((1.0 + varB - varF) / 3)
        FROM [CTE2]
    )
    , [CTE4]
    AS
    (
        SELECT             
            /*Previous step fields*/
              varA
            , varB
            , varC
            , varD
            , varE
            , varF
            , varG
            /*New fields*/
            , varH = (19 * varA + varB - varD - varG + 15) % 30
            , varI = FLOOR(1.0 * varC / 4)
            , varK = @pYear % 4
        FROM [CTE3]
    )
    , [CTE5]
    AS
    (
        SELECT
        /*Previous step fields*/
              varA
            , varB
            , varC
            , varD
            , varE
            , varF
            , varG
            , varH
            , varI
            , varK
            /*New fields*/
            , varL = (32.0 + 2 * varE + 2 * varI - varH - varK) % 7
        FROM [CTE4]
    )
    , [CTE6]
    AS
    (
        SELECT 
            /*Previous step fields*/
              varA
            , varB
            , varC
            , varD
            , varE
            , varF
            , varG
            , varH
            , varI
            , varK
            , varL
            /*New fields*/
            , varM = FLOOR((1.0 * varA + 11 * varH + 22 * varL) / 451)
        FROM [CTE5]
    )
    SELECT 
        [EasterSundayDate] = DATEADD(dd, (varH + varL - 7 * varM + 114) % 31, DATEADD(mm, FLOOR((1.0 * varH + varL - 7 * varM + 114) / 31) - 1, DATEADD(yy, @pYear - 2000, {d '2000-01-01' })))
    FROM[CTE6]

