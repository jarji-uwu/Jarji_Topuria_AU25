--
--1)The marketing team needs a list of animation movies between 2017 and 2019 to promote family-friendlycontent in an upcoming season in stores
--Show all animation movies released during this period with rate more than 1, sorted alphabetically

--1.1)joins
SELECT f.title AS movie, f.release_year AS released, f.rental_rate AS rate
FROM public.film f
LEFT JOIN public.film_category b ON f.film_id = b.film_id
LEFT JOIN public.category c ON b.category_id = c.category_id
WHERE f.release_year BETWEEN 2017 AND 2019
AND f.rental_rate > 1
AND c.name = 'Animation'
ORDER BY f.title ASC

--1.2)cte
WITH animations AS
(
SELECT *
FROM public.film f
LEFT JOIN public.film_category b ON f.film_id = b.film_id
LEFT JOIN public.category c ON b.category_id = c.category_id
WHERE c.name = 'Animation'
AND f.release_year BETWEEN 2017 AND 2019
AND f.rental_rate > 1
)
SELECT title AS movie, release_year AS released, rental_rate AS rate
FROM animations
ORDER BY title asc

--1.3)subquery
EXPLAIN ANALYZE
SELECT title AS movie, release_year AS released, rental_rate AS rate
FROM (
SELECT *
FROM public.film f
LEFT JOIN public.film_category b ON f.film_id = b.film_id
LEFT JOIN public.category c ON b.category_id = c.category_id
WHERE c.name = 'Animation'
AND f.release_year BETWEEN 2017 AND 2019
AND f.rental_rate > 1
)
ORDER BY title ASC

--Simple, straightforward task. Basically the same query rewritten in 3 different forms, no significant differences.
--Fetch time 0.0 seconds for all 3 versions.


--2)The finance department requires a report on store performance to assess profitability and plan resource 
--allocation for stores after March 2017. Calculate the revenue earned by each rental store after March 2017 
--(since April) (include columns: address and address2 – as one column, revenue)

--2.1)joins
SELECT (a.address || ' ' || COALESCE(a.address2, '')) AS full_address, SUM(p.amount) AS revenue
FROM public.payment p
LEFT JOIN public.staff s ON p.staff_id = s.staff_id
LEFT JOIN public.store t ON s.store_id = t.store_id
LEFT JOIN public.address a ON t.address_id = a.address_id
WHERE payment_date > '2017-04-01 00:00:00.000+04'
GROUP BY a.address, a.address2

--2.2)cte
WITH store_addresses AS
(
SELECT *
FROM public.payment p
LEFT JOIN public.staff s ON p.staff_id = s.staff_id
LEFT JOIN public.store t ON s.store_id = t.store_id
LEFT JOIN public.address a ON t.address_id = a.address_id
)
SELECT (address || ' ' || COALESCE(address2, '')) AS full_address, SUM(amount) AS revenue
FROM store_addresses
WHERE payment_date > '2017-04-01 00:00:00.000+04'
GROUP BY address, address2

--2.3)subquery
SELECT (address || ' ' || COALESCE(address2, '')) AS full_address, SUM(amount) AS revenue
FROM (
SELECT *
FROM public.payment p
LEFT JOIN public.staff s ON p.staff_id = s.staff_id
LEFT JOIN public.store t ON s.store_id = t.store_id
LEFT JOIN public.address a ON t.address_id = a.address_id
)
WHERE payment_date > '2017-04-01 00:00:00.000+04'
GROUP BY address, address2

--Simple, straightforward task. Basically the same query rewritten in 3 different forms, no significant differences.
--Fetch time 0.0 seconds for all 3 versions.


--3)The marketing department in our stores aims to identify the most successful actors since 2015
--to boost customer interest in their films. Show top-5 actors by number of movies (released after 2015) they
--took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)

--3.1)joins
SELECT a.first_name, a.last_name, count(*)
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
WHERE f.release_year > 2015
GROUP BY a.first_name, a.last_name
ORDER BY count(*) DESC
LIMIT 5

