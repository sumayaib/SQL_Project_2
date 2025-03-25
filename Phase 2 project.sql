
-- 1.Find the total number of transactions per city.  

select city,count(transaction_id) as total_number_of_transaction
from sales_transactions st
join customer_info ci 
on ci.customer_id = st.customer_id 
group by ci.city 
order by total_number_of_transaction;

-- 2.Retrieve the top 5 most purchased products based on total quantity sold.  

select product_name, sum(quantity) as total_quantity_sold
from sales_transactions
group by product_name 
order by total_quantity_sold desc
limit 5;

-- 3.Find the average transaction amount per category. 

select category, AVG(total_amount):: numeric (20,2) as average_transaction_amount
from sales_transactions
group by category
order by average_transaction_amount desc;

-- 4.Identify the payment method that has the highest total sales.  

select payment_method, SUM(total_amount) as total_sales
from sales_transactions
group by payment_method 
order by total_sales desc
limit 1;

-- 5.Find customers who have made at least 5 transactions. 

select first_name,last_name,count(transaction_id) as transaction_count
from sales_transactions st
join customer_info ci 
on ci.customer_id = st.customer_id
group by first_name,last_name
having count(transaction_id) >= 5;


-- 6.Retrieve all customers who registered in the last 6 months but have not made any transactions.  

select first_name,last_name,transaction_id
from sales_transactions st 
left join customer_info ci 
using (customer_id)
where registration_date >= current_date - interval '6'
and transaction_id is null;


-- 7.Find the total revenue generated in each year from sales transactions. 

select sum(total_amount) as total_revenue,
	extract(year from transaction_date) as sales_year
from sales_transactions
group by sales_year
order by sales_year;

-- 8.List the number of unique products sold in each category.  

select category, count(distinct product_name) as unique_product_sold
from sales_transactions 
group by category 
order by unique_product_sold desc;

-- 9.Find all customers who have made purchases across at least 3 different product categories. 

select customer_id, first_name, COUNT(distinct category) as category_count
from customer_info  ci
join sales_transactions  st
using (customer_id)
group by customer_id
having COUNT(distinct(st.category))>=3
order by category_count DESC;


-- 10.Identify the most popular purchase day of the week based on transaction count. 

select count(transaction_id) as transaction_count,
	   to_char(transaction_date,'day') as day_of_the_week
from sales_transactions st 
group by to_char(transaction_date,'day') 
order by transaction_count desc
limit 1;


-- ## Advanced-Level Questions.

-- 11.Find the top 3 customers who have spent the most in the last 12 months. 

select customer_id,first_name,last_name,city,
	sum(total_amount) as total_spending
from customer_info
join sales_transactions
using(customer_id)
where transaction_date <= current_date - interval '12'
group by customer_id,first_name,last_name
order by total_spending desc
limit 3;

-- 12.Determine the percentage of total revenue contributed by each product category.  

select category,
      sum(total_amount) as categoty_revenue,
      Round(SUM(total_amount) * 100.0 / (SELECT SUM(total_amount) from sales_transactions),2) as revenue_percentage
from sales_transactions
group by category
order by revenue_percentage desc;

-- 13.Find the month-over-month sales growth for the last 12 months.  

WITH monthly_sales AS (
    SELECT 
        TO_CHAR(transaction_date, 'MM') AS sales_month, 
        SUM(total_amount) AS total_monthly_sales
    FROM sales_transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY sales_month
)
SELECT 
    sales_month,
    total_monthly_sales,
    total_monthly_sales - LAG(total_monthly_sales) OVER(ORDER BY sales_month) AS sales_difference,
    (total_monthly_sales - LAG(total_monthly_sales) OVER(ORDER BY sales_month)) / 
    NULLIF(LAG(total_monthly_sales) OVER(ORDER BY sales_month), 0) AS sales_growth_rate
FROM monthly_sales
ORDER BY sales_month;

--14.Identify customers who have increased their spending by at least 30% compared to the previous year.

WITH monthly_sales AS (
    SELECT 
        customer_id,
        to_char(transaction_date,'month') AS sales_month,
        SUM(total_amount) AS total_monthly_sales
    FROM sales_transactions
    GROUP BY customer_id, to_char(transaction_date,'month')
),
sales_growth AS (
    SELECT 
        customer_id,
        sales_month,
        total_monthly_sales,
        LAG(total_monthly_sales) OVER (PARTITION BY customer_id ORDER BY sales_month) AS previous_month_sales,
        CASE 
            WHEN LAG(total_monthly_sales) OVER (PARTITION BY customer_id ORDER BY sales_month) = 0 THEN NULL
            ELSE 
                (total_monthly_sales - LAG(total_monthly_sales) OVER (PARTITION BY customer_id ORDER BY sales_month)) 
                / LAG(total_monthly_sales) OVER (PARTITION BY customer_id ORDER BY sales_month)
        END AS sales_growth_rate
    FROM monthly_sales
)
SELECT 
    customer_id,
    sales_month,
    total_monthly_sales,
    previous_month_sales
FROM sales_growth
WHERE sales_growth_rate >= 0.3
ORDER BY customer_id, sales_month;


-- 15.Find the first purchase date for each customer.

select first_name,last_name, MIN(transaction_date) as first_purchase_date
from sales_transactions st
join customer_info ci 
using (customer_id)
group by first_name,last_name
order by first_purchase_date ASC;




