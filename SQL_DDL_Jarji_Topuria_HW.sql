-- first - CREATE DATABASE auction_house;
--don't run 'create database' with the rest of the code

DROP SCHEMA IF EXISTS auction CASCADE;
CREATE SCHEMA auction;

DROP TABLE IF EXISTS auction.bidding CASCADE;
DROP TABLE IF EXISTS auction.items_auctions CASCADE;
DROP TABLE IF EXISTS auction.items CASCADE;
DROP TABLE IF EXISTS auction.auctions_employees CASCADE;
DROP TABLE IF EXISTS auction.employees CASCADE;
DROP TABLE IF EXISTS auction.auctions CASCADE;
DROP TABLE IF EXISTS auction.persons CASCADE;
DROP TABLE IF EXISTS auction.firms CASCADE;
DROP TABLE IF EXISTS auction.categories CASCADE;
DROP TABLE IF EXISTS auction.accounts CASCADE;

--In the previous schema, the initial account ids were generated in tables firm and persons, accounts table took values
--from them with a foreign key relationship. This turned out to be technically faulty, so I changed the setup.
--Accounts table will generate the initial ids with SERIAL datatype and it will be distributed to firm and persons tables
--with foreign key, based on type of account. This is currently not applied as it requires triggers.
--Changed varchars to texts for flexibility.
--Floats changed to decimals for prices as we want exact values.
--Drop cascade PK added to PKs that produce foreign keys in other tables for rerunnability.
--Personal ids in persons and employees changed to bigint to fit the intended format.
--Not sure what the record_ts table is for, but added to each table as required by task.
CREATE TABLE IF NOT EXISTS auction.accounts(
accounts_id serial,
acc_type text NOT NULL ,
registration_date date NOT NULL,
status text NOT NULL ,
closing_date date
);

ALTER TABLE auction.accounts
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

--some constraints applied separately, outside CREATE TABLE as recommended in theoretical materials and teams chat
--we drop primary key constraint before applying for rerunnability. Same is applied to some other constraints
--that cause error if applied without droppin first. 'NOT NULL' for example can be reapplied without dropping first.
ALTER TABLE auction.accounts
DROP CONSTRAINT IF EXISTS accounts_pk cascade;
ALTER TABLE auction.accounts
ADD CONSTRAINT accounts_pk
PRIMARY KEY (accounts_id);

ALTER TABLE auction.accounts
DROP CONSTRAINT IF EXISTS acc_type_check;
--each account has to be a firm (company/organization) or a person. we'll divide them in corresponding tables later.
ALTER TABLE auction.accounts
ADD CONSTRAINT acc_type_check
CHECK (acc_type IN ('firm','person'));

ALTER TABLE auction.accounts
DROP CONSTRAINT IF EXISTS acc_reg_date_check;
--task requirement to have some dates >year 2000
ALTER TABLE auction.accounts
ADD CONSTRAINT acc_reg_date_check
CHECK (registration_date >= '2000-01-01');

ALTER TABLE auction.accounts
DROP CONSTRAINT IF EXISTS acc_status_check;
--also binary option -  account is either active, or closed.
ALTER TABLE auction.accounts
ADD CONSTRAINT acc_status_check
CHECK (status IN ('active','closed'));

ALTER TABLE auction.accounts
DROP CONSTRAINT IF EXISTS acc_closing_date_later;
--ensuring accounts cant be closed before they're ever registered
ALTER TABLE auction.accounts
ADD CONSTRAINT acc_closing_date_later
CHECK (closing_date >= registration_date);


--onto firms and persons tables. we'll have foreign key for each connected to accounts table. In addition we have
--firm_id and person_id, which will be natural alternate keys.
CREATE TABLE IF NOT EXISTS auction.firms (
account_id integer,
firm_id integer NOT NULL,
firm_name text NOT NULL
);

ALTER TABLE auction.firms
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.firms
DROP CONSTRAINT IF EXISTS firms_pk;
ALTER TABLE auction.firms
ADD CONSTRAINT firms_pk
PRIMARY KEY (firm_id);

ALTER TABLE auction.firms
DROP CONSTRAINT IF EXISTS firms_account_fk;
ALTER TABLE auction.firms
ADD CONSTRAINT firms_account_fk
FOREIGN KEY (account_id)
REFERENCES auction.accounts(accounts_id);

