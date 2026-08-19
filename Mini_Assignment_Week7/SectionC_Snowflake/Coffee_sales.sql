-- Coffee sales pipeline: setup infrastructure, load CSV from stage, 
-- 1. Create warehouse
CREATE OR REPLACE WAREHOUSE lab_wh_SR_Coffee_stage
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- 2. Create database and schemas
CREATE OR REPLACE DATABASE retail_db_SR_Coffee;
CREATE OR REPLACE SCHEMA retail_db_SR_Coffee.raw;
CREATE OR REPLACE SCHEMA retail_db_SR_Coffee.analytics;

USE WAREHOUSE LAB_WH_SR_COFFEE_STAGE;
USE DATABASE retail_db_SR_Coffee;
USE SCHEMA raw;
---SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER LIMIT 10;

-- 3. Create stage for CSV upload
CREATE OR REPLACE STAGE coffee_sales
  FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

SHOW STAGES IN SCHEMA
SHOW STAGES IN SCHEMA RETAIL_DB_SR_COFFEE.RAW

LIST @RETAIL_DB_SR_COFFEE.RAW.COFFEE_SALES;

-- Preview raw content directly from the stage
CREATE OR REPLACE FILE FORMAT retail_db_SR_Coffee.raw.csv_format
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Target table matching the CSV columns
CREATE OR REPLACE TABLE retail_db_SR_Coffee.raw.coffee_sales_tbl (
  date DATE,
  datetime TIMESTAMP_NTZ,
  cash_type STRING,
  card STRING,
  money FLOAT,
  coffee_name STRING
);

COPY INTO retail_db_SR_Coffee.raw.coffee_sales_tbl
FROM @retail_db_SR_Coffee.raw.coffee_sales
FILE_FORMAT = (FORMAT_NAME = 'retail_db_SR_Coffee.raw.csv_format')
ON_ERROR = 'CONTINUE';

SELECT * FROM retail_db_SR_Coffee.raw.coffee_sales_tbl LIMIT 10;


--------Q2. Write a query to find the top 3 coffee types by revenue.
SELECT
  coffee_name,
  SUM(money) AS total_revenue
FROM retail_db_SR_Coffee.raw.coffee_sales_tbl
GROUP BY coffee_name
ORDER BY total_revenue DESC
LIMIT 3;