--3.2)cte
WITH actor_movies as(
SELECT *
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
WHERE f.release_year > 2015
)
SELECT first_name, last_name, count(*)
FROM actor_movies
WHERE release_year > 2015
GROUP BY first_name, last_name
ORDER BY count(*) DESC
LIMIT 5

--3.3)subquery
SELECT first_name, last_name, count(*)
FROM (
SELECT *
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
WHERE f.release_year > 2015
)
WHERE release_year > 2015
GROUP BY first_name, last_name
ORDER BY count(*) DESC
LIMIT 5

--Though the query yields the top 5 actors correctly, number 2-6 actors all share the same number of movies after 2015,
--which may be interesting for the marketing team.
--Simple, straightforward task. Basically the same query rewritten in 3 different forms, no significant differences.
--Fetch time 0.0 seconds for all 3 versions. 


--4)The marketing team needs to track the production trends of Drama, Travel, and Documentary 
--films to inform genre-specific marketing strategies. Ырщц number of Drama, Travel, Documentary per year
--(include columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), 
--sorted by release year in descending order. Dealing with NULL values is encouraged)

--4.1)joins
SELECT 
	f.release_year AS year,
	sum(CASE WHEN c.name='Drama' THEN 1 ELSE 0 END) AS drama,
	sum(CASE WHEN c.name='Travel' THEN 1 ELSE 0 END) AS travel,
	sum(CASE WHEN c.name='Documentary' THEN 1 ELSE 0 END) AS documentary
FROM public.film f
LEFT JOIN public.film_category b ON f.film_id = b.film_id
LEFT JOIN public.category c ON b.category_id = c.category_id
WHERE c.name IN ('Drama', 'Travel', 'Documentary')
GROUP BY f.release_year
ORDER BY f.release_year desc

--4.2)cte
WITH film_categories AS 
(
SELECT *
FROM public.film f
LEFT JOIN public.film_category b ON f.film_id = b.film_id
LEFT JOIN public.category c ON b.category_id = c.category_id
WHERE c.name IN ('Drama', 'Travel', 'Documentary')
)
select
	release_year AS year,
	sum(CASE WHEN name='Drama' THEN 1 ELSE 0 END) AS drama,
	sum(CASE WHEN name='Travel' THEN 1 ELSE 0 END) AS travel,
	sum(CASE WHEN name='Documentary' THEN 1 ELSE 0 END) AS documentary
FROM film_categories
WHERE name IN ('Drama', 'Travel', 'Documentary')
GROUP BY release_year
ORDER BY release_year DESC

--4.3)subquery
select
	release_year AS year,
	sum(CASE WHEN name='Drama' THEN 1 ELSE 0 END) AS drama,
	sum(CASE WHEN name='Travel' THEN 1 ELSE 0 END) AS travel,
	sum(CASE WHEN name='Documentary' THEN 1 ELSE 0 END) AS documentary
FROM (
SELECT *
FROM public.film f
LEFT JOIN public.film_category b ON f.film_id = b.film_id
LEFT JOIN public.category c ON b.category_id = c.category_id
WHERE c.name IN ('Drama', 'Travel', 'Documentary')
)
WHERE name IN ('Drama', 'Travel', 'Documentary')
GROUP BY release_year
ORDER BY release_year DESC

--Simple, straightforward task. Basically the same query rewritten in 3 different forms, no significant differences.
--Fetch time 0.0 seconds for all 3 versions. 


--The HR department aims to reward top-performing employees in 2017 with bonuses to recognize their
--contribution to stores revenue. Show which three employees generated the most revenue in 2017?
--Assumptions: 
--staff could work in several stores in a year, please indicate which store the staff worked in (the last one);
--if staff processed the payment then he works in the same store; 
--take into account only payment_date

--5.1)joins
--Couldn't figure out joins-only method for this task.

