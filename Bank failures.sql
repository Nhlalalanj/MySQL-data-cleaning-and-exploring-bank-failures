-- DATA CLEANING

-- CREATING A STAGING TABLE

select *
from bank_list;

create table banklist_staging
like bank_list;

select *
from banklist_staging;

insert banklist_staging
select * 
from bank_list;

select *
from banklist_staging;

-- REMOVING DUPLICATES

with duplicate_cte as 
(
select *, 
row_number() over(
partition by bank_name, city, state, cert, acquiring_institution, closing_date, fund) as row_num
from banklist_staging
)
select * 
from duplicate_cte
where row_num > 1;

CREATE TABLE `banklist_staging2` (
  `Bank_Name` text,
  `City` text,
  `State` text,
  `Cert` int DEFAULT NULL,
  `Acquiring_Institution` text,
  `Closing_Date` date DEFAULT NULL,
  `Fund` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from banklist_staging2;

insert into banklist_staging2
select *, 
row_number() over(
partition by bank_name, city, state, cert, acquiring_institution, closing_date, fund) as row_num
from banklist_staging;

delete
from banklist_staging2
where row_num > 1;

-- STANDARDIZE THE DATA

alter table banklist_staging
modify column Closing_Date date;

-- EXPLORATORY DATA ANALYSIS

select city, year(Closing_Date) as `year`, count(bank_name) as failed_banks
from banklist_staging2
group by city, year(Closing_Date)
order by count(Bank_Name) desc;

select city, state, count(bank_name) as failed_banks
from banklist_staging2
group by city, state
order by 3 desc;

select *
from banklist_staging2;

select bank_name, city, closing_date, fund
from banklist_staging2
group by Bank_Name, City, Closing_Date, fund
order by fund desc;

select bank_name, count(Bank_Name), avg(fund)
from banklist_staging2
group by Bank_Name
order by 3 desc;

SELECT YEAR(closing_date) AS `year`, sum(fund) 
FROM banklist_staging2 
GROUP BY YEAR(closing_date)
ORDER BY year;

SELECT city, COUNT(Bank_Name) AS failed_banks, SUM(fund) AS total_funds
FROM banklist_staging2
GROUP BY city
ORDER BY total_funds DESC;

select *
from banklist_staging2;

SELECT acquiring_institution, COUNT(bank_name) AS acquisitions, SUM(fund) AS total_funds_acquired
FROM banklist_staging2
GROUP BY acquiring_institution
ORDER BY acquisitions DESC;

SELECT bank_name, state, city, fund
FROM banklist_staging2
ORDER BY fund DESC
LIMIT 10;

with rolling_total as
(
 select year(closing_date) as year, sum(fund) as total_funds
 from banklist_staging2
group by year(closing_date)
order by 1 asc
)
select year, total_funds, sum(total_funds) over(order by year) as rolling_toal
from rolling_total;




