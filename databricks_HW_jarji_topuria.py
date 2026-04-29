# Databricks notebook source
# MAGIC %md
# MAGIC ## Databricks Homework
# MAGIC Since in July 2025 Databricks Community Edition was deprecated and instead of creating separate cluster they are being provided in serverless mode it will be easier for you to work with data - since all the data and tables will be saving not only when cluster as active.
# MAGIC
# MAGIC So, no separate activities for cluser creating should be executed - it will be autoattached/started when you will execute any of the cells below.
# MAGIC
# MAGIC
# MAGIC Please, create table in the default schema using file Sales_December_2019.csv. On the left found Catalog => Add Data => Drop files to upload, or click to browse => Sales_December_2019.csv After file will be uploaded, just need to confirm that table should be uploaded.
# MAGIC
# MAGIC  Make sure that the first row is header selected => Create Table. Table will be created with name that you specified (sales_december_2019 by default) You will be able to change the table name later if needed.

# COMMAND ----------

# MAGIC %md
# MAGIC PySpark can process SQL queries as a text. In other words you don't need to switch cell language to SQL.
# MAGIC 1. Write data from table that you created into the dataframe using PySpark with SQL query. Show data in the dataframe

# COMMAND ----------

# Create DataFrame from SQL query
df = spark.sql("SELECT * FROM sales_december_2019")
df.show()

# COMMAND ----------

# MAGIC %md
# MAGIC Any notebook can be parameterized using dbutils.widgets. Try to add one parameter "Product_name" and select data from dataframe filtered by value from this parameter. 
# MAGIC
# MAGIC 2. Select data where product = "product_name" from dataframe using PySpark

# COMMAND ----------

dbutils.widgets.text("product_name", "")

# COMMAND ----------

product_name = dbutils.widgets.get("product_name")
print(product_name)

# COMMAND ----------

# MAGIC %md
# MAGIC As well as in SQL, in PySpark you can use aggregate functions. Package pyspark.sql.functions contains all aggregated function from SQL. Try to perform simple aggregation with dataframe. Don't forget, that column types, which you want to calculate, shoud be numerical.  
# MAGIC 3. Calculate the sales for each product, including the number of products sold

# COMMAND ----------

# Your code here
filtered_df = df.filter(df["Product"] == product_name)
filtered_df.show()


# COMMAND ----------

# MAGIC %md
# MAGIC In the PySpark you can perform dataframe profiling using one of two special commands or simple aggregated functions. Try to find special commands to complete this task or just use aggregated functions. Hint: please, сhange the column data types based on the data in them
# MAGIC
# MAGIC 4. Show data profiles output for the new dataframe of table sales_december_2019_csv: row count, min and max value for each column

# COMMAND ----------

from pyspark.sql.functions import expr, min, max

df_clean = df \
    .withColumn("Order ID", expr("try_cast(`Order ID` as int)")) \
    .withColumn("Quantity Ordered", expr("try_cast(`Quantity Ordered` as int)")) \
    .withColumn("Price Each", expr("try_cast(`Price Each` as double)"))

# remove bad rows (null after cast)
df_clean = df_clean.filter("`Order ID` IS NOT NULL")

print("Row count:")
print(df_clean.count())

df_clean.select(
    min("Order ID").alias("min_order_id"),
    max("Order ID").alias("max_order_id"),
    min("Quantity Ordered").alias("min_qty"),
    max("Quantity Ordered").alias("max_qty"),
    min("Price Each").alias("min_price"),
    max("Price Each").alias("max_price")
).show()

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC 5. Add new column to the dataframe from previous task with any default value that you want

# COMMAND ----------



# COMMAND ----------

# MAGIC %md
# MAGIC Temporary views are processed by cluster and always dropped when the session ends (when the cluster turns off).
# MAGIC
# MAGIC 6. Create temporary view from task 4 dataframe using PySpark and perform any select using SQL

# COMMAND ----------

df_clean.createOrReplaceTempView("sales_view")



# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM sales_view
# MAGIC LIMIT 10