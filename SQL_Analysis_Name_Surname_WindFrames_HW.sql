--Task1
--annual channel sales analysis by region (1999–2001)
--we first aggregate sales by region, year, and channel
--this gives us a clean base to calculate percentages on top of
WITH base_sales AS (
SELECT
    co.country_region,
    t.calendar_year,
    h.channel_desc,
    SUM(s.amount_sold) AS amount_sold
FROM public.sales s
JOIN public.channels h ON s.channel_id = h.channel_id
JOIN public.customers u ON s.cust_id = u.cust_id
JOIN public.countries co ON u.country_id = co.country_id
JOIN public.times t ON s.time_id = t.time_id
WHERE co.country_region IN ('Americas', 'Asia', 'Europe')
  AND t.calendar_year BETWEEN 1999 AND 2001
GROUP BY co.country_region, t.calendar_year, h.channel_desc
),

--next, we calculate the percentage share of each channel
--within the same region and year
channel_percentages AS (
SELECT
    country_region,
    calendar_year,
    channel_desc,
    amount_sold,
    amount_sold * 100.0
        / SUM(amount_sold) OVER (PARTITION BY country_region, calendar_year)
        AS pct_by_channels
FROM base_sales
),

--finally, we compare each channel's percentage
--to the same channel in the previous year
final_calc AS (
SELECT
    country_region,
    calendar_year,
    channel_desc,
    amount_sold,
    pct_by_channels,
    LAG(pct_by_channels) OVER (
        PARTITION BY country_region, channel_desc
        ORDER BY calendar_year
    ) AS pct_previous_period
FROM channel_percentages
)

--final presentation layer
SELECT
    country_region,
    calendar_year,
    channel_desc,
    TO_CHAR(amount_sold, 'FM9999999990.00') AS amount_sold,
    TO_CHAR(pct_by_channels, 'FM99.99') || '%' AS "% BY CHANNELS",
    TO_CHAR(pct_previous_period, 'FM99.99') || '%' AS "% PREVIOUS PERIOD",
    TO_CHAR(pct_by_channels - pct_previous_period, 'FM99.99') || '%' AS "% DIFF"
FROM final_calc
ORDER BY country_region, calendar_year, channel_desc;


--Task2
WITH daily_sales AS (
SELECT
 t.time_id::date AS sales_date,
 t.calendar_week_number AS week_no,
 t.day_number_in_week AS dow,
 SUM(s.amount_sold) AS daily_sales
FROM sales s
JOIN times t ON s.time_id = t.time_id
WHERE t.calendar_year = 1999
 AND t.calendar_week_number IN (49,50,51)
GROUP BY
 t.time_id,
 t.calendar_week_number,
 t.day_number_in_week
)
SELECT
 sales_date,
 week_no,
 daily_sales,
 --cumulative sum per week
 SUM(daily_sales) OVER (
  PARTITION BY week_no
  ORDER BY sales_date
 ) AS cum_sum,

 --centered moving average with business rules
 -- Monday: Sat + Sun + Mon + Tue
 CASE WHEN dow = 1 THEN
 AVG(daily_sales) OVER (
    ORDER BY sales_date
    ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING)
--ფriday: Thu + Fri + Sat + Sun
WHEN dow = 5 THEN AVG(daily_sales) OVER (ORDER BY sales_date
    ROWS BETWEEN 1 PRECEDING AND 2 FOLLOWING)

--normal days: prev + current + next
ELSE
AVG(daily_sales) OVER (ORDER BY sales_date
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
 END AS centered_3_day_avg

FROM daily_sales
ORDER BY sales_date;

--task3
--RANGE
--treats all rows with the same ordering value as a frame.
--Here, all sales on the same date are grouped together.
--This is the best solution for cases where multiple sales happen each day
SELECT
    s.prod_id,
    t.fiscal_month_number,
    s.amount_sold,
    SUM(s.amount_sold) OVER (PARTITION BY s.prod_id, t.fiscal_month_number
        ORDER BY s.time_id
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales_in_month
FROM sales s
JOIN times t ON s.time_id = t.time_id;

--ROWS
--here we're looking just for straight-up count of rows, not values in them
SELECT
    s.prod_id,
    s.time_id,
    s.amount_sold,
    SUM(s.amount_sold) OVER (PARTITION BY s.prod_id
        ORDER BY s.time_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_last_3_sales
FROM sales s;