WITH
  repos AS (
    SELECT
      r.title,
      dsc.code_translation AS scope,
      dsu.code_translation AS subject_area,
      CONCAT('repository_', r.repository_id) AS repo_name,
      CONCAT(
        'SELECT ',
        r.repository_id,
        ' AS repository_id',
        CHAR(10),
        CHAR(13),
        ',repository_row_id',
        CHAR(10),
        CHAR(13),
        ',student_id',
        CHAR(10),
        CHAR(13),
        'FROM gabby.illuminate_dna_repositories.',
        CONCAT('repository_', r.repository_id),
        CHAR(10),
        CHAR(13),
        'UNION ALL '
      ) AS select_statement
    FROM
      gabby.illuminate_dna_repositories.repositories AS r
      INNER JOIN gabby.illuminate_codes.dna_scopes AS dsc ON r.code_scope_id = dsc.code_id
      INNER JOIN gabby.illuminate_codes.dna_subject_areas AS dsu ON r.code_subject_area_id = dsu.code_id
      /* F&P */
    WHERE
      dsc.code_translation = 'Reporting'
      AND dsu.code_translation = 'F&P'
  )
SELECT
  column_name,
  label,
  COALESCE(
    [repository_126],
    CONCAT(',NULL AS [', label, ']')
  ) AS [repository_126],
  COALESCE(
    [repository_169],
    CONCAT(',NULL AS [', label, ']')
  ) AS [repository_169],
  COALESCE(
    [repository_170],
    CONCAT(',NULL AS [', label, ']')
  ) AS [repository_170]
FROM
  (
    SELECT
      t.name AS table_name,
      c.name AS column_name,
      f.label,
      COALESCE(
        ',' + c.name + ' AS [' + LTRIM(RTRIM(f.label)) + ']',
        ',' + c.name
      ) AS pivot_value
    FROM
      gabby.sys.tables AS t
      INNER JOIN gabby.sys.all_columns AS c ON t.object_id = c.object_id
      AND c.name NOT LIKE '_fivetran%'
      INNER JOIN gabby.illuminate_dna_repositories.fields AS f ON c.name = f.name
      AND SUBSTRING(
        t.name,
        CHARINDEX('_', t.name) + 1,
        LEN(t.name)
      ) = f.repository_id
      AND f.deleted_at IS NULL
    WHERE
      t.name IN (
        SELECT
          repo_name
        FROM
          repos
      )
      -- /*
  ) AS sub PIVOT (
    MAX(pivot_value) FOR table_name IN (
      [repository_126],
      [repository_169],
      [repository_170]
    )
  ) AS p
  -- */
