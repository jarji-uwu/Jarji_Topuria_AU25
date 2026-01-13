/*
1)Create a view called 'sales_revenue_by_category_qtr' that shows the film category and total sales revenue 
for the current quarter and year. The view should only display categories with at least one sale in the current quarter. 
Note: make it dynamic - when the next quarter begins, it automatically considers that as the current quarter
*/

--joins used to get from categories to payments. grouped by category and summed by payment_amounts.

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT c.name, sum(p.amount)
FROM public.category c
LEFT JOIN public.film_category fc ON c.category_id = fc.category_id
LEFT JOIN public.inventory i ON fc.film_id = i.film_id
LEFT JOIN public.rental r ON i.inventory_id = r.inventory_id
LEFT JOIN public.payment p ON r.rental_id = p.rental_id
WHERE date_part('quarter', p.payment_date) = date_part('quarter', NOW())
  AND date_part('year', p.payment_date) = date_part('year', NOW())
GROUP BY c.name;


/*
2)Create a query language function called 'get_sales_revenue_by_category_qtr' that accepts one parameter
representing the current quarter and year and returns the same result as the 'sales_revenue_by_category_qtr' view.
*/

--since we are using one parameter, it should encapsulate both year and quarter in one value. Decimal works.
--later, as u see we derive year and quarter separately by some quick maths.
--In Where statement we turn both sides of the equation to an integer and compare,
--If the int value of year and then quarter equals our parameter's corresponding value, it's summed up in the resulting table
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr (year_quarter DECIMAL)
RETURNS TABLE (
    category TEXT,
    revenue  DECIMAL
)
LANGUAGE SQL
AS $$
SELECT c.name AS category, SUM(p.amount) AS revenue
FROM public.category c
LEFT JOIN public.film_category fc ON c.category_id = fc.category_id
LEFT JOIN public.inventory i ON fc.film_id = i.film_id
LEFT JOIN public.rental r ON i.inventory_id = r.inventory_id
LEFT JOIN public.payment p ON r.rental_id = p.rental_id
WHERE DATE_PART('year', p.payment_date)::INT = FLOOR(year_quarter)::INT
    AND DATE_PART('quarter', p.payment_date)::INT =
        ((year_quarter - FLOOR(year_quarter)) * 10)::INT
GROUP BY c.name;
$$;

/*
test successful:
SELECT *
FROM get_sales_revenue_by_category_qtr (2017.2)

SELECT get_sales_revenue_by_category_qtr (2017.2) also returns the correct values, but puts them in one column
*/




/*
3)Create a function that takes a country as an input parameter and returns the most popular film in that specific country. 
The function should format the result set as follows:
Query (example):select * from core.most_popular_films_by_countries(array['Afghanistan','Brazil','United States’]);
*/

--in returns table we assign type using the columns that are going to be used to fetch corresponding data with
--title schema.table.column%type syntax. In the function itself, distinct on ensures that we only look at
--one result per country. Joins are used to get from country to rental count and to fetch all columns in 
--the resulting table. WHERE UPPER(co.country) = ANY(popular_in) syntax ensures that the data will be only
--about the countries that the user will request through the function. Country appears in order id to support
--the distinct on function, not that we're ordering the finals set of films by country.
--Though we don't have an aggregadet function in the select, we do have it in order by, hence we have to
--group by by all the non-aggregate features.


CREATE OR REPLACE FUNCTION public.most_popular_films_by_countries(popular_in TEXT[])
RETURNS TABLE (
    country public.country.country%type,
    film public.film.title%type,
    rating public.film.rating%type,
    "Language" public.language.name%type,
    length public.film.length%type,
    "Release Year" public.film.release_year%type
)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
SELECT DISTINCT ON (co.country)
	co.country,
    f.title AS film,
    f.rating,
    l.name AS "Language",
    f.length,
    f.release_year AS "Release Year"
FROM public.film f
LEFT JOIN public.inventory i ON f.film_id = i.film_id
LEFT JOIN public.rental r ON i.inventory_id = r.inventory_id
LEFT JOIN public.customer cu ON r.customer_id = cu.customer_id
LEFT JOIN public.address a ON cu.address_id = a.address_id
LEFT JOIN public.city ci ON a.city_id = ci.city_id
LEFT JOIN public.country co ON ci.country_id = co.country_id
LEFT JOIN public.language l ON f.language_id = l.language_id 
WHERE UPPER(co.country) = ANY(popular_in)
GROUP BY co.country, f.title, f.rating, l.name, f.length, f.release_year
ORDER BY co.country, COUNT(r.rental_id) DESC;

IF NOT FOUND THEN
	RAISE EXCEPTION 'No results for the requested countries: %', popular_in;
END IF;
END;
$$;


/*
SELECT *
FROM public.most_popular_films_by_countries('{MALAYSIA, BRAZIL,SLOVAKIA,SLOVENIA}'
);
checked, works. Nothing deliberate to decide winner of the tie in the function. For example, Malaysia
has more than a couple of films with exactly 4 rentals
*/



