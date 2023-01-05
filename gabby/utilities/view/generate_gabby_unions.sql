CREATE OR ALTER VIEW
  utilities.generate_gabby_unions AS
WITH
  atc AS (
    SELECT
      [db_name],
      [schema_name],
      table_name,
      column_name,
      column_type
    FROM
      utilities.all_tables_columns
    WHERE
      [db_name] IN (
        'kippnewark',
        'kippcamden',
        'kippmiami'
      )
      AND column_id > -1
      AND table_name NOT IN ('all_tables_columns')
      AND table_name NOT LIKE 'fivetran%'
      AND [schema_name] != 'fivetran_log'
  ),
  atc_pivot AS (
    SELECT
      [schema_name],
      table_name,
      column_name,
      kippmiami AS kippmiami_column_type,
      kippcamden AS kippcamden_column_type,
      kippnewark AS kippnewark_column_type,
      CONCAT(
        kippnewark,
        kippcamden,
        kippmiami
      ) AS column_type_concat,
      CASE
        WHEN (
          (
            CONCAT(kippcamden, kippnewark) != ''
            AND CHARINDEX(
              kippmiami,
              CONCAT(kippcamden, kippnewark)
            ) = 0
          )
          OR (
            CONCAT(kippmiami, kippnewark) != ''
            AND CHARINDEX(
              kippcamden,
              CONCAT(kippmiami, kippnewark)
            ) = 0
          )
          OR (
            CONCAT(kippmiami, kippcamden) != ''
            AND CHARINDEX(
              kippnewark,
              CONCAT(kippmiami, kippcamden)
            ) = 0
          )
        ) THEN 1
        ELSE 0
      END AS column_type_mismatch
    FROM
      atc PIVOT (
        MAX(column_type) FOR [db_name] IN (
          kippnewark,
          kippcamden,
          kippmiami
        )
      ) AS p
  ),
  cols AS (
    SELECT
      [schema_name],
      table_name,
      column_name,
      kippmiami_column_type,
      kippcamden_column_type,
      kippnewark_column_type,
      column_type_mismatch,
      CASE
        WHEN (kippnewark_column_type IS NULL) THEN 'NULL AS [' + column_name + ']'
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%varchar%'
        ) THEN CONCAT(
          'CAST(',
          '[' + column_name + '] ',
          'AS NVARCHAR) ',
          'COLLATE SQL_Latin1_General_CP1_CI_AS ',
          'AS [' + column_name + ']'
        )
        WHEN (
          column_type_concat LIKE '%varchar%'
        ) THEN CONCAT(
          '[' + column_name + '] ',
          'COLLATE SQL_Latin1_General_CP1_CI_AS ',
          'AS [' + column_name + ']'
        )
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%float%'
        ) THEN 'CAST([' + column_name + '] AS FLOAT) AS [' + column_name + ']'
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%datetimeoffset%'
        ) THEN 'CAST([' + column_name + '] AS DATETIMEOFFSET) AS [' + column_name + ']'
        WHEN (column_type_mismatch = 1) THEN (
          'CAST([' + column_name + '] AS INT) AS [' + column_name + ']'
        )
        ELSE '[' + column_name + ']'
      END AS kippnewark,
      CASE
        WHEN (kippmiami_column_type IS NULL) THEN 'NULL AS [' + column_name + ']'
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%varchar%'
        ) THEN CONCAT(
          'CAST(',
          '[' + column_name + '] ',
          'AS NVARCHAR) ',
          'COLLATE SQL_Latin1_General_CP1_CI_AS ',
          'AS [' + column_name + ']'
        )
        WHEN (
          column_type_concat LIKE '%varchar%'
        ) THEN CONCAT(
          '[' + column_name + '] ',
          'COLLATE SQL_Latin1_General_CP1_CI_AS ',
          'AS [' + column_name + ']'
        )
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%float%'
        ) THEN 'CAST([' + column_name + '] AS FLOAT) AS [' + column_name + ']'
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%datetimeoffset%'
        ) THEN 'CAST([' + column_name + '] AS DATETIMEOFFSET) AS [' + column_name + ']'
        WHEN (column_type_mismatch = 1) THEN (
          'CAST([' + column_name + '] AS INT) AS [' + column_name + ']'
        )
        ELSE '[' + column_name + ']'
      END AS kippmiami,
      CASE
        WHEN (kippcamden_column_type IS NULL) THEN 'NULL AS [' + column_name + ']'
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%varchar%'
        ) THEN CONCAT(
          'CAST(',
          '[' + column_name + '] ',
          'AS NVARCHAR) ',
          'COLLATE SQL_Latin1_General_CP1_CI_AS ',
          'AS [' + column_name + ']'
        )
        WHEN (
          column_type_concat LIKE '%varchar%'
        ) THEN CONCAT(
          '[' + column_name + '] ',
          'COLLATE SQL_Latin1_General_CP1_CI_AS ',
          'AS [' + column_name + ']'
        )
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%float%'
        ) THEN 'CAST([' + column_name + '] AS FLOAT) AS [' + column_name + ']'
        WHEN (
          column_type_mismatch = 1
          AND column_type_concat LIKE '%datetimeoffset%'
        ) THEN 'CAST([' + column_name + '] AS DATETIMEOFFSET) AS [' + column_name + ']'
        WHEN (column_type_mismatch = 1) THEN (
          'CAST([' + column_name + '] AS INT) AS [' + column_name + ']'
        )
        ELSE '[' + column_name + ']'
      END AS kippcamden
    FROM
      atc_pivot
  ),
  row_gen AS (
    SELECT
      n
    FROM
      utilities.row_generator
    WHERE
      (n BETWEEN 1 AND 2)
  )
