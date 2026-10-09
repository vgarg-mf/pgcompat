DROP SCHEMA IF EXISTS pg_catalog CASCADE;

CREATE SCHEMA pg_catalog;

CREATE VIEW pg_catalog.pg_namespace AS
SELECT
    schema_id AS oid,
    schema_name AS nspname
FROM v_catalog.schemata;


CREATE VIEW pg_catalog.pg_class AS
SELECT
    table_id AS oid,
    table_name AS relname,
    table_schema_id AS relnamespace,
    'r' AS relkind
FROM v_catalog.tables

UNION ALL

SELECT
    table_id AS oid,
    table_name AS relname,
    table_schema_id AS relnamespace,
    'v' AS relkind
FROM v_catalog.views;


CREATE VIEW pg_catalog.pg_attribute AS
SELECT
    table_id AS attrelid,
    column_name AS attname,
    DENSE_RANK() OVER (
        ORDER BY LOWER(data_type)
    ) AS atttypid,
    ordinal_position AS attnum,
    NOT is_nullable AS attnotnull
FROM v_catalog.columns;


CREATE VIEW pg_catalog.pg_type AS
SELECT
    DENSE_RANK() OVER (
        ORDER BY LOWER(data_type)
    ) AS oid,
    data_type AS typname
FROM (
    SELECT DISTINCT data_type
    FROM v_catalog.columns
) types;



CREATE VIEW pg_catalog.pg_description AS
SELECT
    CAST(NULL AS INT) AS objoid,
    CAST(NULL AS INT) AS objsubid,
    CAST(NULL AS VARCHAR(65000)) AS description
WHERE 1 = 0;


CREATE VIEW pg_catalog.pg_constraint AS
SELECT
    tc.constraint_schema_id AS connamespace,
    tc.table_id AS conrelid,
    ARRAY[c.ordinal_position] AS conkey,
    tc.constraint_type AS contype
FROM v_catalog.table_constraints tc
JOIN v_catalog.constraint_columns cc
    ON cc.constraint_id = tc.constraint_id
JOIN v_catalog.columns c
    ON c.table_id = cc.table_id
    AND c.column_name = cc.column_name
WHERE tc.constraint_type = 'p';


CREATE VIEW pg_catalog.pg_matviews AS
SELECT
    CAST(NULL AS VARCHAR(128)) AS schemaname,
    CAST(NULL AS VARCHAR(128)) AS matviewname,
    CAST(NULL AS VARCHAR(128)) AS matviewowner,
    CAST(NULL AS VARCHAR(128)) AS tablespace,
    CAST(NULL AS BOOLEAN) AS hasindexes,
    CAST(NULL AS BOOLEAN) AS ispopulated,
    CAST(NULL AS VARCHAR(65000)) AS definition
WHERE 1 = 0;


GRANT USAGE ON SCHEMA pg_catalog TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA INFORMATION_SCHEMA TO PUBLIC;
