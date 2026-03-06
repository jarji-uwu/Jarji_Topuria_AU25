CREATE SCHEMA IF NOT EXISTS sa_retail_sales;

CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS retail_sales_server
FOREIGN DATA WRAPPER file_fdw;

CREATE FOREIGN TABLE IF NOT EXISTS sa_retail_sales.ext_retail_sales (
    transaction_id        VARCHAR(4000),
    "date"                VARCHAR(4000),
    product_id            VARCHAR(4000),
    product_category      VARCHAR(4000),
    product_subcategory   VARCHAR(4000),
    product_material      VARCHAR(4000),
    product_cost          VARCHAR(4000),
    supplier_id           VARCHAR(4000),
    supplier_country      VARCHAR(4000),
    supplier_size         VARCHAR(4000),
    store_id              VARCHAR(4000),
    store_district        VARCHAR(4000),
    store_city            VARCHAR(4000),
    store_brand           VARCHAR(4000),
    seller_employee_id    VARCHAR(4000),
    seller_employee_role  VARCHAR(4000),
    seller_employee_years VARCHAR(4000),
    customer_id           VARCHAR(4000),
    customer_gender       VARCHAR(4000),
    customer_age          VARCHAR(4000),
    customer_segment      VARCHAR(4000),
    price_retail          VARCHAR(4000),
    price_discount        VARCHAR(4000),
    price_sale            VARCHAR(4000)
)
SERVER retail_sales_server
OPTIONS (
    filename '/Library/PostgreSQL/18/data/csv/retail_furniture_sales_data.csv',
    format 'csv',
    header 'true',
    delimiter ';'
);

CREATE TABLE IF NOT EXISTS sa_retail_sales.src_retail_sales (
    transaction_id        VARCHAR(4000),
    "date"                VARCHAR(4000),
    product_id            VARCHAR(4000),
    product_category      VARCHAR(4000),
    product_subcategory   VARCHAR(4000),
    product_material      VARCHAR(4000),
    product_cost          VARCHAR(4000),
    supplier_id           VARCHAR(4000),
    supplier_country      VARCHAR(4000),
    supplier_size         VARCHAR(4000),
    store_id              VARCHAR(4000),
    store_district        VARCHAR(4000),
    store_city            VARCHAR(4000),
    store_brand           VARCHAR(4000),
    seller_employee_id    VARCHAR(4000),
    seller_employee_role  VARCHAR(4000),
    seller_employee_years VARCHAR(4000),
    customer_id           VARCHAR(4000),
    customer_gender       VARCHAR(4000),
    customer_age          VARCHAR(4000),
    customer_segment      VARCHAR(4000),
    price_retail          VARCHAR(4000),
    price_discount        VARCHAR(4000),
    price_sale            VARCHAR(4000)
);

INSERT INTO sa_retail_sales.src_retail_sales (
    transaction_id,
    "date",
    product_id,
    product_category,
    product_subcategory,
    product_material,
    product_cost,
    supplier_id,
    supplier_country,
    supplier_size,
    store_id,
    store_district,
    store_city,
    store_brand,
    seller_employee_id,
    seller_employee_role,
    seller_employee_years,
    customer_id,
    customer_gender,
    customer_age,
    customer_segment,
    price_retail,
    price_discount,
    price_sale
)
SELECT
    transaction_id,
    "date",
    product_id,
    product_category,
    product_subcategory,
    product_material,
    product_cost,
    supplier_id,
    supplier_country,
    supplier_size,
    store_id,
    store_district,
    store_city,
    store_brand,
    seller_employee_id,
    seller_employee_role,
    seller_employee_years,
    customer_id,
    customer_gender,
    customer_age,
    customer_segment,
    price_retail,
    price_discount,
    price_sale
FROM sa_retail_sales.ext_retail_sales;

SELECT * FROM sa_retail_sales.ext_retail_sales LIMIT 10;
SELECT * FROM sa_retail_sales.src_retail_sales LIMIT 10;
