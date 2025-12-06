--CREATE DATABASE fuel_stations

CREATE SCHEMA IF NOT EXISTS fuel;


CREATE TABLE IF NOT EXISTS fuel.fuel 
	(fuel_id serial PRIMARY KEY NOT NULL,
	name text NOT NULL,
	default_price decimal NOT NULL);

CREATE TABLE IF NOT EXISTS fuel.stations
	(station_id serial PRIMARY KEY NOT NULL,
	address text NOT NULL,
	start_date date NOT NULL,
	available_fulltime boolean DEFAULT TRUE NOT NULL,
	fuelling_slots SMALLINT NOT NULL);

CREATE TABLE IF NOT EXISTS fuel.orders
	(order_id serial PRIMARY KEY NOT NULL ,
	provider text NOT NULL,
	order_price decimal NOT NULL,
	order_date date NOT NULL);

CREATE TABLE IF NOT EXISTS fuel.sales
	(transaction_id serial PRIMARY KEY NOT NULL,
	station_id int REFERENCES fuel.stations(station_id) NOT NULL,
	fuel_id int REFERENCES fuel.fuel(fuel_id) NOT NULL,
	amount_litres decimal NOT NULL,
	price decimal NOT NULL,
	payment_type text NOT NULL,
	sale_time timestamp NOT NULL);

--all constraint creation blocks must be rerun together with drop to avoid 'constraint exists errors'
ALTER TABLE fuel.sales
DROP CONSTRAINT IF EXISTS cash_or_card;
ALTER TABLE fuel.sales
ADD CONSTRAINT cash_or_card
CHECK (payment_type IN ('cash','card'));
	
CREATE TABLE IF NOT EXISTS fuel.refills
	(refill_id serial PRIMARY KEY NOT NULL,
	order_id int REFERENCES fuel.orders(order_id) NOT NULL,
	station_id int REFERENCES fuel.stations(station_id) NOT NULL,
	fuel_id int REFERENCES fuel.fuel(fuel_id) NOT NULL,
	amount_litres decimal NOT NULL,
	refill_time timestamp NOT NULL);

ALTER TABLE fuel.refills
DROP CONSTRAINT IF EXISTS refill_new_date;
ALTER TABLE fuel.refills
ADD CONSTRAINT refill_new_date
CHECK (refill_time >= '2024-01-01');
	
CREATE TABLE IF NOT EXISTS fuel.station_fuel
	(station_id int REFERENCES fuel.stations(station_id) NOT NULL,
	fuel_id int REFERENCES fuel.fuel(fuel_id) NOT NULL,
	current_amount_litres decimal NOT NULL,
	max_capacity_litres decimal NOT NULL,
	price decimal NOT NULL,
	discount_price decimal,
	PRIMARY KEY (station_id, fuel_id));

ALTER TABLE fuel.station_fuel
DROP CONSTRAINT IF EXISTS curr_not_neg;
ALTER TABLE fuel.station_fuel
ADD CONSTRAINT curr_not_neg
CHECK (current_amount_litres >= 0);

ALTER TABLE fuel.station_fuel
DROP CONSTRAINT IF EXISTS max_not_neg;
ALTER TABLE fuel.station_fuel
ADD CONSTRAINT max_not_neg
CHECK (max_capacity_litres >= 0);

--onto values

INSERT INTO fuel.fuel (name, default_price)
SELECT t.name, t.default_price
FROM
(VALUES
	('diesel', 4.95),
	('premium', 7.20),
	('gas', 3.00),
	('dieselplus', 5.01),
	('premprem', 7.50),
	('gasgas', 3.50)
) AS t(name, default_price)
WHERE NOT EXISTS (
SELECT 1 FROM fuel.fuel c WHERE c.name = t.name
	AND c.default_price = t.default_price
);


