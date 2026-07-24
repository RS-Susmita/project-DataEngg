# Write SQL queries to: 
# 1. Find top 10 customers by revenue.  

SELECT
c.customer_id,
c.customer_name,
ROUND(SUM(o.quantity * o.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;




-- ==========================================
# Query 2: Month-over-Month Sales Growth
-- ==========================================

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(quantity * unit_price) AS monthly_revenue
    FROM orders
    GROUP BY sales_month
)

SELECT
    sales_month,
    ROUND(monthly_revenue,2) AS monthly_revenue,

    ROUND(
        LAG(monthly_revenue)
        OVER (ORDER BY sales_month),
        2
    ) AS previous_month,

    ROUND(
        (
            monthly_revenue -
            LAG(monthly_revenue)
            OVER (ORDER BY sales_month)
        ) *100.0/
        LAG(monthly_revenue)
        OVER (ORDER BY sales_month),
        2
    ) AS growth_percent

FROM monthly_sales;

# Query 3 :  Find customers who ordered in consecutive months. 
-- ==========================================
-- Query 3: Customers Ordering in Consecutive Months
-- ==========================================

WITH customer_months AS (

SELECT DISTINCT

customer_id,

strftime('%Y-%m',order_date) AS order_month

FROM orders

)

SELECT *

FROM customer_months

ORDER BY customer_id, order_month
LIMIT 10; 


-- ==========================================
# Query 4: Products Never Ordered
-- ==========================================

SELECT

p.product_id,

p.product_name

FROM products p

LEFT JOIN orders o

ON p.product_id=o.product_id

WHERE o.product_id IS NULL;

-- ==========================================
-- Query 5: Revenue Contribution by Category
-- ==========================================

SELECT

p.category,

ROUND(SUM(o.quantity*o.unit_price),2) AS revenue,

ROUND(

100.0*SUM(o.quantity*o.unit_price)/

(

SELECT SUM(quantity*unit_price)

FROM orders

)

,2) AS revenue_percentage

FROM products p

JOIN orders o

ON p.product_id=o.product_id

GROUP BY p.category

ORDER BY revenue DESC;
