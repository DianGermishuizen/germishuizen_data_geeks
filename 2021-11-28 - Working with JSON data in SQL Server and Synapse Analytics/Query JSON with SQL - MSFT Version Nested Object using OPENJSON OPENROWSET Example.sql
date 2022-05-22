DECLARE @json NVARCHAR(MAX);
SET @json = N'[  
  {"id": 2, "info": {"name": "John", "surname": "Smith"}, "age": 25},
  {"id": 5, "info": {"name": "Jane", "surname": "Smith", "skills": ["SQL", "C#", "Azure"]}, "dob": "2005-11-04T12:00:00"}  
]';

SELECT id, firstName, lastName, age, dateOfBirth, skill  
FROM OPENJSON(@json)  
  WITH (
    id INT 'strict $.id',
    firstName NVARCHAR(50) '$.info.name',
    lastName NVARCHAR(50) '$.info.surname',  
    age INT,
    dateOfBirth DATETIME2 '$.dob',
    skills NVARCHAR(MAX) '$.info.skills' AS JSON 
        /*Note here you use NVARCHAR(MAX) as the data type for the attribute 
            with nested complex object. In the next OPENJSON you can 
            then parse this JSON again using the regular methods.
        */
  )
OUTER APPLY OPENJSON(skills)
  WITH (skill NVARCHAR(8) '$')
    /*Since the entire value of the array element is a string value, 
    you can just use the $ notation to get the value.*/
;