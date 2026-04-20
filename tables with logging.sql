CREATE OR REPLACE PROCEDURE bl_cl.load_ce_products()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows integer := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_get_distinct_products()
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM bl_3nf.ce_products p
            WHERE p.product_src_id = rec.product_id
        ) THEN

            INSERT INTO bl_3nf.ce_products (
                product_id, product_src_id,
                product_category, product_subcategory, product_material,
                insert_dt, update_dt, source_system, source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_products_id'),
                rec.product_id,
                rec.product_category,
                rec.product_subcategory,
                rec.product_material,
                CURRENT_DATE, CURRENT_DATE,
                'MULTI', 'SRC_ONLINE_SALES / SRC_RETAIL_SALES'
            );

            v_rows := v_rows + 1;

        ELSE
            UPDATE bl_3nf.ce_products p
            SET product_category = rec.product_category,
                product_subcategory = rec.product_subcategory,
                product_material = rec.product_material,
                update_dt = CURRENT_DATE
            WHERE p.product_src_id = rec.product_id
              AND (
                  p.product_category IS DISTINCT FROM rec.product_category OR
                  p.product_subcategory IS DISTINCT FROM rec.product_subcategory OR
                  p.product_material IS DISTINCT FROM rec.product_material
              );

            IF FOUND THEN v_rows := v_rows + 1; END IF;
        END IF;
    END LOOP;

    CALL bl_cl.write_log('load_ce_products', v_rows,
        'Products loaded', 'SUCCESS');

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log('load_ce_products', 0,
        SQLERRM, 'ERROR');
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_suppliers()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT supplier_id, supplier_country, supplier_size
        FROM (
            SELECT supplier_id, supplier_country, supplier_size FROM sa_online_sales.src_online_sales
            UNION
            SELECT supplier_id, supplier_country, supplier_size FROM sa_retail_sales.src_retail_sales
        ) s
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM bl_3nf.ce_suppliers t
            WHERE t.supplier_src_id = rec.supplier_id
        ) THEN

            INSERT INTO bl_3nf.ce_suppliers (
                supplier_id, supplier_src_id,
                supplier_country, supplier_size,
                insert_dt, update_dt,
                source_system, source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_suppliers_id'),
                rec.supplier_id,
                rec.supplier_country,
                rec.supplier_size,
                CURRENT_DATE, CURRENT_DATE,
                'MULTI', 'SRC_ONLINE_SALES / SRC_RETAIL_SALES'
            );

            v_rows := v_rows + 1;

        ELSE
            UPDATE bl_3nf.ce_suppliers t
            SET supplier_country = rec.supplier_country,
                supplier_size = rec.supplier_size,
                update_dt = CURRENT_DATE
            WHERE t.supplier_src_id = rec.supplier_id
              AND (
                  t.supplier_country IS DISTINCT FROM rec.supplier_country OR
                  t.supplier_size IS DISTINCT FROM rec.supplier_size
              );

            IF FOUND THEN v_rows := v_rows + 1; END IF;
        END IF;
    END LOOP;

    CALL bl_cl.write_log('load_ce_suppliers', v_rows,
        'Suppliers loaded', 'SUCCESS');

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log('load_ce_suppliers', 0,
        SQLERRM, 'ERROR');
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_cities()
LANGUAGE plpgsql
AS $$
DECLARE rec RECORD;
DECLARE v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT store_city
        FROM sa_retail_sales.src_retail_sales
        WHERE store_city IS NOT NULL
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM bl_3nf.ce_cities c
            WHERE c.city_src_id = rec.store_city
        ) THEN

            INSERT INTO bl_3nf.ce_cities (
                city_id, city_src_id, city_name,
                insert_dt, update_dt,
                source_system, source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_cities_id'),
                rec.store_city, rec.store_city,
                CURRENT_DATE, CURRENT_DATE,
                'RETAIL', 'SRC_RETAIL_SALES'
            );

            v_rows := v_rows + 1;
        END IF;
    END LOOP;

    CALL bl_cl.write_log('load_ce_cities', v_rows,
        'Cities loaded', 'SUCCESS');

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log('load_ce_cities', 0,
        SQLERRM, 'ERROR');
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_districts()
LANGUAGE plpgsql
AS $$
DECLARE rec RECORD;
DECLARE v_city_id bigint;
DECLARE v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT store_district, store_city
        FROM sa_retail_sales.src_retail_sales
        WHERE store_district IS NOT NULL
    LOOP
        SELECT city_id INTO v_city_id
        FROM bl_3nf.ce_cities
        WHERE city_src_id = rec.store_city;

        IF NOT EXISTS (
            SELECT 1 FROM bl_3nf.ce_districts d
            WHERE d.district_src_id = rec.store_district
        ) THEN

            INSERT INTO bl_3nf.ce_districts (
                district_id, district_src_id, district_name, city_id,
                insert_dt, update_dt,
                source_system, source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_districts_id'),
                rec.store_district, rec.store_district,
                v_city_id,
                CURRENT_DATE, CURRENT_DATE,
                'RETAIL', 'SRC_RETAIL_SALES'
            );

            v_rows := v_rows + 1;
        END IF;
    END LOOP;

    CALL bl_cl.write_log('load_ce_districts', v_rows,
        'Districts loaded', 'SUCCESS');

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log('load_ce_districts', 0,
        SQLERRM, 'ERROR');
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_stores()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_district_id bigint;
    v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT store_id, store_brand, store_district
        FROM sa_retail_sales.src_retail_sales
        WHERE store_id IS NOT NULL
    LOOP
        SELECT district_id
        INTO v_district_id
        FROM bl_3nf.ce_districts
        WHERE district_src_id = rec.store_district;

        IF NOT EXISTS (
            SELECT 1
            FROM bl_3nf.ce_stores s
            WHERE s.store_src_id = rec.store_id
        ) THEN

            INSERT INTO bl_3nf.ce_stores (
                store_id,
                store_src_id,
                store_brand,
                district_id,
                insert_dt,
                update_dt,
                source_system,
                source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_stores_id'),
                rec.store_id,
                rec.store_brand,
                v_district_id,
                CURRENT_DATE,
                CURRENT_DATE,
                'RETAIL',
                'SRC_RETAIL_SALES'
            );

            v_rows := v_rows + 1;

        END IF;
    END LOOP;

    CALL bl_cl.write_log(
        'load_ce_stores',
        v_rows,
        'Stores loaded successfully',
        'SUCCESS'
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.write_log(
            'load_ce_stores',
            0,
            SQLERRM,
            'ERROR'
        );
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT
            seller_employee_id,
            seller_employee_role,
            seller_employee_years
        FROM sa_retail_sales.src_retail_sales
        WHERE seller_employee_id IS NOT NULL
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM bl_3nf.ce_employees e
            WHERE e.employee_src_id = rec.seller_employee_id
        ) THEN

            INSERT INTO bl_3nf.ce_employees (
                employee_id,
                employee_src_id,
                employee_role,
                employee_years,
                insert_dt,
                update_dt,
                source_system,
                source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_employees_id'),
                rec.seller_employee_id,
                rec.seller_employee_role,
                rec.seller_employee_years::int,
                CURRENT_DATE,
                CURRENT_DATE,
                'RETAIL',
                'SRC_RETAIL_SALES'
            );

            v_rows := v_rows + 1;

        ELSE

            UPDATE bl_3nf.ce_employees e
            SET employee_role = rec.seller_employee_role,
                employee_years = rec.seller_employee_years::int,
                update_dt = CURRENT_DATE
            WHERE e.employee_src_id = rec.seller_employee_id
              AND (
                  e.employee_role IS DISTINCT FROM rec.seller_employee_role OR
                  e.employee_years IS DISTINCT FROM rec.seller_employee_years::int
              );

            IF FOUND THEN
                v_rows := v_rows + 1;
            END IF;

        END IF;
    END LOOP;

    CALL bl_cl.write_log(
        'load_ce_employees',
        v_rows,
        'Employees loaded successfully',
        'SUCCESS'
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.write_log(
            'load_ce_employees',
            0,
            SQLERRM,
            'ERROR'
        );
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_payments()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted integer := 0;
BEGIN

INSERT INTO bl_3nf.ce_payments (
    payment_id,
    payment_src_id,
    payment_method,
    payment_status,
    payment_provider,
    insert_dt,
    update_dt,
    source_system,
    source_entity
)
SELECT
    nextval('bl_3nf.seq_ce_payments_id'),
    s.payment_method || '|' || s.payment_status || '|' || s.payment_provider,
    s.payment_method,
    s.payment_status,
    s.payment_provider,
    CURRENT_DATE,
    CURRENT_DATE,
    'ONLINE',
    'SRC_ONLINE_SALES'
FROM (
    SELECT DISTINCT
        payment_method,
        payment_status,
        payment_provider
    FROM sa_online_sales.src_online_sales
    WHERE payment_method IS NOT NULL
) s
LEFT JOIN bl_3nf.ce_payments p
    ON p.payment_method   = s.payment_method
   AND p.payment_status   = s.payment_status
   AND p.payment_provider = s.payment_provider
WHERE p.payment_id IS NULL;

GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

CALL bl_cl.write_log(
    'load_ce_payments',
    v_rows_inserted,
    'Payments loaded successfully',
    'SUCCESS'
);

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.write_log(
            'load_ce_payments',
            0,
            SQLERRM,
            'ERROR'
        );
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_landings()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT landing_page
        FROM sa_online_sales.src_online_sales
        WHERE landing_page IS NOT NULL
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM bl_3nf.ce_landings l
            WHERE l.landing_src_id = rec.landing_page
        ) THEN

            INSERT INTO bl_3nf.ce_landings (
                landing_id,
                landing_src_id,
                landing_name,
                insert_dt,
                update_dt,
                source_system,
                source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_landings_id'),
                rec.landing_page,
                rec.landing_page,
                CURRENT_DATE,
                CURRENT_DATE,
                'ONLINE',
                'SRC_ONLINE_SALES'
            );

            v_rows := v_rows + 1;

        END IF;
    END LOOP;

    CALL bl_cl.write_log(
        'load_ce_landings',
        v_rows,
        'Landings loaded successfully',
        'SUCCESS'
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.write_log(
            'load_ce_landings',
            0,
            SQLERRM,
            'ERROR'
        );
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_deliveries()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows integer := 0;
BEGIN
    FOR rec IN
        SELECT DISTINCT i_delivery_address
        FROM sa_online_sales.src_online_sales
        WHERE i_delivery_address IS NOT NULL
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM bl_3nf.ce_deliveries d
            WHERE d.delivery_src_id = rec.i_delivery_address
        ) THEN

            INSERT INTO bl_3nf.ce_deliveries (
                delivery_id,
                delivery_src_id,
                delivery_address,
                insert_dt,
                update_dt,
                source_system,
                source_entity
            )
            VALUES (
                nextval('bl_3nf.seq_ce_deliveries_id'),
                rec.i_delivery_address,
                rec.i_delivery_address,
                CURRENT_DATE,
                CURRENT_DATE,
                'ONLINE',
                'SRC_ONLINE_SALES'
            );

            v_rows := v_rows + 1;

        END IF;
    END LOOP;

    CALL bl_cl.write_log(
        'load_ce_deliveries',
        v_rows,
        'Deliveries loaded successfully',
        'SUCCESS'
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.write_log(
            'load_ce_deliveries',
            0,
            SQLERRM,
            'ERROR'
        );
        RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_ce_sales()
LANGUAGE plpgsql
AS $$
DECLARE 
    v_rows_inserted integer := 0;
BEGIN

/* =========================================================
   ENSURE UNKNOWN DIMENSION HIERARCHY
========================================================= */

-- City
INSERT INTO bl_3nf.ce_cities (
    city_id, city_src_id, city_name,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN',
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_cities WHERE city_id = 0
);

-- District
INSERT INTO bl_3nf.ce_districts (
    district_id, district_src_id, district_name, city_id,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN',0,
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_districts WHERE district_id = 0
);

-- Store
INSERT INTO bl_3nf.ce_stores (
    store_id, store_src_id, store_brand, district_id,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN',0,
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_stores WHERE store_id = 0
);

-- Employee
INSERT INTO bl_3nf.ce_employees (
    employee_id, employee_src_id, employee_role, employee_years,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN',0,
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_employees WHERE employee_id = 0
);

-- Customer (SCD2)
INSERT INTO bl_3nf.ce_customers_scd (
    customer_id, customer_src_id,
    customer_gender, customer_age, customer_segment,
    registered_customer, customer_registration_date,
    start_dt, end_dt, is_active,
    source_system, source_entity,
    insert_dt, update_dt
)
SELECT 0,0,
       'UNKNOWN',0,'UNKNOWN',
       false, DATE '1900-01-01',
       CURRENT_DATE,DATE '9999-12-31','Y',
       'SYSTEM','SYSTEM',
       CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_customers_scd WHERE customer_id = 0
);