--firms_id is a natural unique alternate key.
ALTER TABLE auction.firms
DROP CONSTRAINT IF EXISTS firms_firm_id_unique;
ALTER TABLE auction.firms
ADD CONSTRAINT firms_firm_id_unique
UNIQUE (firm_id);


CREATE TABLE IF NOT EXISTS auction.persons (
account_id integer,
personal_id bigint NOT NULL, --bigint for personal ids
first_name text NOT NULL,
last_name text NOT NULL
);

ALTER TABLE auction.persons
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.persons
DROP CONSTRAINT IF EXISTS persons_pk;
ALTER TABLE auction.persons
ADD CONSTRAINT persons_pk
PRIMARY KEY (personal_id);

ALTER TABLE auction.persons
DROP CONSTRAINT IF EXISTS persons_account_fk;
ALTER TABLE auction.persons
ADD CONSTRAINT persons_account_fk
FOREIGN KEY (account_id)
REFERENCES auction.accounts(accounts_id);

--personal_id is a natural unique alternate key.
ALTER TABLE auction.persons
DROP CONSTRAINT IF EXISTS persons_personal_id_unique;
ALTER TABLE auction.persons
ADD CONSTRAINT persons_personal_id_unique
UNIQUE (personal_id);


--next, categories as items table is dependent on it.
CREATE TABLE IF NOT EXISTS auction.categories (
item_category_id serial,
name text NOT NULL,
description text
);

ALTER TABLE auction.categories
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.categories
DROP CONSTRAINT IF EXISTS categories_pk CASCADE;
ALTER TABLE auction.categories
ADD CONSTRAINT categories_pk
PRIMARY KEY (item_category_id);

--items table has 3 foreign keys - each account can be a buyer or a seller of multitude of items - one to many relationship.
--there can be lots of items with the same item category - also one to many relationship. some columns can be null, such as
--buyer_id - if the item is not sold yet, production_year - if it's unknown or the seller refuses to share, item_description -
--may be unnecessary for some items, parent_item_id - will be relevant only for items that are a part of larger set.
CREATE TABLE IF NOT EXISTS auction.items (
item_id serial,
item_name text NOT NULL,
seller_id integer NOT NULL,
available boolean NOT NULL,
buyer_id integer,
production_year smallint,
item_category_id integer NOT NULL,
item_description text,
starting_price decimal(12,2)NOT NULL,
parent_item_id bigint,
sold_price decimal(12,2)
);

ALTER TABLE auction.items
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.items
DROP CONSTRAINT IF EXISTS items_pk CASCADE;
ALTER TABLE auction.items
ADD CONSTRAINT items_pk
PRIMARY KEY (item_id);

ALTER TABLE auction.items
DROP CONSTRAINT IF EXISTS items_seller_fk;
ALTER TABLE auction.items
ADD CONSTRAINT items_seller_fk
FOREIGN KEY (seller_id)
REFERENCES auction.accounts(accounts_id);

ALTER TABLE auction.items
DROP CONSTRAINT IF EXISTS items_buyer_fk;
ALTER TABLE auction.items
ADD CONSTRAINT items_buyer_fk
FOREIGN KEY (buyer_id)
REFERENCES auction.accounts(accounts_id);

ALTER TABLE auction.items
DROP CONSTRAINT IF EXISTS items_category_fk;
ALTER TABLE auction.items
ADD CONSTRAINT items_category_fk
FOREIGN KEY (item_category_id)
REFERENCES auction.categories(item_category_id);

--ensuring prices are not negative
ALTER TABLE auction.items
DROP CONSTRAINT IF EXISTS items_price_positive;
ALTER TABLE auction.items
ADD CONSTRAINT items_price_positive
CHECK (
starting_price >= 0
AND (sold_price IS NULL OR sold_price >= 0)
);


--next, auctions table which will open path to the rest of the tables.
CREATE TABLE IF NOT EXISTS auction.auctions (
auction_id serial,
start_time timestamp NOT NULL,
end_time timestamp NOT NULL,
location text NOT NULL
);

ALTER TABLE auction.auctions
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.auctions
DROP CONSTRAINT IF EXISTS auctions_pk CASCADE;
ALTER TABLE auction.auctions
ADD CONSTRAINT auctions_pk
PRIMARY KEY (auction_id);

