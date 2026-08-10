CREATE OR REPLACE STREAM raw.orders_stream ON TABLE raw.orders;   -- the stream starts empty relative to now 
SELECT * FROM raw.orders_stream;

INSERT INTO raw.orders VALUES
  (2001, 'Meera Nair', 'Webcam', 'Electronics', 1, 2499.00, CURRENT_DATE(), 'West');
 
SELECT * FROM raw.orders_stream;   -- now shows the new row with METADATA$ACTION = 'INSERT'

CREATE OR REPLACE TABLE analytics.new_orders_log (
  order_id INT, customer_name STRING, product STRING,
  logged_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
 
CREATE OR REPLACE TASK raw.process_new_orders
  WAREHOUSE = lab_wh_SR
  SCHEDULE = '1 MINUTE'
WHEN
  SYSTEM$STREAM_HAS_DATA('raw.orders_stream')
AS
  INSERT INTO analytics.new_orders_log (order_id, customer_name, product)
  SELECT order_id, customer_name, product
  FROM raw.orders_stream
  WHERE METADATA$ACTION = 'INSERT';
 
ALTER TASK raw.process_new_orders RESUME;

SELECT * FROM analytics.new_orders_log;
SELECT * FROM raw.orders_stream;  -- empty again

