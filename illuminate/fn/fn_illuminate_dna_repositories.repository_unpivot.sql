USE gabby
GO

CREATE OR ALTER FUNCTION illuminate_dna_repositories.repository_unpivot (
  @repository_id INT,
  @field_names NVARCHAR(MAX) = '',
  @sql NVARCHAR(MAX) = ''
 )
RETURNS NVARCHAR(MAX)
AS
BEGIN
  SELECT @field_names = gabby.dbo.GROUP_CONCAT_D(f.name, ', ')
  FROM gabby.illuminate_dna_repositories.fields f
  WHERE f.repository_id = @repository_id
    AND f.deleted_at IS NULL;

  SELECT @sql = CONCAT('SELECT sub.repository_id, sub.repository_row_id, sub.value, f.label, s.local_student_id, CONVERT(DATE, r.date_administered) AS date_administered FROM (', ' '
                      ,'SELECT', ' '
                      ,@repository_id, ' AS repository_id, repository_row_id, student_id, CONVERT(VARCHAR(125), field) AS field, CONVERT(VARCHAR(25), value) AS value', ' '
                      ,'FROM illuminate_dna_repositories.repository_', @repository_id, ' '
                      ,'UNPIVOT(value FOR field IN (', @field_names, ')) u', ' '
                      ,'WHERE u.repository_row_id IN (SELECT repository_row_id FROM illuminate_dna_repositories.repository_row_ids WHERE repository_id = ', @repository_id, ')', ' '
                      ,') sub', ' '
                      ,'JOIN illuminate_dna_repositories.fields f ON sub.repository_id = f.repository_id AND sub.field = f.name AND f.deleted_at IS NULL', ' '
                      ,'JOIN illuminate_public.students s ON sub.student_id = s.student_id', ' '
                      ,'JOIN illuminate_dna_repositories.repositories r ON sub.repository_id = r.repository_id'
                      );

  RETURN @sql
END