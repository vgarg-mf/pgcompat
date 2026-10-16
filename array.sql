CREATE LIBRARY ArrayCompatLib AS '/opt/vertica/packages/pgcompat/lib/libpgcompat.so';

CREATE FUNCTION array_lower
AS LANGUAGE 'C++'
NAME 'ArrayLowerFactory'
LIBRARY ArrayCompatLib;

CREATE FUNCTION array_upper
AS LANGUAGE 'C++'
NAME 'ArrayUpperFactory'
LIBRARY ArrayCompatLib;

CREATE TRANSFORM FUNCTION generate_series
AS LANGUAGE 'C++'
NAME 'GenerateSeriesFactoryInt2'
LIBRARY ArrayCompatLib;

SELECT generate_series(
        array_lower(ARRAY[10,20,30,40], 1),
        array_upper(ARRAY[10,20,30,40], 1)
      )
OVER () AS array_index
ORDER BY array_index;

