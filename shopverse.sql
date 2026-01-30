use shopverse;

select * from calendar;
select * from campaigns;
select * from customers;
select * from orders;
select * from products;


create view sales_overview as 
#1.What is the total revenue, total profit, and total number of orders for each month and year?

select year(Order_Date) as Year,month(Order_Date) as MonthNum,monthname(Order_Date) as Month,count(Order_ID) as Total_Orders,round(sum(Revenue),0) as Total_Revenue,
round(sum(Profit),0) as Total_profit
from orders
group by year(Order_Date),month(Order_Date),monthname(Order_Date)
order by Year,MonthNum;



create view profit_rank as 
#2.Which month recorded the highest and lowest profit each year?
with MonthlyProfits as 
(select year(Order_Date) as Year,month(Order_Date) as MonthNum,monthname(Order_Date) as Month,round(sum(Profit),0) as TotalProfit
from orders
group by year(Order_Date),month(Order_Date),monthname(Order_Date)
),
monthlyrank as 
(select *, rank() over(Partition by Year order by TotalProfit desc) as Highest_rank,
rank () over (Partition by Year order by TotalProfit ) as Lowest_rank
from MonthlyProfits)
select Year, max(case when Highest_rank = 1 then Month end) as HighestProfitableMonth,
max(case when Highest_rank = 1 then TotalProfit end) as Highest_Profit,
min(case when Lowest_rank = 1 then Month end) as LowestProfitableMonth,
min(case when Lowest_rank = 1 then TotalProfit end) as Lowest_Profit 
from monthlyrank
group by Year
order by Year;



create view yoy_summary as 
#3️.What is the year-over-year growth rate in sales and profit?
with Yearwiseprofit as 
(select year(Order_Date) as Year,sum(Profit) as Total_profit,sum(Revenue) as Total_sales
from orders 
group by year(Order_Date)
),
yoy as 
(select Year,Total_profit,Total_sales,lag(Total_profit) over (order by year) as pyp,lag(Total_sales) over (order by year) as pys
from Yearwiseprofit)
select Year,concat(round((Total_profit - pyp)*100/nullif(pyp,0),0),'%') as YOY_profit,concat(round((Total_sales - pys) *100/nullif(pys,0),0),'%') as Yoy_sales
from yoy;


create view sales_overview as 
#4. Calculate the profit margin (%) for each order, month, and category.

select o.Order_ID,year(o.Order_Date) as Year,month(o.Order_Date) as monthnum,monthname(o.Order_Date) as Month,p.Category,concat(round(o.Profit*100/nullif(o.Revenue,0),0),'%') as Profit_Margin
from orders as o 
join products as p on o.Product_ID = p.Product_ID
order by Year,monthnum;

create  view loss_making_months as 

#5. Identify months with negative total profit (loss-making months).

select year(Order_Date) as Year,month(Order_Date) as Monthnum ,monthname(Order_Date) as Month,sum(Profit) as Total_profit
from orders
group by year(Order_Date),month(Order_Date),monthname(Order_Date)
having sum(Profit) < 0 
order by Year,Monthnum ;



#6.Create a view showing monthly cumulative revenue and profit (for trend charts).

CREATE VIEW cumulative_revenue_profit AS
WITH MonthlyTotals AS (
    SELECT
        YEAR(Order_Date) AS Year,
        MONTH(Order_Date) AS MonthNum,
        MONTHNAME(Order_Date) AS Month,
        SUM(Profit) AS Monthly_Profit,
        SUM(Revenue) AS Monthly_Revenue
    FROM orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date), MONTHNAME(Order_Date)
)
SELECT
    Year,
    MonthNum,
    Month,
    SUM(Monthly_Profit) OVER (
        PARTITION BY Year
        ORDER BY MonthNum
        ROWS UNBOUNDED PRECEDING
    ) AS Cumulative_Profit,
    SUM(Monthly_Revenue) OVER (
        PARTITION BY Year
        ORDER BY MonthNum
        ROWS UNBOUNDED PRECEDING
    ) AS Cumulative_Revenue
FROM MonthlyTotals
ORDER BY Year, MonthNum;



