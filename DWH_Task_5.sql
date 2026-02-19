CREATE SCHEMA IF NOT EXISTS sa_online_sales;
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS online_sales_server
FOREIGN DATA WRAPPER file_fdw;


CREATE FOREIGN TABLE sa_online_sales.ext_online_sales (
    i_transaction_id TEXT,
    i_date TEXT,
    product_id TEXT,
    product_category TEXT,
    product_subcategory TEXT,
    product_material TEXT,
    product_cost TEXT,
    supplier_id TEXT,
    supplier_country TEXT,
    supplier_size TEXT,
    landing_page TEXT,
    i_registered_customer TEXT,
    i_customer_id TEXT,
    i_customer_registration_date TEXT,
    i_delivery_address TEXT,
    i_delivered_in TEXT,
    price_retail TEXT,
    price_discount TEXT,
    price_sale TEXT,
    payment_method TEXT,
    payment_status TEXT,
    payment_provider TEXT
)
SERVER online_sales_server
OPTIONS (
    filename '/Library/PostgreSQL/18/data/csv/online_sales_with_payment.csv',
    format 'csv',
    header 'true',
    null 'N/A'
);

CREATE TABLE IF NOT EXISTS sa_online_sales.src_online_sales (
    i_transaction_id TEXT,
    i_date TEXT,
    product_id TEXT,
    product_category TEXT,
    product_subcategory TEXT,
    product_material TEXT,
    product_cost TEXT,
    supplier_id TEXT,
    supplier_country TEXT,
    supplier_size TEXT,
    landing_page TEXT,
    i_registered_customer TEXT,
    i_customer_id TEXT,
    i_customer_registration_date TEXT,
    i_delivery_address TEXT,
    i_delivered_in TEXT,
    price_retail TEXT,
    price_discount TEXT,
    price_sale TEXT,
    payment_method TEXT,
    payment_status TEXT,
    payment_provider TEXT
);
INSERT INTO sa_online_sales.src_online_sales
SELECT *
FROM sa_online_sales.ext_online_sales;

-- Show first 10 rows from source table
SELECT *
FROM sa_online_sales.src_online_sales
LIMIT 10;

SELECT *
FROM sa_online_sales.ext_online_sales
LIMIT 10;