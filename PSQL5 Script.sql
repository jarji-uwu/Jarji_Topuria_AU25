CREATE TABLE test_joins_a
(
id1 int,
id2 int
);
CREATE TABLE test_joins_b
(
id1 int,
id2 int
);
INSERT INTO test_joins_a values(generate_series(1,10000),3);
INSERT INTO test_joins_b values(generate_series(1,10000),3);
ANALYZE;


SELECT *
FROM test_joins_b
LIMIT 10

EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a, test_joins_b b
WHERE a.id1 > b.id1;



EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a
CROSS JOIN test_joins_b b;


--1.2)
SHOW enable_nestloop;
SHOW enable_hashjoin;
SHOW enable_mergejoin;

SET enable_nestloop = off;
SET enable_mergejoin = off;

EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a
JOIN test_joins_b b
ON a.id1 = b.id1;

--semi joins

EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a
WHERE EXISTS (
    SELECT 1
    FROM test_joins_b b
    WHERE a.id1 = b.id1
);

SET enable_hashjoin = off;

EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a
WHERE EXISTS (
    SELECT 1
    FROM test_joins_b b
    WHERE a.id1 = b.id1
);

SET enable_hashjoin = on;

EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a
WHERE EXISTS (
    SELECT 1
    FROM test_joins_b b
    WHERE a.id1 = b.id1
);

--1.3)

SET enable_hashjoin = on;
SET enable_nestloop = on;
SET enable_mergejoin = on;

EXPLAIN ANALYZE
SELECT *
FROM test_joins_a a
JOIN test_joins_b b
ON a.id1 = b.id1
ORDER BY a.id1;

--2.1)

CREATE TABLE test_joins_c
(
id1 int,
id2 int
);

INSERT INTO test_joins_c
values(generate_series(1,1000000),(random()*10)::int);

EXPLAIN
SELECT c.id2
FROM test_joins_b b
JOIN test_joins_a a on (b.id1 = a.id1)
LEFT JOIN test_joins_c c on (c.id1 = b.id1);

SET join_collapse_limit = 1;

EXPLAIN
SELECT c.id2
FROM test_joins_b b
JOIN test_joins_a a ON (b.id1 = a.id1)
LEFT JOIN test_joins_c c ON (c.id1 = b.id1);

SET join_collapse_limit = 8;

--2.2)

CREATE TABLE orders AS
SELECT id AS order_id,
 (id * 10 * random()*10)::int AS order_cost,
 'order number ' || id AS order_num
FROM generate_series(1, 1000) AS id;

CREATE TABLE stores (
store_id int,
store_name text,
max_order_cost int
);

INSERT INTO stores VALUES
 (1, 'grossery shop', '800'),
 (2, 'bakery', '100'),
 (3, 'manufactured goods', '3000')
;

SELECT s.store_id,
       s.store_name,
       o.order_id,
       o.order_cost,
       o.order_num
FROM stores s
CROSS JOIN LATERAL (
    SELECT *
    FROM orders o
    WHERE o.order_cost < s.max_order_cost
    ORDER BY o.order_cost DESC
    LIMIT 10
) o
ORDER BY s.store_id, o.order_cost DESC;


--3.1)
WITH RECURSIVE emp_hierarchy AS (
    -- anchor: start from president
    SELECT 
        e.empno,
        e.ename,
        e.mgr,
        NULL::varchar AS manager_name,
        1 AS lvl
    FROM emp e
    WHERE e.job = 'PRESIDENT'

    UNION ALL

    -- recursive part
    SELECT 
        e.empno,
        e.ename,
        e.mgr,
        m.ename AS manager_name,
        h.lvl + 1
    FROM emp e
    JOIN emp_hierarchy h ON e.mgr = h.empno
    JOIN emp m ON e.mgr = m.empno
)
SELECT *
FROM emp_hierarchy
ORDER BY lvl, empno;


--3.2)
CREATE TABLE order_log
(
    log_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id integer,
    order_cost integer,
    order_num text,
    action_type varchar(1) CHECK (action_type IN ('U','D')),
    log_date timestamptz DEFAULT now()
);


WITH updated AS (
    UPDATE orders
    SET order_cost = order_cost / 2
    WHERE order_cost BETWEEN 100 AND 1000
    RETURNING order_id, order_cost, order_num
),
logged_updates AS (
    INSERT INTO order_log (order_id, order_cost, order_num, action_type)
    SELECT order_id, order_cost, order_num, 'U'
    FROM updated
),
deleted AS (
    DELETE FROM orders
    WHERE order_cost < 50
    RETURNING order_id, order_cost, order_num
)
INSERT INTO order_log (order_id, order_cost, order_num, action_type)
SELECT order_id, order_cost, order_num, 'D'
FROM deleted;

--checks
SELECT action_type, count(*)
FROM order_log
GROUP BY action_type;

SELECT *
FROM orders
WHERE order_cost BETWEEN 50 AND 500;

SELECT *
FROM orders
WHERE order_cost < 50;