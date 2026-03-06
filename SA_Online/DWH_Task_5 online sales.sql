CREATE SCHEMA IF NOT EXISTS sa_online_sales;

CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS online_sales_server
FOREIGN DATA WRAPPER file_fdw;

CREATE FOREIGN TABLE IF NOT EXISTS sa_online_sales.ext_online_sales (
    i_transaction_id               VARCHAR(4000),
    i_date                          VARCHAR(4000),
    product_id                     VARCHAR(4000),
    product_category               VARCHAR(4000),
    product_subcategory             VARCHAR(4000),
    product_material               VARCHAR(4000),
    product_cost                   VARCHAR(4000),
    supplier_id                    VARCHAR(4000),
    supplier_country               VARCHAR(4000),
    supplier_size                  VARCHAR(4000),
    landing_page                   VARCHAR(4000),
    i_registered_customer           VARCHAR(4000),
    i_customer_id                  VARCHAR(4000),
    i_customer_registration_date   VARCHAR(4000),
    i_delivery_address             VARCHAR(4000),
    i_delivered_in                 VARCHAR(4000),
    price_retail                   VARCHAR(4000),
    price_discount                 VARCHAR(4000),
    price_sale                     VARCHAR(4000),
    payment_method                 VARCHAR(4000),
    payment_status                 VARCHAR(4000),
    payment_provider               VARCHAR(4000)
)
SERVER online_sales_server
OPTIONS (
    filename '/Library/PostgreSQL/18/data/csv/online_sales_with_payment.csv',
    format 'csv',
    header 'true',
    null 'N/A'
);

CREATE TABLE IF NOT EXISTS sa_online_sales.src_online_sales (
    i_transaction_id               VARCHAR(4000),
    i_date                          VARCHAR(4000),
    product_id                     VARCHAR(4000),
    product_category               VARCHAR(4000),
    product_subcategory             VARCHAR(4000),
    product_material               VARCHAR(4000),
    product_cost                   VARCHAR(4000),
    supplier_id                    VARCHAR(4000),
    supplier_country               VARCHAR(4000),
    supplier_size                  VARCHAR(4000),
    landing_page                   VARCHAR(4000),
    i_registered_customer           VARCHAR(4000),
    i_customer_id                  VARCHAR(4000),
    i_customer_registration_date   VARCHAR(4000),
    i_delivery_address             VARCHAR(4000),
    i_delivered_in                 VARCHAR(4000),
    price_retail                   VARCHAR(4000),
    price_discount                 VARCHAR(4000),
    price_sale                     VARCHAR(4000),
    payment_method                 VARCHAR(4000),
    payment_status                 VARCHAR(4000),
    payment_provider               VARCHAR(4000)
);

INSERT INTO sa_online_sales.src_online_sales (
    i_transaction_id,
    i_date,
    product_id,
    product_category,
    product_subcategory,
    product_material,
    product_cost,
    supplier_id,
    supplier_country,
    supplier_size,
    landing_page,
    i_registered_customer,
    i_customer_id,
    i_customer_registration_date,
    i_delivery_address,
    i_delivered_in,
    price_retail,
    price_discount,
    price_sale,
    payment_method,
    payment_status,
    payment_provider
)
SELECT
    i_transaction_id,
    i_date,
    product_id,
    product_category,
    product_subcategory,
    product_material,
    product_cost,
    supplier_id,
    supplier_country,
    supplier_size,
    landing_page,
    i_registered_customer,
    i_customer_id,
    i_customer_registration_date,
    i_delivery_address,
    i_delivered_in,
    price_retail,
    price_discount,
    price_sale,
    payment_method,
    payment_status,
    payment_provider
FROM sa_online_sales.ext_online_sales;

-- sanity checks
SELECT *
FROM sa_online_sales.ext_online_sales
LIMIT 10;

SELECT *
FROM sa_online_sales.src_online_sales
LIMIT 10;

