ALTER TABLE bl_dm.dim_employees
ADD CONSTRAINT uq_dim_employees_src
UNIQUE (employee_src_id);

CREATE TYPE bl_cl.tp_dim_employees AS (
    employee_src_id VARCHAR,
    employee_role   VARCHAR,
    employee_years  INT,
    source_system   VARCHAR,
    source_entity   VARCHAR
);

SELECT *
FROM bl_dm.dim_employees

CALL bl_cl.load_dim_employees()

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec bl_cl.tp_dim_employees;
    v_rows INT := 0;

    cur CURSOR FOR
        SELECT
            employee_src_id,
            employee_role,
            employee_years,
            source_system,
            source_entity
        FROM bl_3nf.ce_employees;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO v_rec;
        EXIT WHEN NOT FOUND;

        EXECUTE '
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
                nextval(''bl_dm.seq_dim_employees_id''),
                $1, $2, $3, $4, $5,
                CURRENT_DATE,
                CURRENT_DATE
            )
            ON CONFLICT (employee_src_id)
            DO UPDATE SET
                employee_role  = EXCLUDED.employee_role,
                employee_years = EXCLUDED.employee_years,
                update_dt      = CURRENT_DATE
            WHERE
                dim_employees.employee_role  IS DISTINCT FROM EXCLUDED.employee_role OR
                dim_employees.employee_years IS DISTINCT FROM EXCLUDED.employee_years
        '
        USING
            v_rec.employee_src_id,
            v_rec.employee_role,
            v_rec.employee_years,
            v_rec.source_system,
            v_rec.source_entity;

        IF FOUND THEN
            v_rows := v_rows + 1;
        END IF;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_employees',
        v_rows,
        'DIM_EMPLOYEES loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_employees',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_dim_landings()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;
    v_count INT;

    v_landing_src_id VARCHAR;
    v_landing_name   VARCHAR;
    v_source_system  VARCHAR;
    v_source_entity  VARCHAR;

    cur CURSOR FOR
        SELECT
            landing_src_id,
            landing_name,
            source_system,
            source_entity
        FROM bl_3nf.ce_landings;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO
            v_landing_src_id,
            v_landing_name,
            v_source_system,
            v_source_entity;

        EXIT WHEN NOT FOUND;

        EXECUTE '
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
                nextval(''bl_dm.seq_dim_landings_id''),
                $1,$2,$3,$4,
                CURRENT_DATE,
                CURRENT_DATE
            )
            ON CONFLICT (landing_src_id)
            DO UPDATE SET
                landing_name = EXCLUDED.landing_name,
                update_dt    = CURRENT_DATE
            WHERE
                dim_landings.landing_name IS DISTINCT FROM EXCLUDED.landing_name
        '
        USING
            v_landing_src_id,
            v_landing_name,
            v_source_system,
            v_source_entity;

        -- 🔥 Correct row counting
        GET DIAGNOSTICS v_count = ROW_COUNT;
        v_rows := v_rows + v_count;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_landings',
        v_rows,
        'DIM_LANDINGS loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_landings',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;

CALL bl_cl.load_dim_products();

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_landings()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;

    v_landing_src_id VARCHAR;
    v_landing_name   VARCHAR;
    v_source_system  VARCHAR;
    v_source_entity  VARCHAR;

    v_existing_name VARCHAR;

    cur CURSOR FOR
        SELECT
            landing_src_id,
            landing_name,
            source_system,
            source_entity
        FROM bl_3nf.ce_landings;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO
            v_landing_src_id,
            v_landing_name,
            v_source_system,
            v_source_entity;

        EXIT WHEN NOT FOUND;

        -- Check if row exists
        SELECT landing_name
        INTO v_existing_name
        FROM bl_dm.dim_landings
        WHERE landing_src_id = v_landing_src_id;

        IF NOT FOUND THEN

            -- INSERT new row
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
                nextval('bl_dm.seq_dim_landings_id'),
                v_landing_src_id,
                v_landing_name,
                v_source_system,
                v_source_entity,
                CURRENT_DATE,
                CURRENT_DATE
            );

            v_rows := v_rows + 1;

        ELSE

            -- UPDATE only if changed
            IF v_existing_name IS DISTINCT FROM v_landing_name THEN

                UPDATE bl_dm.dim_landings
                SET landing_name = v_landing_name,
                    update_dt    = CURRENT_DATE
                WHERE landing_src_id = v_landing_src_id;

                v_rows := v_rows + 1;

            END IF;

        END IF;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_landings',
        v_rows,
        'DIM_LANDINGS loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_landings',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;


