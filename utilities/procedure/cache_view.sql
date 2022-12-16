USE gabby;

GO
SET
ANSI_NULLS ON;

GO
SET
QUOTED_IDENTIFIER ON;

GOCREATE
OR ALTER
PROCEDURE utilities.cache_view @db_name NVARCHAR(MAX),
@schema_name NVARCHAR(MAX),
@view_name NVARCHAR(MAX) AS BEGIN
SET
XACT_ABORT ON;

DECLARE @sql_create NVARCHAR(MAX),
@sql_drop1 NVARCHAR(MAX),
@sql_drop2 NVARCHAR(MAX),
@sql_selectinto NVARCHAR(MAX),
@sql_truncateinsert NVARCHAR(MAX),
@rowcount INT,
@source_view NVARCHAR(MAX),
@temp_table_name NVARCHAR(MAX),
@destination_table_name NVARCHAR(MAX),
@email_subject NVARCHAR(MAX),
@email_body NVARCHAR(MAX)
SET
  @source_view = @db_name + N'.' + @schema_name + N'.' + @view_name;

SET
  @temp_table_name = N'tempdb..##' + @db_name + @schema_name + @view_name;

SET
  @destination_table_name = @source_view + N'_static';

/* if source view does not exist, exit */
IF OBJECT_ID(@source_view, 'V') IS NULL BEGIN RAISERROR ('View does not exist', 0, 1)
WITH
  NOWAIT;

RETURN;

END;

/* if destination table does not exist,CREATE and exit */
IF OBJECT_ID(@destination_table_name) IS NULL BEGIN
SET
  @sql_create = N'
        SELECT *
        INTO ' + @destination_table_name + N'
        FROM ' + @source_view + N';
      ';

BEGIN TRY BEGIN TRANSACTION RAISERROR (@sql_create, 0, 1)
WITH
  NOWAIT;

EXEC (@sql_create);

COMMIT END TRY BEGIN CATCH ROLLBACK;

SET
  @email_body = ERROR_MESSAGE();

SET
  @email_subject = N'CREATE - ' + @destination_table_name + N' failed';

EXEC msdb.dbo.sp_notify_operator @profile_name = N'datarobot',
@name = N'Data Robot',
@subject = @email_subject,
@body = @email_body;

THROW;

END CATCH;

END;

ELSE BEGIN
/* drop temp table, if exists... */
SET
  @sql_drop1 = N'
        IF OBJECT_ID(N''' + @temp_table_name + N''') IS NOT NULL
          BEGIN
            DROP TABLE ' + @temp_table_name + N';
          END
      ' BEGIN TRY BEGIN TRANSACTION RAISERROR (@sql_drop1, 0, 1)
WITH
  NOWAIT;

EXEC (@sql_drop1);

COMMIT END TRY BEGIN CATCH ROLLBACK;

SET
  @email_body = ERROR_MESSAGE();

SET
  @email_subject = N'DROP TEMP - ' + @destination_table_name + N' failed';

EXEC msdb.dbo.sp_notify_operator @profile_name = N'datarobot',
@name = N'Data Robot',
@subject = @email_subject,
@body = @email_body;

THROW;

END CATCH;

/* load data from view into temp table... */
SET
  @sql_selectinto = N'
        SELECT *
        INTO ' + @temp_table_name + N'
        FROM ' + @source_view + N'
        OPTION (MAXDOP 1);
      ' BEGIN TRY BEGIN TRANSACTION RAISERROR (@sql_selectinto, 0, 1)
WITH
  NOWAIT;

EXEC (@sql_selectinto);

COMMIT END TRY BEGIN CATCH ROLLBACK;

SET
  @email_body = ERROR_MESSAGE();

SET
  @email_subject = N'INSERT TEMP - ' + @destination_table_name + N' failed';

EXEC msdb.dbo.sp_notify_operator @profile_name = N'datarobot',
@name = N'Data Robot',
@subject = @email_subject,
@body = @email_body;

THROW;

END CATCH;

/* truncate/insert into destination table */
SET
  @sql_truncateinsert = N'
        TRUNCATE TABLE ' + @destination_table_name + N';
        INSERT INTO ' + @destination_table_name + N' WITH(TABLOCKX)
        SELECT *
        FROM ' + @temp_table_name + N';
      ';

IF @@ROWCOUNT > 0 BEGIN BEGIN TRY BEGIN TRANSACTION RAISERROR (@sql_truncateinsert, 0, 1)
WITH
  NOWAIT;

EXEC (@sql_truncateinsert);

COMMIT END TRY BEGIN CATCH ROLLBACK;

SET
  @email_body = ERROR_MESSAGE();

SET
  @email_subject = N'TRUNCATE/INSERT DEST - ' + @destination_table_name + N' failed';

EXEC msdb.dbo.sp_notify_operator @profile_name = N'datarobot',
@name = N'Data Robot',
@subject = @email_subject,
@body = @email_body;

THROW;

END CATCH;

END
/* drop temp table, if exists... */
SET
  @sql_drop2 = N'
        IF OBJECT_ID(N''' + @temp_table_name + N''') IS NOT NULL
          BEGIN
            DROP TABLE ' + @temp_table_name + N';
          END
      ' BEGIN TRY BEGIN TRANSACTION RAISERROR (@sql_drop2, 0, 1)
WITH
  NOWAIT;

EXEC (@sql_drop2);

COMMIT END TRY BEGIN CATCH ROLLBACK;

SET
  @email_body = ERROR_MESSAGE();

SET
  @email_subject = N'DROP TEMP - ' + @destination_table_name + N' failed';

EXEC msdb.dbo.sp_notify_operator @profile_name = N'datarobot',
@name = N'Data Robot',
@subject = @email_subject,
@body = @email_body;

THROW;

END CATCH;

END END;
