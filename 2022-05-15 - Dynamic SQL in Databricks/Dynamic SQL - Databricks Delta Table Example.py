# pDataLakeContainer: "silver"
# pTableName": "Product"
# vDeltaTablePath: "/mnt/silver/WorldWideImporters/Batch/Product/"

vDeltaTableCreateStatement = 'CREATE TABLE IF NOT EXISTS ' \
+ pDataLakeContainer + '.' + pTableName + ' \n' \
+ 'USING DELTA ' + '\n' \
+ 'LOCATION \'' + vDeltaTablePath + '\' ' + '\n' \
+ 'PARTITIONED BY ( ProductCategory )' + '\n' \
+ 'AS' + '\n' \
+ 'SELECT * FROM sourceTemporaryView'

#Check final output
print('vDeltaTableCreateStatement: ' + vDeltaTableCreateStatement)

#Execute the SQL
spark.sql(vDeltaTableCreateStatement)