--moving onto items_auctions table, which is a bridge table to support many to many relationship between items and auctions.
--One item may appear on many auctions and one auction holds many items. Additionally, we have lot_number column, which
--is given to each item on each auction. auction_id and item_id foreign keys make a compound primary key.
CREATE TABLE IF NOT EXISTS auction.items_auctions (
auction_id integer NOT NULL,
item_id integer NOT NULL,
lot_number integer NOT NULL
);

ALTER TABLE auction.items_auctions
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.items_auctions
DROP CONSTRAINT IF EXISTS items_auctions_pk;
ALTER TABLE auction.items_auctions
ADD CONSTRAINT items_auctions_pk
PRIMARY KEY (auction_id, item_id);

ALTER TABLE auction.items_auctions
DROP CONSTRAINT IF EXISTS items_auctions_auction_fk;
ALTER TABLE auction.items_auctions
ADD CONSTRAINT items_auctions_auction_fk
FOREIGN KEY (auction_id)
REFERENCES auction.auctions(auction_id);

ALTER TABLE auction.items_auctions
DROP CONSTRAINT IF EXISTS items_auctions_item_fk;
ALTER TABLE auction.items_auctions
ADD CONSTRAINT items_auctions_item_fk
FOREIGN KEY (item_id)
REFERENCES auction.items(item_id);

--next - bidding table which will likely contain the most data. We have 3 foreign keys - auction, item and account.
--there is a distinct primary key. We can not make a compound key out of auction, item, account columns, as one entity can
--bid on the same item on the same auction more than once. Sold is boolean - true or false.

CREATE TABLE IF NOT EXISTS auction.bidding (
bid_id serial,
auction_id integer NOT NULL,
item_id integer NOT NULL,
account_id integer NOT NULL,
bid_number integer NOT NULL,
price decimal(12,2) NOT NULL,
sold boolean NOT NULL,
bid_time timestamp NOT NULL
);

ALTER TABLE auction.bidding
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.bidding
DROP CONSTRAINT IF EXISTS bidding_pk;
ALTER TABLE auction.bidding
ADD CONSTRAINT bidding_pk
PRIMARY KEY (bid_id);

ALTER TABLE auction.bidding
DROP CONSTRAINT IF EXISTS bidding_auction_fk;
ALTER TABLE auction.bidding
ADD CONSTRAINT bidding_auction_fk
FOREIGN KEY (auction_id)
REFERENCES auction.auctions(auction_id);

ALTER TABLE auction.bidding
DROP CONSTRAINT IF EXISTS bidding_item_fk;
ALTER TABLE auction.bidding
ADD CONSTRAINT bidding_item_fk
FOREIGN KEY (item_id)
REFERENCES auction.items(item_id);

ALTER TABLE auction.bidding
DROP CONSTRAINT IF EXISTS bidding_account_fk;
ALTER TABLE auction.bidding
ADD CONSTRAINT bidding_account_fk
FOREIGN KEY (account_id)
REFERENCES auction.accounts(accounts_id);

--ensuring price is not negative
ALTER TABLE auction.bidding
DROP CONSTRAINT IF EXISTS bidding_price_positive;
ALTER TABLE auction.bidding
ADD CONSTRAINT bidding_price_positive
CHECK (price >= 0);

--creating empoloyees table to finish up with employees-auctions bridge table. personal_id is a unique alaternate key
CREATE TABLE IF NOT EXISTS auction.employees (
employee_id serial,
personal_id bigint NOT NULL, --bigint to fit personal id
first_name text NOT NULL,
last_name text NOT NULL,
salary decimal(12,2) NOT NULL,
position text NOT NULL
);

ALTER TABLE auction.employees
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.employees
DROP CONSTRAINT IF EXISTS employees_pk CASCADE;
ALTER TABLE auction.employees
ADD CONSTRAINT employees_pk
PRIMARY KEY (employee_id);

ALTER TABLE auction.employees
DROP CONSTRAINT IF EXISTS employees_personal_id_unique;
ALTER TABLE auction.employees
ADD CONSTRAINT employees_personal_id_unique
UNIQUE (personal_id);


--and finally, auctions_employees many to many bridge table. one employee can take part in different auctions and
--one auction can have many employees working on it.
CREATE TABLE IF NOT EXISTS auction.auctions_employees (
auction_id integer NOT NULL,
employee_id integer NOT NULL,
role text NOT NULL
);

