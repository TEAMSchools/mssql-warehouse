CREATE
OR ALTER
FUNCTION illuminate_dna_repositories.repository_unpivot (@repository_id INT)
/**/
RETURNS NVARCHAR(MAX) AS
/**/
BEGIN
/**/
DECLARE @field_names NVARCHAR(MAX) = '',
@field_names_converted NVARCHAR(MAX) = '',
@sql NVARCHAR(MAX) = '';

SELECT
  @field_names = dbo.GROUP_CONCAT_D (f.[name], ', '),
  @field_names_converted = dbo.GROUP_CONCAT_D (
    'CAST(' + f.[name] + ' AS NVARCHAR(256)) AS ' + f.[name],
    ', '
  )
FROM
  illuminate_dna_repositories.fields AS f
  INNER JOIN utilities.all_tables_columns AS atc ON (
    CONCAT('repository_', f.repository_id) = atc.table_name
    AND f.[name] = atc.column_name
    AND atc.[schema_name] = 'illuminate_dna_repositories'
  )
WHERE
  f.repository_id = @repository_id
  AND f.deleted_at IS NULL;

IF @field_names IS NOT NULL
SELECT
  @sql = CONCAT(
    'SELECT sub.repository_id, sub.repository_row_id, sub.[value], ',
    'CAST(f.[label] AS NVARCHAR(32)) AS [label], ',
    's.local_student_id,',
    'CAST(r.date_administered AS DATE) AS date_administered ',
    'FROM ( ',
    'SELECT repository_id, repository_row_id, student_id, ',
    'CAST(field AS VARCHAR(125)) AS field, CAST([value] AS VARCHAR(25)) AS [value] ',
    'FROM ( ',
    'SELECT ',
    @repository_id,
    ' AS repository_id, repository_row_id, student_id, ',
    @field_names_converted,
    ' ',
    'FROM illuminate_dna_repositories.repository_',
    @repository_id,
    ') AS sub ',
    'UNPIVOT([value] FOR field IN (',
    @field_names,
    ')) AS u ',
    'WHERE u.repository_row_id IN ( ',
    'SELECT repository_row_id ',
    'FROM illuminate_dna_repositories.repository_row_ids ',
    'WHERE repository_id = ',
    @repository_id,
    ') ',
    ') AS sub ',
    'INNER JOIN illuminate_dna_repositories.fields AS f ',
    'ON sub.repository_id = f.repository_id ',
    'AND sub.field = f.[name] AND f.deleted_at IS NULL ',
    'INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id ',
    'INNER JOIN illuminate_dna_repositories.repositories AS r ',
    'ON sub.repository_id = r.repository_id'
  );

ELSE
SET
  @sql = NULL;

RETURN @sql;

END;
