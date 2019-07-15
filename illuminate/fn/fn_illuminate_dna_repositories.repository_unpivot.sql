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

  SELECT @sql = CONCAT('SELECT', ' '
                      ,@repository_id, ' AS repository_id, repository_row_id, student_id, CONVERT(VARCHAR(125), field) AS field, CONVERT(VARCHAR(25), value) AS value', ' '
                      ,'FROM illuminate_dna_repositories.repository_', @repository_id, ' '
                      ,'UNPIVOT(value FOR field IN (', @field_names, ')) u');

  RETURN @sql
END