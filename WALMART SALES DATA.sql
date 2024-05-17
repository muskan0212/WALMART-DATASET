CREATE DATABASE WALMART_SALES_DATA;
USE WALMART_SALES_DATA;

CREATE TABLE IF NOT EXISTS WALMARTSALES (
INVOICE_ID VARCHAR(20),
BRANCH VARCHAR(5),
CITY VARCHAR(20),
CUSTOMER_TYPE VARCHAR(20),
GENDER VARCHAR(10),
PRODUCT_LINE VARCHAR(30),
UNIT_PRICE DECIMAL(5,2) ,
QUANTITY INT,
TAX_5_PERCENTAGE DECIMAL(7,4),
TOTAL DECIMAL(30,4) ,
`DATE` DATE,
`TIME` TIME ,
PAYMENT VARCHAR(20),
COGS DECIMAL(10,2),
GROSS_MARGIN_PERCENTAGE DECIMAL(30,9),
GROSS_INCOME DECIMAL(30,4),
RATING DECIMAL(5,2) );

LOAD DATA INFILE
'E:/WalmartSalesData.csv.csv'
into table WALMARTSALES
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from WALMARTSALES;
SET SQL_SAFE_UPDATES =0;

#1. UPDATE TIME INTO MORNING AND AFTERNOON 
ALTER TABLE walmartsales
ADD COLUMN TIME_STATEMENT VARCHAR(20) AFTER `TIME`;
UPDATE walmartsales SET TIME_STATEMENT = 
"MORNING" WHERE TIME < '12:00:00';
UPDATE walmartsales SET TIME_STATEMENT =
"AFTERNOON" WHERE TIME > '12:00:00';
ALTER TABLE walmartsales DROP COLUMN time_statement;
##OTHER METHOD


SELECT *,
CASE
WHEN `TIME` >= "00:00" AND `TIME` < "12:00" THEN "MORNING"
WHEN `TIME` > "12:00" THEN "AFTERNOON"
ELSE 0
END AS STATEMENT
FROM WALMARTSALES; 

#2. UPDATE DAYNAME AND MONTHNAME 
ALTER TABLE walmartsales
ADD column `DAYNAME` VARCHAR (20);
UPDATE walmartsales SET `DAYNAME` = DAYNAME(`DATE`);

ALTER TABLE walmartsales
ADD column `MONTHNAME` VARCHAR (20);
UPDATE walmartsales SET `MONTHNAME` = MONTHNAME(`DATE`);

#3. How many unique cities does the data have?
SELECT COUNT(distinct(CITY)) FROM WALMARTSALES;
SELECT distinct CITY FROM walmartsales; ##MA'AM

#4. In which city is each branch? -
SELECT distinct(branch), CITY from WALMARTSALES;

#5. How many unique product lines does the data have.
 
SELECT distinct(PRODUCT_LINE) 
FROM WALMARTSALES;
	
#6. What is the most selling product line. - 
SELECT PRODUCT_LINE, SUM(QUANTITY) AS SELLING FROM walmartsales GROUP BY PRODUCT_LINE DESC ;
SELECT SUM(quantity) as qty, product_line
FROM walmartsales
GROUP BY product_line
ORDER BY qty DESC; #MA'AM

#7. What is the total revenue by month 
SELECT `MONTHNAME`, SUM(TOTAL) AS REVENUE_BY_MONTH FROM walmartsales
GROUP BY `MONTHNAME`;

#8. What month had the largest COGS?
SELECT `MONTHNAME`, SUM(COGS) AS LARGEST_COGS_MONTH FROM walmartsales
GROUP BY `MONTHNAME` ORDER BY LARGEST_COGS_MONTH DESC LIMIT 1;

#9. What product line had the largest revenue? 
SELECT
	product_line,
	SUM(total) as total_revenue
FROM walmartsales
GROUP BY product_line
ORDER BY total_revenue DESC LIMIT 1; 

#10. What is the city with the largest revenue? - WRONG
SELECT CITY, max(TOTAL) AS REVENUE FROM walmartsales
group by city ORDER BY REVENUE DESC LIMIT 1;
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM walmartsales
GROUP BY city, branch 
ORDER BY total_revenue DESC LIMIT 1; #MA'AM

#11. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales. - WRONG

SELECT*,
CASE
WHEN QUANTITY > (SELECT AVG(QUANTITY) FROM WALMARTSALES) THEN "GOOD"
WHEN QUANTITY < (SELECT AVG(QUANTITY) FROM WALMARTSALES) THEN "BAD"
ELSE 0
END AS STATEMENT
FROM walmartsales;


