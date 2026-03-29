--Create Sample Data
CREATE TABLE sales
AS
SELECT a, b,
       CASE WHEN random() < 0.4 THEN 'bird' ELSE 'bee' END AS c, -- 40% bird, 60% bee/caculating the value of 'c' based on a random.
       10 * random() AS value
FROM generate_series(1,100) a,  --generate_series is a set-returning function that generates a series of numbers. Here its from 1 to 100 for 'a' and 'b'.
     generate_series(1,100) b;

--The Olden Days
SELECT
  100.0 * sum(value) / (SELECT sum(value) AS total FROM sales) AS bee_pct -- caculating the percentege of 'bee'.
FROM sales
WHERE c = 'bee'; 



--I'll running two queries, or perhaps building a CTE like this:
--(1) CTE to calculate the total value of all sales
WITH total AS (
  SELECT sum(value) AS total
  FROM sales
),
bee AS (
  SELECT sum(value) AS bee
  FROM sales
  WHERE c = 'bee'
),
a90 AS (
  SELECT sum(value) AS a90
  FROM sales
  WHERE a > 90
)
SELECT 100.0 * bee / total AS bee_pct,  -- calculating the percentage of 'bee' sales out of the total sales.
       100.0 * a90 / total AS a90_pct -- calculating the percentage of sales where 'a/a90' is greater than 90 out of the total sales.
FROM total, bee, a90;

--a lot of writing the queries.
--(2) Using simple query
SELECT
  100.0 * sum(CASE WHEN c = 'bee' THEN value ELSE 0.0 END) /      -- calculating the percentage of 'bee' sales out of the total sales, still same as before.
    sum(value) AS bee_pct,
  100.0 * sum(CASE WHEN a > 90 THEN value ELSE 0.0 END) /         -- calculating the percentage of sales where 'a/a90' is greater than 90 out of the total sales, still same as before.
    sum(value) AS a90_pct
FROM sales;

--its looking better but we are still doing a lot of writting and loosing efficiency by multiple sum(value) calculations.
--(3) Using FILTER in two ways 
--(3.1)
SELECT
  100.0 * sum(value) FILTER (WHERE c = 'bee') / sum(value) AS bee_pct, -- calculating the percentage of 'bee' sales out of the total sales using FILTER.
  100.0 * sum(value) FILTER (WHERE a > 90) / sum(value) AS a90_pct -- calculating the percentage of sales where 'a/a90' is greater than 90 out of the total sales using FILTER.
--FILTER is used to specify a condition for an aggregate function, allowing us to calculate the sum of 'value' only for rows that meet the specified conditions (c = 'bee' and a > 90) without needing to write multiple CASE statements or subqueries.
--This is so much clearer than the other alternatives, and it runs faster than them too!
--(3.2)
SELECT
  stddev(value) FILTER (WHERE c = 'bee') AS bee_stddev, -- calculating the standard deviation of 'value' for rows where 'c' is 'bee' using FILTER.
  stddev(value) FILTER (WHERE a > 90) AS a90_stddev     -- calculating the standard deviation of 'value' for rows where 'a' is greater than 90 using FILTER.
FROM sales;
--here we have only one different aggregate function, stddev that helps us to calculate the standard deviation of 'value' for the specified conditions.