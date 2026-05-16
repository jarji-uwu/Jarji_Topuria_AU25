
INSERT INTO bl_dm.dim_employees (
    employee_surr_id,
    employee_src_id,
    employee_role,
    employee_years,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    -1,
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;

INSERT INTO bl_dm.dim_products (
    product_surr_id,
    product_src_id,
    product_name,
    product_category,
    product_subcategory,
    product_material,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;


ALTER TABLE bl_dm.dim_products
DROP COLUMN product_name;

ALTER TABLE bl_dm.dim_products
ADD CONSTRAINT uq_dim_products_src
UNIQUE (product_src_id);

INSERT INTO bl_dm.dim_landings (
    landing_surr_id,
    landing_src_id,
    landing_name,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;

ALTER TABLE bl_dm.dim_landings
ADD CONSTRAINT uq_dim_landings_src
UNIQUE (landing_src_id);


INSERT INTO bl_dm.dim_deliveries (
    delivery_surr_id,
    delivery_src_id,
    delivery_address,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;

ALTER TABLE bl_dm.dim_deliveries
ADD CONSTRAINT uq_dim_deliveries_src
UNIQUE (delivery_src_id);


--payments

ALTER TABLE bl_dm.dim_payments
DROP COLUMN payment_name;

INSERT INTO bl_dm.dim_payments (
    payment_surr_id,
    payment_src_id,
    payment_method,
    payment_status,
    payment_provider,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;


--stores

INSERT INTO bl_dm.dim_stores (
    store_surr_id,
    store_src_id,
    store_name,
    store_brand,
    store_district,
    store_city,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;

ALTER TABLE bl_dm.dim_stores
ADD CONSTRAINT uq_dim_stores_src
UNIQUE (store_src_id);


--customer

INSERT INTO bl_dm.dim_customers_scd (
    customer_surr_id,
    customer_src_id,
    customer_gender,
    customer_age,
    customer_segment,
    registered_customer,
    customer_registration_date,
    start_dt,
    end_dt,
    is_active,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    -1,
    'N/A',
    -1,
    'N/A',
    FALSE,
    NULL,
    DATE '1900-01-01',
    DATE '9999-12-31',
    'Y',
    'MANUAL',
    'MANUAL',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT DO NOTHING;

INSERT INTO bl_dm.dim_suppliers (
    supplier_surr_id,
    supplier_src_id,
    supplier_country,
    supplier_size,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)
VALUES (
    -1,
    'N/A',
    'N/A',
    'N/A',
    'MANUAL',
    'MANUAL',
    CURRENT_DATE,
    CURRENT_DATE
)
ON CONFLICT DO NOTHING;