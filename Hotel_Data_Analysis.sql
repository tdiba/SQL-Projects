--select 2018 data
select* from dbo.['2018$']

--Make one unified data set for all the years
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$']

--Name the unified table
--use CTE / with statement
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select*from hotels

--Add a Revenue column
--first add the stay in nights into one column
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select stays_in_week_nights + stays_in_weekend_nights 
from hotels

--Multiply Hotel Stays by adr to get the revenue
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select (stays_in_week_nights + stays_in_weekend_nights)*adr as revenue 
from hotels

--Bring arrival_date_year as an additional column
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select arrival_date_year, (stays_in_week_nights + stays_in_weekend_nights)*adr as revenue 
from hotels

--Group the result by year and revenue
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select arrival_date_year, sum((stays_in_week_nights + stays_in_weekend_nights)*adr) as revenue 
from hotels
group by arrival_date_year

--Group revenue by hotel type
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select arrival_date_year, hotel, round(sum((stays_in_week_nights + stays_in_weekend_nights)*adr),2) as revenue 
from hotels
group by arrival_date_year,hotel

--Join Maerket segments table to hotel table
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select* 
from hotels
join dbo.market_segments
on hotels.market_segment=market_segments.market_segment

--Left Join Market segment and Meal Costs table to Hotels table
with hotels as (
select* from dbo.['2018$']
union
select* from dbo.['2019$']
union
select* from dbo.['2020$'])
select* 
from hotels
left join dbo.market_segments
on hotels.market_segment=market_segments.market_segment
left join dbo.meal_costs
on meal_costs.meal=hotels.meal

--SQL is now developed for Power BI