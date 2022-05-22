/*JSON_MODIFY Example*/

DECLARE @vJSONVariable NVARCHAR(255) = 
'
    {
        "name" : "Dian",
        "skills": ["Procrastinating" , "Movie Trivia"]
    }
'

/*Test that the string is saved correctly into the variable*/
PRINT @vJSONVariable

/* Update Attribute*/
SET @vJSONVariable = JSON_MODIFY( @vJSONVariable, '$.name' , 'Tony Stark')

/*Test that the change was applied correctly */
PRINT @vJSONVariable

/*Output would be
{
    "name" : "Tony Stark",
    "skills": ["Procrastinating" , "Movie Trivia"]
}
*/