create database Pizza;
use pizza;
show tables;

select *from pizzas;
select *from pizza_types;
select *from orders;
select *from order_details;

describe pizzas;
describe pizza_types;
describe orders;
describe order_details;

#	Basic:

# Q1 : Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_numbers_order
FROM
    orders;

#	Q2 : Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS Total_revenue
FROM
    pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id;

#	Q3 : Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzas AS p
        INNER JOIN	
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

#	Q3 : Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

#	Q5 : List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(quantity) AS most_ordered_pizza
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY most_ordered_pizza DESC
LIMIT 5;

#	Intermediate:

#	Q1 : Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS Total_quantity
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

#	Q2 : Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) AS Hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);


#	Q3 : Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS No_Pizza_in_category
FROM
    pizza_types
GROUP BY category;


#	Q4 : Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Avg_Pizzas_ordered_per_day), 0) AS Avg_perday
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS Avg_Pizzas_ordered_per_day
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.date) AS order_quantity;


#	Q5 : Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(p.price * od.quantity) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


#	Advanced:
#	Q1 : Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND((SUM(p.price * od.quantity) / (SELECT 
                    SUM(p.price * od.quantity)
                FROM
                    pizzas AS p
                        INNER JOIN
                    order_details AS od ON p.pizza_id = od.pizza_id)) * 100,
            2) AS Percentage_Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

#	Q2 : Analyze the cumulative revenue generated over time.

select date,
sum(revenue) over(order by date) as cumulative_revenue
from
(select o.date, 
round(sum(od.quantity * p.price),0) as revenue 
from orders as o
join order_details as od
on o.order_id = od.order_id
join pizzas as p 
on p.pizza_id = od.pizza_id
group by o.date) as sales;


#	Q3 : Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from 
(select category, name, revenue,
rank()
over (partition by category order by revenue desc) as rn
from
(select pt.category, pt.name, 
sum(od.quantity * p.price) as revenue
from pizzas as p
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.category, pt.name) as a)as b
where rn <=3 ;


#	Aggregate Functions:
# Write a SQL query to calculate the total revenue generated from pizza orders in months wise.

SELECT 
    MONTH(o.date) AS Months,
    SUM(p.price * od.quantity) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        JOIN
    orders AS o ON o.order_id = od.order_id
GROUP BY months;


#	Conditional Aggregation:
#	Write a SQL query to find the average price of pizzas for each category, excluding pizzas with a price greater than $20.

SELECT 
    pt.category, ROUND(AVG(p.price), 2) AS avg_price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
WHERE
    p.price <= 20
GROUP BY pt.category;


#	Write a SQL query to update the prices of all pizzas in a specific category by increasing them by 10%, rounding to the nearest dollar.

UPDATE pizzas AS p 
SET 
    p.price = ROUND(p.price * 1.10, 2)
WHERE
    pizza_type_id IN (SELECT 
            category
        FROM
            pizza_types
        WHERE
            category = 'classic');




