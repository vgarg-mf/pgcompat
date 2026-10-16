CREATE TYPE IF NOT EXISTS pg_catalog.text(x=varchar);

SELECT 'probe'::pg_catalog.text;
SELECT 'probe'::text;

SELECT attname, attname::text AS cast_name
FROM pg_catalog.pg_attribute
LIMIT 10;
