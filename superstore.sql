SELECT * FROM superstore_db.`sample - superstore`;
RENAME TABLE `sample - superstore` TO superstore;

-- DATA CLEANING --

SELECT COUNT(*) AS total_records FROM superstore;

-- CHECK NULL VALUES --

SELECT * FROM superstore
WHERE `Row ID` IS NULL
   OR `Order ID` IS NULL
   OR `Order Date` IS NULL
   OR `Ship Date` IS NULL
   OR `Customer Name` IS NULL
   OR Sales IS NULL
   OR Profit IS NULL;
   

SELECT `Row ID`,COUNT(*) AS duplicate_count
FROM superstore
GROUP BY `Row ID`
HAVING COUNT(*) > 1;

-- CHECK BLANK PRODUCT 
SELECT *FROM superstore
WHERE TRIM(`Product Name`) = '';

-- CHECK BlANK CUSTOMER
SELECT *FROM superstore
WHERE TRIM(`Customer Name`) = '';

-- CHECK INVALID CUSTOMER
SELECT *FROM superstore
WHERE Discount < 0 OR Discount > 1; 

-- CHECK CATEGORY 
SELECT DISTINCT Category FROM superstore;

-- CHECK DATE RANGE
SELECT MIN(`Order Date`) AS first_order, MAX(`Order Date`) AS last_order FROM superstore;


/* =========================================================
   📊 01. OVERALL BUSINESS PERFORMANCE

   Business Question:
   What are the overall sales, profit, orders,
   and quantity sold by the business?
   ========================================================= */

SELECT
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity
FROM superstore;



/* =========================================================
   02. CATEGORY PERFORMANCE
   ---------------------------------------------------------
   Business Question:
   Which product categories generate the highest
   sales and profit?
   ========================================================= */

SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Category
ORDER BY total_sales DESC;


/* =========================================================
   03. TOP-SELLING PRODUCTS
   ---------------------------------------------------------
   Business Question:
   Which are the top 10 products contributing
   the most to total sales?
   ========================================================= */

SELECT
    `Product Name`,
    ROUND(SUM(Sales), 2) AS total_sales
FROM superstore
GROUP BY `Product Name`
ORDER BY total_sales DESC
LIMIT 10;


/* =========================================================
   04. REGIONAL PERFORMANCE
   ---------------------------------------------------------
   Business Question:
   Which regions are performing the best and worst
   in terms of sales and profitability?
   ========================================================= */

SELECT
    Region,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC;


/* =========================================================
   05. MONTHLY SALES & PROFIT TREND
   ---------------------------------------------------------
   Business Question:
   How do sales and profit change across different months?
   ========================================================= */

SELECT
    MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS order_month,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))
ORDER BY order_month;


/* =========================================================
   06. CUSTOMER SEGMENT PERFORMANCE
   ---------------------------------------------------------
   Business Question:
   Which customer segments contribute the most
   to overall sales and profit?
   ========================================================= */

SELECT
    Segment,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Segment
ORDER BY total_sales DESC;



/* =========================================================
   07. LOSS-MAKING PRODUCTS
   ---------------------------------------------------------
   Business Question:
   Which products are generating losses for the business?
   ========================================================= */

SELECT
    `Product Name`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `Product Name`
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC;


/* =========================================================
   08. DISCOUNT & PROFITABILITY ANALYSIS
   ---------------------------------------------------------
   Business Question:
   How does the average discount affect profitability
   across categories?
   ========================================================= */

SELECT
    Category,
    ROUND(AVG(Discount) * 100, 2) AS average_discount_percent,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Category
ORDER BY total_profit DESC;

/* =========================================================
   09. HIGH VALUE CUSTOMERS
   ---------------------------------------------------------
   Business Question:
   Which customers have spent more than the average customer?
   ========================================================= */

WITH customer_sales AS (
    SELECT
        `Customer Name`,
        ROUND(SUM(Sales), 2) AS total_sales
    FROM superstore
    GROUP BY `Customer Name`
)

SELECT
    `Customer Name`,
    total_sales
FROM customer_sales
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM customer_sales
)
ORDER BY total_sales DESC;


/* =========================================================
   10. YEAR-OVER-YEAR SALES GROWTH
   ---------------------------------------------------------
   Business Question:
   Is the company's sales performance improving or declining
   compared with the previous year?
   ========================================================= */

WITH yearly_sales AS (
    SELECT
        YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS order_year,
        ROUND(SUM(Sales), 2) AS total_sales
    FROM superstore
    GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))
)

SELECT
    order_year,
    total_sales,
    LAG(total_sales) OVER (ORDER BY order_year) AS previous_year_sales,
    ROUND(
        total_sales - LAG(total_sales) OVER (ORDER BY order_year),
        2
    ) AS sales_change
FROM yearly_sales
ORDER BY order_year;

