CREATE TABLE bl_dm.fct_sales (
    sales_surr_id BIGINT NOT NULL,
    sales_src_id  BIGINT NOT NULL,
    source_system VARCHAR(4000) NOT NULL,
    event_dt DATE NOT NULL,

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
    profit NUMERIC(18,2) NOT NULL,

    insert_dt TIMESTAMP NOT NULL,
    update_dt TIMESTAMP
)
PARTITION BY RANGE (event_dt);



ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT uq_fct_sales_src
UNIQUE (sales_src_id, source_system, event_dt);



ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_product
FOREIGN KEY (product_surr_id)
REFERENCES bl_dm.dim_products(product_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_supplier
FOREIGN KEY (supplier_surr_id)
REFERENCES bl_dm.dim_suppliers(supplier_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_customer
FOREIGN KEY (customer_surr_id)
REFERENCES bl_dm.dim_customers_scd(customer_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_store
FOREIGN KEY (store_surr_id)
REFERENCES bl_dm.dim_stores(store_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_employee
FOREIGN KEY (employee_surr_id)
REFERENCES bl_dm.dim_employees(employee_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_delivery
FOREIGN KEY (delivery_surr_id)
REFERENCES bl_dm.dim_deliveries(delivery_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_payment
FOREIGN KEY (payment_surr_id)
REFERENCES bl_dm.dim_payments(payment_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_landing
FOREIGN KEY (landing_surr_id)
REFERENCES bl_dm.dim_landings(landing_surr_id);

ALTER TABLE bl_dm.fct_sales
ADD CONSTRAINT fk_fct_sales_date
FOREIGN KEY (date_surr_id)
REFERENCES bl_dm.dim_dates(date_surr_id);



CREATE OR REPLACE PROCEDURE bl_cl.ensure_month_partition(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start DATE;
    v_end DATE;
    v_table_name TEXT;
BEGIN
    v_start := date_trunc('month', p_date)::DATE;
    v_end   := (v_start + INTERVAL '1 month')::DATE;

    v_table_name := 'fct_sales_' || to_char(v_start, 'YYYY_MM');

    -- create standalone table if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'bl_dm'
          AND c.relname = v_table_name
    ) THEN

        EXECUTE format(
            'CREATE TABLE bl_dm.%I (LIKE bl_dm.fct_sales INCLUDING ALL)',
            v_table_name
        );

        EXECUTE format(
            'ALTER TABLE bl_dm.fct_sales
             ATTACH PARTITION bl_dm.%I
             FOR VALUES FROM (%L) TO (%L)',
            v_table_name,
            v_start,
            v_end
        );
    END IF;
END;
$$;



CREATE OR REPLACE PROCEDURE bl_cl.load_fct_sales()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT;
    v_min_date DATE;
    v_max_date DATE;
    v_month DATE;
BEGIN

    -- rolling 3 months window
    v_min_date := date_trunc('month', CURRENT_DATE - INTERVAL '3 months')::DATE;
    v_max_date := date_trunc('month', CURRENT_DATE)::DATE;

    -- ensure partitions exist for window
    v_month := v_min_date;

    WHILE v_month <= v_max_date LOOP
        CALL bl_cl.ensure_month_partition(v_month);
        v_month := (v_month + INTERVAL '1 month')::DATE;
    END LOOP;

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
    WHERE s.sale_date >= v_min_date
      AND NOT EXISTS (
          SELECT 1
          FROM bl_dm.fct_sales f
          WHERE f.sales_src_id = s.transaction_src_id
            AND f.source_system = s.source_system
            AND f.event_dt = s.sale_date
      );

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    CALL bl_cl.write_log(
        'load_fct_sales',
        v_rows,
        'Partitioned rolling 3-month load',
        'SUCCESS'
    );

END;
$$;


CALL bl_cl.load_fct_sales();









