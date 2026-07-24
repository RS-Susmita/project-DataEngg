DELETE FROM customers
WHERE rowid NOT IN
(
SELECT MIN(rowid)
FROM customers
GROUP BY customer_id
);

DELETE FROM orders
WHERE quantity<=0;

UPDATE orders
SET payment_status='Pending'
WHERE payment_status IS NULL;