create view Top_Product_Category as
#7. What are the top 5 product categories by total profit and revenue?
select p.Category,round(sum(o.Revenue),0) as Total_Revenue,round(sum(o.Profit),0) as Total_Profit
from products as p 
join orders as o on p.Product_ID = o.Product_ID
group by p.Category
order by Total_Profit,Total_Revenue desc
limit 5;

Create view Cat_subcat_Performance as
#8.Within each category, which subcategory performs the best and worst in terms of profit margin?
with categorywise as 
(select p.Category,p.Sub_Category,round(sum(o.Profit)*100/nullif(sum(o.Revenue),0),2) as Profit_Margin
from products as p 
join orders as o on p.Product_ID = o.Product_ID
group by p.Category,p.Sub_Category),
Ranking as 
(select Category,Sub_Category,Profit_Margin,rank() over (Partition by Category order by Profit_Margin desc) as Bestperforming,
rank() over (Partition by Category order by Profit_Margin ) as worstperforming
from categorywise)
select Category,max(case when Bestperforming = 1 then Sub_Category end) as BestSubcategory,
max(case when Bestperforming = 1 then Profit_Margin end) as BestProfit_Margin,
max(case when worstperforming = 1 then Sub_Category end ) as WorstSubcategory,
max(case when worstperforming = 1 then Profit_Margin end ) as WorstProfitMargin
from Ranking
group by Category
order by Category;




Create view AOV_Category as
#9. calculate the average order value (AOV) for each category and compare it across years.
SELECT 
    YEAR(o.Order_Date) AS Year,
    p.Category,
    ROUND(
        SUM(o.Revenue) / NULLIF(COUNT(DISTINCT o.Order_ID), 0),
        0
    ) AS AOV
FROM products p
JOIN orders o 
    ON p.Product_ID = o.Product_ID
GROUP BY 
    YEAR(o.Order_Date),
    p.Category
ORDER BY 
    Year, p.Category;


Create view loss_Profit_Margin as
#10. Which products have negative profit margins in any month (sold at a loss)?
select year(o.Order_Date) as Year,month(o.Order_Date) as Monthnum,monthname(o.Order_Date) as Month,p.Product_Name,concat(round(sum(o.Profit)*100/nullif(sum(o.Revenue),0),2),'%') as ProfitMargin
from products as p 
join orders as o on p.Product_ID = o.Product_ID
group by year(o.Order_Date),month(o.Order_Date),monthname(o.Order_Date),p.Product_Name
having  (SUM(o.Profit) * 100.0 / NULLIF(SUM(o.Revenue), 0)) < 0
 order by Year,Monthnum;


Create view neg_Profit_Margin as
#10. Which products have negative profit margins in any month (sold at a loss)?
select year(o.Order_Date) as Year,month(o.Order_Date) as Monthnum,monthname(o.Order_Date) as Month,p.Product_Name,concat(round(sum(o.Profit)*100/nullif(sum(o.Revenue),0),2),'%') as ProfitMargin
from products as p 
join orders as o on p.Product_ID = o.Product_ID
group by year(o.Order_Date),month(o.Order_Date),monthname(o.Order_Date),p.Product_Name
having  (SUM(o.Profit) * 100.0 / NULLIF(SUM(o.Revenue), 0)) < 0
 order by Year,Monthnum;



Create view Category_contribution as
#11. Determine the contribution percentage of each category to total company revenue.
with categoryrevenue as 
(select p.Category,round(sum(o.Revenue),0) as Categorywiserevenue
from products as p 
join orders as o on p.Product_ID = o.Product_ID
group by p.Category),
companyrevenue as 
(select round(sum(Revenue),0) as Totalrevenue
from orders)
select Category, Categorywiserevenue,Totalrevenue,concat(round(Categorywiserevenue * 100/Totalrevenue,2),'%') as PercentageContribution
from categoryrevenue as car
cross join companyrevenue as cr;



#12. Create a view that ranks products and regions by total sales (for leaderboards).
create view leaderboard as
with Regionwsales as 
(select p.Product_Name,o.Region,sum(o.Revenue) as TotalSales
from products as p
join orders as o on p.Product_ID = o.Product_ID
group by p.Product_Name,o.Region)
select Region,Product_Name,TotalSales,rank() over (Partition by Region order by TotalSales desc) as RegionwiseRank
from Regionwsales;




