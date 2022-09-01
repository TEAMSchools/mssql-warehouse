USE gabby
GO

CREATE OR ALTER FUNCTION illuminate_dna_repositories.repository_unpivot (
  @repository_id INT
 )
RETURNS NVARCHAR(MAX)
AS

BEGIN
  DECLARE
    @field_names NVARCHAR(MAX) = '',
    @field_names_converted NVARCHAR(MAX) = '',
    @sql NVARCHAR(MAX) = '';

  SELECT @field_names = gabby.dbo.GROUP_CONCAT_D(f.[name], ', ')
        ,@field_names_converted = gabby.dbo.GROUP_CONCAT_D('CONVERT(NVARCHAR(256),' + f.[name] + ') AS ' + f.[name], ', ')
  FROM illuminate_dna_repositories.fields f 
  JOIN gabby.utilities.all_tables_columns atc
    ON CONCAT('repository_', f.repository_id) = atc.table_name
   AND f.[name] = atc.column_name COLLATE Latin1_General_BIN
   AND atc.[schema_name] = 'illuminate_dna_repositories'
  WHERE f.repository_id = @repository_id
    AND f.deleted_at IS NULL;

  SELECT @sql = CONCAT('SELECT sub.repository_id, sub.repository_row_id, sub.[value], CAST(f.[label] AS NVARCHAR(32)) AS [label], s.local_student_id, CAST(r.date_administered AS DATE) AS date_administered', ' '
                      ,'FROM (', ' '
                      ,'SELECT repository_id, repository_row_id, student_id, CAST(field AS VARCHAR(125)) AS field, CAST([value] AS VARCHAR(25)) AS [value] FROM (', ' '
                      ,'SELECT ', @repository_id, ' AS repository_id, repository_row_id, student_id, ', @field_names_converted, ' '
                      ,'FROM illuminate_dna_repositories.repository_', @repository_id, ') sub', ' '
                      ,'UNPIVOT([value] FOR field IN (', @field_names, ')) u', ' '
                      ,'WHERE u.repository_row_id IN (', ' '
                      ,'SELECT repository_row_id', ' '
                      ,'FROM illuminate_dna_repositories.repository_row_ids', ' '
                      ,'WHERE repository_id = ', @repository_id, ')', ' '
                      ,') sub', ' '
                      ,'JOIN illuminate_dna_repositories.fields f ON sub.repository_id = f.repository_id AND sub.field = f.[name] AND f.deleted_at IS NULL', ' '
                      ,'JOIN illuminate_public.students s ON sub.student_id = s.student_id', ' '
                      ,'JOIN illuminate_dna_repositories.repositories r ON sub.repository_id = r.repository_id'
                      );

  RETURN @sql

END
