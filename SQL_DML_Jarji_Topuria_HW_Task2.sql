--1. Create table ‘table_to_delete’ and fill it with the following query:
CREATE TABLE table_to_delete AS
	SELECT 'veeeeeeery_long_string' || x AS col
	FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7)

	
--2. Lookup how much space this table consumes with the following query:
--table consumes 575MBs
SELECT
	*,
	pg_size_pretty(total_bytes) AS total,
	pg_size_pretty(index_bytes) AS INDEX,
	pg_size_pretty(toast_bytes) AS toast,
	pg_size_pretty(table_bytes) AS TABLE
FROM
	(
	SELECT
		*,
		total_bytes-index_bytes-COALESCE(toast_bytes, 0) AS table_bytes
	FROM
		(
		SELECT
			c.oid,
			nspname AS table_schema,
			relname AS TABLE_NAME,
			c.reltuples AS row_estimate,
			pg_total_relation_size(c.oid) AS total_bytes,
			pg_indexes_size(c.oid) AS index_bytes,
			pg_total_relation_size(reltoastrelid) AS toast_bytes
		FROM
			pg_class c
		LEFT JOIN pg_namespace n ON
			n.oid = c.relnamespace
		WHERE
			relkind = 'r'
                                              ) a
                                    ) a
WHERE
	table_name LIKE '%table_to_delete%';



--3. Issue the following DELETE operation on ‘table_to_delete’:
DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; 
--execute time was 16s. checked table memory consumption, its 575mbs again.
--the conclusion is, that while DELETEd data can't be accessed by querying, they still take up space in DB. 

VACUUM FULL VERBOSE table_to_delete;
--after this function that 1/3 of data was wiped from memory, now the table takes 383mbs

DROP TABLE IF EXISTS public.table_to_delete;
CREATE TABLE public.table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;
ANALYZE public.table_to_delete;
--dropped and recreated. back to 575mbs

--4. Issue the following TRUNCATE operation: TRUNCATE table_to_delete;
TRUNCATE table_to_delete;
--execute time was just 0.1s.
--table takes up 0 bytes, its compeltely wiped.

/*5. Hand over your investigation's results to your trainer. The results must include:
a) Space consumption of ‘table_to_delete’ table before and after each operation;
b) Duration of each operation (DELETE, TRUNCATE)
We conducted three different operations - delete, vacuum, truncate.
Initial data was 575mb. Truncating was almost instant and fully removed data, while delete + vacuum is
a two-step process that takes longer, ~26 sec total.
Truncate interacts with the whole table, while delete can be used to target specific rows.
If we want to fully wipe tables, usually truncate is the way to go, however for very small tables it was
revealed in our theoretical materials that delete-vacuum combination can be slightly faster.
+------------+----------------------------------+------------+----------------------+
| Step       | Action                           | Duration   | Data size remaining  |
+------------+----------------------------------+------------+----------------------+
| DELETE     | Remove 1/3 of the rows           | ~16 sec    | ~575mb		        |
| TRUNCATE   | Drop all rows instantly          | <1 sec     | ~0mb   	 	        |
| VACUUM     | Reclaim disk space after 1/3 del | ~10 sec    | ~383mb 	 	        |
+------------+----------------------------------+------------+----------------------+
*/




