Create view Order_Trend as
#13. Show monthly order count trends per category (for area charts).
select year(o.Order_Date) as Year,month(o.Order_Date) as Monthnum,monthname(o.Order_Date) as Month,p.Category,count(o.Order_ID) as Ordercount
from products as p 
join orders as o on p.Product_ID = o.Product_ID
group by year(o.Order_Date),month(o.Order_Date),monthname(o.Order_Date),p.Category
order by Year,Monthnum;


create view Regional_Sales_Analysis as 
#14.What is the total revenue and profit by region and country?
select o.Region,c.Country,round(sum(o.Revenue),0) as TotalRevenue,round(sum(o.Profit),0) as TotalProfit
from orders as o 
join customers as c on o.Customer_ID = c.Customer_ID
group by o.Region,c.Country;

Create view Region_Rank as
#15.Which region achieved the highest average order value?
select Region,round(sum(Revenue)/nullif(count(Order_ID),0),2) as AOV
from orders 
group by Region
order by AOV desc
limit 1;


Create view Top3_Countries as
#16.Identify the top 3 countries contributing the most to total revenue.
select c.Country,round(sum( o.Revenue),0) as TotalRevenue
from customers as c
join orders as o on c.Customer_ID = o.Customer_ID
group by c.Country
order by TotalRevenue desc
limit 3;

create view Profitability_Ratio as 
#17.Compare the profitability ratio (Profit/Revenue) among all regions.

select Region, round(sum(Profit)/nullif(sum(Revenue),0),2) as ProfitabilityRatio
from orders
group by Region;


Create view Region_Contribution as
#18.Find the region-month combinations where profit dropped below zero.
select Region,year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month,sum(Profit) as MonthlyProfits
from orders
group by Region,year(Order_Date),month(Order_Date),monthname(Order_Date)
having sum(Profit) < 0;

Create view Avg_profit_Per_order as
#19.Calculate the average profit per order for each region and category.
WITH OrderLevelProfit AS (
    SELECT
        o.Region,
        p.Category,
        o.Order_ID,
        SUM(o.Profit) AS Order_Profit
    FROM orders o
    JOIN products p
        ON o.Product_ID = p.Product_ID
    GROUP BY
        o.Region,
        p.Category,
        o.Order_ID
)
SELECT
    Region,
    Category,
    ROUND(AVG(Order_Profit), 2) AS Avg_Profit_per_Order
FROM OrderLevelProfit
GROUP BY
    Region,
    Category
ORDER BY
    Region,
    Category;


create view unique_Customers as 
#20.How many unique customers placed orders each year?
SELECT
    YEAR(o.Order_Date) AS Year,
    COUNT(DISTINCT o.Customer_ID) AS Unique_Customers
FROM orders o
GROUP BY
    YEAR(o.Order_Date)
ORDER BY
    Year;


Create view Gender_Revenue_Contribution as
#21.Find the average revenue and profit per customer segmented by gender.
WITH CustomerLevel AS (
    SELECT
        c.Gender,
        c.Customer_ID,
        SUM(o.Revenue) AS Customer_Revenue,
        SUM(o.Profit) AS Customer_Profit
    FROM customers c
    JOIN orders o ON c.Customer_ID = o.Customer_ID
    GROUP BY c.Gender, c.Customer_ID
)
SELECT
    Gender,
    ROUND(AVG(Customer_Revenue), 0) AS Avg_Revenue_per_Customer,
    ROUND(AVG(Customer_Profit), 0) AS Avg_Profit_per_Customer
FROM CustomerLevel
GROUP BY Gender;

Create view Repeat_purchases as
#23.Identify customers who made repeat purchases across multiple years.
 WITH MultiYearCustomers AS (
    SELECT 
        Customer_ID,
        COUNT(DISTINCT YEAR(Order_Date)) AS Years_Active
    FROM orders
    GROUP BY Customer_ID
    HAVING Years_Active > 1
)
SELECT 
    YEAR(o.Order_Date) AS Year,
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Orders
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
JOIN MultiYearCustomers m ON c.Customer_ID = m.Customer_ID
GROUP BY YEAR(o.Order_Date), c.Customer_ID, c.Customer_Name
ORDER BY c.Customer_Name, Year;





