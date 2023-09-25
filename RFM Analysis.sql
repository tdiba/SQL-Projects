--Check Data First
select _CustomerID from PortfolioProject..Sales_Data

--Find out what the latest date is
select max(OrderDate) 
from PortfolioProject..Sales_Data

--Assume today's date is 2021-01-01
--Declare a variable
declare @today_date as DATE = '2021-01-01'

--Get the most recent purchase by each customer
select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date
from Sales_Data
Group by _CustomerID 

--Get the date difference between the last ordr date and today's date
declare @today_date as DATE = '2021-01-01'
select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date,
DATEDIFF(day,MAX(OrderDate), @today_date) as recency_score
from Sales_Data
Group by _CustomerID 

--The above query gives a recency score

--In addition to the recency score, we will calculate the frequency score
declare @today_date as DATE = '2021-01-01'
select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date,
DATEDIFF(day,MAX(OrderDate), @today_date) as recency_score,
COUNT(OrderNumber) as Frequency_Score
from Sales_Data
Group by _CustomerID 

--Add the monetary score to the table
declare @today_date as DATE = '2021-01-01'
select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date,
DATEDIFF(day,MAX(OrderDate), @today_date) as Recency_score,
COUNT(OrderNumber) as Frequency_Score,
SUM([Unit Price]-([Unit Price]*[Discount Applied])-[Unit Cost]) as Monetary_Score
from Sales_Data
Group by _CustomerID 


--Create brackets for the different scores
--We will create five brackets (1-5)
--We'll start by creating a CTE of the previous above query
declare @today_date as DATE = '2021-01-01';
with base as
(select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date,
DATEDIFF(day,MAX(OrderDate), @today_date) as Recency_score,
COUNT(OrderNumber) as Frequency_Score,
ROUND(SUM([Unit Price]-([Unit Price]*[Discount Applied])-[Unit Cost]),0) as Monetary_Score
from Sales_Data
Group by _CustomerID )
select customer_id, Recency_score, Frequency_Score, Monetary_Score,
NTILE(5) over (order by Recency_score desc) as R,
NTILE(5) over (order by Frequency_Score asc) as F,
NTILE(5) over (order by Monetary_Score asc) as M
from base 


--Convert the above table, base into another CTE
declare @today_date as DATE = '2021-01-01';
with base as
(select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date,
DATEDIFF(day,MAX(OrderDate), @today_date) as Recency_score,
COUNT(OrderNumber) as Frequency_Score,
ROUND(SUM([Unit Price]-([Unit Price]*[Discount Applied])-[Unit Cost]),0) as Monetary_Score
from Sales_Data
Group by _CustomerID ),

rfm_scores as
(select customer_id, Recency_score, Frequency_Score, Monetary_Score,
NTILE(5) over (order by Recency_score desc) as R,
NTILE(5) over (order by Frequency_Score asc) as F,
NTILE(5) over (order by Monetary_Score asc) as M
from base)
select customer_id,
CONCAT_WS('-',R,F,M) as RFM_Cell,
CAST((CAST(R as Float)+F+M)/3 as Decimal(16,2)) as Avg_rfm_scores
from rfm_scores 

--Get the revenue from each bucket
--Average revenue
declare @today_date as DATE = '2021-01-01';
with base as
(select _CustomerID as customer_id, MAX(OrderDate) as most_recent_purchase_date,
DATEDIFF(day,MAX(OrderDate), @today_date) as Recency_score,
COUNT(OrderNumber) as Frequency_Score,
ROUND(SUM([Unit Price]-([Unit Price]*[Discount Applied])-[Unit Cost]),0) as Monetary_Score
from Sales_Data
Group by _CustomerID ),

rfm_scores as
(select customer_id, Recency_score, Frequency_Score, Monetary_Score,
NTILE(5) over (order by Recency_score desc) as R,
NTILE(5) over (order by Frequency_Score asc) as F,
NTILE(5) over (order by Monetary_Score asc) as M
from base)
select (R+F+M)/3 as RFM_GROUP,
COUNT(rfm.customer_id) as Customer_Count,
SUM(base.Monetary_Score) as Total_Revenue,
SUM(base.Monetary_Score)/COUNT(rfm.customer_id) as Avg_Revenue_Per_Customer
From rfm_scores as rfm
inner join base 
on base.customer_id=rfm.customer_id
group by (R+F+M)/3
order by RFM_GROUP desc