-- Delivery
INSERT INTO bl_3nf.ce_deliveries (
    delivery_id, delivery_src_id, delivery_address,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN',
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_deliveries WHERE delivery_id = 0
);

-- Landing
INSERT INTO bl_3nf.ce_landings (
    landing_id, landing_src_id, landing_name,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN',
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_landings WHERE landing_id = 0
);

-- Payment
INSERT INTO bl_3nf.ce_payments (
    payment_id, payment_src_id, payment_method,
    payment_status, payment_provider,
    insert_dt, update_dt, source_system, source_entity
)
SELECT 0,'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',
       CURRENT_DATE,CURRENT_DATE,'SYSTEM','SYSTEM'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_payments WHERE payment_id = 0
);


/* =========================================================
   INSERT SALES FACT
========================================================= */

INSERT INTO bl_3nf.ce_sales (
    sales_id,
    transaction_src_id,
    product_id,
    supplier_id,
    customer_id,
    store_id,
    employee_id,
    delivery_id,
    landing_id,
    payment_id,
    sale_date,
    price_retail,
    price_discount,
    price_sale,
    product_cost,
    i_delivered_in,
    source_system,
    source_entity,
    insert_dt,
    update_dt
)

SELECT DISTINCT
    nextval('bl_3nf.seq_ce_sales_id'),
    src.transaction_src_id,
    p.product_id,
    s.supplier_id,
    COALESCE(c.customer_id, 0),
    COALESCE(st.store_id, 0),
    COALESCE(e.employee_id, 0),
    COALESCE(d.delivery_id, 0),
    COALESCE(l.landing_id, 0),
    COALESCE(pay.payment_id, 0),
    src.sale_date,
    src.price_retail,
    src.price_discount,
    src.price_sale,
    src.product_cost,
    COALESCE(src.i_delivered_in, 0),
    src.source_system,
    src.source_entity,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP

FROM (

    /* ================= ONLINE ================= */
    SELECT
        i_transaction_id::bigint AS transaction_src_id,
        CASE
            WHEN i_date LIKE '____-__-__' THEN i_date::date
            WHEN i_date LIKE '__.__.____' THEN to_date(i_date,'DD.MM.YYYY')
            WHEN i_date LIKE '__.__.__' THEN to_date(i_date,'DD.MM.YY')
            ELSE NULL
        END AS sale_date,
        product_id::varchar,
        supplier_id::varchar,
        i_customer_id::varchar AS customer_id,
        NULL::varchar AS store_id,
        NULL::varchar AS employee_id,
        i_delivery_address::varchar AS delivery_address,
        landing_page::varchar,
        payment_method::varchar,
        price_retail::numeric,
        price_discount::numeric,
        price_sale::numeric,
        product_cost::numeric,
        i_delivered_in::integer,
        'ONLINE'::varchar AS source_system,
        'SRC_ONLINE_SALES'::varchar AS source_entity
    FROM sa_online_sales.src_online_sales

    UNION ALL

    /* ================= RETAIL ================= */
    SELECT
        transaction_id::bigint,
        CASE
            WHEN date LIKE '____-__-__' THEN date::date
            WHEN date LIKE '__.__.____' THEN to_date(date,'DD.MM.YYYY')
            WHEN date LIKE '__.__.__' THEN to_date(date,'DD.MM.YY')
            ELSE NULL
        END,
        product_id::varchar,
        supplier_id::varchar,
        customer_id::varchar,
        store_id::varchar,
        seller_employee_id::varchar,
        NULL::varchar,
        NULL::varchar,
        NULL::varchar,
        price_retail::numeric,
        price_discount::numeric,
        price_sale::numeric,
        product_cost::numeric,
        NULL::integer,
        'RETAIL'::varchar,
        'SRC_RETAIL_SALES'::varchar
    FROM sa_retail_sales.src_retail_sales

) src

LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = src.product_id

LEFT JOIN bl_3nf.ce_suppliers s
    ON s.supplier_src_id = src.supplier_id

LEFT JOIN bl_3nf.ce_customers_scd c
    ON c.customer_src_id = src.customer_id::bigint
   AND c.is_active = 'Y'
   AND c.source_system = src.source_system

LEFT JOIN bl_3nf.ce_stores st
    ON st.store_src_id = src.store_id

LEFT JOIN bl_3nf.ce_employees e
    ON e.employee_src_id = src.employee_id

LEFT JOIN bl_3nf.ce_deliveries d
    ON d.delivery_src_id = src.delivery_address

LEFT JOIN bl_3nf.ce_landings l
    ON l.landing_src_id = src.landing_page

LEFT JOIN bl_3nf.ce_payments pay
    ON pay.payment_src_id = src.payment_method

ON CONFLICT (transaction_src_id, source_system) DO NOTHING;


/* =========================================================
   LOGGING
========================================================= */

GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

CALL bl_cl.write_log(
    'load_ce_sales',
    v_rows_inserted,
    'Sales loaded successfully',
    'SUCCESS'
);

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.write_log(
            'load_ce_sales',
            0,
            SQLERRM,
            'ERROR'
        );
        RAISE;

END;
$$;