create view Customer_LTV as 

#24.Determine the customer with the highest lifetime value (LTV).

SELECT 
    c.Customer_ID,
    c.Customer_Name,
    ROUND(SUM(o.Revenue), 0) AS Lifetime_Revenue,
    ROUND(SUM(o.Profit), 0) AS Lifetime_Profit
FROM customers c
JOIN orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Lifetime_Revenue DESC
LIMIT 1;


create view New_Customer_Acquistion as 

#25.Identify the month with maximum new customer acquisition.
WITH FirstOrder AS (
    SELECT
        Customer_ID,
        MIN(Order_Date) AS First_Order_Date
    FROM orders
    GROUP BY Customer_ID
)
SELECT
    YEAR(First_Order_Date) AS Year,
    MONTH(First_Order_Date) AS MonthNum,
    MONTHNAME(First_Order_Date) AS Month,
    COUNT(Customer_ID) AS New_Customers
FROM FirstOrder
GROUP BY
    YEAR(First_Order_Date),
    MONTH(First_Order_Date),
    MONTHNAME(First_Order_Date)
ORDER BY New_Customers DESC
LIMIT 1;





create view Gender_Profit as 
#26.Find the most profitable customer segment (based on gender).	

select c.Gender,round(sum(o.Profit),0) as Total_Profit
from customers as c 
join orders as o on c.Customer_ID = o.Customer_ID
group by c.Gender;



create view Payment_Mode_Analysis as 
#27.What is the total number of orders and total revenue by payment mode?
select Payment_Mode,count(distinct Order_ID) as Total_Orders,round(sum(Revenue),0) as Total_Revenue
from orders
group by Payment_Mode
order by Total_Revenue desc;

create view Payment_Mode_Contribution as 
#28.Which payment mode contributes the most to profit?

select Payment_Mode,round(sum(Profit),0) as Total_Profit
from orders 
group by Payment_Mode
order by Total_Profit desc;

create view Payment_Mode_Avg as 
#29.Calculate the average order amount by payment mode and year.
select year(Order_Date) as Year,Payment_Mode,round(SUM(Revenue) / COUNT(DISTINCT Order_ID),0) as Avg_Order_Amt
from orders 
group by year(Order_Date),Payment_Mode
order by Year;





create view Payment_Mode_usage as 
#31.Compare payment mode usage across regions.

select Region,Payment_Mode,count(*) as No_Of_Occurances
from orders
group by Region,Payment_Mode
order by Region desc;

create view  Target_Vs_Revenue as 
#32.Compare actual revenue vs. target revenue for each month.

select year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month,round(sum(Revenue),0) as Actual_Revenue,round(sum(Target_Revenue),0) as Target_Rev,round(sum(Revenue) - sum(Target_Revenue),0) as Actual_Difference
from orders 
group by year(Order_Date) ,month(Order_Date) ,monthname(Order_Date) 
order by  Year,Monthnum ;

create view Product_Performance as 
#33.Find top-performing products or regions that exceeded their targets.
SELECT
    o.Region,
    p.Product_Name,
    ROUND(SUM(o.Revenue), 0) AS Actual_Revenue,
    ROUND(SUM(o.Target_Revenue), 0) AS Target_Revenue,
    ROUND(SUM(o.Revenue) - SUM(o.Target_Revenue), 0) AS Revenue_Difference
FROM orders o
JOIN products p 
    ON o.Product_ID = p.Product_ID
GROUP BY
    o.Region,
    p.Product_Name
HAVING
    SUM(o.Revenue) > SUM(o.Target_Revenue)
ORDER BY
    Revenue_Difference DESC;



create view Revenue_Target_Analysis as 
#34.What is the total actual revenue and target revenue for each month and year?

select year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month,round(sum(Revenue),0) as Actual_Revenue,round(sum(Target_Revenue),0) as Target_Rev
from orders
group by year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
order by Year,Monthnum;