CALL bl_cl.load_dim_landings();

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_deliveries()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;

    v_delivery_src_id VARCHAR;
    v_delivery_address VARCHAR;
    v_source_system   VARCHAR;
    v_source_entity   VARCHAR;

    v_existing_address VARCHAR;

    cur CURSOR FOR
        SELECT
            delivery_src_id,
            delivery_address,
            source_system,
            source_entity
        FROM bl_3nf.ce_deliveries;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO
            v_delivery_src_id,
            v_delivery_address,
            v_source_system,
            v_source_entity;

        EXIT WHEN NOT FOUND;

        -- Check if exists
        SELECT delivery_address
        INTO v_existing_address
        FROM bl_dm.dim_deliveries
        WHERE delivery_src_id = v_delivery_src_id;

        IF NOT FOUND THEN

            -- INSERT
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
                nextval('bl_dm.seq_dim_deliveries_id'),
                v_delivery_src_id,
                v_delivery_address,
                v_source_system,
                v_source_entity,
                CURRENT_DATE,
                CURRENT_DATE
            );

            v_rows := v_rows + 1;

        ELSE

            -- UPDATE only if changed
            IF v_existing_address IS DISTINCT FROM v_delivery_address THEN

                UPDATE bl_dm.dim_deliveries
                SET delivery_address = v_delivery_address,
                    update_dt        = CURRENT_DATE
                WHERE delivery_src_id = v_delivery_src_id;

                v_rows := v_rows + 1;

            END IF;

        END IF;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_deliveries',
        v_rows,
        'DIM_DELIVERIES loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_deliveries',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;

CALL bl_cl.load_dim_deliveries();

--payments
ALTER TABLE bl_dm.dim_payments
ADD CONSTRAINT uq_dim_payments_src
UNIQUE (payment_src_id);

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_payments()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;

    v_payment_src_id   VARCHAR;
    v_payment_method   VARCHAR;
    v_payment_status   VARCHAR;
    v_payment_provider VARCHAR;
    v_source_system    VARCHAR;
    v_source_entity    VARCHAR;

    v_existing_method   VARCHAR;
    v_existing_status   VARCHAR;
    v_existing_provider VARCHAR;

    cur CURSOR FOR
        SELECT
            payment_src_id,
            payment_method,
            payment_status,
            payment_provider,
            source_system,
            source_entity
        FROM bl_3nf.ce_payments;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO
            v_payment_src_id,
            v_payment_method,
            v_payment_status,
            v_payment_provider,
            v_source_system,
            v_source_entity;

        EXIT WHEN NOT FOUND;

        -- Check if exists
        SELECT
            payment_method,
            payment_status,
            payment_provider
        INTO
            v_existing_method,
            v_existing_status,
            v_existing_provider
        FROM bl_dm.dim_payments
        WHERE payment_src_id = v_payment_src_id;

        IF NOT FOUND THEN

            -- INSERT
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
                nextval('bl_dm.seq_dim_payments_id'),
                v_payment_src_id,
                v_payment_method,
                v_payment_status,
                v_payment_provider,
                v_source_system,
                v_source_entity,
                CURRENT_DATE,
                CURRENT_DATE
            );

            v_rows := v_rows + 1;

        ELSE

            -- UPDATE only if changed
            IF v_existing_method   IS DISTINCT FROM v_payment_method
            OR v_existing_status   IS DISTINCT FROM v_payment_status
            OR v_existing_provider IS DISTINCT FROM v_payment_provider THEN

                UPDATE bl_dm.dim_payments
                SET payment_method   = v_payment_method,
                    payment_status   = v_payment_status,
                    payment_provider = v_payment_provider,
                    update_dt        = CURRENT_DATE
                WHERE payment_src_id = v_payment_src_id;

                v_rows := v_rows + 1;

            END IF;

        END IF;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_payments',
        v_rows,
        'DIM_PAYMENTS loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_payments',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;