/*
 * 4) Create a function that generates a list of movies available in stock based on a partial title match 
 * (e.g., movies containing the word 'love' in their title). 
The titles of these movies are formatted as '%...%', and if a movie with the specified title is not in stock, 
return a message indicating that it was not found.
The function should produce the result set in the following format (note: the 'row_num' field is an automatically
generated counter field, starting from 1 and incrementing for each entry, e.g., 1, 2, ..., 100, 101, ...).
Query (example):select * from core.films_in_stock_by_title('%love%’);
*/


--In the screenshot of the task there is a column customer name and rental date, however we're fetching AVAILABLE
--films with this functon, so there is no client or renting date relevant to the copies we care about.
--
--Function body split in two parts - one for fetching available inventory, incrementally increasing ids, getting their
--film title, name and count of available copies and the second part to inform the user that there 
--are 'no such films available'.
--
--To calculate availability, we use a cte 'rented' to get a list of inventory (grouped by inventory_id, as we care
--about count of inventory, not how many times it was rented), then we use that data to subtract from the total copies.
--
--in cte 'per_film' we get film title, language, count of total copies and
--HAVING COUNT(i.inventory_id) - COUNT(r.inventory_id) > 0 ensures there are no films in the final table that have all
--its copies rented out.
--
--in cte 'numbered' we assign pseudo-incrementing numbering by comparing title of each film to others and fetch all 
--data we need for the final table.
--
--works as intended:
--SELECT *
--FROM public.films_in_stock_by_title('%angel%');


CREATE OR REPLACE FUNCTION public.films_in_stock_by_title(partial_title TEXT)
RETURNS TABLE (
    row_num BIGINT,
    title TEXT,
    language TEXT,
    available_copies INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    counter BIGINT := 0;
BEGIN
    FOR rec IN
        SELECT
            f.title::TEXT AS title,
            l.name::TEXT AS language,
            (COUNT(i.inventory_id) - COUNT(r.inventory_id))::INT AS available_copies
        FROM public.film f
        JOIN public.language l ON l.language_id = f.language_id
        JOIN public.inventory i ON i.film_id = f.film_id
        LEFT JOIN public.rental r ON r.inventory_id = i.inventory_id AND r.return_date IS NULL
        WHERE f.title ILIKE partial_title
        GROUP BY f.title, l.name
        HAVING (COUNT(i.inventory_id) - COUNT(r.inventory_id)) > 0
        ORDER BY f.title
    LOOP
        counter := counter + 1;
        row_num := counter;
        title := rec.title;
        language := rec.language;
        available_copies := rec.available_copies;
        RETURN NEXT;
    END LOOP;

    -- Raise exception if no rows were returned
    IF counter = 0 THEN
        RAISE EXCEPTION 'No films found matching: %', partial_title;
    END IF;

END;
$$;

/*
 * Create a procedure language function called 'new_movie' that takes a movie title as a parameter and inserts 
 * a new movie with the given title in the film table. The function should generate a new unique film ID, set 
 * the rental rate to 4.99, the rental duration to three days, the replacement cost to 19.99. The release year 
 * and language are optional and by default should be current year and Klingon respectively. The function should 
 * also verify that the language exists in the 'language' table. Then, ensure that no such function has been created 
 * before; if so, replace it.
 */

/*
 *to allow the user of the function to input release year and/or language and to have a default value, we use select
 *function parameter and a coalesce default value, if function parameter is null. There is no Klingon in the default
 *DVDRENTAL database, so it should be added for this to work properly, otherwise languages with blank values won't be added
 *and the function won't work as intended.
 *
 *to make sure new film_id is unique, we use max(film_id)+1. This is risky only if we actually have 0 films. In that case
 *we could have used coalesce again.
 *
 *tested sucessfully with
 *
 *SELECT new_movie('25 angry men', 2009,'JAPANESE');
 *
 *fails correctly with
 *
 *SELECT new_movie('25 angry men', 2009,'FUNN');
 */


CREATE OR REPLACE FUNCTION public.new_movie(
    p_title TEXT,
    p_release_year INT DEFAULT NULL,
    p_language TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
WITH
year_val AS (SELECT COALESCE(p_release_year,EXTRACT(YEAR FROM CURRENT_DATE)::INT) AS year),
lang_val AS (
SELECT language_id
FROM public.language
WHERE UPPER(name) = UPPER(COALESCE(p_language, 'Klingon'))
),
new_id AS (
SELECT MAX(film_id) + 1 AS id
FROM public.film)
INSERT INTO public.film (
    film_id,
    title,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update
)
SELECT
    new_id.id, p_title, year_val.year, lang_val.language_id, 3, 4.99, 90, 19.99,'PG', NOW()
FROM new_id, year_val, lang_val;
    IF NOT EXISTS (
        SELECT 1
        FROM public.language
        WHERE UPPER(name) = UPPER(COALESCE(p_language, 'Klingon'))
    ) THEN
        RAISE EXCEPTION 'Language not found: %', COALESCE(p_language, 'Klingon');
    END IF;

END;
$$;