create view low_Target_Revenue as 
#35.Which months and years exceeded or fell short of their target revenue?
SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS MonthNum,
    MONTHNAME(Order_Date) AS Month,
    ROUND(SUM(Revenue), 0) AS Actual_Revenue,
    ROUND(SUM(Target_Revenue), 0) AS Target_Revenue,
    ROUND(SUM(Revenue) - SUM(Target_Revenue), 0) AS Revenue_Difference,
    CASE
        WHEN SUM(Revenue) > SUM(Target_Revenue) THEN 'Exceeded Target'
        WHEN SUM(Revenue) < SUM(Target_Revenue) THEN 'Fell Short'
        ELSE 'Met Target'
    END AS Target_Status
FROM orders
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date)
ORDER BY
    Year,
    MonthNum;

create view Monthly_Percent_Target_Achieved as 
#36.What is the percentage of target achieved for each month?
select year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month,round(sum(Revenue) * 100 / nullif(sum(Target_Revenue),0),0) as Percentage_Achieved
from orders 
group by year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
order by Year,Monthnum;



create view Monthly_Achievement_Rate as 
#37.Identify the months with the highest and lowest achievement rate.
WITH MonthlyAchievement AS (
    SELECT
        YEAR(Order_Date) AS Year,
        MONTH(Order_Date) AS MonthNum,
        MONTHNAME(Order_Date) AS Month,
        ROUND((SUM(Revenue) * 100.0 / NULLIF(SUM(Target_Revenue),0)),2) AS Achievement_Percent
    FROM orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date), MONTHNAME(Order_Date)
),
Ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY Year ORDER BY Achievement_Percent DESC) AS High_Rank,
        RANK() OVER (PARTITION BY Year ORDER BY Achievement_Percent ASC) AS Low_Rank
    FROM MonthlyAchievement
)
SELECT
    Year,
    MAX(CASE WHEN High_Rank = 1 THEN Month END) AS Highest_Achievement_Month,
    MAX(CASE WHEN High_Rank = 1 THEN Achievement_Percent END) AS Highest_Achievement_Percent,
    MAX(CASE WHEN Low_Rank = 1 THEN Month END) AS Lowest_Achievement_Month,
    MAX(CASE WHEN Low_Rank = 1 THEN Achievement_Percent END) AS Lowest_Achievement_Percent
FROM Ranked
GROUP BY Year
ORDER BY Year;



create view Yoy_improvement as 
#38.Compare year-over-year improvement in target achievement percentage.
with Yearly_Achievement as 
(select year(Order_Date) as Year,round(sum(Revenue) * 100/ nullif(sum(Target_Revenue),0),2) as Achievement_Percentage
from orders
group by year(Order_Date)
order by Year)
select Year,Achievement_Percentage,lag(Achievement_Percentage) over (order by Year) as Previous_Year_percentage,concat(round(Achievement_Percentage - lag(Achievement_Percentage) over (Order by Year),0),'%') as Yoy_Growth
from Yearly_Achievement;


create View Profit_Target_Analysis as 
#39.What is the total actual profit and target profit for each category and region?
select o.Region,p.Category,sum(o.Profit) as Total_Profit,sum(o.Target_Profit) as Target_Prof,(sum(o.Profit) - sum(o.Target_Profit)) as Actual_Profit
from orders as o 
join products as p on o.Product_ID = p.Product_ID
group by o.Region,p.Category;


create view Category_Performance_Analysis as 
#40.Which categories or regions outperformed or underperformed relative to profit targets?
WITH CategoryProfit AS (
    SELECT
        o.Region,p.Category,
        ROUND(SUM(o.Profit),2) AS Actual_Profit,
        ROUND(SUM(o.Target_Profit),2) AS Target_Profit,
        ROUND((SUM(o.Profit) * 100.0 / NULLIF(SUM(o.Target_Profit),0)),2) AS Achievement_Percent
    FROM orders o
    JOIN products p ON o.Product_ID = p.Product_ID
    GROUP BY o.Region,p.Category
)
SELECT Region,
    Category,
    Actual_Profit,
    Target_Profit,
    Achievement_Percent,
    CASE
        WHEN Actual_Profit > Target_Profit THEN 'Exceeded Target'
        WHEN Actual_Profit = Target_Profit THEN 'Met Target'
        ELSE 'Underperformed'
    END AS Performance_Status
