
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT,
    email TEXT,
    city TEXT,
    signup_date DATE
);


CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    product_id INTEGER,
    order_date DATE,
    quantity INTEGER,
    unit_price REAL,
    payment_status TEXT
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    supplier_id INTEGER,
    cost_price REAL,
    selling_price REAL
);

CREATE TABLE clickstream (
    event_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    event_type TEXT,
    page_url TEXT,
    event_timestamp TEXT,
    device_type TEXT
);