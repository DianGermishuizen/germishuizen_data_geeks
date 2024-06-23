# import the regex python library
import re
import dlt
from pyspark.sql.functions import *
import json

def to_snake_case(name):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    name = re.sub('__([A-Z])', r'_\1', name)
    name = re.sub('([a-z0-9])([A-Z])', r'\1_\2', name)
    return name.lower()

def create_streaming_table(table_name, path):
  # keywords to state this will be a dlt table
  @dlt.table(
      name = table_name
      , comment = 'DLT streaming table dynamically generated for bronze layer to ingest data from cloud storage using auto loader.'
    )
  # add a dynamic data quality expectation
  @dlt.expect("file_date_not_empty", "_metadata.file_modification_time IS NOT NULL")
  # a sub function that actually performs the data ingestion
  def t():
    # read data using a spark stream and auto loader (cloudFiles)
    # specify the source files are csv. You can add additional csv options like a custom separator
    # specify the path parameter as the load source path.
    # select all the fields, and add the metadata fields to capture the file name, size, modification time
    df = spark.readStream.format("cloudFiles")\
        .option("cloudFiles.format", "csv")\
        .load(path)\
        .select("*", "_metadata.file_name","_metadata.file_size","_metadata.file_modification_time")
    
    # automatically change columns that are determined to be timestamp_ntz to be only timestamp. 
    # dlt does not support timestamp_ntz at the time of writing
    df = df.withColumns(dict([(field,to_timestamp(field).alias(field)) for (field, dataType) in df.dtypes if dataType == "timestamp_ntz"]))

    # use the to snake case function to auto change all column names to snake case
    df = df.withColumns(dict([(to_snake_case(field),field) for (field, dataType) in df.dtypes]))

    # return the data frame that becomes the streaming table
    return df

tables_data = [
{"path":"s3://databricks-staging-layer/crm_sales_opportunities_demo_data/accounts*.csv", "table_name":"accounts"},
{"path":"s3://databricks-staging-layer/crm_sales_opportunities_demo_data/data_dictionary*.csv", "table_name":"data_dictionary"},
{"path":"s3://databricks-staging-layer/crm_sales_opportunities_demo_data/products*.csv", "table_name":"products"},
{"path":"s3://databricks-staging-layer/crm_sales_opportunities_demo_data/sales_pipeline*.csv", "table_name":"sales_pipeline"},
{"path":"s3://databricks-staging-layer/crm_sales_opportunities_demo_data/sales_teams*.csv", "table_name":"sales_teams"}
]

# for every object in the array, create a dlt streaming table based on the attributes it contains
for t in tables_data:
  create_streaming_table(t["table_name"], t["path"])