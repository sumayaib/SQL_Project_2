# SQL_Project_2
# Sales Transaction Analysis Using PostgreSQL

► This project contains SQL queries to analyze sales transactions and customer information data. Each query addresses a specific business question.

► As a Data Analyst, I have analysed the sales transactions and customer information dataset using PostgreSQL.

# Objective Of The Project

* Understand customers behaviour by identifying loyal customers and inactive users
* Gain geographic market insights
* Enhance operational efficiency
* Optimize sales and revenue


# SQL Queries
## 1. Total transactions per city  
* The objective is to find the number of transactions made in each city.  
* SQL Query
``` sql
select city,count(transaction_id) as total_number_of_transaction
from data_project_phase2.sales_transactions st
join data_project_phase2.customer_info ci 
on ci.customer_id = st.customer_id 
group by ci.city 
order by total_number_of_transaction;
```
➤ Explanation

♦ Combines customer location data with transaction records using a JOIN

♦ Uses COUNT() to tally transactions per city

## 2. Top 5 most purchased products
* The objective is to identify products with highest total quantity sold.
* SQL Query:
```sql
select product_name, sum(quantity) as total_quantity_sold
from sales_transactions
group by product_name 
order by total_quantity_sold desc
limit 5;
```
➤ Explanation

♦ Aggregates sales quantities with SUM(quantity)

♦ Orders results in a descending order with ORDER BY 

## 3. Average transaction amount per category
* The objective is to calculate average transaction value per product category.
* SQL Query:
```sql
select category, AVG(total_amount):: numeric (20,2) as average_transaction_amount
from sales_transactions
group by category
order by average_transaction_amount desc;
```
➤ Explanation

♦ Calculates monetary averages with AVG(total_amount)

♦ Formats numbers to 2 decimals using ::NUMERIC(20,2)

## 4. Payment method with highest sales
* The objective is to find the payment method with the highest sales.
* SQL Query:
```sql
select payment_method, SUM(total_amount) as total_sales
from sales_transactions
group by payment_method 
order by total_sales desc
limit 1;
```
➤ Explanation

♦ Sums total_amount per payment method.

♦ Returns the method with the highest total sales.

## 5. Customers with more than 5 transactions
* The objective is to find customers with more than 5 transactions.
* SQL Query:
```sql
select first_name,last_name,count(transaction_id) as transaction_count
from sales_transactions st
join customer_info ci 
on ci.customer_id = st.customer_id
group by first_name,last_name
having count(transaction_id) >= 5;
```
➤ Explanation

♦ Uses HAVING clause to filter customers after grouping by name.

## 6. Last 6 months inactive registered customers
* The objective is to identify customers registered in the last 6 months with no transactions.
* SQL Query:
```sql
select first_name,last_name,transaction_id
from sales_transactions st 
left join customer_info ci 
using (customer_id)
where registration_date >= current_date - interval '6'
and transaction_id is null;
```
➤ Explanation

♦ LEFT JOIN ensures all registrants are included.

♦ (transaction_id IS NULL) filters out those with no transactions.

## 7. Yearly revenue from sales
* The objective is to calculate yearly revenue from sales.
* SQL Query:
```sql
select sum(total_amount) as total_revenue,
	extract(year from transaction_date) as sales_year
from sales_transactions
group by sales_year
order by sales_year;
```
➤ Explanation

♦ Extracts the year from transaction_date with  the function EXTRACT(YEAR)

♦ Aggregates revenue by year using SUM(total_amount)

## 8. Unique products per category
* The objective is to count distinct products sold in each category.
* SQL Query:
```sql
select category, count(distinct product_name) as unique_product_sold
from sales_transactions 
group by category 
order by unique_product_sold desc;
```
➤ Explanation

♦ Uses COUNT(DISTINCT product_name) to avoid duplicate and retrieve unique product counts

## 9. Customers who bought from 3 or more categories
* The Objective is to find customers who bought from 3 or more categories.
* SQL Query:
```sql
select customer_id, first_name, COUNT(distinct category) as category_count
from customer_info  ci
join sales_transactions  st
using (customer_id)
group by customer_id
having COUNT(distinct(st.category))>=3
order by category_count DESC;
```
➤ Explanation

♦ Combines customer location data with transaction records using a JOIN

♦ HAVING filters customers with purchases in 3 or more categories

## 10. Most popular purchase day
* The objective is to identify the day of the week with the most transactions.
* SQL Query:
```sql
select count(transaction_id) as transaction_count,
	   to_char(transaction_date,'day') as day_of_the_week
from sales_transactions st 
group by to_char(transaction_date,'day') 
order by transaction_count desc
limit 1;
```
➤ Explanation

♦TO_CHAR(..., 'Day') function converts dates to weekday names 

## 11. Top 3 customers by spending the last 12 months
* The objective is to identify top spenders in the last 12 months.
* SQL Query:
```sql
select customer_id,first_name,last_name,city,
	sum(total_amount) as total_spending
from customer_info
join sales_transactions
using(customer_id)
where transaction_date <= current_date - interval '12'
group by customer_id,first_name,last_name
order by total_spending desc
limit 3;
```
➤ Explanation

♦ The function (INTERVAL '12 months') filters transactions from the last 12 months

## 12. Percentage of total revenue contribution by category
* The objective is to calculate the percentage of total revenue contributed by each product category.
*SQL Query:
```sql
select category,
      sum(total_amount) as categoty_revenue,
      Round(SUM(total_amount) * 100.0 / (SELECT SUM(total_amount) from sales_transactions),2) as revenue_percentage
from sales_transactions
group by category
order by revenue_percentage desc;
```
➤ Explanation

♦ Introduced a subquery (SELECT SUM(total_amount) FROM sales_transactions) to calculate the total revenue across all categories.
♦ A point to note that the multiplication by 100.0 (instead of 100) ensures floating-point division, avoiding integer truncation.

## 13. First Purchase Date for Each Customer
* The objective is todentify the earliest transaction date for every customer.
* SQL Query:
```
select first_name,last_name, MIN(transaction_date) as first_purchase_date
from sales_transactions st
join customer_info ci 
using (customer_id)
group by first_name,last_name
order by first_purchase_date ASC;
```
➤ Explanation

♦ MIN(transaction_date) function returns the earliest transaction date for each customer.


# Key Insights

1. Sales Trends Are Seasonal & Predictable

* Transaction peaks on specific days like on Tuesdays and consistent month-over-month growth patterns suggest opportunities to align marketing and inventory with demand cycles.

2. Customer Loyalty Drives Revenue

* A small scale of high value customers contributes disproportionately to sales. Retaining and rewarding these customers is critical for sustained growth.

3. Product & Category Optimization Matters

* Top selling products and high revenue categories reveal consumer preferences, while low-performing categories highlight opportunities for diversification or marketing promotions.


# Recommendations for stakeholders
1. Focus on high-revenue categories , popular products and preferred payment methods to streamline operations and maximize profitability.

2. Monitor annual revenue  and month-over-month growth to validate business strategies and adapt to market shifts.

3. Identify high value customers and inactive customers to drive loyalty programs and re-engagement campaigns.








































