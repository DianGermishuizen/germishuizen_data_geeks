CREATE OR ALTER FUNCTION [dbo].[ufn_CalcualteEasterSundayFromYear] 
(
    @pYear SMALLINT
)
RETURNS DATE
AS
/*=====================================================================================================================================================
Description:	Calculates the date of easter sunday for a given year, using the Meeus-Jones-Butcher algorithm.
              The formula calculates the number of days from january 1 for a specific year, using a number of variables.
Source: 		  http://en.wikipedia.org/wiki/Computus
-------------------------------------------------------------------------------------------------------------------------------------------------------
Output Structure
    Scalar value with the following data type: DATE
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Place code to test object here
SELECT [dbo].[ufn_CalcualteEasterSundayFromYear] (2022)
=====================================================================================================================================================*/
BEGIN
    /* Declare Variables used */
    DECLARE 
		      @varA TINYINT
        , @varB TINYINT
        , @varC TINYINT
        , @varD TINYINT
        , @varE TINYINT
        , @varF TINYINT
        , @varG TINYINT
        , @varH TINYINT
        , @varI TINYINT
        , @varK TINYINT
        , @varL TINYINT
        , @varM TINYINT
        , @varDate DATE;

    /* Calculation steps */
    SELECT 
		      @varA = @pYear % 19
        , @varB = FLOOR(1.0 * @pYear / 100)
        , @varC = @pYear % 100;

    SELECT 
		      @varD = FLOOR(1.0 * @varB / 4)
        , @varE = @varB % 4
        , @varF = FLOOR((8.0 + @varB) / 25);

    SELECT 
		    @varG = FLOOR((1.0 + @varB - @varF) / 3);

    SELECT 
		      @varH = (19 * @varA + @varB - @varD - @varG + 15) % 30
        , @varI = FLOOR(1.0 * @varC / 4)
        , @varK = @pYear % 4;

    SELECT 
        @varL = (32.0 + 2 * @varE + 2 * @varI - @varH - @varK) % 7;

    SELECT 
        @varM = FLOOR((1.0 * @varA + 11 * @varH + 22 * @varL) / 451);

    SELECT 
        @varDate = DATEADD(dd, (@varH + @varL - 7 * @varM + 114) % 31, DATEADD(mm, FLOOR((1.0 * @varH + @varL - 7 * @varM + 114) / 31) - 1, DATEADD(yy, @pYear - 2000, {d '2000-01-01' })));

    /* Return the output date*/
    RETURN @varDate;
END;
