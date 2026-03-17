--

SELECT * FROM products.reviews
ORDER BY id ASC 


--Task 1

SELECT id, name
	FROM products.catalog;

--Task 2

SELECT 
	price, 
	name
FROM 
	products.catalog
WHERE price < 15
ORDER BY price DESC;


--Task 3

SELECT price, name
FROM 
	products.catalog

ORDER BY price DESC
LIMIT 2;


--Task 4
SELECT id, name
	FROM customers.accounts;


--Task 5


SELECT category, COUNT(stock_quantity) AS ammo
	FROM products.catalog
GROUP BY category;


--Task 7

SELECT 
	sales.orders.total_amount,
	customers.accounts.name,
	sales.orders.order_date 
FROM
	customers.accounts
JOIN sales.orders
  	ON customers.accounts.id = sales.orders.customer_id;

--Task 8


SELECT 
	sales.orders.total_amount,
	customers.accounts.name,
	sales.orders.order_date 
FROM
	customers.accounts
LEFT JOIN sales.orders
  	ON customers.accounts.id = sales.orders.customer_id
WHERE sales.orders.total_amount IS NULL






--Task 9



SELECT 
	customers.accounts.name,
	products.catalog.name,
	sales.order_items.price,
	sales.order_items.quantity
FROM
	customers.accounts
JOIN sales.orders
  	ON customers.accounts.id = sales.orders.customer_id
JOIN sales.order_items
	ON sales.orders.id = sales.order_items.order_id
JOIN products.catalog
	ON sales.order_items.product_id = products.catalog.id;


--Task 10

SELECT 
	products.reviews.review,
	customers.accounts.name,
	products.catalog.name AS product
FROM
	products.reviews
JOIN customers.accounts
  	ON customers.accounts.id = products.reviews.customer_id
JOIN products.catalog
	ON products.catalog.id = products.reviews.product_id;

--Task 11

SELECT   
	p.name,
    ROUND(AVG(r.rank), 1) AS avg_rank
FROM     products.catalog p
JOIN     products.reviews r ON r.product_id = p.id
GROUP BY p.name
ORDER BY avg_rank DESC;


--Task 12

SELECT   
	p.name,
    ROUND(AVG(r.rank), 1) AS avg_rank
FROM     products.catalog p
JOIN     products.reviews r 
ON r.product_id = p.id
GROUP BY p.name
HAVING   AVG(r.rank) > 3.5
ORDER BY avg_rank DESC;


--Task 13

SELECT  p.name, p.category
FROM    products.catalog p
LEFT JOIN products.reviews r 
ON r.product_id = p.id
WHERE   r.id IS NULL


--Task 14
-- ai
SELECT   
	p.name,
    COALESCE(SUM(oi.quantity), 0)                 AS total_sold,
    COALESCE(SUM(oi.quantity * oi.price), 0)       AS total_revenue
FROM     products.catalog   p
LEFT JOIN sales.order_items oi 
ON oi.product_id = p.id
GROUP BY p.name
ORDER BY total_revenue DESC;


--либо


SELECT   
	p.name,
    SUM(oi.quantity)           AS total_sold,
    SUM(oi.quantity * oi.price)     AS total_revenue
FROM     products.catalog   p
LEFT JOIN sales.order_items oi 
ON oi.product_id = p.id
GROUP BY p.name
ORDER BY total_revenue DESC;


--Task 15

SELECT   
	c.name,
    COUNT(o.id)             AS total_orders,
	SUM(o.total_amount)     AS lifetime_value
FROM     customers.accounts c
JOIN     sales.orders        o 
ON o.customer_id = c.id
GROUP BY c.name
ORDER BY lifetime_value DESC;



--bonus 1

SELECT   
	c.name,
    COUNT(r.id) AS review_count
FROM     products.catalog c
LEFT JOIN products.reviews r 
ON c.id = r.product_id
GROUP BY c.name
ORDER BY review_count DESC;

--bonus 2

SELECT DISTINCT category FROM products.catalog;

SELECT COUNT(DISTINCT category) AS category_count
FROM   products.catalog;

--bonus 3

SELECT COUNT(DISTINCT customer_id) AS reviewers
FROM   products.reviews;

