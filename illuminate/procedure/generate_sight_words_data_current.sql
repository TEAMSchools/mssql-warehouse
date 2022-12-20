CREATE
OR ALTER
/* trunk-ignore(sqlfluff/L016) */
PROCEDURE illuminate_dna_repositories.generate_sight_words_data_current AS BEGIN DECLARE @sql NVARCHAR(MAX);

/* reset view */
/* trunk-ignore(sqlfluff/L036) */
SELECT
  @sql = CONCAT(
    'CREATE OR ALTER VIEW illuminate_dna_repositories.sight_words_data_current AS ',
    gabby.dbo.GROUP_CONCAT_D (select_sql, '')
  )
FROM
  (
    SELECT
      /* trunk-ignore(sqlfluff/L041) */
      TOP 1000 CONCAT(
        select_sql,
        CASE
          WHEN ROW_NUMBER() OVER (
            ORDER BY
              repository_id DESC
          ) = 1 THEN ''
          ELSE ' UNION ALL '
        END
      ) AS select_sql
    FROM
      gabby.illuminate_dna_repositories.sight_words_quiz_union_generator
    WHERE
      select_sql IS NOT NULL
      AND is_missing = 0
    ORDER BY
      repository_id
  ) AS sub EXEC (@sql);

/* drop indexes */
BEGIN TRY;

/* trunk-ignore(sqlfluff/L036) */
SELECT
  @sql = gabby.dbo.GROUP_CONCAT_D (drop_index_sql, ' ')
FROM
  illuminate_dna_repositories.sight_words_quiz_index_generator;

EXEC (@sql);

END TRY BEGIN CATCH
/* trunk-ignore(sqlfluff/L036) */
SELECT
  1;

END CATCH;

/* reset indexes */
/* trunk-ignore(sqlfluff/L036) */
SELECT
  @sql = gabby.dbo.GROUP_CONCAT_D (create_index_sql, ' ')
FROM
  illuminate_dna_repositories.sight_words_quiz_index_generator;

EXEC (@sql);

END;