SELECT
	product_line,
	CASE
		WHEN AVG(rating) > 7 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM walmartsales
GROUP BY product_line; 

#13. Which branch sold more products than average product sold? 
SELECT BRANCH, MAX(QUANTITY) AS PRODUCT FROM walmartsales GROUP BY BRANCH 
ORDER BY PRODUCT DESC LIMIT 1;
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM walmartsales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM walmartsales); #MA'AM

#14. What is the most common product line by gender?

 
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM walmartsales
GROUP BY gender, product_line
ORDER BY total_cnt DESC; 

#15. What is the average rating of each product line? 

SELECT
	ROUND(AVG(rating), 1) as avg_rating,
    product_line
FROM walmartsales
GROUP BY product_line
ORDER BY avg_rating DESC; 

#16. How many unique customer types does the data have? 
SELECT distinct(CUSTOMER_TYPE) FROM WALMARTSALES;

#17. How many unique payment methods does the data have? 
SELECT distinct(PAYMENT) FROM WALMARTSALES;

#18. What is the most common customer type?
SELECT COUNT(CUSTOMER_TYPE), CUSTOMER_TYPE FROM walmartsales
GROUP BY CUSTOMER_TYPE ORDER BY COUNT(CUSTOMER_TYPE) DESC LIMIT 1;

#19. What is the gender distribution per branch? 
SELECT BRANCH, COUNT(GENDER) AS GENDER_DISRIBUTION FROM walmartsales group by BRANCH; 

#20. Which time of the day do customers give most ratings.

SELECT
	`TIME`,
	AVG(rating) AS avg_rating
FROM walmartsales
GROUP BY `TIME`
ORDER BY avg_rating DESC; ##MA'AM
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter #MA'AM

#21. Which time of the day do customers give most ratings per branch? 
SELECT RATING,BRANCH,MAX(`TIME`)FROM walmartsales WHERE RATING = 10 GROUP BY BRANCH;
SELECT
	`time`,
	AVG(rating) AS avg_rating
FROM walmartsales
WHERE branch = "A"
GROUP BY `TIME`
ORDER BY avg_rating DESC; ##MA'AM
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings. #MA'AM

#22. Which day OF the week has the best avg ratings?
SELECT `DAYNAME`, AVG(RATING) AS BEST_AVG_RATING FROM walmartsales
GROUP BY `DAYNAME` ORDER BY BEST_AVG_RATING DESC limit 1;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days? #MA'AM


#23. Which day of the week has the best average ratings per branch? 
SELECT BRANCH,`DAYNAME`, AVG(RATING) AS BEST_AVG_RATING FROM walmartsales 
GROUP BY `DAYNAME`, BRANCH ORDER BY BEST_AVG_RATING DESC LIMIT 3;


SELECT
	`dayname`,
	AVG(rating) AS avg_rating
FROM walmartsales
GROUP BY `dayname` 
ORDER BY avg_rating DESC; #MA'AM
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days? #MA'AM

#24. Number of sales made in each time of the day per weekday.
SELECT
	`TIME`,
	COUNT(*) AS total_sales
FROM walmartsales
WHERE `DAYNAME` = "Sunday"
GROUP BY `TIME` 
ORDER BY total_sales DESC ; 
-- Evenings experience most sales, the stores are 
-- filled during the evening hours #MA'AM

#25. Which of the customer types brings the most revenue? 
SELECT CUSTOMER_TYPE, MAX(TOTAL) AS MOST_REVENUE FROM walmartsales 
GROUP BY CUSTOMER_TYPE ORDER BY MOST_REVENUE DESC LIMIT 1;
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM WALMARTsales
GROUP BY customer_type
ORDER BY total_revenue; #MA'AM

#26. Which city has the largest tax/VAT percent?
SELECT CITY, MAX(TAX_5_PERCENTAGE) AS LARGEST_TAX FROM walmartsales 
GROUP BY CITY ORDER BY LARGEST_TAX DESC LIMIT 1;



SELECT
	city,
    ROUND(AVG(tax_5_percentage), 2) AS avg_tax_pct
FROM walmartsales
GROUP BY city 
ORDER BY avg_tax_pct DESC; 


#27. Which customer type pays the most in VAT?
SELECT CUSTOMER_TYPE, MAX(TAX_5_PERCENTAGE) AS MOST_VAT FROM walmartsales
group by CUSTOMER_TYPE ORDER BY MOST_VAT DESC LIMIT 1;
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax; #MA'AM