CALL bl_cl.load_dim_payments();

--stores

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_stores()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;

    v_store_src_id   VARCHAR;
    v_store_brand    VARCHAR;
    v_store_district VARCHAR;
    v_store_city     VARCHAR;
    v_source_system  VARCHAR;
    v_source_entity  VARCHAR;

    v_existing_brand    VARCHAR;
    v_existing_district VARCHAR;
    v_existing_city     VARCHAR;

    cur CURSOR FOR
        SELECT
            s.store_src_id,
            s.store_brand,
            d.district_name,
            c.city_name,
            s.source_system,
            s.source_entity
        FROM bl_3nf.ce_stores s
        LEFT JOIN bl_3nf.ce_districts d
            ON s.district_id = d.district_id
        LEFT JOIN bl_3nf.ce_cities c
            ON d.city_id = c.city_id;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO
            v_store_src_id,
            v_store_brand,
            v_store_district,
            v_store_city,
            v_source_system,
            v_source_entity;

        EXIT WHEN NOT FOUND;

        SELECT
            store_brand,
            store_district,
            store_city
        INTO
            v_existing_brand,
            v_existing_district,
            v_existing_city
        FROM bl_dm.dim_stores
        WHERE store_src_id = v_store_src_id;

        IF NOT FOUND THEN

            INSERT INTO bl_dm.dim_stores (
                store_surr_id,
                store_src_id,
                store_brand,
                store_district,
                store_city,
                source_system,
                source_entity,
                insert_dt,
                update_dt
            )
            VALUES (
                nextval('bl_dm.seq_dim_stores_id'),
                v_store_src_id,
                v_store_brand,
                v_store_district,
                v_store_city,
                v_source_system,
                v_source_entity,
                CURRENT_DATE,
                CURRENT_DATE
            );

            v_rows := v_rows + 1;

        ELSE

            IF v_existing_brand    IS DISTINCT FROM v_store_brand
            OR v_existing_district IS DISTINCT FROM v_store_district
            OR v_existing_city     IS DISTINCT FROM v_store_city THEN

                UPDATE bl_dm.dim_stores
                SET store_brand    = v_store_brand,
                    store_district = v_store_district,
                    store_city     = v_store_city,
                    update_dt      = CURRENT_DATE
                WHERE store_src_id = v_store_src_id;

                v_rows := v_rows + 1;

            END IF;

        END IF;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_stores',
        v_rows,
        'DIM_STORES loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_stores',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;

CALL bl_cl.load_dim_stores();


CREATE OR REPLACE PROCEDURE bl_cl.load_dim_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;

    v_customer_src_id BIGINT;
    v_gender VARCHAR;
    v_age INT;
    v_segment VARCHAR;
    v_registered BOOLEAN;
    v_registration_date DATE;
    v_start_dt DATE;
    v_end_dt DATE;
    v_is_active VARCHAR;
    v_source_system VARCHAR;
    v_source_entity VARCHAR;

    cur CURSOR FOR
        SELECT
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
            source_entity
        FROM bl_3nf.ce_customers_scd;

BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO
            v_customer_src_id,
            v_gender,
            v_age,
            v_segment,
            v_registered,
            v_registration_date,
            v_start_dt,
            v_end_dt,
            v_is_active,
            v_source_system,
            v_source_entity;

        EXIT WHEN NOT FOUND;

        -- Check if this version already exists
        PERFORM 1
        FROM bl_dm.dim_customers_scd
        WHERE customer_src_id = v_customer_src_id
          AND start_dt = v_start_dt;

        IF NOT FOUND THEN

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
                nextval('bl_dm.seq_dim_customers_id'),
                v_customer_src_id,
                v_gender,
                v_age,
                v_segment,
                v_registered,
                v_registration_date,
                v_start_dt,
                v_end_dt,
                v_is_active,
                v_source_system,
                v_source_entity,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            );

            v_rows := v_rows + 1;

        END IF;

    END LOOP;

    CLOSE cur;

    CALL bl_cl.write_log(
        'load_dim_customers_scd',
        v_rows,
        'DIM_CUSTOMERS_SCD loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_dim_customers_scd',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;


CALL bl_cl.load_dim_customers_scd();

CREATE OR REPLACE PROCEDURE bl_cl.load_fct_sales()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;
BEGIN

    INSERT INTO bl_dm.fct_sales (
        sales_surr_id,
        sales_src_id,
        source_system,
        event_dt,
        product_surr_id,
        supplier_surr_id,
        customer_surr_id,
        store_surr_id,
        employee_surr_id,
        delivery_surr_id,
        payment_surr_id,
        landing_surr_id,
        date_surr_id,
        price_retail,
        price_discount,
        price_sale,
        product_cost,
        delivered_in_days,
        profit,
        insert_dt,
        update_dt
    )
    SELECT
        nextval('bl_dm.seq_fct_sales_id'),
        s.transaction_src_id,
        s.source_system,
        s.sale_date,
        COALESCE(p.product_surr_id, -1),
        COALESCE(sup.supplier_surr_id, -1),
        COALESCE(c.customer_surr_id, -1),
        COALESCE(st.store_surr_id, -1),
        COALESCE(e.employee_surr_id, -1),
        COALESCE(d.delivery_surr_id, -1),
        COALESCE(pay.payment_surr_id, -1),
        COALESCE(l.landing_surr_id, -1),
        COALESCE(dt.date_surr_id, -1),
        s.price_retail,
        s.price_discount,
        s.price_sale,
        s.product_cost,
        s.i_delivered_in,
        s.price_sale - s.product_cost,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    FROM bl_3nf.ce_sales s

    LEFT JOIN bl_dm.dim_products p
        ON p.product_src_id = s.product_id::varchar

    LEFT JOIN bl_dm.dim_suppliers sup
        ON sup.supplier_src_id = s.supplier_id::varchar

    LEFT JOIN bl_dm.dim_customers_scd c
        ON c.customer_src_id = s.customer_id
       AND s.sale_date BETWEEN c.start_dt AND c.end_dt

    LEFT JOIN bl_dm.dim_stores st
        ON st.store_src_id = s.store_id::varchar

    LEFT JOIN bl_dm.dim_employees e
        ON e.employee_src_id = s.employee_id::varchar

    LEFT JOIN bl_dm.dim_deliveries d
        ON d.delivery_src_id = s.delivery_id::varchar

    LEFT JOIN bl_dm.dim_landings l
        ON l.landing_src_id = s.landing_id::varchar

    LEFT JOIN bl_dm.dim_payments pay
        ON pay.payment_src_id = s.payment_id::varchar

    LEFT JOIN bl_dm.dim_dates dt
        ON dt.full_date = s.sale_date

    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_dm.fct_sales f
        WHERE f.sales_src_id = s.transaction_src_id
          AND f.source_system = s.source_system
    );

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    CALL bl_cl.write_log(
        'load_fct_sales',
        v_rows,
        'FCT_SALES loaded',
        'SUCCESS'
    );

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.write_log(
        'load_fct_sales',
        0,
        SQLERRM,
        'ERROR'
    );
    RAISE;
END;
$$;


CALL bl_cl.load_fct_sales();

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT uq_fct_sales_src
UNIQUE (sales_src_id, source_system);

SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'bl_dm.fct_sales'::regclass
AND contype = 'u';