--5.2)cte
WITH totals AS
(
SELECT staff_id, SUM(amount) AS sum_payment
FROM public.payment
WHERE EXTRACT(YEAR FROM payment_date) = 2017
GROUP BY staff_id
),
staff_from_store AS
(
SELECT DISTINCT ON (p.staff_id)
p.staff_id, p.payment_date, i.store_id
FROM public.payment p
LEFT JOIN public.rental r ON p.rental_id = r.rental_id
LEFT JOIN public.inventory i ON r.inventory_id = i.inventory_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
ORDER BY p.staff_id, p.payment_date DESC
)
SELECT s.staff_id, s.first_name, s.last_name, f.store_id, t.sum_payment
FROM public.staff s
LEFT JOIN totals t ON s.staff_id = t.staff_id
LEFT JOIN staff_from_store f ON s.staff_id = f.staff_id
ORDER BY t.sum_payment DESC
LIMIT 3

--5.3)subquery
SELECT s.staff_id, s.first_name, s.last_name, f.store_id, t.sum_payment
FROM public.staff s
LEFT JOIN
(
SELECT staff_id, SUM(amount) AS sum_payment
FROM public.payment
WHERE EXTRACT(YEAR FROM payment_date) = 2017
GROUP BY staff_id
) t ON s.staff_id = t.staff_id
LEFT JOIN
(
SELECT DISTINCT ON (p.staff_id)
p.staff_id, p.payment_date, i.store_id
FROM public.payment p
LEFT JOIN public.rental r ON p.rental_id = r.rental_id
LEFT JOIN public.inventory i ON r.inventory_id = i.inventory_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
ORDER BY p.staff_id, p.payment_date DESC
) f ON s.staff_id = f.staff_id
ORDER BY t.sum_payment DESC
LIMIT 3

--Solved with subquery and cte. We need to find two separate things for the final result - one, calculate
--the total revenue per employee, two, determine where was thir last 'payment' to asign them store.
--task was completed with ctes and subquerys however, not with join-only version. Joins are restrict


--2. The management team wants to identify the most popular movies and their target audience age groups
-- to optimize marketing efforts. Show which 5 movies were rented more than others (number of rentals),
-- and what's the expected age of the audience for these movies? To determine expected age please use
-- 'Motion Picture Association film rating system'
SELECT DISTINCT rating
FROM public.film

--6.1)joins
SELECT count(*) AS rented_count, 
i.film_id, 
f.title,
f.rating,
CASE
  WHEN f.rating = 'G' THEN '0-7'
  WHEN f.rating = 'PG' THEN '8-12'
  WHEN f.rating = 'PG-13' THEN '13-16'
  WHEN f.rating = 'R' THEN '17+'
  WHEN f.rating = 'NC-17' THEN '18+'
  ELSE ''
END AS target_age
FROM public.rental r
LEFT JOIN public.inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN public.film f ON f.film_id = i.film_id
GROUP BY i.film_id, f.rating, f.title
ORDER BY rented_count DESC
LIMIT 5

--6.2)cte
WITH film_rentals AS
(
SELECT i.film_id, f.title, f.rating, COUNT(*) AS rental_count
FROM public.rental r
LEFT JOIN public.inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN public.film f ON f.film_id = i.film_id
GROUP BY i.film_id, f.title, f.rating
)
SELECT film_id, title, rating, rental_count,
CASE
  WHEN rating = 'G' THEN '0-7'
  WHEN rating = 'PG' THEN '8-12'
  WHEN rating = 'PG-13' THEN '13-16'
  WHEN rating = 'R' THEN '17+'
  WHEN rating = 'NC-17' THEN '18+'
  ELSE ''
END AS target_age
FROM film_rentals
ORDER BY rental_count DESC
LIMIT 5

--6.3)subquery
SELECT film_id, title, rating, rental_count,
CASE
  WHEN rating = 'G' THEN '0-7'
  WHEN rating = 'PG' THEN '8-12'
  WHEN rating = 'PG-13' THEN '13-16'
  WHEN rating = 'R' THEN '17+'
  WHEN rating = 'NC-17' THEN '18+'
  ELSE ''
