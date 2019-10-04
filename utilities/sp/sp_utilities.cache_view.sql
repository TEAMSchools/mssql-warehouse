USE gabby;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE utilities.cache_view
    @db_name     NVARCHAR(MAX)
   ,@schema_name NVARCHAR(MAX)
   ,@view_name   NVARCHAR(MAX)
AS

BEGIN
    DECLARE @sql                    NVARCHAR(MAX)
           ,@source_view            NVARCHAR(MAX)
           ,@temp_table_name        NVARCHAR(MAX)
           ,@destination_table_name NVARCHAR(MAX)
           ,@email_subject          NVARCHAR(MAX)
           ,@email_body             NVARCHAR(MAX);

    SET @source_view = @db_name + N'.' + @schema_name + N'.' + @view_name;
    SET @temp_table_name = N'#' + @db_name + @schema_name + @view_name + N'_temp';
    SET @destination_table_name = @source_view + N'_static';

    /* if source view does not exist, exit */
    IF OBJECT_ID(@source_view, 'V') IS NULL
      BEGIN
        PRINT ('View does not exist');
        RETURN;
      END;

    /* if destination table does not exist, create and exit */
    IF OBJECT_ID(@destination_table_name) IS NULL
      BEGIN
        SET @sql = N'
          SELECT *
          INTO ' + @destination_table_name + N'
          FROM ' + @source_view + N';
        ';
        EXEC (@sql);
        PRINT (@sql);
        RETURN;
      END;

    /* otherwise, drop temp table, if exists... */
    /* load data from view into temp table... */
    /* truncate destination table... */
    /* insert into destination table */
    ELSE
      BEGIN TRY
          SET @sql = N'
            DECLARE @nrows BIGINT;

            IF OBJECT_ID(N''' + @temp_table_name + N''') IS NOT NULL
              BEGIN
                DROP TABLE ' + @temp_table_name + N';
              END

              SELECT *
              INTO ' + @temp_table_name + N'
              FROM ' + @source_view + N'; 

              SELECT @nrows = COUNT(*) FROM ' + @temp_table_name + N';

            IF @nrows > 1
              BEGIN
                EXEC(''TRUNCATE TABLE ' + @destination_table_name + N''');
                INSERT INTO ' + @destination_table_name + N'
                SELECT *
                FROM ' + @temp_table_name + N';
              END
          ' ;
          PRINT (@sql);
          EXEC (@sql);
      END TRY
      BEGIN CATCH
          PRINT (ERROR_MESSAGE());

          SET @email_subject = @db_name + N'.' + @schema_name + N'.' + @view_name + N' static refresh failed';
          SET @email_body = N'The refresh procedure for ' + @db_name + N'.' + @schema_name + N'.' + @view_name + N'failed.' + CHAR(10) + ERROR_MESSAGE();

          EXEC msdb.dbo.sp_send_dbmail @profile_name = 'datarobot'
                                      ,@recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com'
                                      ,@subject = @email_subject
                                      ,@body = @email_body;
      END CATCH;
END;