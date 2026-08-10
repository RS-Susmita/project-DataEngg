-- Lab 4.1
CREATE OR REPLACE VIEW analytics.v_all_line_items AS
SELECT
  order_id, customer_name, product, quantity AS qty,
  unit_price, order_date, region, 'csv' AS source
FROM raw.orders
 
UNION ALL
 
SELECT
  data:order_id::INT, data:customer.name::STRING,
  f.value:product::STRING, f.value:qty::INT,
  f.value:price::NUMBER(10,2), CURRENT_DATE(),
  data:customer.city::STRING, 'json' AS source
FROM raw.orders_json, LATERAL FLATTEN(input => data:items) f;

-- Lab 4.2
SELECT
  region,
  SUM(qty * unit_price) AS revenue,
  COUNT(DISTINCT order_id) AS orders
FROM analytics.v_all_line_items
GROUP BY region
ORDER BY revenue DESC;

-- Check points: 

CREATE OR REPLACE VIEW analytics.v_all_line_items AS
SELECT
  order_id, customer_name, product, quantity AS qty,
  unit_price, order_date, region, 'csv' AS source
FROM raw.orders
 
UNION ALL
 
SELECT
  data:order_id::INT, data:customer.name::STRING,
  f.value:product::STRING, f.value:qty::INT,
  f.value:price::NUMBER(10,2), CURRENT_DATE(),
  data:customer.city::STRING, 'json' AS source
FROM raw.orders_json, LATERAL FLATTEN(input => data:items) f;


4.2  Aggregate revenue by region
SELECT
  region,
  SUM(qty * unit_price) AS revenue,
  COUNT(DISTINCT order_id) AS orders
FROM analytics.v_all_line_items
GROUP BY region
ORDER BY revenue DESC;


☐
--Checkpoint
SHOW VIEWS IN SCHEMA analytics;
DESCRIBE VIEW analytics.v_all_line_items;

SELECT COUNT(*) AS line_item_rows
FROM raw.orders_json,
LATERAL FLATTEN(input => data:items) f;