FROM CategoryProfit
ORDER BY Region,Category,Achievement_Percent DESC;


create view regionwise_profit_achievement as 
#41.What is the average profit achievement % across all regions and months?
select Region,year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month, concat(round(sum(Profit) * 100/nullif(sum(Target_Profit),0),0),'%') as Avg_Profit_Achievement
from orders
group by Region,year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
order by Region,Year,Monthnum;

create view Top3_Cat_achievement_Rate as 
#42.Identify the top 3 performing categories based on target achievement rate.
select p.Category,round(sum(o.Revenue)/nullif(sum(o.Target_Revenue),0),2) as Revenue_Achievement_Rate,round(sum(o.Profit)/nullif(sum(o.Target_Profit),0),2) as Profit_Achievement_Rate
from orders as o 
join products as p on o.Product_ID = p.Product_ID
group by p.Category
order by Revenue_Achievement_Rate,Profit_Achievement_Rate desc
limit 3;

create view Low_Performing_Region as 
#43.Highlight the lowest-performing region or month based on profit gap.
select Region,year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month,round(sum(Target_Profit) - sum(Profit),0) as Profit_gap
from orders
group by Region,year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
having Profit_gap >  0
order by Profit_gap;
          
create view Target_Summary as 
#44.What is the overall revenue and profit target achievement % at the company level?
select concat(round(sum(Revenue)*100/nullif(sum(Target_Revenue),0),2),'%') as Revenue_Achievement_Percent,concat(round(sum(Profit)*100/nullif(sum(Target_Profit),0),2),'%') as Profit_Achievement_Percent
from orders;

create view Target_Status as 
#45.How many months or categories met, exceeded, or missed their targets?
select p.Category,year(o.Order_Date) as Year,month(o.Order_Date) as Monthnum,monthname(o.Order_Date) as Month,sum(o.Profit) as Actual_Profit,sum(o.Target_Profit) as Target_Profit,
(case when sum(o.Profit) > sum(o.Target_Profit) then 'Exceeded' 
when sum(o.Profit) <  sum(o.Target_Profit) then 'Missed'
else 'Met' end) as Target_Status
from orders as o 
join products as p on o.Product_ID = p.Product_ID
group by p.Category,year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
order by Year,Monthnum;

create view Target_Achievement as 
#46.Which year achieved the highest percentage of overall targets met?
select year(Order_Date) as Year, round((sum(Profit) *100)/nullif(sum(Target_Profit),0),2) as Target_met_Percentage
from orders
group by year(Order_Date)
order by Target_met_Percentage desc;

create view Avg_Target_Achievement as 
#47.What is the average achievement % across all months and years?
select year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month, round(avg(Profit)*100/nullif(avg(Target_Profit),0),2) as Percentage_Achieved
from orders
group by year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
order by Year,Monthnum;

create view Top_performing_month as 
#48.Identify the top-performing month where both revenue and profit targets were achieved.
select year(Order_Date) as Year,month(Order_Date) as Monthnum,monthname(Order_Date) as Month,round(sum(Revenue),2) as Actual_Revenue ,round(sum(Target_Revenue),2) as Target_Revenue,round(sum(Profit),2) as Actual_Profit ,round(sum(Target_Profit),2) as Target_Profit
from orders
group by year(Order_Date) ,month(Order_Date) ,monthname(Order_Date)
having sum(Revenue) >= sum(Target_Revenue) and sum(Profit) >= sum(Target_Profit)
order by Year,Monthnum;

Create view profitability_dashboard as 
select round(sum(Profit),0) as Total_profit,round(sum(Revenue),0)as Total_Revenue, round(sum(Profit) *100/nullif(sum(Revenue),0),2) as Profit_Margin,count(Order_ID) as Total_Orders, round(sum(Revenue)/nullif(count(Order_ID),0),2 )as Average_Order_Value
from orders ;
