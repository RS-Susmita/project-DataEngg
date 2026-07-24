
-- ============================================================
-- Section B - Q2: Advanced SQL
-- ============================================================
 
-- 1. Rank customers based on total revenue
SELECT
    customer_id,
    customer_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price) AS revenue
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
);
 
-- 2. Running total sales by month
WITH monthly AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(quantity * unit_price) AS revenue
    FROM orders
    GROUP BY month
)
SELECT
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM monthly
ORDER BY month;
 
-- 3. Highest selling product per category
WITH product_sales AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(o.quantity * o.unit_price) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM product_sales
)
SELECT category, product_id, product_name, revenue
FROM ranked
WHERE rnk = 1;
 
-- 4. 7-day rolling average sales
WITH daily AS (
    SELECT
        order_date,
        SUM(quantity * unit_price) AS daily_revenue
    FROM orders
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    AVG(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7day_avg
FROM daily
ORDER BY order_date;
 
