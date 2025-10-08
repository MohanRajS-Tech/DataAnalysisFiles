--EDA of a supermarket data set

SELECT * FROM customer
--9 columns , 793 rows

SELECT * FROM product
--4 columns , 1862 rows

SELECT * FROM sales
--11 columns , 9994 rows


--Customer Demographics & Segmentation

SELECT segment,
    COUNT(DISTINCT "customer_id") AS total_customers,
    ROUND(AVG(age)) AS average_age,
    country,
    city,
    state,
    region
FROM Customer
GROUP BY segment, country, city, state, region
ORDER BY segment, total_customers DESC;


--Segment wise user count,sales,avg order value, quantity,profit

SELECT c.segment,
    COUNT(DISTINCT s."customer_id") AS unique_customers_in_segment,
    ROUND(SUM(s.sales)) AS total_sales,
    ROUND(AVG(s.sales)) AS average_order_value_per_item,
    SUM(s.quantity) AS total_quantity_ordered,
    ROUND(SUM(s.profit)) AS total_profit,
    ROUND(AVG(s.profit)) AS average_profit_per_item
FROM Customer c
JOIN Sales s ON c."customer_id" = s."customer_id"
GROUP BY c.segment
ORDER BY total_sales DESC;

--sales and revenue trends

SELECT
    TO_CHAR("order_date", 'YYYY-MM') AS sales_month,
    ROUND(SUM(sales)) AS monthly_sales,
    ROUND(SUM(profit)) AS monthly_profit
FROM Sales
GROUP BY sales_month
ORDER BY sales_month;

--to know avg sales and profit in each day of the week

SELECT TO_CHAR("order_date", 'Day') AS day_of_week,
    ROUND(AVG(sales)) AS average_daily_sales,
    ROUND(AVG(profit)) AS average_daily_profit,
    COUNT(DISTINCT "order_id") AS total_orders
FROM Sales
GROUP BY day_of_week
ORDER BY
    CASE
        WHEN TO_CHAR("order_date", 'Day') = 'Sunday' THEN 1
        WHEN TO_CHAR("order_date", 'Day') = 'Monday' THEN 2
        WHEN TO_CHAR("order_date", 'Day') = 'Tuesday' THEN 3
        WHEN TO_CHAR("order_date", 'Day') = 'Wednesday' THEN 4
        WHEN TO_CHAR("order_date", 'Day') = 'Thursday' THEN 5
        WHEN TO_CHAR("order_date", 'Day') = 'Friday' THEN 6
        WHEN TO_CHAR("order_date", 'Day') = 'Saturday' THEN 7
    END;

--Top 10 best performing products

SELECT p."product_name",
    p.category,
    p."sub_category",
    ROUND(SUM(s.sales)) AS total_sales,
    ROUND(SUM(s.profit)) AS total_profit
FROM Sales s
JOIN Product p ON s."product_id" = p."product_id"
GROUP BY p."product_name", p.category, p."sub_category"
ORDER BY total_sales DESC
LIMIT 10; -- Top 10 products

--Low profitability product

SELECT p."product_name",
    p.category,
    p."sub_category",
    ROUND(SUM(s.sales)) AS total_sales,
    ROUND(SUM(s.profit)) AS total_profit,
    ROUND(AVG(s.discount)::numeric,2)  AS average_discount_applied
FROM Sales s
JOIN Product p ON s."product_id" = p."product_id"
GROUP BY p."product_name", p.category, p."sub_category"
HAVING SUM(s.profit) <= 0 -- Or SUM(s.profit) < (some threshold)
ORDER BY total_profit ASC
LIMIT 10;

--Reginal wise user base, sales, profit

SELECT c.region,
    ROUND(SUM(s.sales)) AS total_sales,
    ROUND(SUM(s.profit)) AS total_profit,
    COUNT(DISTINCT s."customer_id") AS unique_customers_in_region
FROM Customer c
JOIN Sales s ON c."customer_id" = s."customer_id"
GROUP BY c.region
ORDER BY total_sales DESC;

--Product category movement across region wise

