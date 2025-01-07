-- DATABASE CREATED FOR HIGCLOUD AIRLINES PROJECT

CREATE DATABASE HIGHCLOUD_AIRLINES;

SELECT *
FROM maindata;

-- CREATED AND INSERTED COPY OF MAINDATA FOR ANALYSIS SO THAT MAIN DATA DOES NOT TAMPER

Create table maindata_1
like maindata;

SELECT *
FROM maindata_1;

Insert Maindata_1
SELECT *
FROM maindata;

----------- KPI 1 -----------------
-- Calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
-- A.Year
-- B.Monthno
-- C.Monthfullname
-- D.Quarter(Q1,Q2,Q3,Q4)
-- E. YearMonth ( YYYY-MMM)
-- F. Weekdayno
-- G.Weekdayname
-- H.FinancialMOnth
-- I. Financial Quarter 

-- Using Common Table Expression, KPI 1 has been extracted

WITH Date_cte AS (
SELECT
	CONCAT(`year` ,'-', LPAD(`Month`,2,0), '-', LPAD(`Day`,2,0)) AS Date_field,
    `year`, `Month`, `Day`
FROM
	maindata_1
)
SELECT
	Date_field,
    `year`, `Month`, `Day`,
    MONTHNAME(Date_field) AS MonthFullname,
    CONCAT('Q-', QUARTER(Date_field)) AS `Quarter`,
    CONCAT(`year`,'-', SUBSTR(LPAD(`Month`,2,0),1,2)) AS `Year_Month`,
    WEEKDAY(Date_field) AS Weekday_No,
    DAYNAME(Date_field) AS Weekday_Name,
    CASE
		WHEN `Month` IN (4,5,6) THEN 'Q1'
		WHEN `Month` IN (7,8,9) THEN 'Q2'
        WHEN `Month` IN (10,11,12) THEN 'Q3'
        WHEN `Month` IN (1,2,3) THEN 'Q4'
	END AS Financial_Quarter,
    IF(MONTH(Date_field) > 3, MONTH(Date_field) - 3, MONTH(Date_field) + 9) AS Financial_Month
FROM
	Date_cte;

----------- KPI 2 -----------------
-- Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

-- YEAR WISE --
SELECT
	`Year`,
	SUM(Transported_Passengers)/ SUM(Available_Seats) *100 AS Load_Factor_Percentage
FROM
	maindata_1
GROUP BY
	`Year`;

-- MONTH WISE --
SELECT
	`Month`,
	SUM(Transported_Passengers)/ SUM(Available_Seats) *100 AS Load_Factor_Percentage
FROM
	maindata_1
GROUP BY 
	`Month`
ORDER BY
	`Month`;
    
-- QUARTER WISE --

SELECT 
    `Year`, 
    QUARTER(STR_TO_DATE(CONCAT(`Year`, '-', LPAD(`Month`, 2, '0'), '-01'), '%Y-%m-%d')) AS `Quarter`,
    SUM(Transported_Passengers) / SUM(Available_Seats) * 100 AS Load_Factor_Percentage
FROM 
    maindata_1
GROUP BY 
    `Year`, `Quarter`
ORDER BY
	`Year`,`Quarter`;  

----------- KPI 3 -----------------
-- Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)

SELECT 
	DISTINCT Carrier_Name,
    (SUM(Transported_Passengers/Available_Seats) * 100) /10000 AS Load_Factor_Percentage
FROM
	maindata_1
GROUP BY
	Carrier_Name
ORDER BY
	Load_factor_Percentage DESC
LIMIT 10;

----------- KPI 4 -----------------
-- Identify Top 10 Carrier Names based passengers preference 

SELECT 
	DISTINCT Carrier_Name,
    SUM(Transported_Passengers) AS Total_Transported_Passengers
FROM
	maindata_1
GROUP BY
	Carrier_Name
ORDER BY
	Total_Transported_Passengers DESC
LIMIT 10;

----------- KPI 5 -----------------
-- Display top Routes (from-to City) based on Number of Flights 

SELECT
	DISTINCT from_to_city AS Top_Routes,
   COUNT(from_to_city) AS From_To_City
FROM
	Maindata_1
GROUP BY
	From_to_city
ORDER BY
	From_To_City DESC
LIMIT 10;

----------- KPI 6 -----------------
-- Identify the how much load factor is occupied on Weekend vs Weekdays.

SELECT
    CASE
        WHEN WEEKDAY(STR_TO_DATE(CONCAT(`Year`, '-', LPAD(`Month`, 2, '0'), '-', LPAD(`Day`, 2, '0')), '%Y-%m-%d')) < 5 THEN 'Weekday'
        ELSE 'Weekend'
    END AS Day_Type,
    SUM(Transported_passengers) AS Total_Transported,
    (SUM(Transported_passengers) / (SELECT SUM(Transported_passengers) FROM maindata_1 WHERE Transported_passengers > 0)) * 100 AS Load_Factor_Percentage
FROM
    maindata_1
WHERE
    Transported_passengers > 0 AND Available_Seats > 0
GROUP BY
    Day_Type;
    
----------- KPI 7 -----------------
-- Identify number of flights based on Distance group

SELECT
	DISTINCT Distance_Group_ID AS Distance_Group,
    COUNT(distance_group_id) AS Number_of_Flights
FROM
	maindata_1
GROUP by
	Distance_Group_ID
ORDER BY
	Number_of_Flights DESC
LIMIT 10;

----------- END -----------------