--Materialized views are saved queries that you store in your database as a table. Materialized views can be queried like any other table. Typically materialized views are used for situations where you want to save yourself, or the database, from intensive queries or for data that is frequently used.


--(1)
--this is how you gonna use your queries without materialized views. it bad :(
SELECT * FROM products LIMIT 10; 
SELECT * from orders LIMIT 10; 
SELECT * from product_orders LIMIT 10; 

--(2)
--and this is how you create a materialized view. 
CREATE MATERIALIZED VIEW recent_product_sales AS --here we are creating a materialized view called recent_product_sales, after AS we write the query that we want to save as a materialized view.
SELECT p.sku, SUM(po.qty) AS total_quantity
FROM products p
JOIN product_orders po ON p.sku = po.sku    --some joins and stuff
JOIN orders o ON po.order_id = o.order_id
WHERE o.status = 'Shipped'
GROUP BY p.sku
ORDER BY 2 DESC;

--if you have new data use:
REFRESH MATERIALIZED VIEW recent_product_sales; 


--(3)
--this is how you gonna use your queries with materialized views. it good :D
SELECT * FROM recent_product_sales; --now we can just query the materialized view like a normal table, and it will return the results of the query we defined when we created the materialized view.


--(4)
--also after materialized view is created we need create an index on it, otherwise it will be slow to query.
CREATE INDEX sku_qty ON recent_product_sales(total_quantity); -- INDEX is used to create an index on the materialized view, we specify the name of the index (sku_qty) and the column we want to index (total_quantity)