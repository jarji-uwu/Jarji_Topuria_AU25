

INSERT INTO bl_3nf.ce_products (
    PRODUCT_ID,
    PRODUCT_SRC_ID,
    PRODUCT_CATEGORY,
    PRODUCT_SUBCATEGORY,
    PRODUCT_MATERIAL,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    'n.a.',
    'n.a.',
    CURRENT_DATE,
    CURRENT_DATE,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products
    WHERE PRODUCT_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_products (
    PRODUCT_ID,
    PRODUCT_SRC_ID,
    PRODUCT_CATEGORY,
    PRODUCT_SUBCATEGORY,
    PRODUCT_MATERIAL,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_products_id'),
    x.product_src_id,
    x.product_category,
    x.product_subcategory,
    x.product_material,
    CURRENT_DATE,
    CURRENT_DATE,
    'RETAIL',
    'SRC_RETAIL_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(product_id, 'n.a.')         AS product_src_id,
        COALESCE(product_category, 'n.a.')   AS product_category,
        COALESCE(product_subcategory, 'n.a.') AS product_subcategory,
        COALESCE(product_material, 'n.a.')   AS product_material
    FROM sa_retail_sales.src_retail_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products p
    WHERE p.product_src_id = x.product_src_id
      AND p.source_system = 'RETAIL'
);

COMMIT;

INSERT INTO bl_3nf.ce_products (
    PRODUCT_ID,
    PRODUCT_SRC_ID,
    PRODUCT_CATEGORY,
    PRODUCT_SUBCATEGORY,
    PRODUCT_MATERIAL,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_products_id'),
    x.product_src_id,
    x.product_category,
    x.product_subcategory,
    x.product_material,
    CURRENT_DATE,
    CURRENT_DATE,
    'ONLINE',
    'SRC_ONLINE_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(product_id, 'n.a.')           AS product_src_id,
        COALESCE(product_category, 'n.a.')     AS product_category,
        COALESCE(product_subcategory, 'n.a.')  AS product_subcategory,
        COALESCE(product_material, 'n.a.')     AS product_material
    FROM sa_online_sales.src_online_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products p
    WHERE p.product_src_id = x.product_src_id
      AND p.source_system = 'ONLINE'
);

COMMIT;

INSERT INTO bl_3nf.ce_suppliers (
    SUPPLIER_ID,
    SUPPLIER_SRC_ID,
    SUPPLIER_COUNTRY,
    SUPPLIER_SIZE,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    'n.a.',
    CURRENT_DATE,
    CURRENT_DATE,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_suppliers
    WHERE SUPPLIER_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_suppliers (
    SUPPLIER_ID,
    SUPPLIER_SRC_ID,
    SUPPLIER_COUNTRY,
    SUPPLIER_SIZE,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_suppliers_id'),
    x.supplier_src_id,
    x.supplier_country,
    x.supplier_size,
    CURRENT_DATE,
    CURRENT_DATE,
    'RETAIL',
    'SRC_RETAIL_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(supplier_id, 'n.a.')       AS supplier_src_id,
        COALESCE(supplier_country, 'n.a.')  AS supplier_country,
        COALESCE(supplier_size, 'n.a.')     AS supplier_size
    FROM sa_retail_sales.src_retail_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_suppliers s
    WHERE s.supplier_src_id = x.supplier_src_id
      AND s.source_system = 'RETAIL'
);


COMMIT;


INSERT INTO bl_3nf.ce_suppliers (
    SUPPLIER_ID,
    SUPPLIER_SRC_ID,
    SUPPLIER_COUNTRY,
    SUPPLIER_SIZE,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_suppliers_id'),
    x.supplier_src_id,
    x.supplier_country,
    x.supplier_size,
    CURRENT_DATE,
    CURRENT_DATE,
    'ONLINE',
    'SRC_ONLINE_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(supplier_id, 'n.a.')       AS supplier_src_id,
        COALESCE(supplier_country, 'n.a.')  AS supplier_country,
        COALESCE(supplier_size, 'n.a.')     AS supplier_size
    FROM sa_online_sales.src_online_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_suppliers s
    WHERE s.supplier_src_id = x.supplier_src_id
      AND s.source_system = 'ONLINE'
);

COMMIT;


INSERT INTO bl_3nf.ce_employees (
    EMPLOYEE_ID,
    EMPLOYEE_SRC_ID,
    EMPLOYEE_ROLE,
    EMPLOYEE_YEARS,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    0,
    CURRENT_DATE,
    CURRENT_DATE,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_employees
    WHERE EMPLOYEE_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_employees (
    EMPLOYEE_ID,
    EMPLOYEE_SRC_ID,
    EMPLOYEE_ROLE,
    EMPLOYEE_YEARS,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_employees_id'),
    x.employee_src_id,
    x.employee_role,
    x.employee_years,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'RETAIL',
    'SRC_RETAIL_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(seller_employee_id, 'n.a.')                AS employee_src_id,
        COALESCE(seller_employee_role, 'n.a.')              AS employee_role,
        COALESCE(NULLIF(seller_employee_years, '')::INT, 0) AS employee_years
    FROM sa_retail_sales.src_retail_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_employees e
    WHERE e.employee_src_id = x.employee_src_id
      AND e.source_system = 'RETAIL'
);

COMMIT;

INSERT INTO bl_3nf.ce_cities (
    CITY_ID,
    CITY_SRC_ID,
    CITY_NAME,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities
    WHERE CITY_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_cities (
    CITY_ID,
    CITY_SRC_ID,
    CITY_NAME,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_cities_id'),
    x.city_src_id,
    x.city_name,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'RETAIL',
    'SRC_RETAIL_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(store_city, 'n.a.') AS city_src_id,
        COALESCE(store_city, 'n.a.') AS city_name
    FROM sa_retail_sales.src_retail_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities c
    WHERE c.city_src_id = x.city_src_id
      AND c.source_system = 'RETAIL'
);

COMMIT;

INSERT INTO bl_3nf.ce_districts (
    DISTRICT_ID,
    DISTRICT_SRC_ID,
    DISTRICT_NAME,
    CITY_ID,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_districts
    WHERE DISTRICT_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_districts (
    DISTRICT_ID,
    DISTRICT_SRC_ID,
    DISTRICT_NAME,
    CITY_ID,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_districts_id'),
    x.district_src_id,
    x.district_name,
    COALESCE(c.city_id, -1),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'RETAIL',
    'SRC_RETAIL_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(store_city, 'n.a.') || '_' || 
        COALESCE(store_district, 'n.a.')     AS district_src_id,
        COALESCE(store_district, 'n.a.')     AS district_name,
        COALESCE(store_city, 'n.a.')         AS city_src_id
    FROM sa_retail_sales.src_retail_sales
) x
LEFT JOIN bl_3nf.ce_cities c
    ON c.city_src_id = x.city_src_id
   AND c.source_system = 'RETAIL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_districts d
    WHERE d.district_src_id = x.district_src_id
      AND d.source_system = 'RETAIL'
);

COMMIT;

INSERT INTO bl_3nf.ce_stores (
    STORE_ID,
    STORE_SRC_ID,
    STORE_BRAND,
    DISTRICT_ID,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_stores
    WHERE STORE_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_stores (
    STORE_ID,
    STORE_SRC_ID,
    STORE_BRAND,
    DISTRICT_ID,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_stores_id'),
    x.store_src_id,
    x.store_brand,
    COALESCE(d.district_id, -1),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'RETAIL',
    'SRC_RETAIL_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(store_city, 'n.a.') || '_' ||
        COALESCE(store_district, 'n.a.') || '_' ||
        COALESCE(store_id, 'n.a.')          AS store_src_id,
        COALESCE(store_brand, 'n.a.')       AS store_brand,
        COALESCE(store_city, 'n.a.') || '_' ||
        COALESCE(store_district, 'n.a.')    AS district_src_id
    FROM sa_retail_sales.src_retail_sales
) x
LEFT JOIN bl_3nf.ce_districts d
    ON d.district_src_id = x.district_src_id
   AND d.source_system = 'RETAIL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_stores s
    WHERE s.store_src_id = x.store_src_id
      AND s.source_system = 'RETAIL'
);

COMMIT;

INSERT INTO bl_3nf.ce_landings (
    LANDING_ID,
    LANDING_SRC_ID,
    LANDING_NAME,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_landings
    WHERE LANDING_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_landings (
    LANDING_ID,
    LANDING_SRC_ID,
    LANDING_NAME,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_landings_id'),
    x.landing_src_id,
    x.landing_name,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'ONLINE',
    'SRC_ONLINE_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(landing_page, 'n.a.') AS landing_src_id,
        COALESCE(landing_page, 'n.a.') AS landing_name
    FROM sa_online_sales.src_online_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_landings l
    WHERE l.landing_src_id = x.landing_src_id
      AND l.source_system = 'ONLINE'
);

COMMIT;

INSERT INTO bl_3nf.ce_deliveries (
    DELIVERY_ID,
    DELIVERY_SRC_ID,
    DELIVERY_ADDRESS,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_deliveries
    WHERE DELIVERY_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_deliveries (
    DELIVERY_ID,
    DELIVERY_SRC_ID,
    DELIVERY_ADDRESS,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_deliveries_id'),
    x.delivery_src_id,
    x.delivery_address,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'ONLINE',
    'SRC_ONLINE_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(i_delivery_address, 'n.a.') AS delivery_src_id,
        COALESCE(i_delivery_address, 'n.a.') AS delivery_address
    FROM sa_online_sales.src_online_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_deliveries d
    WHERE d.delivery_src_id = x.delivery_src_id
      AND d.source_system = 'ONLINE'
);

COMMIT;

INSERT INTO bl_3nf.ce_payments (
    PAYMENT_ID,
    PAYMENT_SRC_ID,
    PAYMENT_METHOD,
    PAYMENT_STATUS,
    PAYMENT_PROVIDER,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    -1,
    'n.a.',
    'n.a.',
    'n.a.',
    'n.a.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'MANUAL',
    'MANUAL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_payments
    WHERE PAYMENT_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_payments (
    PAYMENT_ID,
    PAYMENT_SRC_ID,
    PAYMENT_METHOD,
    PAYMENT_STATUS,
    PAYMENT_PROVIDER,
    INSERT_DT,
    UPDATE_DT,
    SOURCE_SYSTEM,
    SOURCE_ENTITY
)
SELECT
    nextval('bl_3nf.seq_ce_payments_id'),
    x.payment_src_id,
    x.payment_method,
    x.payment_status,
    x.payment_provider,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'ONLINE',
    'SRC_ONLINE_SALES'
FROM (
    SELECT DISTINCT
        COALESCE(payment_method, 'n.a.') || '_' ||
        COALESCE(payment_provider, 'n.a.') || '_' ||
        COALESCE(payment_status, 'n.a.')       AS payment_src_id,
        COALESCE(payment_method, 'n.a.')       AS payment_method,
        COALESCE(payment_status, 'n.a.')       AS payment_status,
        COALESCE(payment_provider, 'n.a.')     AS payment_provider
    FROM sa_online_sales.src_online_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_payments p
    WHERE p.payment_src_id = x.payment_src_id
      AND p.source_system = 'ONLINE'
);

COMMIT;

INSERT INTO bl_3nf.ce_customers_scd (
    CUSTOMER_ID,
    CUSTOMER_SRC_ID,
    CUSTOMER_GENDER,
    CUSTOMER_AGE,
    CUSTOMER_SEGMENT,
    REGISTERED_CUSTOMER,
    CUSTOMER_REGISTRATION_DATE,
    START_DT,
    END_DT,
    IS_ACTIVE,
    SOURCE_SYSTEM,
    SOURCE_ENTITY,
    INSERT_DT,
    UPDATE_DT
)
SELECT
    -1,
    -1,
    'n.a.',
    0,
    'n.a.',
    FALSE,
    DATE '1900-01-01',
    DATE '1990-01-01',
    DATE '9999-12-31',
    'Y',
    'MANUAL',
    'MANUAL',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers_scd
    WHERE CUSTOMER_ID = -1
);

COMMIT;

INSERT INTO bl_3nf.ce_customers_scd (
    CUSTOMER_ID,
    CUSTOMER_SRC_ID,
    CUSTOMER_GENDER,
    CUSTOMER_AGE,
    CUSTOMER_SEGMENT,
    REGISTERED_CUSTOMER,
    CUSTOMER_REGISTRATION_DATE,
    START_DT,
    END_DT,
    IS_ACTIVE,
    SOURCE_SYSTEM,
    SOURCE_ENTITY,
    INSERT_DT,
    UPDATE_DT
)
SELECT
    nextval('bl_3nf.seq_ce_customers_id'),
    x.customer_src_id,
    x.customer_gender,
    x.customer_age,
    x.customer_segment,
    FALSE,
    DATE '1900-01-01',
    DATE '1990-01-01',
    DATE '9999-12-31',
    'Y',
    'RETAIL',
    'SRC_RETAIL_SALES',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT
        COALESCE(customer_id::BIGINT, -1)                 AS customer_src_id,
        COALESCE(customer_gender, 'n.a.')                 AS customer_gender,
        COALESCE(NULLIF(customer_age, '')::INT, 0)        AS customer_age,
        COALESCE(customer_segment, 'n.a.')                AS customer_segment
    FROM sa_retail_sales.src_retail_sales
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers_scd c
    WHERE c.customer_src_id = x.customer_src_id
      AND c.source_system = 'RETAIL'
);

COMMIT;


INSERT INTO bl_3nf.ce_customers_scd (
    CUSTOMER_ID,
    CUSTOMER_SRC_ID,
    CUSTOMER_GENDER,
    CUSTOMER_AGE,
    CUSTOMER_SEGMENT,
    REGISTERED_CUSTOMER,
    CUSTOMER_REGISTRATION_DATE,
    START_DT,
    END_DT,
    IS_ACTIVE,
    SOURCE_SYSTEM,
    SOURCE_ENTITY,
    INSERT_DT,
    UPDATE_DT
)
SELECT
    nextval('bl_3nf.seq_ce_customers_id'),
    x.customer_src_id,
    'n.a.' AS customer_gender,
    0      AS customer_age,
    'n.a.' AS customer_segment,
    (x.registered_customer_int = 1) AS registered_customer,
    x.registration_date,
    DATE '1990-01-01',
    DATE '9999-12-31',
    'Y',
    'ONLINE',
    'SRC_ONLINE_SALES',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT
        COALESCE(i_customer_id::BIGINT, -1) AS customer_src_id,
        MAX(
            CASE 
                WHEN i_registered_customer = 'TRUE' THEN 1 
                ELSE 0 
            END
        ) AS registered_customer_int,
        MAX(
            COALESCE(
                NULLIF(i_customer_registration_date, '')::DATE,
                DATE '1900-01-01'
            )
        ) AS registration_date
    FROM sa_online_sales.src_online_sales
    GROUP BY COALESCE(i_customer_id::BIGINT, -1)
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers_scd c
    WHERE c.customer_src_id = x.customer_src_id
      AND c.source_system = 'ONLINE'
      AND c.start_dt = DATE '1990-01-01'
);

COMMIT;

INSERT INTO bl_3nf.ce_sales (
    SALES_ID,
    TRANSACTION_SRC_ID,
    PRODUCT_ID,
    SUPPLIER_ID,
    CUSTOMER_ID,
    STORE_ID,
    EMPLOYEE_ID,
    DELIVERY_ID,
    LANDING_ID,
    PAYMENT_ID,
    SALE_DATE,
    PRICE_RETAIL,
    PRICE_DISCOUNT,
    PRICE_SALE,
    PRODUCT_COST,
    I_DELIVERED_IN,
    SOURCE_SYSTEM,
    SOURCE_ENTITY,
    INSERT_DT,
    UPDATE_DT
)
SELECT
    nextval('bl_3nf.seq_ce_sales_id'),
    x.transaction_src_id,
    COALESCE(p.product_id, -1),
    COALESCE(sup.supplier_id, -1),
    COALESCE(c.customer_id, -1),
    COALESCE(st.store_id, -1),
    COALESCE(e.employee_id, -1),
    -1,
    -1,
    -1,
    x.sale_date,
    x.price_retail,
    x.price_discount,
    x.price_sale,
    x.product_cost,
    0,
    'RETAIL',
    'SRC_RETAIL_SALES',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT
        transaction_id::BIGINT AS transaction_src_id,
        TO_DATE("date", 'YYYY-MM-DD') AS sale_date,
        MAX(product_id) AS product_id,
        MAX(supplier_id) AS supplier_id,
        MAX(customer_id::BIGINT) AS customer_id,
        MAX(store_id) AS store_id,
        MAX(seller_employee_id) AS seller_employee_id,
        MAX(COALESCE(NULLIF(price_retail,'')::NUMERIC,0)) AS price_retail,
        MAX(COALESCE(NULLIF(price_discount,'')::NUMERIC,0)) AS price_discount,
        MAX(COALESCE(NULLIF(price_sale,'')::NUMERIC,0)) AS price_sale,
        MAX(COALESCE(NULLIF(product_cost,'')::NUMERIC,0)) AS product_cost
    FROM sa_retail_sales.src_retail_sales
    GROUP BY transaction_id::BIGINT, TO_DATE("date", 'YYYY-MM-DD')
) x
LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = x.product_id
   AND p.source_system = 'RETAIL'
LEFT JOIN bl_3nf.ce_suppliers sup
    ON sup.supplier_src_id = x.supplier_id
   AND sup.source_system = 'RETAIL'
LEFT JOIN bl_3nf.ce_customers_scd c
    ON c.customer_src_id = x.customer_id
   AND c.source_system = 'RETAIL'
   AND c.is_active = 'Y'
LEFT JOIN bl_3nf.ce_employees e
    ON e.employee_src_id = x.seller_employee_id
   AND e.source_system = 'RETAIL'
LEFT JOIN bl_3nf.ce_stores st
    ON st.store_src_id = x.store_id
   AND st.source_system = 'RETAIL'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_sales f
    WHERE f.transaction_src_id = x.transaction_src_id
      AND f.source_system = 'RETAIL'
);

COMMIT;

INSERT INTO bl_3nf.ce_sales (
    SALES_ID,
    TRANSACTION_SRC_ID,
    PRODUCT_ID,
    SUPPLIER_ID,
    CUSTOMER_ID,
    STORE_ID,
    EMPLOYEE_ID,
    DELIVERY_ID,
    LANDING_ID,
    PAYMENT_ID,
    SALE_DATE,
    PRICE_RETAIL,
    PRICE_DISCOUNT,
    PRICE_SALE,
    PRODUCT_COST,
    I_DELIVERED_IN,
    SOURCE_SYSTEM,
    SOURCE_ENTITY,
    INSERT_DT,
    UPDATE_DT
)
SELECT
    nextval('bl_3nf.seq_ce_sales_id'),
    x.transaction_src_id,
    COALESCE(p.product_id, -1),
    COALESCE(sup.supplier_id, -1),
    COALESCE(c.customer_id, -1),
    -1,
    -1,
    COALESCE(d.delivery_id, -1),
    COALESCE(l.landing_id, -1),
    COALESCE(pay.payment_id, -1),
    x.sale_date,
    x.price_retail,
    x.price_discount,
    x.price_sale,
    x.product_cost,
    x.i_delivered_in,
    'ONLINE',
    'SRC_ONLINE_SALES',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT
        i_transaction_id::BIGINT AS transaction_src_id,
        TO_DATE(i_date, 'YYYY-MM-DD') AS sale_date,
        MAX(product_id) AS product_id,
        MAX(supplier_id) AS supplier_id,
        MAX(i_customer_id::BIGINT) AS customer_id,
        MAX(landing_page) AS landing_page,
        MAX(i_delivery_address) AS delivery_address,
        MAX(payment_method) AS payment_method,
        MAX(payment_status) AS payment_status,
        MAX(payment_provider) AS payment_provider,
        MAX(COALESCE(NULLIF(price_retail,'')::NUMERIC,0)) AS price_retail,
        MAX(COALESCE(NULLIF(price_discount,'')::NUMERIC,0)) AS price_discount,
        MAX(COALESCE(NULLIF(price_sale,'')::NUMERIC,0)) AS price_sale,
        MAX(COALESCE(NULLIF(product_cost,'')::NUMERIC,0)) AS product_cost,
        MAX(COALESCE(NULLIF(i_delivered_in,'')::INT,0)) AS i_delivered_in
    FROM sa_online_sales.src_online_sales
    GROUP BY i_transaction_id::BIGINT, TO_DATE(i_date, 'YYYY-MM-DD')
) x
LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = x.product_id
   AND p.source_system = 'ONLINE'
LEFT JOIN bl_3nf.ce_suppliers sup
    ON sup.supplier_src_id = x.supplier_id
   AND sup.source_system = 'ONLINE'
LEFT JOIN bl_3nf.ce_customers_scd c
    ON c.customer_src_id = x.customer_id
   AND c.source_system = 'ONLINE'
   AND c.is_active = 'Y'
LEFT JOIN bl_3nf.ce_landings l
    ON l.landing_src_id = x.landing_page
   AND l.source_system = 'ONLINE'
LEFT JOIN bl_3nf.ce_deliveries d
    ON d.delivery_src_id = x.delivery_address
   AND d.source_system = 'ONLINE'
LEFT JOIN bl_3nf.ce_payments pay
    ON pay.payment_src_id = x.payment_method
   AND pay.source_system = 'ONLINE'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_sales f
    WHERE f.transaction_src_id = x.transaction_src_id
      AND f.source_system = 'ONLINE'
);

COMMIT;