END AS target_age
FROM
(
SELECT i.film_id, f.title, f.rating, COUNT(*) AS rental_count
FROM public.rental r
LEFT JOIN public.inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN public.film f ON f.film_id = i.film_id
GROUP BY i.film_id, f.title, f.rating
)
ORDER BY rental_count DESC
LIMIT 5

--Case when used to assign information not availalbe in DB, namely approximate age ranges per rating.
--For the future this info can be added into db.


--The stores’ marketing team wants to analyze actors' inactivity periods to select those with notable
--career breaks for targeted promotional campaigns, highlighting their comebacks or consistent appearances
--to engage customers with nostalgic or reliable film stars The task can be interpreted in various ways,
--and here are a few options (provide solutions for each one):
--V1: gap between the latest release_year and current year per each actor;
--V2: gaps between sequential films per each actor;

--v1
--7.1)joins
SELECT 
a.actor_id,
a.first_name,
a.last_name,
EXTRACT(YEAR FROM CURRENT_DATE) - MAX(f.release_year) AS inactivity
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY inactivity DESC

--7.2)cte
WITH actor_films AS
(
SELECT a.actor_id, a.first_name, a.last_name, f.release_year
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
)
SELECT actor_id, first_name, last_name,
EXTRACT(YEAR FROM CURRENT_DATE) - MAX(release_year) AS inactivity
FROM actor_films
GROUP BY actor_id, first_name, last_name
ORDER BY inactivity DESC

--7.3)subquery
SELECT actor_id, first_name, last_name,
EXTRACT(YEAR FROM CURRENT_DATE) - MAX(release_year) AS inactivity
FROM
(
SELECT a.actor_id, a.first_name, a.last_name, f.release_year
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
) 
GROUP BY actor_id, first_name, last_name
ORDER BY inactivity DESC

--v2
--8.1)joins
SELECT a.actor_id, a.first_name, a.last_name,
f1.release_year AS prev_film, f2.release_year AS next_film,
f2.release_year - f1.release_year AS gap
FROM public.actor a
LEFT JOIN public.film_actor b1 ON a.actor_id = b1.actor_id
LEFT JOIN public.film f1 ON b1.film_id = f1.film_id
LEFT JOIN public.film_actor b2 ON a.actor_id = b2.actor_id
LEFT JOIN public.film f2 ON b2.film_id = f2.film_id
WHERE f2.release_year > f1.release_year
ORDER BY gap DESC;

--8.2)cte
WITH actor_films AS
(
SELECT a.actor_id, a.first_name, a.last_name, f.release_year
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
WHERE f.release_year IS NOT NULL
)
SELECT a1.actor_id, a1.first_name, a1.last_name,
a1.release_year AS prev_film, a2.release_year AS next_film,
a2.release_year - a1.release_year AS gap
FROM actor_films a1
JOIN actor_films a2 ON a1.actor_id = a2.actor_id AND a2.release_year > a1.release_year
ORDER BY gap DESC;

--8.3)subquery
SELECT a1.actor_id, a1.first_name, a1.last_name,
a1.release_year AS prev_film, a2.release_year AS next_film,
a2.release_year - a1.release_year AS gap
FROM
(
SELECT a.actor_id, a.first_name, a.last_name, f.release_year
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
WHERE f.release_year IS NOT NULL
) a1
JOIN
(
SELECT a.actor_id, a.first_name, a.last_name, f.release_year
FROM public.actor a
LEFT JOIN public.film_actor b ON a.actor_id = b.actor_id
LEFT JOIN public.film f ON b.film_id = f.film_id
WHERE f.release_year IS NOT NULL
) a2 ON a1.actor_id = a2.actor_id AND a2.release_year > a1.release_year
ORDER BY gap DESC;








