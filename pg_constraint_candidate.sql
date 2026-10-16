CREATE OR REPLACE VIEW pg_catalog.pg_constraint_sigma_candidate AS
WITH key_positions AS (
    SELECT constraint_id, column_name, ordinal_position
    FROM v_catalog.primary_keys
    UNION ALL
    SELECT constraint_id, column_name, ordinal_position
    FROM v_catalog.foreign_keys
)
SELECT
    constraints.constraint_schema_id AS connamespace,
    constraints.table_id AS conrelid,
    IMPLODE(source_columns.ordinal_position)
        WITHIN GROUP (ORDER BY key_positions.ordinal_position) AS conkey,
    constraints.constraint_type AS contype,
    constraint_columns.reference_table_id AS confrelid,
    IMPLODE(target_columns.ordinal_position)
        WITHIN GROUP (ORDER BY key_positions.ordinal_position) AS confkey,
    constraints.constraint_name AS conname
FROM v_catalog.table_constraints AS constraints
JOIN v_catalog.constraint_columns AS constraint_columns
  ON constraint_columns.constraint_id = constraints.constraint_id
 AND constraint_columns.table_id = constraints.table_id
JOIN key_positions
  ON key_positions.constraint_id = constraints.constraint_id
 AND key_positions.column_name = constraint_columns.column_name
JOIN v_catalog.columns AS source_columns
  ON source_columns.table_id = constraint_columns.table_id
 AND source_columns.column_name = constraint_columns.column_name
LEFT JOIN v_catalog.columns AS target_columns
  ON target_columns.table_id = constraint_columns.reference_table_id
 AND target_columns.column_name = constraint_columns.reference_column_name
WHERE constraints.constraint_type IN ('p', 'f')
GROUP BY constraints.constraint_id,
         constraints.constraint_schema_id,
         constraints.table_id,
         constraints.constraint_type,
         constraints.constraint_name,
         constraint_columns.reference_table_id;

SELECT constraint_type, COUNT(*) AS constraint_count
FROM v_catalog.table_constraints
WHERE constraint_type IN ('p', 'f')
GROUP BY constraint_type;

SELECT contype, COUNT(*) AS constraint_count
FROM pg_catalog.pg_constraint_sigma_candidate
GROUP BY contype;

SELECT conname, contype, conrelid, conkey, confrelid, confkey
FROM pg_catalog.pg_constraint_sigma_candidate
ORDER BY conrelid, conname;

SELECT candidate.conname,
       candidate.conrelid,
       candidate.confrelid,
       source_class.oid AS source_class_oid,
       target_class.oid AS target_class_oid
FROM pg_catalog.pg_constraint_sigma_candidate AS candidate
LEFT JOIN pg_catalog.pg_class AS source_class
  ON source_class.oid = candidate.conrelid
LEFT JOIN pg_catalog.pg_class AS target_class
  ON target_class.oid = candidate.confrelid
WHERE source_class.oid IS NULL
   OR (candidate.contype = 'f' AND target_class.oid IS NULL);


CREATE OR REPLACE VIEW pg_catalog.pg_constraint AS
SELECT connamespace, conrelid, conkey, contype,
       confrelid, confkey, conname
FROM pg_catalog.pg_constraint_sigma_candidate;

CREATE OR REPLACE VIEW public.pg_constraint AS
SELECT connamespace, conrelid, conkey, contype,
       confrelid, confkey, conname
FROM pg_catalog.pg_constraint_sigma_candidate;
