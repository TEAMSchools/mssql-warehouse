CREATE
OR ALTER
PROCEDURE illuminate_dna_repositories.repository_row_ids_merge AS BEGIN
SET
ANSI_NULLS ON;

SET
QUOTED_IDENTIFIER ON;

/*
SET NOCOUNT ON added to prevent extra result sets
from interfering with SELECT statements
*/
SET
NOCOUNT ON;

/* Declare variables */
DECLARE @query NVARCHAR(MAX),
@repository_id NVARCHAR(MAX),
@linked_server_name NVARCHAR(MAX),
@message NVARCHAR(MAX);

/* Drop and recreate the temp table */
DROP TABLE IF EXISTS [#repository_row_ids];

CREATE TABLE
  [#repository_row_ids] (
    repository_id INT,
    repository_row_id INT
  );

SET
  @linked_server_name = 'ILLUMINATE';

/*
Declare the cursor FOR the set of records it will loop over
Cursor name MUST be within schema
Only use tables updated in past 24 hrs
*/
DECLARE repository_cursor CURSOR FOR
SELECT
  repository_id
FROM
  illuminate_dna_repositories.repositories
WHERE
  deleted_at IS NULL
  AND repository_id IN (
    SELECT
      CAST(
        RIGHT(
          [table],
          LEN([table]) - CHARINDEX('_', [table])
        ) AS INT
      )
    FROM
      illuminate_dna_repositories.fivetran_audit
    WHERE
      ISNUMERIC(RIGHT([table], 1)) = 1
      AND done >= DATEADD(HOUR, -24, CURRENT_TIMESTAMP)
  )
ORDER BY
  repository_id DESC;

/* Do work son */
OPEN repository_cursor;

FETCH NEXT
FROM
  repository_cursor INTO @repository_id;

WHILE @@FETCH_STATUS = 0 BEGIN
FETCH NEXT
FROM
  repository_cursor INTO @repository_id;

/*
here's the beef: the cursor is going to iterate over each repo ID
and INSERT INTO the temp table
*/
SET
  @query = N'
          INSERT INTO [#repository_row_ids]
          SELECT ' + @repository_id + ' AS repository_id
                 ,repository_row_id
          FROM OPENQUERY(' + @linked_server_name + ', ''
              SELECT repository_row_id
              FROM dna_repositories.repository_' + @repository_id + '
          '')
        ';

SET
  @message = CONCAT(
    'Loading dna_repositories.repository_',
    @repository_id
  );

RAISERROR (@message, 0, 1);

EXEC (@query);

END;

CLOSE repository_cursor;

DEALLOCATE repository_cursor;

/*
UPSERT: matching on repo, row number, studentid, and field name
DELETE if on TARGET but not MATCHED by SOURCE
*/
IF OBJECT_ID(
  N'illuminate_dna_repositories.repository_row_ids'
) IS NULL BEGIN
SET
  @message = 'Creating destination table';

RAISERROR (@message, 0, 1);

SELECT
  repository_id,
  repository_row_id INTO illuminate_dna_repositories.repository_row_ids
FROM
  #repository_row_ids;

END;

ELSE BEGIN
SET
  @message = 'Merging into destination table';

RAISERROR (@message, 0, 1);

MERGE INTO
  illuminate_dna_repositories.repository_row_ids AS tgt USING (
    SELECT
      repository_id,
      repository_row_id
    FROM
      #repository_row_ids
  ) AS src (repository_id, repository_row_id) ON tgt.repository_id = src.repository_id
  AND tgt.repository_row_id = src.repository_row_id
WHEN MATCHED THEN
UPDATE SET
  tgt.repository_id = src.repository_id,
  tgt.repository_row_id = src.repository_row_id
WHEN NOT MATCHED BY TARGET THEN
INSERT
  (repository_id, repository_row_id)
VALUES
  (
    src.repository_id,
    src.repository_row_id
  )
WHEN NOT MATCHED BY SOURCE
  AND tgt.repository_id IN (
    SELECT
      repository_id
    FROM
      #repository_row_ids
  ) THEN
DELETE;

END;

END;
