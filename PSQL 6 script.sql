--1.1)

CREATE TABLE SALES_INFO
(
id INTEGER,
category VARCHAR(1),
ischeck BOOLEAN,
eventdate DATE
);

CREATE TABLE sales_info_2021 (
    CHECK (eventdate >= DATE '2021-01-01' AND eventdate < DATE '2022-01-01')
) INHERITS (sales_info);

CREATE TABLE sales_info_2022 (
    CHECK (eventdate >= DATE '2022-01-01' AND eventdate < DATE '2023-01-01')
) INHERITS (sales_info);

CREATE TABLE sales_info_2023 (
    CHECK (eventdate >= DATE '2023-01-01' AND eventdate < DATE '2024-01-01')
) INHERITS (sales_info);

CREATE TABLE sales_info_2024 (
    CHECK (eventdate >= DATE '2024-01-01' AND eventdate < DATE '2025-01-01')
) INHERITS (sales_info);


CREATE OR REPLACE FUNCTION partition_sales_info()
RETURNS trigger AS $$
BEGIN
    IF (NEW.eventdate >= DATE '2021-01-01' AND NEW.eventdate < DATE '2022-01-01') THEN
        INSERT INTO sales_info_2021 VALUES (NEW.*);
    ELSIF (NEW.eventdate >= DATE '2022-01-01' AND NEW.eventdate < DATE '2023-01-01') THEN
        INSERT INTO sales_info_2022 VALUES (NEW.*);
    ELSIF (NEW.eventdate >= DATE '2023-01-01' AND NEW.eventdate < DATE '2024-01-01') THEN
        INSERT INTO sales_info_2023 VALUES (NEW.*);
    ELSIF (NEW.eventdate >= DATE '2024-01-01' AND NEW.eventdate < DATE '2025-01-01') THEN
        INSERT INTO sales_info_2024 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER partition_sales_info_trigger
BEFORE INSERT ON sales_info
FOR EACH ROW
EXECUTE FUNCTION partition_sales_info();


INSERT INTO sales_info (id, category, ischeck, eventdate)
SELECT id,
       ('{"A","B","C","D","E","F","J","H","I","K"}'::text[])[((RANDOM())*9)::INTEGER],
       (RANDOM() > 0.5),
       (DATE '2021-01-01' + (RANDOM() * 1460)::INT)
FROM generate_series(1, 10000000) id;


UPDATE sales_info
SET eventdate = DATE '2024-06-01'
WHERE id <= 1000;




CREATE TABLE sales_info_simple (
    id INTEGER,
    category VARCHAR(1),
    ischeck BOOLEAN,
    eventdate DATE
);

INSERT INTO sales_info_simple (id, category, ischeck, eventdate)
SELECT id,
       ('{"A","B","C","D","E","F","J","H","I","K"}'::text[])[((RANDOM())*9)::INTEGER],
       (RANDOM() > 0.5),
       (DATE '2021-01-01' + (RANDOM() * 1460)::INT)
FROM generate_series(1, 10000000) id;


EXPLAIN ANALYZE
SELECT * FROM sales_info;

EXPLAIN ANALYZE
SELECT * FROM sales_info_simple;

EXPLAIN ANALYZE
SELECT *
FROM sales_info
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';


EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';


EXPLAIN ANALYZE
SELECT *
FROM sales_info
WHERE eventdate = DATE '2023-05-01';

EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE eventdate = DATE '2023-05-01';


EXPLAIN ANALYZE
SELECT COUNT(*) FROM sales_info;

EXPLAIN ANALYZE
SELECT COUNT(*) FROM sales_info_simple;



EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info_simple
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';



DROP TABLE sales_info_2021;

SELECT COUNT(*)
FROM sales_info
WHERE eventdate >= DATE '2021-01-01'
  AND eventdate < DATE '2022-01-01';

CREATE TABLE sales_info_3000 (
    CHECK (
        eventdate >= DATE '3000-01-01'
        AND eventdate < DATE '3001-01-01'
    )
) INHERITS (sales_info);

CREATE OR REPLACE FUNCTION partition_sales_info()
RETURNS trigger AS $$
BEGIN
    IF (NEW.eventdate >= DATE '2021-01-01' AND NEW.eventdate < DATE '2022-01-01') THEN
        INSERT INTO sales_info_2021 VALUES (NEW.*);

    ELSIF (NEW.eventdate >= DATE '2022-01-01' AND NEW.eventdate < DATE '2023-01-01') THEN
        INSERT INTO sales_info_2022 VALUES (NEW.*);

    ELSIF (NEW.eventdate >= DATE '2023-01-01' AND NEW.eventdate < DATE '2024-01-01') THEN
        INSERT INTO sales_info_2023 VALUES (NEW.*);

    ELSIF (NEW.eventdate >= DATE '2024-01-01' AND NEW.eventdate < DATE '2025-01-01') THEN
        INSERT INTO sales_info_2024 VALUES (NEW.*);

    ELSIF (NEW.eventdate >= DATE '3000-01-01' AND NEW.eventdate < DATE '3001-01-01') THEN
        INSERT INTO sales_info_3000 VALUES (NEW.*);

    ELSE
        RAISE EXCEPTION 'Date out of range';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;




--1.2)


CREATE TABLE sales_info_dp (
    id INTEGER,
    category VARCHAR(1),
    ischeck BOOLEAN,
    eventdate DATE
)
PARTITION BY RANGE (eventdate);


CREATE TABLE sales_info_dp_2021
PARTITION OF sales_info_dp
FOR VALUES FROM ('2021-01-01') TO ('2022-01-01')
PARTITION BY LIST (category);


CREATE TABLE sales_info_dp_2021_ab
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2021_fg
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('F','J','H','I','K');

