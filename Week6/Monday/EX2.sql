CREATE OR REPLACE TABLE raw.orders (
  order_id       INT,
  customer_name  STRING,
  product        STRING,
  category       STRING,
  quantity       INT,
  unit_price     NUMBER(10,2),
  order_date     DATE,
  region         STRING
);

SELECT * From ORDERS
CREATE OR REPLACE STAGE raw.orders_stage

--- LAB 3
CREATE OR REPLACE TABLE raw.orders_json (data VARIANT);

INSERT INTO raw.orders_json
SELECT PARSE_JSON('{
  "order_id": 1001,
  "customer": {"name": "Asha Verma", "city": "Delhi"},
  "items": [
    {"product": "Wireless Mouse", "qty": 2, "price": 799},
    {"product": "USB-C Hub", "qty": 1, "price": 1499}
  ]
}');
 
INSERT INTO raw.orders_json
SELECT PARSE_JSON('{
  "order_id": 1002,
  "customer": {"name": "Rohan Iyer", "city": "Bengaluru"},
  "items": [
    {"product": "Mechanical Keyboard", "qty": 1, "price": 3999}
  ]
}');

-- 3.3
SELECT
  data:order_id::INT               AS order_id,
  data:customer.name::STRING       AS customer_name,
  data:customer.city::STRING       AS city
FROM raw.orders_json;

--3.4
SELECT
  data:order_id::INT                    AS order_id,
  data:customer.name::STRING            AS customer_name,
  f.value:product::STRING               AS product,
  f.value:qty::INT                      AS qty,
  f.value:price::NUMBER(10,2)           AS unit_price
FROM raw.orders_json,
  LATERAL FLATTEN(input => data:items) f;



SHOW TABLES LIKE 'ORDERS_JSON' IN SCHEMA RAW;