INSERT INTO fuel.stations (address, start_date, available_fulltime, fuelling_slots)
SELECT t.address, t.start_date, t.available_fulltime, t.fuelling_slots
FROM
(VALUES
	('Kazbegi 14', DATE '2025-10-21', FALSE, 4),
	('Vazha 23', DATE '2025-11-02', TRUE, 5),
	('Rustaveli 3', DATE '2025-12-01', TRUE, 3),
	('Chavchavadze 5', DATE '2025-10-22', FALSE, 6),
	('Tabidze 6', DATE '2025-10-23', TRUE, 7),
	('GOGEBASHVILI 10', DATE '2025-11-04', FALSE, 2)
) AS t(address, start_date, available_fulltime, fuelling_slots)
WHERE NOT EXISTS (
SELECT 1 FROM fuel.stations c WHERE c.address = t.address
	AND c.start_date = t.start_date);


INSERT INTO fuel.orders (provider, order_price, order_date)
SELECT t.provider, t.order_price, t.order_date
FROM 
(VALUES
	('bigoil', 7500.25, DATE '2025-11-22'),
	('yumoil', 2012.12, DATE '2025-12-01'),
	('bigoil', 500.00, DATE '2025-12-01'),
	('bigoil', 3200.25, DATE '2025-12-01'),
	('yumoil', 7000, DATE '2025-12-01'),
	('funoil', 0, DATE '2025-12-03') --value  0 on ongoing orders, until its finished, then change. its better than
										 --having to deal with nulls.
		
) AS t(provider, order_price, order_date)
WHERE NOT EXISTS(
SELECT 1 FROM fuel.orders c WHERE c.provider = t.provider
	AND c.order_price = t.order_price
	AND c.order_date = t.order_date);


INSERT INTO fuel.station_fuel (station_id, fuel_id, current_amount_litres, max_capacity_litres, price, discount_price)
SELECT s.station_id, f.fuel_id, 0, 1000, f.default_price, NULL --lets start with empty tanks and default prices from fuel table
FROM fuel.stations s 
CROSS JOIN fuel.fuel f --cross join allows us to get all combinations of fuels in all stations.
WHERE NOT EXISTS (
    SELECT 1 
    FROM fuel.station_fuel sf
    WHERE sf.station_id = s.station_id
      AND sf.fuel_id = f.fuel_id
);


INSERT INTO fuel.sales (station_id, fuel_id, amount_litres, price, payment_type, sale_time)
SELECT 
    s.station_id,
    s.fuel_id,
    s.amount_litres,
    s.amount_litres * sf.price AS price,  --calculating price dynamically.
    s.payment_type,
    s.sale_time
FROM
(VALUES
	(1, 1, 100, 'cash', TIMESTAMP '2025-11-10 10:00:00'),
	(1, 1, 150, 'card', TIMESTAMP '2025-11-20 11:00:00'),
	(1, 1, 50,  'cash', TIMESTAMP '2025-11-21 12:00:00'),
	(2, 2, 120, 'cash', TIMESTAMP '2025-11-22 10:30:00'),
	(2, 2, 80,  'card', TIMESTAMP '2025-11-30 11:30:00'),
	(2, 2, 60,  'cash', TIMESTAMP '2025-12-02 12:30:00')
) AS s(station_id, fuel_id, amount_litres, payment_type, sale_time)
JOIN fuel.station_fuel sf --joining fuel_station allows us to get correct prices
ON sf.station_id = s.station_id
AND sf.fuel_id = s.fuel_id
WHERE NOT EXISTS
(SELECT 1
FROM fuel.sales t
WHERE t.station_id = s.station_id
AND t.fuel_id = s.fuel_id
AND t.sale_time = s.sale_time
);


INSERT INTO fuel.refills (order_id, station_id, fuel_id, amount_litres, refill_time)
SELECT 
    (SELECT MIN(order_id) FROM fuel.orders) AS order_id, 
    r.station_id,
    r.fuel_id,
    r.amount_litres,
    r.refill_time
FROM
(VALUES
	(1, 1, 500, TIMESTAMP '2025-12-03 09:00:00'),
	(2, 1, 300, TIMESTAMP '2025-12-03 10:00:00'),
	(3, 1, 200, TIMESTAMP '2025-12-03 11:00:00'),
	(4, 1, 600, TIMESTAMP '2025-12-03 09:30:00'),
	(5, 1, 400, TIMESTAMP '2025-12-03 10:30:00'),
	(6, 1, 250, TIMESTAMP '2025-12-03 11:30:00')
) AS r(station_id, fuel_id, amount_litres, refill_time)  -- FIX: fuel_id is 2nd, timestamp last
WHERE NOT EXISTS (
SELECT 1
FROM fuel.refills t
WHERE t.order_id = (SELECT MIN(order_id) FROM fuel.orders)
	AND t.fuel_id = r.fuel_id
	AND t.refill_time = r.refill_time
);