CREATE TABLE sales_info_dp_2021_default
PARTITION OF sales_info_dp_2021
DEFAULT;


CREATE TABLE sales_info_dp_2021_ab
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2021_fg
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('F','J','H','I','K');

CREATE TABLE sales_info_dp_2021_default
PARTITION OF sales_info_dp_2021
DEFAULT;


CREATE TABLE sales_info_dp_2022
PARTITION OF sales_info_dp
FOR VALUES FROM ('2022-01-01') TO ('2023-01-01')
PARTITION BY LIST (category);

CREATE TABLE sales_info_dp_2022_grp1
PARTITION OF sales_info_dp_2022
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2022_grp2
PARTITION OF sales_info_dp_2022
FOR VALUES IN ('F','J','H','I','K');

CREATE TABLE sales_info_dp_2022_default
PARTITION OF sales_info_dp_2022
DEFAULT;


CREATE TABLE sales_info_dp_2023
PARTITION OF sales_info_dp
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01')
PARTITION BY LIST (category);

CREATE TABLE sales_info_dp_2023_grp1
PARTITION OF sales_info_dp_2023
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2023_grp2
PARTITION OF sales_info_dp_2023
FOR VALUES IN ('F','J','H','I','K');

CREATE TABLE sales_info_dp_2023_default
PARTITION OF sales_info_dp_2023
DEFAULT;


CREATE TABLE sales_info_dp_2024
PARTITION OF sales_info_dp
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01')
PARTITION BY LIST (category);

CREATE TABLE sales_info_dp_2024_grp1
PARTITION OF sales_info_dp_2024
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2024_grp2
PARTITION OF sales_info_dp_2024
FOR VALUES IN ('F','J','H','I','K');

CREATE TABLE sales_info_dp_2024_default
PARTITION OF sales_info_dp_2024
DEFAULT;


INSERT INTO sales_info_dp (id, category, ischeck, eventdate)
SELECT id,
       ('{"A","B","C","D","E","F","J","H","I","K"}'::text[])[((RANDOM())*9)::INTEGER],
       (RANDOM() > 0.5),
       (DATE '2021-01-01' + (RANDOM() * 1460)::INT)
FROM generate_series(1, 10000000) id;

SELECT *
FROM sales_info_dp_2024


UPDATE sales_info_dp
SET category = 'A'
WHERE id <= 1000;


EXPLAIN ANALYZE
SELECT * FROM sales_info_dp;

EXPLAIN ANALYZE
SELECT * FROM sales_info_simple;

EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';

EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';



EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE eventdate = DATE '2023-05-01';



EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE eventdate = DATE '2023-05-01';


EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE category = 'A';


EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE category = 'A';

EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE category IN ('A','B','C');

EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE category IN ('A','B','C');


EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE eventdate = DATE '2023-05-01'
  AND category IN ('A','B','C');

EXPLAIN ANALYZE
SELECT *
FROM sales_info_simple
WHERE eventdate = DATE '2023-05-01'
  AND category IN ('A','B','C');



EXPLAIN ANALYZE
SELECT COUNT(*) FROM sales_info_dp;

EXPLAIN ANALYZE
SELECT COUNT(*) FROM sales_info_simple;


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info_dp
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info_simple
WHERE eventdate >= DATE '2022-01-01'
  AND eventdate < DATE '2023-01-01';



ALTER TABLE sales_info_dp_2021
DETACH PARTITION sales_info_dp_2021_ab;

CREATE TABLE sales_info_dp_2021_abc
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('A','B','C');

CREATE TABLE sales_info_dp_2021_de
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('D','E');

INSERT INTO sales_info_dp_2021
SELECT * FROM sales_info_dp_2021_ab;

DROP TABLE sales_info_dp_2021_ab;

ALTER TABLE sales_info_dp_2021 DETACH PARTITION sales_info_dp_2021_abc;
ALTER TABLE sales_info_dp_2021 DETACH PARTITION sales_info_dp_2021_de;

CREATE TABLE sales_info_dp_2021_ab
PARTITION OF sales_info_dp_2021
FOR VALUES IN ('A','B','C','D','E');

INSERT INTO sales_info_dp_2021
SELECT * FROM sales_info_dp_2021_abc;

INSERT INTO sales_info_dp_2021
SELECT * FROM sales_info_dp_2021_de;

DROP TABLE sales_info_dp_2021_abc;
DROP TABLE sales_info_dp_2021_de;



--2.1)
SET max_parallel_workers_per_gather = 4;


EXPLAIN ANALYZE SELECT * FROM sales_info;
EXPLAIN ANALYZE SELECT * FROM sales_info_dp;
EXPLAIN ANALYZE SELECT * FROM sales_info_simple;

EXPLAIN ANALYZE
SELECT * FROM sales_info ORDER BY eventdate;
EXPLAIN ANALYZE
SELECT * FROM sales_info_dp ORDER BY eventdate;
EXPLAIN ANALYZE
SELECT * FROM sales_info_simple ORDER BY eventdate;


EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info;
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_dp;
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_simple;


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info_dp
WHERE eventdate >= DATE '2022-01-01'
AND eventdate < DATE '2023-01-01';


EXPLAIN ANALYZE
SELECT category, COUNT(*)
FROM sales_info_dp
GROUP BY category;


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info s
JOIN sales_info_dp d
ON s.id = d.id
WHERE s.eventdate = DATE '2023-05-01';


CREATE INDEX idx_dp_eventdate ON sales_info_dp (eventdate);
CREATE INDEX idx_dp_category ON sales_info_dp (category);


EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE eventdate = DATE '2023-05-01';


EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE category = 'A';


EXPLAIN ANALYZE
SELECT *
FROM sales_info_dp
WHERE eventdate = DATE '2023-05-01'
  AND category = 'A';




