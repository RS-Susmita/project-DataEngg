----- LAb 6.1
CREATE OR REPLACE ROLE analyst_SR;
 
GRANT USAGE ON WAREHOUSE LAB_WH_SR TO ROLE analyst_SR;
GRANT USAGE ON DATABASE RETAIL_DB_SR TO ROLE analyst_SR;
GRANT USAGE ON SCHEMA RETAIL_DB_SR.analytics TO ROLE analyst_SR;
GRANT SELECT ON ALL VIEWS IN SCHEMA RETAIL_DB_SR.analytics
  TO ROLE analyst_SR;
 
-- make sure FUTURE views are covered too, not just existing ones
GRANT SELECT ON FUTURE VIEWS IN SCHEMA RETAIL_DB_SR.analytics
  TO ROLE analyst_SR;

----- Lab 6.2
GRANT ROLE analyst_SR TO USER SUSMITA;
 
-- switch role in the Snowsight worksheet role-picker (top right), then:
USE ROLE analyst_SR;
SELECT * FROM RETAIL_DB_SR.analytics.v_all_line_items LIMIT 5;  -- works
SELECT * FROM retail_db_SR.raw.orders;   
