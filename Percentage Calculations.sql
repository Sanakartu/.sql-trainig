--With modern PostgreSQL, you can calculate complex percentages over different groups in a single pass, using "window functions".
--Example Table
CREATE TABLE musicians (
    band text,
    name text,
    earnings numeric(10,2)
);

INSERT INTO musicians VALUES
    ('PPM',  'Paul',   2.2),
    ('PPM',  'Peter',  4.5),
    ('PPM',  'Mary',   1.1),
    ('CSNY', 'Crosby', 4.2),
    ('CSNY', 'Stills', 6.3),
    ('CSNY', 'Nash',   0.3),
    ('CSNY', 'Young',  2.2);



--Ernings per person/band? idk.
SELECT
    band, name,
    round(100 * earnings/sums.sum,1) AS percent  --Formula to caculate the % of earnings for each musician. From the total earnings of all musicians.
FROM musicians
CROSS JOIN (                                     --Using CROSS JOIN to join the musicians table with a subquery that calculates the total earnings of all musicians.
    SELECT Sum(earnings)
    FROM musicians
    ) AS sums
ORDER BY percent;


--Eazy version using window functions
SELECT
    band, name,
    round(100 * earnings /
        Sum(earnings) OVER (),    --still same formula but using window function OVER () to calculate the total earnings of all musicians without needing a subquery or CROSS JOIN.
        1) AS percent             --OVER() is used to specify that the sum of earnings should be calculated over the entire result set.
FROM musicians
ORDER BY percent;


--Another remake
SELECT
    band, name,
    round(100 * earnings /
        Sum(earnings) OVER (PARTITION BY band), --OVER (PARTITION BY ...) this function does give us the sum of earnings for each band separately and then we can calculate the percentage of earnings for each musician within their respective band.
        1) AS percent
FROM musicians
ORDER BY band, percent;