CREATE OR REPLACE FUNCTION fuel.update_order
	(n_order_id   int,
    n_column     text,
    n_new_value  text)
RETURNS fuel.orders
LANGUAGE plpgsql
AS $$
DECLARE updated_row fuel.orders;
BEGIN
IF n_column = 'provider' THEN
	UPDATE fuel.orders
	SET provider = n_new_value
	WHERE order_id = n_order_id
	RETURNING * INTO updated_row;
ELSIF n_column = 'order_price' THEN
    UPDATE fuel.orders
    SET order_price = n_new_value::decimal
    WHERE order_id = n_order_id
	RETURNING * INTO updated_row;
ELSIF n_column = 'order_date' THEN
    UPDATE fuel.orders
    SET order_date = n_new_value::date
    WHERE order_id = n_order_id
	RETURNING * INTO updated_row;
ELSE
    RAISE EXCEPTION 'Column "%" cannot be updated by this function', n_column;
END IF;
RETURN updated_row;
END;
$$;
/* quick test:
SELECT fuel.update_order (2,'provider', 'yumoil') --works
SELECT fuel.update_order (31413413,'provider', 'yumoil') --fails correctly
*/


CREATE OR REPLACE FUNCTION fuel.new_sale
(
--id is added incrementally
n_address text,
n_fuel text,
n_amount decimal,
--payment is calculated
n_cashorcard text
--time is always now()
)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
INSERT INTO fuel.sales (station_id, fuel_id, amount_litres, price, payment_type, sale_time)
SELECT s.station_id, sf.fuel_id, n_amount, n_amount * sf.price, n_cashorcard, NOW()
FROM fuel.stations s
JOIN fuel.station_fuel sf ON sf.station_id = s.station_id
JOIN fuel.fuel f ON f.fuel_id = sf.fuel_id
WHERE UPPER(s.address) = UPPER(n_address)
AND UPPER(f.name)   = UPPER(n_fuel);

IF NOT FOUND THEN
RAISE EXCEPTION 'No matching station or fuel found';
END IF;

RETURN 'Transaction added';
END;
$$;

--SELECT fuel.new_sale ('Kazbegi 14', 'diEselPlus', 14.5,'cash') --works! not case sensitive at all

CREATE OR REPLACE VIEW fuel.overview AS
SELECT
    t.address AS station,
    f.name AS fuel,
    SUM(s.amount_litres) AS total_litres,
    SUM(s.price) AS total_revenue,
    SUM(CASE WHEN s.payment_type = 'cash' THEN s.price ELSE 0 END) AS cash_revenue,
    SUM(CASE WHEN s.payment_type = 'card' THEN s.price ELSE 0 END) AS card_revenue
FROM fuel.sales AS s
JOIN fuel.stations AS t ON s.station_id = t.station_id
JOIN fuel.fuel AS f ON s.fuel_id = f.fuel_id
WHERE s.sale_time >= (SELECT MAX(sale_time) - INTERVAL '3 months' FROM fuel.sales)
  AND s.sale_time <= (SELECT MAX(sale_time) FROM fuel.sales)
GROUP BY t.address, f.name
ORDER BY t.address, f.name;

/*
SELECT *
FROM fuel.overview

looks good. depending on what department it is, or what's the kind of information management is looking for, the view
will be altered accordingly.
*/

CREATE ROLE manager --won't let me to add IF NOT EXISTS to role :/ not sure if it should
LOGIN
PASSWORD 'wowgreatofferepamthx';

GRANT CONNECT ON DATABASE fuel_stations TO manager;

GRANT USAGE ON SCHEMA fuel TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA fuel TO manager;

--if we want the manager to autmatically have read permission on future tables, we add this too.
ALTER DEFAULT PRIVILEGES IN SCHEMA fuel
GRANT SELECT ON TABLES TO manager;










