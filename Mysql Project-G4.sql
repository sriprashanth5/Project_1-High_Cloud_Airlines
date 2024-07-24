use projecthighcloud;
show tables;
select * from maindata limit 5;
select count(*) from maindata;
select count(*) from flighttypes;
select * from `distance groups`;
DESCRIBE maindata;
ALTER TABLE maindata RENAME COLUMN `%Distance Group ID` TO `Distance_Group_ID`;
ALTER TABLE maindata RENAME COLUMN `# Available Seats` TO `Available_Seats`;
ALTER TABLE maindata RENAME COLUMN `From - To City` TO `From_To_City`;
ALTER TABLE maindata RENAME COLUMN `Carrier Name` TO `Carrier_Name`;
ALTER TABLE maindata RENAME COLUMN `# Transported passengers` TO `Transported_Passengers`;
ALTER TABLE `distance groups` RENAME COLUMN `ï»¿%Distance Group ID` TO `Distance_Group_ID`;
ALTER TABLE `distance groups` RENAME COLUMN `Distance Interval` TO `distance_Interval`;
ALTER TABLE maindata RENAME COLUMN `%Airline ID` TO `airline_id`;

select * from `distance groups`;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
create view order_date as 
select
	concat(Year, '-', `Month (#)`, '-', Day)as order_date,
    Transported_Passengers,
    Available_Seats,
    From_To_City,
    Carrier_Name,
    Distance_Group_ID
from
	maindata;
    
select * from order_date limit 10;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- "1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)"
--  A.Year
-- B.Monthno
-- C.Monthfullname
-- D.Quarter(Q1,Q2,Q3,Q4)
-- E. YearMonth ( YYYY-MMM)
-- F. Weekdayno
-- G.Weekdayname
-- H.FinancialMOnth
-- I. Financial Quarter 

create view kpil as select year(order_date) as year_number,
month(order_date) as month_number,
day(order_date) as day_number,
monthname(order_date) as month_name,
concat("Q", quarter(order_date)) as quarter_number,
concat(year(order_date),'-',monthname (order_date)) as year_month_number,
weekday (order_date) as weekday_number,
dayname(order_date) as day_name,
case
when quarter(order_date)=1 then "FQ4"
when quarter(order_date)=2 then "FQ1"
when quarter(order_date)=3 then "FQ2"
when quarter(order_date)=4 then "FQ3"
end as Financial_Quarter,
case
when month(order_date) = 1 then "10"
when month(order_date) = 2 then "11"
when month(order_date) = 3 then "12"
when month(order_date) = 4 then "1"
when month(order_date) = 5 then "2"
when month(order_date) = 6 then "3"
when month(order_date) = 7 then "4"
when month(order_date) = 8 then "5"
when month(order_date) = 9 then "6"
when month(order_date) = 10 then "7"
when month(order_date) = 11 then "8"
when month(order_date) = 12 then "9"
end as Financial_month,
case
when weekday (order_date) in (5,6) then "Weekend"
when weekday (order_date) in (0,1,2,3,4) then "Weekday"
end as weekend_weekday,
Transported_Passengers,
Available_Seats,
From_To_City,
Carrier_Name,
Distance_Group_ID
from order_date;

select * from kpil;
select count(*) from kpil;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

select year_number,sum(Transported_Passengers),sum(Available_Seats),
(sum(Transported_Passengers)/sum(Available_Seats)*100)
as "load_Factor" from kpil group by year_number;
----------------------------------------------------------------------------------------------------------------------------------------------------------
select quarter_number,sum(Transported_Passengers), sum(Available_Seats),
(sum(Transported_Passengers)/sum(Available_Seats)*100) 
as "load Factor" from kpil group by quarter_number order by quarter_number;
----------------------------------------------------------------------------------------------------------------------------------------------------------
select month_name,sum(Transported_Passengers),sum(Available_Seats),
(sum(Transported_Passengers)/sum(Available_Seats)*100)
as "load Factor" from kpil group by month_name order by `load Factor` desc;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)

select Carrier_Name,sum(Transported_Passengers),sum(Available_Seats),
(sum(Transported_Passengers)/sum(Available_Seats)*100) 
as "load_Factor" from kpil group by Carrier_Name order by load_Factor desc;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Identify Top 10 Carrier Names based passengers preference 

select Carrier_Name,sum(Transported_Passengers) 
from kpil group by Carrier_Name order by sum(Transported_Passengers) desc limit 10;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Display top Routes ( from-to City) based on Number of Flights 

select From_To_City, count(From_To_City) as Number_of_flights from kpil
group by From_To_City order by count(From_To_City) desc limit 10;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.

select weekend_weekday,sum(Transported_Passengers),sum(Available_Seats),
(sum(Transported_Passengers)/sum(Available_Seats)*100)
as "load Factor" from kpil group by weekend_weekday;

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8. Identify number of flights based on Distance groups      
        
 SELECT
		`distance groups`.Distance_Group_ID AS Distance_Group_ID,
		`distance groups`.distance_interval AS distance_interval,
    COUNT(maindata.airline_id) AS `count(airline_id)`
FROM
	`distance groups`
LEFT JOIN maindata ON (`distance groups`.Distance_Group_ID = maindata.Distance_Group_ID)
GROUP BY `distance groups`.Distance_Group_ID,`distance groups`.distance_interval;
