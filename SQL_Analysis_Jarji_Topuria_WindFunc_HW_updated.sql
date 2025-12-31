--task 1
--first, we prepare cte for customers, their sum amounts and we can put their percentage value of sales
--by dividing their sales over the partitioned total per channel
--Accounting for customers with similar names by grouping by id too
WITH customer_sales AS (
SELECT
    s.channel_id,
    h.channel_desc,
    u.cust_id,
    u.cust_first_name,
    u.cust_last_name,
    SUM(s.amount_sold) AS amount_sold,
    SUM(s.amount_sold) * 100.0 / SUM(SUM(s.amount_sold)) OVER (PARTITION BY s.channel_id) AS sales_percentage
FROM public.sales s
JOIN public.channels h ON s.channel_id = h.channel_id
JOIN public.customers u ON s.cust_id = u.cust_id
GROUP BY s.channel_id, h.channel_desc, u.cust_id, u.cust_first_name, u.cust_last_name
)
--now that its nicely aggregated, we can partition by channels and pick top 5 per each
SELECT
    channel_desc,
    cust_last_name,
    cust_first_name,
    TO_CHAR(amount_sold, 'FM9999999990.00') AS amount_sold,
    TO_CHAR(sales_percentage, 'FM99.9999') || '%' AS sales_percentage
FROM (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY channel_id ORDER BY amount_sold DESC) AS rn
FROM customer_sales
) ranked
WHERE rn <= 5
ORDER BY channel_desc, amount_sold DESC;

    
    

 
--task 2: updated to breakdown by quarters
WITH photo_asia_sales AS (
    SELECT
        t.calendar_quarter_desc AS quarter,
        SUM(s.amount_sold) AS quarter_sales
    FROM public.sales s
    JOIN public.products  p ON s.prod_id = p.prod_id
    JOIN public.customers u ON s.cust_id = u.cust_id
    JOIN public.countries co ON u.country_id = co.country_id
    JOIN public.times     t ON s.time_id = t.time_id
    WHERE p.prod_category = 'Photo'
      AND co.country_region = 'Asia'
      AND t.calendar_year = 2000
    GROUP BY t.calendar_quarter_desc
)
SELECT
    quarter,
    TO_CHAR(quarter_sales, 'FM999999990.00') AS amount_sold,
    TO_CHAR(SUM(quarter_sales) OVER (), 'FM999999990.00') AS YEAR_SUM
FROM photo_asia_sales
ORDER BY YEAR_SUM DESC;




--task 3
--first, we prepare cte for customers, their yearly sum amounts per channel
--we extract the year from time_id and aggregate per customer per channel per year
WITH customer_yearly_sales AS (
SELECT
    s.channel_id,
    h.channel_desc,
    u.cust_id,
    u.cust_first_name,
    u.cust_last_name,
    EXTRACT(YEAR FROM s.time_id::date) AS sales_year,
    SUM(s.amount_sold) AS total_sales
FROM public.sales s
JOIN public.channels h ON s.channel_id = h.channel_id
JOIN public.customers u ON s.cust_id = u.cust_id
JOIN public.times t ON s.time_id = t.time_id
WHERE EXTRACT(YEAR FROM s.time_id::date) IN (1998, 1999, 2001)
GROUP BY s.channel_id, h.channel_desc, u.cust_id, u.cust_first_name, u.cust_last_name, sales_year
),
-- now we rank customers per channel per year based on their total sales
ranked_customers AS (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY channel_id, sales_year ORDER BY total_sales DESC) AS rn
FROM customer_yearly_sales
)
--finally, select top 300 customers per channel per year
SELECT
    channel_desc,
    cust_last_name,
    cust_first_name,
    sales_year,
    TO_CHAR(total_sales, 'FM999999990.00') AS total_sales
FROM ranked_customers
WHERE rn <= 300
ORDER BY channel_desc, sales_year, total_sales DESC;




--task 4
--first, we prepare cte for total sales per month and product category
--filtering for europe and americas regions and months Jan-Mar 2000
--breakdown by region added

WITH monthly_category_sales AS (
    SELECT
        t.calendar_month_number AS month_num,
        t.calendar_month_desc   AS month,
        co.country_region       AS region,
        p.prod_category,
        SUM(s.amount_sold) AS total_sales
    FROM public.sales s
    JOIN public.products  p ON s.prod_id = p.prod_id
    JOIN public.customers u ON s.cust_id = u.cust_id
    JOIN public.countries co ON u.country_id = co.country_id
    JOIN public.times     t ON s.time_id = t.time_id
    WHERE co.country_region IN ('Europe', 'Americas')
      AND t.calendar_year = 2000
      AND t.calendar_month_number IN (1, 2, 3)
    GROUP BY
        t.calendar_month_number,
        t.calendar_month_desc,
        co.country_region,
        p.prod_category
)
SELECT
    month,
    region,
    prod_category,
    TO_CHAR(total_sales, 'FM999999990.00') AS total_sales
FROM monthly_category_sales
ORDER BY
    month_num,
    region,
    prod_category;





