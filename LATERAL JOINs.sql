--LATERAL JOINs
--LATERAL JOINs to join top-query with sub-query
--Example
SELECT    --top-query
  accounts.id,
  accounts.name,
  last_purchase.*
FROM
  accounts
INNER JOIN (SELECT  --sub-query
              *
            FROM purchases
            WHERE account_id = accounts.id
            ORDER BY created_at DESC
            LIMIT 1
           ) AS last_purchase ON true;

--but here we would gat an error

/* ERROR:  invalid reference to FROM-clause entry for table "accounts"
LINE 9:  WHERE account_id = accounts.id
                            ^
HINT:  There is an entry for table "accounts", but it cannot be referenced from this part of the query. 

Сause INNER JOIN cant see the top-query and when we are tring to reference accounts.id in the sub-query.

*/

--To fix this we can use LATERAL JOIN.
SELECT
  accounts.id,
  accounts.name,
  last_purchase.*
FROM
  accounts
INNER JOIN LATERAL (SELECT      --here our little LATERAL.
                      *
                    FROM purchases
                    WHERE account_id = accounts.id
                    ORDER BY created_at DESC
                    LIMIT 1
                   ) AS last_purchase ON true;
-- now its done.



--Here we have good choise for small ammo of data
SELECT
	accounts.id,
	last_purchase.*
FROM
	accounts, LATERAL (SELECT
                       *
                     FROM purchases
                     WHERE account_id = accounts.id
                     ORDER BY created_at DESC
                     LIMIT 1
                    ) AS last_purchase;
--but if we have a lot of data, its better to use JOINs and GROUP BY, because they are more efficient.


--AND for large ammo of data
WITH latest_purchase_per_account AS (                 --WITH here for CTE to calculate the latest purchase for each account.
                                                      --Small tip(CTE is used to create a temporary result set that can be referenced within the main query, allowing us to calculate the latest purchase for each account in a separate step before joining it with the accounts table.).
	SELECT
		account_id,
		MAX(purchases.created_at) AS created_at            --MAX is used to find the latest created_at timestamp for each account_id.
	FROM purchases
	GROUP BY 1
)

SELECT
	accounts.id,
	purchases.*                                                                         --Forgot to mention that * is used to select all columns from the purchases table, which is kinda obvious.
FROM latest_purchase_per_account
	INNER JOIN accounts ON latest_purchase_per_account.account_id = accounts.id                 --Here some JOINs.
	INNER JOIN purchases ON latest_purchase_per_account.created_at = purchases.created_at
		AND latest_purchase_per_account.account_id = purchases.account_id;


--AND HERE IT IS JSONB WITH LATERAL.
SELECT
  accounts.id,
  accounts.name,
  address_elements.value->>'state' AS state,
  address_elements.value->>'city' AS city
FROM
  accounts,
  LATERAL jsonb_array_elements(accounts.addresses) AS address_elements
WHERE
  address_elements.value->>'state' = 'California';
--Scary thing.


--Manipulation of JSONB with LATERAL.
--sales for electronics products
SELECT
  accounts.id AS account_id,
  accounts.name AS account_name,
  purchases.name AS product_name,
  unnested_tags.tag
FROM
  accounts
INNER JOIN purchases ON accounts.id = purchases.account_id
JOIN LATERAL unnest(REGEXP_SPLIT_TO_ARRAY(purchases.tags, E',')) AS unnested_tags(tag) ON true -- Unnest is used to expand the array of tags into a set of rows, which can then be joined with the accounts and purchases tables to associate each tag with the corresponding account and product. REGEXP_SPLIT_TO_ARRAY is used to split the tags string into an array of individual tags based on the comma delimiter.
WHERE
  unnested_tags.tag = 'electronics'; --And here we are filtering the results to only include rows where the tag is 'electronics'.


--sales for every tag
SELECT
  unnested_tags.tag,
  COUNT(*) AS purchases_per_tag
FROM
  purchases,
LATERAL unnest(REGEXP_SPLIT_TO_ARRAY(purchases.tags, E',')) AS unnested_tags(tag)
GROUP BY
  unnested_tags.tag;