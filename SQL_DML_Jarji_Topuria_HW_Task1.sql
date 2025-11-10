/*
1) and 2)
Rating is a custom data type so casting it as such. language could be just id 1 as all 3 movies are english,
however its using select Upper(name)='English' to be fancy and to mitigate the unlikely risk of language ids
being reordered. we have just 3 factors to keep the films unique - title, release year, length.
if we include other things such as rental rate, rating(varies by source), they could change from time to time
and could create unintended duplicates.
 */


INSERT INTO public.film
	(title, description, release_year, language_id, rental_duration, rental_rate,
	length, replacement_cost, rating, last_update)

SELECT v.title, v.description, v.release_year, v.language_id, v.rental_duration,
	v.rental_rate, v.length, v.replacement_cost, v.rating::mpaa_rating, CURRENT_DATE
FROM
	(VALUES
	('12 Angry Men',
	'Story of a jury of twelve men as they deliberate the conviction or acquittal of a teenager charged with murder.',
	1957, (SELECT language_id FROM public.language WHERE UPPER(name)='ENGLISH'), 1, 4.99, 96, 20.99, 'PG'),
	('Pirates of the Caribbean: The Curse of the Black Pearl',
	'A blacksmith and a pirate team up to rescue a kidnapped woman from a cursed crew.',
	2003, (SELECT language_id FROM public.language WHERE UPPER(name)='ENGLISH'), 2, 9.99, 143, 20.99, 'PG-13'),
	('Midsommar',
	'A grieving woman joins her boyfriend on a Swedish festival that turns sinister.',
	2019, (SELECT language_id FROM public.language WHERE UPPER(name)='ENGLISH'), 3, 19.99, 141, 20.99, 'R')
) AS v(title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating)
WHERE NOT EXISTS
	(SELECT * FROM public.film f
	WHERE UPPER(f.title) = UPPER(v.title)
		AND f.release_year = v.release_year
		AND f.length = v.length
		AND f.language_id = v.language_id)
RETURNING *;
COMMIT;


/*
3)
actor_id serialized so we can skip it. Last update set up as requested in task, not defined fore each row, rather
selected straight away.
Where not exists part ensures thatif we are trying to add an actor whose name and last name are already in the database,
they will be filtered out.
*/


INSERT INTO public.actor (first_name, last_name, last_update)
SELECT v.first_name, v.last_name, CURRENT_DATE
FROM (
    VALUES 
   	('Henry', 'Fonda'),
	('Ed', 'Begley'),
    ('Geoffrey', 'Rush'),
    ('Johnny', 'Depp'),
    ('Florence', 'Pugh'),
    ('Jack', 'Reynor')
) AS v(first_name, last_name)
WHERE NOT EXISTS (
    SELECT * FROM public.actor a
    WHERE UPPER(a.first_name) = UPPER(v.first_name)
    AND UPPER(a.last_name)  = UPPER(v.last_name)
)
RETURNING *;
COMMIT;


/*
also 3)
similar principle as previous task, except we are dealing with integers so we don't need Upper capitalization for accuracy
*/
INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT v.actor_id, v.film_id, CURRENT_DATE
FROM (
    VALUES 
        (213, 1008),
        (214, 1008),
        (215, 1009),
        (216, 1009),
        (217, 1010),
        (218, 1010)
) AS v(actor_id, film_id)
WHERE NOT EXISTS (
    SELECT * FROM public.film_actor a
    WHERE a.actor_id = v.actor_id
      AND a.film_id  = v.film_id
)
RETURNING *;
COMMIT;

/*
4) No unique approach or syntax applied for this part.
 */
INSERT INTO public.inventory (film_id, store_id, last_update)
SELECT v.film_id, v.store_id, CURRENT_DATE
FROM (
    VALUES 
        (1008, 1),
        (1009, 2),
        (1010, 1)
) AS v(film_id, store_id)
WHERE NOT EXISTS (
    SELECT * FROM public.inventory a
    WHERE a.film_id  = v.film_id
    	AND a.store_id = v.store_id
)
RETURNING *;
COMMIT;

