--Using flat with money is not recommended
select 0.0001::float4;  --will show 0.0001 but if we do select 0.0001::float4 
select 0.0001::float4 + 0.0001::float4 + 0.0001::float4;  -- it will show select 0.00029999 --this is because of the way floating point numbers are stored in the computer, they are not exact and can lead to rounding errors


--let's use numeric instead
select 0.0001::numeric; --will show 0.0001


--numeric / decimal is widely considered the ideal datatype for storing money in Postgres.
--NUMERIC allows you to specify the precision and scale of the number 
--DECIMAL is an alias for NUMERIC, so they are essentially the same thing.
--Syntax
NUMERIC(7,5)
--WHERE
--7 is the total number of digits that can be stored, including both the digits before and after the decimal point.
--5 is the number of digits that can be stored after the comma.

--Example table with NUMERIC
CREATE TABLE products (
    sku SERIAL PRIMARY KEY,
    name VARCHAR(255),
    price NUMERIC(7,5), --this is our numeric
    currency TEXT CHECK (currency IN ('USD', 'EUR', 'GBP'))
);

--(1) rounding to the nearest cent
SELECT ROUND(AVG(price), 2) AS truncated_average_price --ROUND will round to the nearest cent (in scale of 2)
FROM products; 


--(2) Rounding up with ceiling totaling and rounding up to the nearest integer
SELECT CEIL(SUM(price)) AS rounded_total_price --CEIL will round up to the nearest integer
FROM products;



--(3) Rounding down to the nearest integer
SELECT FLOOR(SUM(price)) AS  --FLOOR will round down to the nearest integer
FROM products;



--(4) Median price 
WITH sorted_prices AS (                                     --WIH is used to create a Common Table Expression (CTE).
    SELECT price,
           ROW_NUMBER() OVER (ORDER BY price) as r,         --ROW_NUMBER() is a window function that assigns a unique sequential integer to rows within a partition of a result set.
           COUNT(*) OVER () as total_count                  --OVER() is used to calculate the total count of rows in the products table.
    FROM products
)
SELECT FLOOR(AVG(price)) AS rounded_median_price
FROM sorted_prices
WHERE r IN (total_count / 2, (total_count + 1) / 2);         -- Formula for finding the median.


--(5) Casting to the money type
SELECT CEIL(SUM(price))::money AS rounded_total_price_money  --::money will cast the result to the money type.
FROM products;



--Samury:
--Use NUMERIC or DECIMAL for money in Postgres, not FLOAT or REAL.
--Use ROUND to round to a specific number of decimal places, CEIL to round up, and FLOOR to round down.
--To calculate the median, you can use a Common Table Expression (CTE) to sort the prices and then select the middle value(s).
--You can also cast the result to the money type if you want to display it in a
--Use int or bigint if you can work with whole numbers of cents and you don’t need fractional cents. This saves space and offers better performance. Store your money in cents and convert to a decimal on your output. This is also really the preferred method if all currency is the same type. If you’re changing currency often and dealing with fractional cents, move on to numeric.
--Use numeric for storing money in fractional cents and even out to many many decimal points. If you need to support lots of precision in money, this is the best bet but there’s a bit of storage and performance cost here.
--Store currency separately from the actual monetary values, so you can run calculations on currency conversions.