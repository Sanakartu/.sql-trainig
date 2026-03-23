
-- CTEs and Window Functions
--(1)
CREATE TABLE births (   
    id serial,   
    day date,   
    births int 
    );



INSERT INTO births (day, births) 
SELECT make_date(year, month, date_of_month),        
births FROM US_births_20002014_SSA; 
-- just creating a table with the data from the csv file(US_births_20002014_SSA)

--(2)

SELECT date_trunc('week', day) week, --truncating the date to the week level, so we can group by week
        sum(births) births -- summing the births for each week
FROM births   -- selecting from the births table we just created
GROUP BY 1 	
ORDER BY week DESC; 


--(3)

WITH weekly_births AS (   -- this is the CTE, we can reference it in the main query below/opertor ''WITH'' is used to define a CTE
    SELECT date_trunc('week', day) week, --truncating the date to the week level, so we can group by week
              sum(births) births   
              FROM births   
              GROUP BY 1 ) 
SELECT week,
        births,
        lag(births, 1) OVER (                       -- lag function to get the previous week's births, we specify the column we want to lag (births) and the number of rows to lag (1)/ OVER clause to specify the window we want to apply the lag function to
                             ORDER BY week DESC        
                            ) prev_births 
FROM weekly_births; 


