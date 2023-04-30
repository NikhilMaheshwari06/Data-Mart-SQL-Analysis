create database data_mart;
use data_mart;
show tables;
select * from weekly_sales limit 20;

-- Data Cleansing and adding New columns
drop table clean_weekly_sales;
create table clean_weekly_sales As
select week_date, 
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calender_year,
region, platform,
case
when segment =null then 'unknown'
else segment 
end as segment,
case
	when right(segment,1)='1' then 'Young Adults'
	when right(segment,1)='2' then 'Middle Aged'
	when right(segment,1) in ('3','4') then 'Retired'
	else 'unknown'
end as age_band,
case
	when left(segment,1)='C' then 'Couples'
    when left(segment,1)='F' then 'Families'
    else 'unknown'
end as demographic,
customer_type,transactions,sales,
round(sales/transactions,2) as 'avg_transactions'
from weekly_sales;
show tables;

select * from clean_weekly_sales limit 20;

-- Data Exploration

-- 1. How many total transactions were there for each year in the dataset?
select calender_year,
sum(transactions) as total_transactions
from clean_weekly_sales
group by calender_year;

-- 2.  What are the total sales for each region for each month?
select region, month_number,
sum(sales) as total_sales
from clean_weekly_sales
group by region , month_number
order by month_number;

-- 3. What is the total count of transactions for each platform?
select platform,
sum(transactions) as total_transactions 
from clean_weekly_sales
group by platform;

-- 4. What is the percentage of sales for Retail vs Shopify for each month?
with cte_monthly_platform_sales as 
(
select month_number , calender_year, platform,
sum(sales) as monthly_sales
from clean_weekly_sales
group by month_number , calender_year, platform
)

select month_number, calender_year,
round(
100 *Max(case when platform ='Retail' then monthly_sales else null end)/sum(monthly_sales), 2)
as retail_percentage,
round(
100 *Max(case when platform ='Shopify' then monthly_sales else null end)/sum(monthly_sales), 2)
as shopify_percentage
from cte_monthly_platform_sales
group by month_number , calender_year
order by month_number , calender_year;

-- 5.  What is the percentage of sales by demographic for each year in the dataset?
select calender_year , demographic,
sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales))
over (partition by demographic),2) as percentage
from clean_weekly_sales
group by calender_year,demographic;

-- 6. Which age_band and demographic values contribute the most to Retail sales?
select age_band, demographic,
sum(sales) as total_sales
from clean_weekly_sales
where platform='Retail'
group by age_band, demographic
order by total_sales desc ;
