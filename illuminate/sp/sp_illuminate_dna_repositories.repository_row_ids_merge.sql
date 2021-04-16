USE gabby 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE illuminate_dna_repositories.repository_row_ids_merge AS 

BEGIN
  /* SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements */
  SET NOCOUNT ON;

  /* 1.) Drop and recreate the temp table */
  IF OBJECT_ID(N'tempdb..#repository_row_ids') IS NOT NULL
    DROP TABLE [#repository_row_ids]
    CREATE TABLE [#repository_row_ids] (
        repository_id INT
       ,repository_row_id INT
     )

  /* 2.) Declare variables */
  DECLARE @query NVARCHAR(MAX)
  DECLARE @repository_id NVARCHAR(MAX)  
  DECLARE @linked_server_name NVARCHAR(MAX)
  DECLARE @message NVARCHAR(MAX)

  SET @linked_server_name = 'ILLUMINATE';

  /*
  -- 3.) Declare the cursor FOR the set of records it will loop over
  -- cursor name MUST be unique within schema 
  -- only use tables updated in past 24 hrs
  */
  DECLARE repository_cursor CURSOR FOR
    SELECT repository_id
    FROM illuminate_dna_repositories.repositories
    WHERE deleted_at IS NULL
      AND repository_id IN (SELECT CONVERT(INT, RIGHT([table], LEN([table]) - CHARINDEX('_', [table])))
                            FROM gabby.illuminate_dna_repositories.fivetran_audit
                            WHERE ISNUMERIC(RIGHT([table], 1)) = 1
                              AND done >= DATEADD(HOUR, -24, GETDATE()))
    ORDER BY repository_id DESC;

  /* 4.) Do work son */
  OPEN repository_cursor
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM repository_cursor INTO @repository_id
        IF @@FETCH_STATUS <> 0
          BEGIN
            BREAK
          END

        /*
        -- here's the beef, the cursor is going to iterate over each repo ID, and INSERT INTO the temp table
        */
        SET @query = N'
          INSERT INTO [#repository_row_ids]
          SELECT ' + @repository_id + ' AS repository_id
                 ,repository_row_id
          FROM OPENQUERY(' + @linked_server_name + ', ''
              SELECT repository_row_id
              FROM dna_repositories.repository_' + @repository_id + '
          '')
        '

        SET @message = CONCAT('Loading dna_repositories.repository_', @repository_id)
        RAISERROR(@message, 0, 1)

        EXEC(@query)
      END
  CLOSE repository_cursor
  DEALLOCATE repository_cursor;

  /*
  -- 5.) UPSERT: matching on repo, row number, studentid, and field name.  DELETE if on TARGET but not MATCHED by SOURCE 
  */
  IF OBJECT_ID(N'illuminate_dna_repositories.repository_row_ids') IS NULL
    BEGIN
      SET @message = 'Creating destination table'
      RAISERROR(@message, 0, 1)

      SELECT *
      INTO illuminate_dna_repositories.repository_row_ids
      FROM #repository_row_ids
    END
  ELSE
    BEGIN
      SET @message = 'Merging into destination table'
      RAISERROR(@message, 0, 1);

      WITH TARGET AS (
        SELECT repository_id
              ,repository_row_id
        FROM gabby.illuminate_dna_repositories.repository_row_ids
        WHERE repository_id IN (SELECT DISTINCT repository_id FROM #repository_row_ids)
       )
      MERGE INTO TARGET
        USING (SELECT repository_id
                     ,repository_row_id
               FROM #repository_row_ids) AS SOURCE
              (repository_id
              ,repository_row_id)
           ON TARGET.repository_id = SOURCE.repository_id
          AND TARGET.repository_row_id = SOURCE.repository_row_id
        WHEN MATCHED THEN
          UPDATE
            SET TARGET.repository_id = SOURCE.repository_id
               ,TARGET.repository_row_id = SOURCE.repository_row_id
        WHEN NOT MATCHED BY TARGET THEN 
          INSERT
            (repository_id
            ,repository_row_id)
          VALUES 
            (SOURCE.repository_id
            ,SOURCE.repository_row_id)
        WHEN NOT MATCHED BY SOURCE THEN 
          DELETE
        --OUTPUT $ACTION, deleted.*
        ;
    END
END
GO