ALTER TABLE auction.auctions_employees
ADD COLUMN record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE auction.auctions_employees
DROP CONSTRAINT IF EXISTS auctions_employees_pk;
ALTER TABLE auction.auctions_employees
ADD CONSTRAINT auctions_employees_pk
PRIMARY KEY (auction_id, employee_id);

ALTER TABLE auction.auctions_employees
DROP CONSTRAINT IF EXISTS auctions_employees_auction_fk;
ALTER TABLE auction.auctions_employees
ADD CONSTRAINT auctions_employees_auction_fk
FOREIGN KEY (auction_id)
REFERENCES auction.auctions(auction_id);

ALTER TABLE auction.auctions_employees
DROP CONSTRAINT IF EXISTS auctions_employees_employee_fk;
ALTER TABLE auction.auctions_employees
ADD CONSTRAINT auctions_employees_employee_fk
FOREIGN KEY (employee_id)
REFERENCES auction.employees(employee_id);


--onto adding values to tables. min 2 each.
--there are no necessary rerunnability steps here, as we are dropping and adding a table above. All values will be dropped
--and reinserted each time the code runs. Of course, if we want to make this part separately rerunnable without making duplicates,
--we'd add a constraint of uniquness to combination of first name+last name and firm name

INSERT INTO auction.accounts (acc_type, registration_date, status, closing_date)
VALUES 
('firm',   '2025-05-05', 'active', NULL),
('firm',   '2025-01-01', 'active', NULL),
('person', '2025-06-13', 'active', NULL),
('person', '2024-08-10', 'closed', '2025-09-10');

INSERT INTO auction.firms (account_id, firm_id, firm_name)
VALUES
(1, 405405405, 'epam'),
(2, 406406406, 'bolt');

INSERT INTO auction.persons (account_id, personal_id, first_name, last_name)
VALUES
(3, 01010101001, 'Jarji', 'Topuria'),
(4, 02020202002, 'Leo', 'Messi');

INSERT INTO auction.categories (name, description)
VALUES
('paintings', NULL),
('weapons', 'swords, axes, maces, shields, spears, guns, etc...');

INSERT INTO auction.items 
(item_name, seller_id, available, buyer_id, production_year, item_category_id, item_description, starting_price, parent_item_id, sold_price)
VALUES
('Sunset Over River', 1, true, NULL, 2015, 1, 'Oil painting on canvas', 350.00, NULL, NULL),
('Viking Longsword', 2, false, 3, 1890, 2, 'Antique steel blade, oak handle', 900.00, NULL, 1250.00);

INSERT INTO auction.auctions (start_time, end_time, location)
VALUES
('2025-07-01 14:00', '2025-07-01 18:00', 'Tbilisi Exhibition Hall'),
('2025-08-15 10:00', '2025-08-15 16:00', 'Batumi Art Center');

--item_auction values are better filled with triggers. Still, this is an example of non-hardcoded ids. Downside is
--manually writing in name of the items and auction locations.
INSERT INTO auction.items_auctions (auction_id, item_id, lot_number)
SELECT a.auction_id, i.item_id, 10
FROM auction.auctions a
JOIN auction.items i ON i.item_name = 'Sunset Over River'
WHERE a.location = 'Tbilisi Exhibition Hall';

INSERT INTO auction.items_auctions (auction_id, item_id, lot_number)
SELECT a.auction_id, i.item_id, 5
FROM auction.auctions a
JOIN auction.items i ON i.item_name = 'Viking Longsword'
WHERE a.location = 'Batumi Art Center';

INSERT INTO auction.employees (personal_id, first_name, last_name, salary, position)
VALUES
(11111111111, 'Nika', 'Beridze', 1800.00, 'Auctioneer'),
(22222222222, 'Mariam', 'Kapanadze', 1500.00, 'Assistant');

INSERT INTO auction.bidding
(auction_id, item_id, account_id, bid_number, price, sold, bid_time)
VALUES
(1, 1, 3, 1, 400.00, false, '2025-07-01 14:15'),
(1, 1, 4, 2, 450.00, false, '2025-07-01 14:20'),
(2, 2, 3, 1, 950.00, true,  '2025-08-15 10:30'),
(2, 2, 4, 2, 1000.00, true, '2025-08-15 10:34');

INSERT INTO auction.auctions_employees
(auction_id, employee_id, role)
VALUES
(1, 1, 'Lead Auctioneer'),
(2, 1, 'Lead Auctioneer'),
(2, 2, 'Assistant');




