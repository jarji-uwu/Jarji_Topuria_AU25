--TASK 2

--1)Create a new user with the username "rentaluser" and the password "rentalpassword". 
--Give the user the ability to connect to the database but no other permissions.

--adding login to make it a user and not just a role.
CREATE ROLE rentaluser
LOGIN PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;


--2)Grant "rentaluser" SELECT permission for the "customer" table.
--Сheck to make sure this permission works correctly—write a SQL query to select all customers.

--usage on schema is a must to access the table later.
GRANT USAGE ON SCHEMA public TO rentaluser;
GRANT SELECT ON public.customer TO rentaluser;
--test
SET ROLE rentaluser;
SELECT *
FROM public.customer
LIMIT 10;
--back to superuser 
RESET ROLE;


--3)Create a new user group called "rental" and add "rentaluser" to the group. 

-- no LOGIN, group role
CREATE ROLE rental;
--membership to our previous user
--lets allow rentaluser to inherit accesses of rental
ALTER ROLE rentaluser INHERIT;
GRANT rental TO rentaluser;


--4)Grant the "rental" group INSERT and UPDATE permissions for the "rental" table.
--Insert a new row and update one existing row in the "rental" table under that role. 

--granting accesses. Granting select too, otherwise update doesn't work on rows.

GRANT USAGE ON SCHEMA public TO rental;
GRANT INSERT, UPDATE, SELECT ON public.rental TO rental;
--for the update that we want, there is a foreign key from

--turns out, we need access to sequence to use the rental_id serial feature
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO rental;
--conducting operations as rentaluser.
SET ROLE rental;
--ID is serial so no need to specify.
INSERT INTO public.rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 1, 1);


--in addition to codes above, I manually set rental's premissions to rental table, as it was
--struggling to work otherwise :(
UPDATE public.rental
SET return_date = NOW()
WHERE rental_id = 32310;


RESET ROLE;

--5)Revoke the "rental" group's INSERT permission for the "rental" table.
--Try to insert new rows into the "rental" table make sure this action is denied.

--revoking
REVOKE INSERT ON public.rental FROM rental;

--testing
SET ROLE rental;
INSERT INTO public.rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 2, 2, 2);
--we get error message:
-- SQL Error [42501]: ERROR: permission denied for table rental
--Error position:

--back to being almighty:
RESET ROLE;

--6)Create a personalized role for any customer already existing in the dvd_rental database.
--The name of the role name must be client_{first_name}_{last_name} (omit curly brackets).
--The customer's payment and rental history must not be empty. 

--lets look for such customer with a query instead of scouring them one by one:
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN rental  r ON r.customer_id = c.customer_id
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) > 0
   AND COUNT(p.payment_id) > 0
LIMIT 1;

--customer with id 1 - Jarji Topuria

CREATE ROLE client_JARJI_TOPURIA
LOGIN
PASSWORD 'thx4offerEpamWow';


--TASK 3
--Read about row-level security (https://www.postgresql.org/docs/12/ddl-rowsecurity.html) 
--Configure that role so that the customer can only access their own data in the "rental" and "payment" tables.
--Write a query to make sure this user sees only their own data.

--switch on rls first
ALTER TABLE rental  ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

--basic rights for the customer
GRANT CONNECT ON DATABASE dvdrental TO client_JARJI_TOPURIA;
GRANT USAGE ON SCHEMA public TO client_JARJI_TOPURIA;

--granting 'select' access to role client_jarji_topuria basedo n their own customer id of 1.
CREATE POLICY personal_Access
ON rental
FOR SELECT
TO client_JARJI_TOPURIA
USING (customer_id = 1);

--same with payment table
CREATE POLICY personal_access_payment
ON payment
FOR SELECT
TO client_JARJI_TOPURIA
USING (customer_id = 1);

--lets test what client_jarji_topuria sees:
--role must have a general select access to tables to see rls-filtered rows. RLS overrides the general select right
GRANT SELECT ON rental TO client_JARJI_TOPURIA;
GRANT SELECT ON payment TO client_JARJI_TOPURIA;

SET SESSION AUTHORIZATION client_JARJI_TOPURIA;

SELECT * FROM rental;
SELECT * FROM payment;

--jarji topuria sees only 4 rental rows and 3 payment rowss. all on customer_id 1. PErfect!

--back to being almighty
RESET ROLE;
RESET  SESSION authorization





















