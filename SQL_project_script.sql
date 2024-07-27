CREATE DATABASE amazon;

USE amazon;

CREATE TABLE sales(
        invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
        branch VARCHAR(30) NOT NULL,
        city VARCHAR(30) NOT NULL,
        customer_type VARCHAR(30) NOT NULL,
        gender VARCHAR(10) NOT NULL,
        product_line VARCHAR(100) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        quantity INT NOT NULL,
        VAT FLOAT(6,4) NOT NULL,
        total DECIMAL(10,2) NOT NULL,
        date DATETIME NOT NULL,
        time TIME NOT NULL,
        payment_method VARCHAR(15) NOT NULL,
        cogs DECIMAL(10,2) NOT NULL,
        gross_margin_percentage FLOAT(11,9) NOT NULL,
        gross_income DECIMAL(10,2) NOT NULL,
        rating FLOAT(2,1)

);

SELECT * FROM sales;


# Product_line working best regarding sales: 
SELECT product_line, 
       sum(total) AS total_sales 
FROM sales
GROUP BY product_line
ORDER BY total_sales DESC ; 


# sales trends over time for each product line
SELECT product_line,
    YEAR(date) AS sales_year,
    MONTH(date) AS sales_month,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_units_sold,
    SUM(total) AS total_sales_amount
FROM 
    sales
GROUP BY 
    product_line, YEAR(date), MONTH(date)
ORDER BY 
   product_line, YEAR(date), MONTH(date);
 
 #total sales of each branch
select branch,city, sum(total)  as total_Sales 
from Sales 
group by branch, city
order by total_Sales desc;  


# count the number of transactions and total sales amount for each customer segment
SELECT 
    customer_type,
    gender,
    COUNT(*) AS total_transactions,
    SUM(total) AS total_sales_amount
FROM 
    Sales
GROUP BY 
    customer_type, gender