/*
5)looking for a customer to replace. Looks like we have 515 customers to choose from who satisfy
the > 43 rentals and payments criteria. I'll be customer wiht id 1! woohooo. Looking for a random address too.
Filters are not in where but in having as they are aggregates.
 */
SELECT p.customer_id, count(DISTINCT p.payment_id), count(DISTINCT p.rental_id), active
FROM public.customer c
LEFT JOIN public.payment p ON c.customer_id = p.customer_id
GROUP BY p.customer_id, active
HAVING count(distinct p.payment_id) > 43
	AND count(DISTINCT p.rental_id) > 43
	
SELECT *
FROM address
	
	
/*
also 5) address_id = 2. 28 MySQL Boulevard. Leaving out create_date, as we're updating not inserting. Not sure what
 the last column, 'active' is, just putting in 0 as I've seen on some customers. I guess number of active rents right now?
 */

UPDATE public.customer
SET store_id = 1,
	first_name = 'Jarji',
	last_name = 'Topuria',
	email = NULL,
	address_id = 2,
	activebool = TRUE,
    last_update = CURRENT_DATE,
    active = 0
WHERE customer_id = 1
RETURNING *;
COMMIT;

/*
6) Customer id appears in payment and rental tables. deleting my records from both.
 */

DELETE FROM public.payment
WHERE customer_id = 1
RETURNING *;
COMMIT;

DELETE FROM public.rental
WHERE customer_id = 1
RETURNING*;
COMMIT;

/*
7)Rental first.
First, we find inventory ids for our mouves.
they're 4582, 4583 and 4584
There is a fancy way, I'm sure a non-static way to fetch return_date for each inventory item by joining film table
and adding rental_duration value to current_date, however not today... Just keeping it simple and static for now
The duplicate filtering is correct assuming same person wont rent the same movie
the same day.
 */

SELECT  *
FROM inventory
WHERE film_id IN (1008, 1009, 1010)

INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT v.rental_date, v.inventory_id, v.customer_id, v.return_date, v.staff_id, CURRENT_DATE
FROM (
	VALUES
		(CURRENT_DATE, 4582, 1, CURRENT_DATE + INTERVAL '1 day', 1),
		(current_date, 4583, 1, CURRENT_DATE + INTERVAL '2 day', 2),
		(current_date, 4584, 1, CURRENT_DATE + INTERVAL '3 day', 1)
) AS v(rental_date, inventory_id, customer_id, return_date, staff_id)
JOIN public.inventory i ON i.inventory_id = v.inventory_id
JOIN public.film f ON f.film_id = i.film_id
WHERE NOT EXISTS (
	SELECT * FROM public.rental a
	WHERE a.rental_date = v.rental_date
		AND a.inventory_id = v.inventory_id
		AND a.customer_id = v.customer_id)
RETURNING *;
COMMIT;


/*
7)Onto payments - now that we have data in rental, we can fetch data for payment straight from there.
As per instructions, putting payment in early 2017 partition.
Here also, this could be more dynamic by connecting rental id to inventory id and then to film id, I went the static way.
Considering that payments can be less than rental amount - maybe paid accross 2 days, where not exist applied to
rental id, amount and payment_date. This doesn't work well with the edge case where customer legitimately decides to pay
the same amount twice on the same day. Can we make this slide?
 */

SELECT *
FROM rental
WHERE inventory_id in(4582, 4583, 4584)


INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT v.customer_id, v.staff_id, v.rental_id, v.amount, v.payment_date
FROM (
	VALUES
		(1, 1, 32307, 4.99, DATE '2017-03-15'),
		(1, 2, 32308, 9.99, DATE '2017-03-16'),
		(1, 1, 32309, 19.99, DATE '2017-03-17')
) AS v(customer_id, staff_id, rental_id, amount, payment_date)
WHERE NOT EXISTS (
  SELECT 1 FROM public.payment p
  WHERE p.rental_id = v.rental_id
  AND p.payment_date = v.payment_date
  AND p.amount = v.amount
)
RETURNING *;
COMMIT;



