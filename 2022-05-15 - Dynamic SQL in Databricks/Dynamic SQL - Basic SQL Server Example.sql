/*Variable to hold the value we will filter on at runtime*/
DECLARE @vCustomerID INT;

/*Variable to hold the query string we will alter at runtime then execute*/
DECLARE @vSqlQuery VARCHAR(4000);

/*Define the base version of the query*/
SET @vSqlQuery = '
SELECT *
FROM [dbo].[Customers]
WHERE [Customers].[CustomerID] = ' + @vCustomerID + ''

/*Execute the code*/
EXEC (@vSqlQuery)