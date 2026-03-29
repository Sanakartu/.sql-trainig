--Using FILTER vs CTEs and CASE WHEN
--(1) Using CTEs
WITH totals AS (
	SELECT
	  lower(i.invoice_period) as mnth,               --lower is used to convert the invoice_period to lowercase, so we can group by month regardless of the case.
	  SUM(i.net_total_in_cents) / 100.0 as net_total -- calculating the total net amount in dollars by summing the net_total_in_cents and dividing by 100.
	FROM invoices i
	GROUP BY 1
), collected AS (
	SELECT
	  lower(i.invoice_period) as mnth,              --same as above.
	  SUM(i.net_total_in_cents) / 100.0 as amount   --same as above.
	FROM invoices i
	WHERE status = 'paid'
	GROUP BY 1
), invoiced AS (
	SELECT
	  lower(i.invoice_period) AS mnth,              --same as above.
	  sum(i.net_total_in_cents) / 100.0 AS amount   --same as above.
	FROM invoices i
	WHERE status = 'invoiced'
	GROUP BY 1
)

SELECT totals.mnth,
       totals.net_total as billed,
       COALESCE(invoiced.amount, 0) as uncollected, -- COALESCE is used to return the first non-null value from the list of arguments, in this case if invoiced.amount is null it will return 0.
       COALESCE(collected.amount, 0) as collected
FROM totals
	LEFT JOIN invoiced ON totals.mnth = invoiced.mnth
	LEFT JOIN collected on totals.mnth = collected.mnth
ORDER BY 1 desc;




--(2) Using CASE WHEN
--(2.1) Case statements for conditional filtering
SELECT LOWER(i.invoice_period) as mnth,                --same as (1) above.
       SUM(i.net_total_in_cents) / 100.0 as billed,    --same as (1) above.
       SUM (CASE WHEN status = 'invoiced' THEN  i.net_total_in_cents END) / 100.00 as uncollected,  -- CASE WHEN is used to conditionally sum the net_total_in_cents only for rows where the status is 'invoiced', if the condition is not met it will return null and those nulls will be ignored in the sum.
       SUM (CASE WHEN status = 'paid' THEN  i.net_total_in_cents END) / 100.00 as collected  -- same as above but for 'paid' status.
FROM invoices i
GROUP BY 1
ORDER BY 1 desc;



--(3) Using FILTER
SELECT LOWER(i.invoice_period) as mnth,                                                         --SAME
       SUM (i.net_total_in_cents) / 100.0 as billed,                                            --SAME
       SUM (i.net_total_in_cents) FILTER (WHERE status = 'invoiced') / 100.00 as uncollected, -- using FILTER to conditionally sum the net_total_in_cents only for rows where the status is 'invoiced', this is more concise and efficient than using CASE WHEN.
       SUM (i.net_total_in_cents) FILTER (WHERE status = 'paid') / 100.00 as collected
FROM invoices i
GROUP BY 1
ORDER BY 1 desc;



