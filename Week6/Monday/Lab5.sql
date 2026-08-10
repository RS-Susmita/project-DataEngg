-- note the row count before
--5.1
SELECT COUNT(*) AS Current_Count
FROM raw.orders;

 
-- accidentally wipe out a region's data
DELETE FROM raw.orders WHERE region = 'North';
 
SELECT COUNT(*) FROM raw.orders;


--5.2
-- look at the table as it was 5 minutes ago
SELECT * FROM raw.orders AT(OFFSET => -60*5);

SELECT COUNT(*) AS before_delete_count
FROM raw.orders AT(OFFSET => -60*5);
-- restore it properly

CREATE OR REPLACE TABLE raw.orders AS
SELECT * FROM raw.orders BEFORE(STATEMENT => LAST_QUERY_ID());
--- Lab 5.3 



 
-- alternative: UNDROP if you'd dropped the whole table instead
-- UNDROP TABLE raw.orders;


