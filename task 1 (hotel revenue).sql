use project1

create view hotel_revn as
select *
from dbo.['2018']
union select *
from dbo.['2019']
union 
select * 
from dbo.['2020']

select * 
from hotel_revn

-- Q1: What is the total number of nights stayed by guests?
SELECT stays_in_weekend_nights + stays_in_week_nights
FROM hotel_revn

-- Renames the result as 'TotalStays' using the 'AS' keyword for better clarity.
SELECT stays_in_weekend_nights + stays_in_week_nights AS TotalStays
FROM hotel_revn

--Q2: How much revenue did each stay generate?
SELECT(stays_in_weekend_nights + stays_in_week_nights)*adr AS Revenue
FROM hotel_revn

--Q3: What was the yearly total revenue from both weekend and weekday stays?
SELECT arrival_date_year,arrival_date_month,
(stays_in_weekend_nights + stays_in_week_nights)*adr AS Revenue
FROM hotel_revn

--Q5: What is the total revenue generated for all stays in the data(years--> 2018, 2019, and 2020)?
SELECT SUM((stays_in_weekend_nights + stays_in_week_nights)*adr) AS Revenue
FROM hotel_revn

--Round the total revenue to the nearest integer for easier reporting
SELECT ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr),0) AS Revenue
FROM hotel_revn

--Q6: What was the total revenue per year?
SELECT arrival_date_year,
ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr),0) AS Revenue -- rounded to the nearest integer
FROM hotel_revn
GROUP BY arrival_date_year

-- Total Revenue per year, broken down by hotel type
SELECT arrival_date_year,hotel,
ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr),0) AS Revenue
FROM hotel_revn
GROUP BY arrival_date_year,hotel

-- Adding meal cost and market segment information using JOIN
SELECT *
FROM hotel_revn 
LEFT JOIN dbo.meal_cost
ON hotel_revn.meal = dbo.meal_cost.meal
LEFT JOIN dbo.market_segment
ON hotel_revn.market_segment = dbo.market_segment.market_segment

-- Answer the following with queries, and create 5 additional questions of your own, answering them with queries as well.

-- Q1: What is the profit percentage for each month across all years?
select arrival_date_year,arrival_date_month,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn
group by arrival_date_year,arrival_date_month
order by arrival_date_year asc


-- Q2: Which meals and market segments (e.g., families, corporate clients, etc.) contribute the most to the total revenue for each hotel annually?
select top(10)arrival_date_year,hotel,mc.meal,ms.market_segment,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn as h
join meal_cost as mc
on mc.meal=h.meal
join market_segment as ms
on ms.market_segment=h.market_segment
group by arrival_date_year,hotel,mc.meal,ms.market_segment
order by total_revenue desc


-- Q3: How does revenue compare between public holidays and regular days each year?
select arrival_date_year,round(sum(stays_in_week_nights*adr),1) as revenue_in_regular_days,round(sum(stays_in_weekend_nights*adr),1) as revenue_in_public_holidays
from hotel_revn
group by arrival_date_year


-- Q4: What are the key factors (e.g., hotel type, market type, meals offered, number of nights booked) significantly impact hotel revenue annually?
select hotel,market_segment,meal,sum(stays_in_week_nights+stays_in_weekend_nights) as number_of_nights_booked,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn
group by hotel,market_segment,meal
order by total_revenue desc

-- Q5: Based on stay data, what are the yearly trends in customer preferences for room types (e.g., family rooms vs. single rooms), and how do these preferences influence revenue?
select arrival_date_year,assigned_room_type,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn
where assigned_room_type=reserved_room_type
group by arrival_date_year,assigned_room_type
order by total_revenue desc


--Q6: How many canceled visits for each year?
select arrival_date_year,COUNT(case when is_canceled=0 then 1 end) as not_canceled_visits,count(case when is_canceled=1 then 1 end) as canceled_visits
from hotel_revn
group by arrival_date_year

--Q7: what is the most popular hotel in each year
select arrival_date_year,hotel,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue,sum((stays_in_week_nights+stays_in_weekend_nights)) as total_nights_booked
from hotel_revn
group by hotel ,arrival_date_year

--Q8: what is the country with a large number of visitors?
select arrival_date_year,country as country_code,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn
group by country,arrival_date_year
order by total_revenue desc

--Q9: what is the most popular meal and room type per each year?
select arrival_date_year,meal_cost.meal,assigned_room_type,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn
join meal_cost
on meal_cost.meal=hotel_revn.meal
group by meal_cost.meal,assigned_room_type,arrival_date_year
order by total_revenue desc

--without years
select meal_cost.meal,assigned_room_type,round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),1) as total_revenue
from hotel_revn
join meal_cost
on meal_cost.meal=hotel_revn.meal
group by meal_cost.meal,assigned_room_type
order by total_revenue desc

--Q10: checking customer commitment
select COUNT(case when is_repeated_guest=0 then 1 end) as new_visitors,count(case when is_repeated_guest=1 then 1 end) as old_visitors
from hotel_revn

--Q11: what is the most popular customer type (group or transient) arrived in the hotels?
select customer_type,count(customer_type) as total_visits
from hotel_revn
group by customer_type

--Q12: in all years, what is the month with the largest number of visitors?
select arrival_date_month,COUNT(case when is_canceled=0 then 1 end) as #Visitors
from hotel_revn
group by arrival_date_month
order by #Visitors desc