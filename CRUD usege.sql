--CRUD means Create, Read, Update and Delete. 
--Create (selfexplanatory)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
    );

CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers (customer_id)
    );

CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    invoice_id BIGINT REFERENCES invoices (invoice_id),
    name TEXT NOT NULL
    );


--Simple CRUD
--(1)
INSERT INTO customers (name) 
    VALUES ('Ben'); 


--(2)
INSERT INTO customers (name)
    VALUES ('Peter'), ('Paul'), ('Mary');


--(3)
UPDATE customers
  SET name = 'Jen'
  WHERE name = 'Ben';

DELETE FROM customers
  WHERE name = 'Jen';


--Super Complex CRUD(from site)
--(1)
WITH new_invoice AS (
    -- Add a fresh invoice and return the newly created id 
    INSERT INTO invoices (customer_id)
        SELECT customer_id FROM customers WHERE name = 'Mary'
        RETURNING invoice_id
)
-- Add the items, using the new invoice id 
INSERT INTO items (name, invoice_id)
    SELECT n.name, new_invoice.invoice_id
    FROM new_invoice
    CROSS JOIN
    (VALUES ('Purple Automobile'),
            ('Yellow Automobile')) AS n(name);


--(2)
WITH i AS (
    -- Insert three new invoices for each customer 
    -- returning the invoice_id for each one 
    INSERT INTO invoices (customer_id)
        SELECT customer_id
        FROM customers
        CROSS JOIN generate_series(1,3)                                             --generate_series is used to create a series of numbers from 1 to 3, which is then cross joined with the customers to create three invoices for each customer.
        RETURNING invoice_id
)
 --Insert three new items for each invoice 
 --Each items is a "colored vehicle", with a 
 --distinct color for each item on an invoice, 
 --and a single kind of vehicle for each invoice 
INSERT INTO items (invoice_id, name)
    SELECT i.invoice_id,
        Format('%s %s',                                                             --Format is used to create a string with the color and vehicle type
            c,
            (ARRAY['Train', 'Plane', 'Automobile'])[i.invoice_id % 3 + 1]) AS name  --ARRAY is used to create a list of vehicle types, and the modulo operator is used to cycle through them for each invoice.
    FROM unnest(ARRAY['Red', 'Blue', 'Green']) AS c    --unnest is used to expand the array of colors into a set of rows, which are then cross joined with the invoices to create a combination of each color with each invoice.
    CROSS JOIN i;


--Read
--USING SELECT
SELECT *
FROM customers
JOIN invoices USING (customer_id)   --USING is a shorthand for ON customers.customer_id = invoices.customer_id.
JOIN items USING (invoice_id)
WHERE customers.name = 'Paul'
ORDER BY customers.name, invoice_id;


--


SELECT DISTINCT
    customers.name,
    split_part(items.name, ' ', 2) AS vehicle
FROM customers
JOIN invoices USING (customer_id)              --same as above
JOIN items USING (invoice_id);


--Update
--Example, with tips
 Target table to change
UPDATE items
-- Change to apply to target rows 
SET name = replace(items.name, 'Blue', 'Purple')
-- Other relations to use in finding target rows 
FROM customers, invoices
-- Restriction on relations to find just target rows 
WHERE customers.customer_id = invoices.customer_id
AND invoices.invoice_id = items.invoice_id
AND customers.name = 'Mary'
AND items.name ~ '^Blue';


--Delete
--Example, with tips also
DELETE FROM items
USING invoices, customers                       --Here USING is used to specify additional tables to join in order to find the target rows for deletion. 
WHERE items.invoice_id = invoices.invoice_id
AND invoices.invoice_id = customers.customer_id
AND customers.name = 'Peter'
AND items.name ~ 'Red';


/*Conclusion
Doing things in the database is faster!
The database knows more about the data, thanks to planner statistics and other metadata.
The database is closer to the data than any client program.
Getting data to client programs is costly.
The database is happy to work on full relations and affect multiple records at a time. That's faster than one-at-a-time logic in a client.
The database is designed to do this kind of work, and it does it well.
*/