SELECT c.region,
    p.category,
    ROUND(SUM(s.sales)) AS category_sales_in_region,
    COUNT(DISTINCT s."order_id") AS total_orders
FROM Customer c
JOIN Sales s ON c."customer_id" = s."customer_id"
JOIN Product p ON s."product_id" = p."product_id"
GROUP BY c.region, p.category
ORDER BY c.region, category_sales_in_region DESC;

--Discount and its effectiveness

SELECT
    AVG(discount) AS average_discount_rate,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM
    Sales;

--discount based sales,profit category wise


SELECT p.category,
    CASE
        WHEN s.discount = 0 THEN 'No Discount'
        WHEN s.discount > 0 AND s.discount <= 0.1 THEN '0-10% Discount'
        WHEN s.discount > 0.1 AND s.discount <= 0.2 THEN '10-20% Discount'
        ELSE 'Over 20% Discount'
    END AS discount_range,
    SUM(s.sales) AS total_sales,
    SUM(s.profit) AS total_profit,
    COUNT(DISTINCT s."order_id") AS total_orders
FROM Sales s
JOIN Product p ON s."product_id" = p."product_id"
GROUP BY p.category,
    CASE
        WHEN s.discount = 0 THEN 'No Discount'
        WHEN s.discount > 0 AND s.discount <= 0.1 THEN '0-10% Discount'
        WHEN s.discount > 0.1 AND s.discount <= 0.2 THEN '10-20% Discount'
        ELSE 'Over 20% Discount'
    END
ORDER BY p.category,discount_range;	

--orders and shipping pattern

SELECT
  AVG("ship_date" - "order_date") AS average_shipping_days
FROM Sales;

--orders and shipping pattern by region and category

SELECT c.region,p.category,
AVG("ship_date" - "order_date") AS average_shipping_days
   -- AVG(EXTRACT(EPOCH FROM (s."ship date" - s."order date")) / (60 * 60 * 24)) AS average_shipping_days
FROM Sales s
JOIN Customer c ON s."customer_id" = c."customer_id"
JOIN Product p ON s."product_id" = p."product_id"
GROUP BY c.region, p.category
ORDER BY c.region, p.category;

--average quantity of items per order

SELECT s."order_id",
    SUM(s.quantity) AS total_quantity_per_order
FROM Sales s
GROUP BY s."order_id";

--Finding Customer Lifetime Value

SELECT
    c."customer_id",
    c.segment,
    SUM(s.sales) AS total_sales_per_customer,
    COUNT(DISTINCT s."order_id") AS total_orders_per_customer,
    MIN(s."order_date") AS first_purchase_date,
    MAX(s."order_date") AS last_purchase_date
FROM
    Customer c
JOIN
    Sales s ON c."customer_id" = s."customer_id"
GROUP BY
    c."customer_id", c.segment;

--Product bucket analysis

SELECT
    s1."product_id" AS product_a_id,
    p1."product_name" AS product_a_name,
    s2."product_id" AS product_b_id,
    p2."product_name" AS product_b_name,
    COUNT(DISTINCT s1."order_id") AS co_occurrence_count
FROM Sales s1
JOIN Sales s2 ON s1."order_id" = s2."order_id" AND s1."product_id" < s2."product_id"
JOIN Product p1 ON s1."product_id" = p1."product_id"
JOIN Product p2 ON s2."product_id" = p2."product_id"
GROUP BY s1."product_id", p1."product_name", s2."product_id", p2."product_name"
ORDER BY co_occurrence_count DESC
LIMIT 20; -- Top 20 co-occurring pairs

--Relationship between discount,sales,quantity and profit

SELECT
    discount,
    AVG(sales) AS avg_sales_at_discount,
    AVG(quantity) AS avg_quantity_at_discount,
    AVG(profit) AS avg_profit_at_discount,
    COUNT(*) AS number_of_transactions
FROM
    Sales
GROUP BY
    discount
ORDER BY
    discount;

--customer, total orders and recent order

SELECT
    "customer_id",
    COUNT(DISTINCT "order_id") AS total_orders,
    MAX("order_date") AS last_order_date
FROM
    Sales
GROUP BY
    "customer_id";

--

