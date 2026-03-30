--Strings to Arrays
--The `string_to_array` function in PostgreSQL allows you to split a string into an array based on a specified delimiter. 
--Example Data
CREATE TABLE weather_data (
    station text,
    temps text
);

--Insert

INSERT INTO weather_data VALUES
('Station North','-1,-4,-14,-15,-16,-15,-12,-9,-3,0,1,2'),
('Station West','2,4,5,6,9,10,15,16,13,12,10,9,5,3,1'),
('Station East','5,3,2,4,5,6,9,10,15,16,13,12,10,9,5,4,2,1'),
('Station South','12,18,22,25,29,30,33,31,30,29,28,25,24,23,14');


--(1)Make a makeup for your table, and use `string_to_array` to split the `temps` column into an array of temperatures.
SELECT
	station,
	string_to_array(temps,',') AS array -- Split the temps column into an array using comma as the delimiter
FROM weather_data;

--Output


station    |                     array
---------------+------------------------------------------------
 Station North | {-1,-4,-14,-15,-16,-15,-12,-9,-3,0,1,2}
 Station West  | {2,4,5,6,9,10,15,16,13,12,10,9,5,3,1}
 Station East  | {5,3,2,4,5,6,9,10,15,16,13,12,10,9,5,4,2,1}
 Station South | {12,18,22,25,29,30,33,31,30,29,28,25,24,23,14}


--(2)Now, we can use analysis arrays
SELECT
	station,
	cardinality(string_to_array(temps,',')) AS array_size -- Use cardinality to get the size of the array created by string_to_array
FROM weather_data;

--Output

   station    | array_size
---------------+------------
 Station North |         12
 Station West  |         15
 Station East  |         18
 Station South |         15


--(3)We can also use unnest to expand the array into a set of rows, for analyzing.
SELECT
	station,
	unnest(string_to_array(temps,',')) AS temps -- Use unnest to expand the array of temperatures into individual rows for analysis
FROM weather_data ;

--Output

       station    | temps
---------------+-------
 Station North | -1
 Station North | -4
 Station North | -14
 Station North | -15
 Station North | -16
 Station North | -15
 Station North | -12
 Station North | -9
 Station North | -3
 Station North | 0
 Station North | 1
 Station North | 2
 Station West  | 2
 Station West  | 4
 Station West  | 5
 Station West  | 6
 Station West  | 9
 Station West  | 10
 Station West  | 15
 Station West  | 16
 Station West  | 13
 Station West  | 12
 Station West  | 10
 Station West  | 9
 Station West  | 5
 Station West  | 3
 Station West  | 1
 Station East  | 5
 Station East  | 3
 Station East  | 2
 Station East  | 4
 Station East  | 5
 Station East  | 6
 Station East  | 9
 Station East  | 10
 Station East  | 15
 Station East  | 16
 Station East  | 13
 Station East  | 12
 Station East  | 10
 Station East  | 9
 Station East  | 5
 Station East  | 4
 Station East  | 2
 Station East  | 1
 Station South | 12
 Station South | 18
 Station South | 22
 Station South | 25
 Station South | 29
 Station South | 30
 Station South | 33
 Station South | 31
 Station South | 30
 Station South | 29
 Station South | 28
 Station South | 25
 Station South | 24
 Station South | 23
 Station South | 14

-- a lot of rows


--(4) We can also use array functions to analyze the data, like here min and max temp
WITH unnested_data AS (
	SELECT
		station,
		unnest(string_to_array(temps,',')) AS temps -- Unnest the array of temperatures into individual rows for analysis, still same as before.
	FROM weather_data
)
SELECT
	station,
	max(temps) AS max_temp,
	min(temps) AS min_temp
FROM unnested_data
GROUP BY station;


--Output

station    | max_temp | min_temp
---------------+----------+----------
 Station North | 2        | -1
 Station West  | 9        | 1
 Station East  | 9        | 1
 Station South | 33       | 12
(4 rows)


--fun stuff
SELECT
	station,
	array_to_string(string_to_array(temps,','),'|') AS temps
FROM weather_data;


--Output


station    |                    temps
---------------+----------------------------------------------
 Station North | -1|-4|-14|-15|-16|-15|-12|-9|-3|0|1|2
 Station West  | 2|4|5|6|9|10|15|16|13|12|10|9|5|3|1
 Station East  | 5|3|2|4|5|6|9|10|15|16|13|12|10|9|5|4|2|1
 Station South | 12|18|22|25|29|30|33|31|30|29|28|25|24|23|14
(4 rows)

