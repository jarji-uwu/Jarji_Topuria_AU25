CREATE TABLE IF NOT EXISTS bl_cl.etl_log (
    log_id            bigserial PRIMARY KEY,
    log_timestamp     timestamp DEFAULT CURRENT_TIMESTAMP,
    procedure_name    varchar(100),
    rows_affected     integer,
    log_message       text,
    log_status        varchar(20)   -- SUCCESS / ERROR
);


CREATE OR REPLACE PROCEDURE bl_cl.write_log(
    p_procedure_name varchar,
    p_rows_affected  integer,
    p_message        text,
    p_status         varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO bl_cl.etl_log (
        procedure_name,
        rows_affected,
        log_message,
        log_status
    )
    VALUES (
        p_procedure_name,
        p_rows_affected,
        p_message,
        p_status
    );
END;
$$;