ORDER BY 
	total_sales_amount DESC;
    
   # Feature Engineering:
   
   -- TIME OF DATE 
   
   SELECT  time FROM Sales;
   
   SELECT time ,
   (CASE
       WHEN  TIME(time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
       WHEN  TIME(time) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
       ELSE "Evening"
  END ) AS time_of_day
FROM Sales;

ALTER TABLE Sales ADD COLUMN time_of_day VARCHAR(20);
   
UPDATE Sales SET time_of_day = (CASE
       WHEN  TIME(time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
       WHEN  TIME(time) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
       ELSE "Evening"
  END);

-- DAY NAME
 SELECT date, DAYNAME(date) FROM Sales;
 
 ALTER TABLE Sales ADD COLUMN day_name VARCHAR(10);

UPDATE Sales SET day_name = DAYNAME(date) ;

-- MONTH NAME 
SELECT date, MONTHNAME(date) FROM Sales;
 
 ALTER TABLE Sales ADD COLUMN month_name VARCHAR(10);

UPDATE Sales SET month_name = MONTHNAME(date) ;

    
    # EDA: 

    #1. What is the count of distinct cities in the dataset?
    
     SELECT  count(DISTINCT city) FROM Sales;

    #2.For each branch, what is the corresponding city?
    
    SELECT branch,city FROM Sales 
    GROUP BY branch, city
    ORDER BY branch;

    #3. What is the count of distinct product lines in the dataset
    
    SELECT COUNT(DISTINCT(product_line)) as Prod_Lines FROM Sales; 
    
    #4. Which payment method occurs most frequently?
    
    SELECT payment_method , count(*) as count_payment_method FROM Sales 
    GROUP BY payment_method 
    ORDER BY count_payment_method DESC
    LIMIT 1 ;

# 5. Which product line has the highest sales?
   SELECT product_line, sum(quantity) AS total_sales FROM sales
   GROUP BY product_line
   ORDER BY total_sales DESC ; 
   
   #6. How much revenue is generated each month?

    SELECT YEAR(date) AS sales_year,
	month_name AS sales_month,
	SUM(total) AS revenue
	FROM Sales
    GROUP BY YEAR(date), month_name
    ORDER BY  month_name ;
    
    #7. In which month did the cost of goods sold reach its peak?
    
	SELECT month_name,sum(cogs) AS cogs  FROM Sales
    GROUP BY month_name
    ORDER BY cogs DESC
	LIMIT 1;

  #8. Which product line generated the highest revenue?
   
   SELECT product_line, sum(total) as total_sales 
   FROM Sales 
   GROUP BY product_line 
   ORDER BY total_sales DESC
   LIMIT 1;
  
  # 9. In which city was the highest revenue recorded?
  
  SELECT city, sum(total) as revenue FROM Sales
  GROUP BY city 
  ORDER BY revenue desc
  LIMIT 1;

# 10. Which product line incurred the highest Value Added Tax?

SELECT product_line, SUM(VAT) AS VAT FROM Sales
GROUP BY product_line 
ORDER BY VAT DESC
LIMIT 1;
 
# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

select round(avg(quantity),2) as avg_quantity from Sales;

SELECT product_line,
CASE 
	WHEN  sum(quantity) > 5.50  THEN "Good"
    ELSE "Bad"
END AS status_of_sales
FROM Sales
GROUP BY product_line;

# 12. Identintfy the branch that exceeded the average number of products sold.

SELECT branch FROM sales
GROUP BY branch
HAVING SUM(quantity) > 
(SELECT AVG(total_quantity) FROM (SELECT SUM(quantity) AS total_quantity FROM sales GROUP BY branch) AS branch_total_avg);



# 13. Which product line is most frequently associated with each gender?



SELECT product_line, gender, frequency FROM (
 SELECT product_line, gender, COUNT(*) AS frequency,
	RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rank_ FROM Sales
    GROUP BY product_line, gender) as ranked
    WHERE rank_ = 1;


# 14. Calculate the average rating for each product line.

SELECT product_line, AVG(rating) AS avg_rating
FROM sales
GROUP BY product_line;


# 15. Count the sales occurrences for each time of day on every weekday.

SELECT day_name ,time_of_day,COUNT(*) AS sales_occurrences FROM sales
GROUP BY day_name,time_of_day
ORDER BY day_name, time_of_day ;


# 16. Identify the customer type contributing the highest revenue.

SELECT  customer_type, SUM(unit_price * quantity) AS Revenue FROM Sales
GROUP BY customer_type
ORDER BY revenue DESC;


# 17. Determine the city with the highest VAT percentage.

SELECT city, sum(VAT) AS VAT FROM Sales 
GROUP BY city
ORDER BY VAT desc
LIMIT 1;

#18. Identify the customer type with the highest VAT payments.

SELECT customer_type, SUM(VAT) AS VAT FROM Sales
GROUP BY customer_type
ORDER BY VAT DESC
LIMIT 1;


#19. What is the count of distinct customer types in the dataset?

SELECT count(DISTINCT(customer_type)) AS distinct_customers FROM Sales;

#20. What is the count of distinct payment methods in the dataset?

SELECT count(DISTINCT(payment_method)) AS distinct_payment_method 
FROM sales;

#21. Which customer type occurs most frequently?

SELECT customer_type , count(*) AS frequency FROM sales 
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;


#22. Identify the customer type with the highest purchase frequency.

SELECT customer_type, sum(quantity) AS purchase_frequency FROM Sales
GROUP BY customer_type
ORDER BY purchase_frequency DESC;

#23. Determine the predominant gender among customers.

SELECT gender, count(*) AS gender_count FROM Sales
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;


#24. Examine the distribution of genders within each branch.

SELECT branch, gender , count(*) AS count_of_distribution FROM sales
GROUP BY branch, gender
ORDER BY branch,gender;

#25. Identify the time of day when customers provide the most ratings.

SELECT hour(time) ,time_of_day, count(*) AS rating_count FROM Sales
WHERE rating IS NOT NULL
GROUP BY hour(time),time_of_day 
ORDER BY rating_count DESC
LIMIT 1;

#26. Determine the time of day with the highest customer ratings for each branch.

SELECT time_of_day, branch, COUNT(rating) AS frequency FROM Sales 
GROUP BY branch,time_of_day
ORDER BY frequency DESC;



# 27.Identify the day of the week with the highest average ratings.

SELECT day_name , avg(rating) as avg_rating FROM Sales 
GROUP BY day_name
ORDER BY avg(rating) desc;

# 28.Determine the day of the week with the highest average ratings for each branch.

SELECT day_name, avg(rating) as avg_rating, branch FROM Sales 
GROUP BY branch,day_name
ORDER BY avg(rating) desc;