SELECT
  sub.[schema_name],
  sub.table_name,
  sub.column_type_mismatch,
  CASE
    WHEN (t.n = 1) THEN CONCAT(
      'CREATE OR ALTER VIEW ',
      sub.[schema_name] + '.',
      sub.table_name + ' AS ',
      CASE
        WHEN sub.kippnewark_count > 0 THEN sub.kippnewark
      END,
      CASE
        WHEN (
          sub.kippnewark_count > 0
          AND sub.kippcamden_count > 0
        ) THEN ' UNION ALL '
      END,
      CASE
        WHEN sub.kippcamden_count > 0 THEN sub.kippcamden
      END,
      CASE
        WHEN (
          sub.kippmiami_count > 0
          AND (
            sub.kippnewark_count > 0
            OR sub.kippcamden_count > 0
          )
        ) THEN ' UNION ALL '
      END,
      CASE
        WHEN sub.kippmiami_count > 0 THEN sub.kippmiami
      END,
      ';'
    )
    WHEN (t.n = 2) THEN 'GO'
  END AS query
FROM
  (
    SELECT
      [schema_name],
      table_name,
      CONCAT(
        'SELECT ''kippnewark'' AS [db_name],',
        dbo.GROUP_CONCAT_D (kippnewark, ',') + ' ',
        'FROM kippnewark.' + [schema_name] + '.' + table_name
      ) AS kippnewark,
      CONCAT(
        'SELECT ''kippcamden'' AS [db_name],',
        dbo.GROUP_CONCAT_D (kippcamden, ',') + ' ',
        'FROM kippcamden.' + [schema_name] + '.' + table_name
      ) AS kippcamden,
      CONCAT(
        'SELECT ''kippmiami'' AS [db_name],',
        dbo.GROUP_CONCAT_D (kippmiami, ',') + ' ',
        'FROM kippmiami.' + [schema_name] + '.' + table_name
      ) AS kippmiami,
      MAX(column_type_mismatch) AS column_type_mismatch,
      COUNT(
        CASE
          WHEN (kippnewark NOT LIKE '%NULL%') THEN kippnewark
        END
      ) AS kippnewark_count,
      COUNT(
        CASE
          WHEN (kippcamden NOT LIKE '%NULL%') THEN kippcamden
        END
      ) AS kippcamden_count,
      COUNT(
        CASE
          WHEN (kippmiami NOT LIKE '%NULL%') THEN kippmiami
        END
      ) AS kippmiami_count
    FROM
      cols
    GROUP BY
      table_name,
      [schema_name]
  ) AS sub
  CROSS JOIN row_gen AS t
