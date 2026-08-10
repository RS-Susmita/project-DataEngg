SELECT
  o.o_orderpriority,
  COUNT(*)               AS order_count,
  SUM(o.o_totalprice)    AS total_value
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER c
  ON o.o_custkey = c.c_custkey
GROUP BY o.o_orderpriority
ORDER BY total_value DESC;

ALTER WAREHOUSE LAB_WH_SR SET WAREHOUSE_SIZE = 'SMALL';
-- re-run the exact same query and compare its duration in Query History
ALTER WAREHOUSE LAB_WH_SR SET WAREHOUSE_SIZE = 'XSMALL';  -- scale back down



