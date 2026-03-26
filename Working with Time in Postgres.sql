--(1)
SELECT now(); --will show curent timestamp with your timezone


--(2)
SELECT now() AT TIME ZONE 'America/Chicago';  --will show current timestamp in the timezone specified (in this case, Central Time)


--(3)
trip_id | track_number | train_number |  scheduled_departure   |   scheduled_arrival    |    actual_departure    |     actual_arrival
---------+--------------+--------------+------------------------+------------------------+------------------------+------------------------
       1 |            1 |          683 | 2023-04-29 11:15:00+00 | 2023-04-29 12:35:00+00 | 2023-04-29 11:21:00+00 | 2023-04-29 12:52:00+00
       2 |            1 |          953 | 2023-04-29 13:49:00+00 | 2023-04-29 15:10:00+00 | 2023-04-29 13:50:00+00 | 2023-04-29 15:17:00+00
       3 |            1 |          140 | 2023-04-29 15:06:00+00 | 2023-04-29 15:23:00+00 | 2023-04-29 15:06:00+00 | 2023-04-29 15:22:00+00


--(4)
SELECT min(actual_arrival) FROM train_schedule; --will show the earliest actual arrival time from the train_schedule 


--(5)
SELECT max(actual_arrival) FROM train_schedule; --will show the latest actual arrival time from the train_schedule


--(6)
SELECT 
(SELECT max(actual_arrival) FROM train_schedule) 
- (SELECT min(actual_arrival) 
FROM train_schedule); --will show the difference between the latest and earliest actual arrival times


--(7)
SELECT avg(arrival_delta)
FROM (SELECT scheduled_arrival, actual_arrival,
	actual_arrival - scheduled_arrival AS arrival_delta
FROM train_schedule)q; -- q here for subquery alias, we need to give a name to the subquery
--will show the average difference between the scheduled and actual arrival times


--(8)
SELECT avg(arrival_delta)
FROM (select scheduled_arrival, actual_arrival,
actual_arrival - scheduled_arrival AS arrival_delta
FROM train_schedule WHERE (actual_arrival - scheduled_arrival)
> INTERVAL '10 minutes')q; --will show the average difference between the scheduled and actual arrival times for only those trains that were more than 10 minutes late
--INTERVAL is used to specify a time interval, in this case, 10 minutes. We are filtering the train_schedule to only include rows where the difference between actual_arrival and scheduled_arrival is greater than 10 minutes.
--simple filter


--(9)
SELECT count(*) FROM train_schedule
WHERE (actual_departure, actual_arrival)
OVERLAPS (now(), now() - INTERVAL '2 hours'); --will show the number of trains that have departed and arrived within the last 2 hours.
--OVERLAPS is used to check if two time periods overlap


--(10)
SELECT
date_trunc('day', train_schedule.actual_departure) d,
COUNT (actual_departure)
FROM
train_schedule
GROUP BY
d
ORDER BY
d; --will show the number of trains that departed on each day


--(overall)
store time in UTC +/- values
timestamptz is your bff
to_char and all of the formatting functions let you query time however you want
Postgres has lots of functions for interval and overlap so you can look at data that intersects
date_trunc can be really helpful if you want to roll up time fields and count by day or month