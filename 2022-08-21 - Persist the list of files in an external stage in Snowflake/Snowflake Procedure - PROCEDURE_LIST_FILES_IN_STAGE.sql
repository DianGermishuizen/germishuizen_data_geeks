
CREATE OR REPLACE PROCEDURE "PROCEDURE_LIST_FILES_IN_STAGE"
(
	STAGE_NAME VARCHAR
)
	RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER
AS
$$
	/*====================================================================
	Author:         Dian Germishuizen
	Description:	List the files available in an external or internal stage.
					Return the results as a CSV delimited list, each file's data seperated by a new line character
	Original Source: https://docs.snowflake.com/en/sql-reference/stored-procedures-javascript.html#using-result-scan-to-retrieve-the-result-from-a-stored-procedure
	------------------------------------------------------------------------------------
	Change History
	-------------
	Date            Author                  Description
	----------      -------------------     -------------------
	2022/08/19      Dian Germishuizen       Created
	------------------------------------------------------------------------------------
	==================================================================================*/
    /* Variable to return at the end */
    var return_value = "";

	try {
		/* Ensure the current session is in the correct database */
		var usedb_stmt = snowflake.createStatement({
			sqlText: 'USE SCHEMA "PC_FIVETRAN_DB"."OZOW_PROD_REPORTING";'
		}).execute();

		/* Make a template command that will be concatenated with the stage name passed in as parameter.
		This can be combined into a single command if you want to.
        Final string should look like "LIST @STAGE_NAME" */
		var sqlText_template = 'list @';
		var sqlText_dynamic = sqlText_template.concat("", STAGE_NAME)

		/* Create an SQL Statement with the LIST command prepared */
		var stmt = snowflake.createStatement({
			sqlText: sqlText_dynamic
		});

		/* Execute the statement prepared */
		var result = stmt.execute();

		/* Take the results of the statement and construct the CSV string with each file from the stage on a new line */
		if (result.next())  {
			  return_value += result.getColumnValue(1);
			  return_value += ", " + result.getColumnValue(2);
			  return_value += ", " + result.getColumnValue(3);
			  return_value += ", " + result.getColumnValue(4);
			  }
		  while (result.next())  {
			  return_value += "\n";
			  return_value += result.getColumnValue(1);
			  return_value += ", " + result.getColumnValue(2);
			  return_value += ", " + result.getColumnValue(3);
			  return_value += ", " + result.getColumnValue(4);
			  }
 	}
	/* Catch errors elegantly */
	catch (err)  {
	  result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
	  result += "\nMessage: " + err.message;
	  result += "\nStack Trace: \n" + err.stackTraceTxt;
	  }

    /* Return the string */
    return return_value;
$$;