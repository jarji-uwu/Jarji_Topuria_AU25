CREATE SCHEMA IF NOT EXISTS bl_dm;

SELECT * FROM
bl_dm.dim_products 

CREATE TABLE IF NOT EXISTS bl_dm.dim_products (
    product_surr_id     BIGINT PRIMARY KEY,
    product_src_id      VARCHAR(4000) NOT NULL,
    product_name        VARCHAR(4000) NOT NULL,
    product_category    VARCHAR(4000),
    product_subcategory VARCHAR(4000),
    product_material    VARCHAR(4000),

    source_system       VARCHAR(4000) NOT NULL,
    source_entity       VARCHAR(4000) NOT NULL,

    insert_dt           TIMESTAMP NOT NULL,
    update_dt           TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_products_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_suppliers (
    supplier_surr_id  BIGINT PRIMARY KEY,
    supplier_src_id   VARCHAR(4000) NOT NULL,
    supplier_name     VARCHAR(4000) NOT NULL,
    supplier_country  VARCHAR(4000),
    supplier_size     VARCHAR(4000),

    source_system     VARCHAR(4000) NOT NULL,
    source_entity     VARCHAR(4000) NOT NULL,

    insert_dt         TIMESTAMP NOT NULL,
    update_dt         TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_suppliers_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_customers_scd (
    customer_surr_id BIGINT PRIMARY KEY,
    customer_src_id  BIGINT NOT NULL,
    customer_gender  VARCHAR(4000),
    customer_age     INT,
    customer_segment VARCHAR(4000),
    registered_customer BOOLEAN,
    customer_registration_date DATE,

    start_dt DATE NOT NULL,
    end_dt DATE NOT NULL,
    is_active VARCHAR(1) NOT NULL,

    source_system VARCHAR(4000) NOT NULL,
    source_entity VARCHAR(4000) NOT NULL,

    insert_dt TIMESTAMP NOT NULL,
    update_dt TIMESTAMP,

    CONSTRAINT uq_dim_customers_version 
        UNIQUE (customer_src_id, start_dt)
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_customers_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_employees (
    employee_surr_id BIGINT PRIMARY KEY,
    employee_src_id  VARCHAR(4000) NOT NULL,
    employee_role    VARCHAR(4000),
    employee_years   INT,

    source_system    VARCHAR(4000) NOT NULL,
    source_entity    VARCHAR(4000) NOT NULL,

    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_employees_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_stores (
    store_surr_id BIGINT PRIMARY KEY,
    store_src_id  VARCHAR(4000) NOT NULL,
    store_name    VARCHAR(4000) NOT NULL,
    store_brand   VARCHAR(4000),
    store_district VARCHAR(4000),
    store_city     VARCHAR(4000),

    source_system  VARCHAR(4000) NOT NULL,
    source_entity  VARCHAR(4000) NOT NULL,

    insert_dt      TIMESTAMP NOT NULL,
    update_dt      TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_stores_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_landings (
    landing_surr_id BIGINT PRIMARY KEY,
    landing_src_id  VARCHAR(4000) NOT NULL,
    landing_name    VARCHAR(4000) NOT NULL,

    source_system   VARCHAR(4000) NOT NULL,
    source_entity   VARCHAR(4000) NOT NULL,

    insert_dt       TIMESTAMP NOT NULL,
    update_dt       TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_landings_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_deliveries (
    delivery_surr_id BIGINT PRIMARY KEY,
    delivery_src_id  VARCHAR(4000) NOT NULL,
    delivery_address VARCHAR(4000) NOT NULL,

    source_system    VARCHAR(4000) NOT NULL,
    source_entity    VARCHAR(4000) NOT NULL,

    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_deliveries_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_payments (
    payment_surr_id BIGINT PRIMARY KEY,
    payment_src_id  VARCHAR(4000) NOT NULL,
    payment_name    VARCHAR(4000) NOT NULL,
    payment_method  VARCHAR(4000),
    payment_status  VARCHAR(4000),
    payment_provider VARCHAR(4000),

    source_system   VARCHAR(4000) NOT NULL,
    source_entity   VARCHAR(4000) NOT NULL,

    insert_dt       TIMESTAMP NOT NULL,
    update_dt       TIMESTAMP
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_payments_id;


CREATE TABLE IF NOT EXISTS bl_dm.dim_dates (
    date_surr_id      BIGINT PRIMARY KEY,
    full_date         DATE NOT NULL,
    day_number        INT NOT NULL,
    month_number      INT NOT NULL, 
    month_name        VARCHAR(20) NOT NULL,
    year_number       INT NOT NULL,
    quarter_number    INT NOT NULL, 
    day_of_week       INT NOT NULL,
    day_name          VARCHAR(20) NOT NULL,
    is_weekend        BOOLEAN NOT NULL
);


CREATE TABLE IF NOT EXISTS bl_dm.fct_sales (
    sales_surr_id BIGINT PRIMARY KEY,
    sales_src_id  BIGINT NOT NULL,

    event_dt         DATE NOT NULL,

    product_surr_id  BIGINT NOT NULL,
    supplier_surr_id BIGINT NOT NULL,
    customer_surr_id BIGINT NOT NULL,
    store_surr_id    BIGINT,
    employee_surr_id BIGINT,
    delivery_surr_id BIGINT,
    payment_surr_id  BIGINT,
    landing_surr_id  BIGINT,
    date_surr_id     BIGINT NOT NULL,

    price_retail   NUMERIC(18,2) NOT NULL,
    price_discount NUMERIC(18,2),
    price_sale     NUMERIC(18,2) NOT NULL,
    product_cost   NUMERIC(18,2) NOT NULL,
    delivered_in_days INT,
    profit         NUMERIC(18,2) NOT NULL,

    insert_dt TIMESTAMP NOT NULL,
    update_dt TIMESTAMP,

    CONSTRAINT fk_fct_sales_product
        FOREIGN KEY (product_surr_id)
        REFERENCES bl_dm.dim_products(product_surr_id),

    CONSTRAINT fk_fct_sales_supplier
        FOREIGN KEY (supplier_surr_id)
        REFERENCES bl_dm.dim_suppliers(supplier_surr_id),

    CONSTRAINT fk_fct_sales_customer
        FOREIGN KEY (customer_surr_id)
        REFERENCES bl_dm.dim_customers_scd(customer_surr_id),

    CONSTRAINT fk_fct_sales_store
        FOREIGN KEY (store_surr_id)
        REFERENCES bl_dm.dim_stores(store_surr_id),

    CONSTRAINT fk_fct_sales_employee
        FOREIGN KEY (employee_surr_id)
        REFERENCES bl_dm.dim_employees(employee_surr_id),

    CONSTRAINT fk_fct_sales_delivery
        FOREIGN KEY (delivery_surr_id)
        REFERENCES bl_dm.dim_deliveries(delivery_surr_id),

    CONSTRAINT fk_fct_sales_payment
        FOREIGN KEY (payment_surr_id)
        REFERENCES bl_dm.dim_payments(payment_surr_id),

    CONSTRAINT fk_fct_sales_landing
        FOREIGN KEY (landing_surr_id)
        REFERENCES bl_dm.dim_landings(landing_surr_id),

    CONSTRAINT fk_fct_sales_date
        FOREIGN KEY (date_surr_id)
        REFERENCES bl_dm.dim_dates(date_surr_id)
);

CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_fct_sales_id;