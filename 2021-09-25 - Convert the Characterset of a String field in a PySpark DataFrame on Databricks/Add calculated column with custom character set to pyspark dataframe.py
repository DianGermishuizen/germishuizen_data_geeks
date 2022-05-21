import pyspark.sql.functions

dataFame = (
    spark.read.json(varFilePath)
)
.withColumns("affectedColumnName", sql.functions.encode("affectedColumnName", 'utf-8'))