--cause some customers may have reviewed multiple products DISTINCT counts each customer only once (он сам мне предложил я не виноват)


--bonus 4

SELECT   
	c.name,
    COUNT(r.id) AS review_count  --смисл тут COUNT(*) если нам нада только r.id
FROM     products.catalog c
LEFT JOIN products.reviews r 
ON c.id = r.product_id
GROUP BY c.name
ORDER BY review_count DESC;



--bonus 5

SELECT name, price
FROM   products.catalog
ORDER BY price DESC
LIMIT  1 OFFSET 1; --OFFSET 1 эта херня пропускает первый товал

--bonus 6



SELECT   
	p.name,
    SUM(oi.quantity) AS total_sold
FROM     products.catalog   p
LEFT JOIN sales.order_items oi 
ON oi.product_id = p.id
GROUP BY p.name
ORDER BY total_sold DESC;



--bonus 7




SELECT
	p.name,
    ROUND(AVG(r.rank), 1) AS avg_rank
FROM     products.catalog p
JOIN     products.reviews r 
ON p.id = r.product_id
GROUP BY p.name;




--JSONB training

SELECT '{
  "name": "Tyler",
  "height": 169,
  "hobby": ["coding", "hiking", "cooking"],
  "address": {
	"street": "123 Main St",
	"city": "Anytown",
	"state": "CA",
	"zip": "12345"
  }
}'::json;

--(1)
--::json->'name' / type would be json
--(2)
--::json->>'name' / type would be text
--(3)
--::json->'address'->>'street' / first arrow to access the street, second arrow to extract the value == type would be text
--(4)
--::json->'hobby'->>0 / first arrow to access the hobby , second arrow with index 0 to get the first hobby == type would be text
--(5)
SELECT ('{
  "name": "Tyler",
  "height": 169,
  "hobby": ["coding", "hiking", "cooking"],
  "address": {
	"street": "123 Main St",
	"city": "Anytown",
	"state": "CA",
	"zip": "12345"
  }
}'::json->'height')::int --/gonna return 169 as an int value



--(6)

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  metadata JSONB
);

--(7)

INSERT INTO users (metadata) VALUES
('{
  "name": "Tyler",
  "height": 169,
  "hobby": ["coding", "hiking", "cooking"],
  "address": {
	"street": "123 Main St",
	"city": "Anytown",
	"state": "CA",
	"zip": "12345"
  }
}');

--


INSERT INTO users (metadata) VALUES (
  '{"name": "Sean", 
  "height": 185, 
  "hobby": ["basketball", "football"], 
  "address": {"country": "UK"}
  }'
);



--




INSERT INTO users (metadata) VALUES (
  '{
  "name": "Thor", 
  "height": 190, 
  "hobby": ["tennis", "cooking"], 
  "address": {"country": "UK"}
  }'
);
--(8)

SELECT * 
FROM users 
WHERE (metadata->>'height')::int < 180; --shows all rows where height is less than 180 (we need to extract height as text and then cast it to int for comparison)


--(9)
SELECT * 
FROM users 
WHERE metadata ? 'height'; --shows all rows where we have height key in our json

--(10)

SELECT * 
FROM users 
WHERE metadata->'hobby' ? 'basketball';  --shows all rows where we have basketball

--(11)	


SELECT * 
FROM users 
WHERE metadata->'hobby' ?& array['basketball', 'tennis']; --shows all rows where we have both basketball and tennis ONLY

--(12)


SELECT * 
FROM users 
WHERE metadata->'hobby' ?| array['football', 'cooking']; --shows all rows where we have either football or cooking (or both)




--(13)

SELECT * 
FROM users 
WHERE metadata @> '{"name": "Tyler"}'; --shows all rows where we have name Tyler (exact match)

--(14)
SELECT * 
FROM users 
WHERE metadata @> '{"hobby": ["basketball"]}'; --shows all rows where we have hobby array that contains basketball ONLY
--(15)
SELECT * 
FROM users 
WHERE metadata @> '{"hobby": ["basketball"], "address": {"country": "Japan"}}'; --shows all rows where we have hobby array that contains basketball ONLY and address with country Japan (exact match)