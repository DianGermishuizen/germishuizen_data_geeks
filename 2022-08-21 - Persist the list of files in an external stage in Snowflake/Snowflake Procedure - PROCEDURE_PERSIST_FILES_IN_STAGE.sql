
CREATE OR REPLACE PROCEDURE "PROCEDURE_PERSIST_FILES_IN_STAGE"
(
	STAGE_NAME VARCHAR
)
	RETURNS VARCHAR
    LANGUAGE SQL
    EXECUTE AS CALLER
AS
$$BEGIN
	/*====================================================================
	Author:         Dian Germishuizen
	Description:	Get the files in an external stage using procedure "PROCEDURE_LIST_FILES_IN_STAGE". Then persist the output to a table. 
	Original Source: https://docs.snowflake.com/en/sql-reference/stored-procedures-javascript.html#using-result-scan-to-retrieve-the-result-from-a-stored-procedure
	------------------------------------------------------------------------------------
	Change History
	-------------
	Date            Author                  Description
	----------      -------------------     -------------------
	2022/08/19      Dian Germishuizen       Created
	------------------------------------------------------------------------------------
	==================================================================================*/
	/*Create the output table if it doesn't exist. */
	CREATE TABLE IF NOT EXISTS "FILES_AVAILABLE_IN_EXTERNAL_STAGE"
	(
		  FILE_NAME VARCHAR(255)
		, SIZE VARCHAR(255)
		, MD5_HASH VARCHAR(255)
		, LAST_MODIFIED_DATE_TIME VARCHAR(255)
		, STAGE_NAME VARCHAR(255)
		, INSERT_DATE_TIME DATETIME
	);

	/*Run the procedure which will return the list of files as a comma seperated value string , each file on a new line*/
	CALL "PROCEDURE_LIST_FILES_IN_STAGE"(:STAGE_NAME);

	/*Insert the data, splitting the string into columns and rows*/
	INSERT INTO "FILES_AVAILABLE_IN_EXTERNAL_STAGE"
	(
		FILE_NAME
		, SIZE
		, MD5_HASH
		, LAST_MODIFIED_DATE_TIME
		, INSERT_DATE_TIME
	)
	WITH ONE_STRING_CTE (string_col)
	AS
	(	/*Get the results from the previous stored procedure call */
		SELECT *
		FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
	)
	, THREE_STRINGS_CTE (one_row)
	AS
	(	/*Take the string and split it into multiple rows based on the delimiter*/
		SELECT VALUE
		FROM ONE_STRING_CTE, LATERAL SPLIT_TO_TABLE(ONE_STRING_CTE.string_col, '\n')
	)
	SELECT
		/*Use STROK to extract sections of a string based on a delimiter. Extract each column value between commas. */
		STRTOK(one_row, ',', 1) AS "FILE_NAME"
		, STRTOK(one_row, ',', 2) AS "SIZE"
		, STRTOK(one_row, ',', 3) AS "MD5_HASH"
		, STRTOK(one_row, ',', 4) AS "LAST_MODIFIED_DATE_TIME"
		, CURRENT_TIMESTAMP AS "INSERT_DATE_TIME"
	FROM THREE_STRINGS_CTE;

END$$;
