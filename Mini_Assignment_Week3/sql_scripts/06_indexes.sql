CREATE INDEX idx_orders_customer
ON orders(customer_id);


CREATE INDEX idx_orders_orderdate
ON orders(order_date);

CREATE INDEX idx_orders_customer_date
ON orders(customer_id,order_date);