USE gabby
GO

CREATE OR ALTER PROCEDURE illuminate_dna_repositories.generate_sight_words_data_current AS

BEGIN

  DECLARE @sql NVARCHAR(MAX);

  /* reset view */
  SELECT @sql = 'CREATE OR ALTER VIEW illuminate_dna_repositories.sight_words_data_current AS ' + gabby.dbo.GROUP_CONCAT_D(select_sql, '')
  FROM
      (
       SELECT TOP 100
              select_sql
       FROM gabby.illuminate_dna_repositories.sight_words_quiz_union_generator
       WHERE is_missing = 0
       ORDER BY repository_id
      ) sub
  EXEC(@sql);

  /* drop indexes */
  BEGIN TRY
    SELECT @sql = gabby.dbo.GROUP_CONCAT_D(drop_index_sql, ' ') FROM illuminate_dna_repositories.sight_words_quiz_index_generator;
    EXEC(@sql);
  END TRY
  BEGIN CATCH
    SELECT 1;
  END CATCH

  /* reset indexes */
  SELECT @sql = gabby.dbo.GROUP_CONCAT_D(create_index_sql, ' ') FROM illuminate_dna_repositories.sight_words_quiz_index_generator;
  EXEC(@sql);

END
