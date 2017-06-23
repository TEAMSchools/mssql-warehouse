USE gabby
GO

IF OBJECT_ID ('powerschool.TR_cohort_AI','TR') IS NOT NULL
   DROP TRIGGER powerschool.TR_cohort_AI;
GO

CREATE TRIGGER powerschool.TR_cohort_AI ON powerschool.fivetran_audit
  AFTER INSERT
AS

DECLARE @schema_name NVARCHAR(MAX)
       ,@view_name NVARCHAR(MAX)
       ,@is_referenced_table INT
       ,@update_status INT
       ,@email_subject NVARCHAR(MAX)
       ,@email_body NVARCHAR(MAX);

SET @schema_name = 'powerschool'
SET @view_name = 'cohort'

BEGIN

  /* get list of tables referenced by view */  
  IF OBJECT_ID(N'tempdb..#referenced_tables') IS NOT NULL
		  BEGIN
		    DROP TABLE #referenced_tables;
		  END
      
  SELECT referenced_entity_name AS table_name
  INTO #referenced_tables
  FROM sys.dm_sql_referenced_entities(@schema_name + '.' + @view_name, 'OBJECT')
  WHERE referenced_minor_id = 0;

  /* get list of tables updated during current hour */  
  IF OBJECT_ID(N'tempdb..#updated_tables') IS NOT NULL
		  BEGIN
		    DROP TABLE #updated_tables;
		  END

  SELECT [table] AS table_name
  INTO #updated_tables
  FROM powerschool.fivetran_audit
  WHERE update_started >= DATETIMEFROMPARTS(DATEPART(YEAR,GETUTCDATE()), DATEPART(MONTH,GETUTCDATE()), DATEPART(DAY,GETUTCDATE())
                                           ,DATEPART(HOUR,GETUTCDATE()), 0, 0, 0);
  
  /* check if updated table is included in view */  
  SELECT @is_referenced_table = CASE WHEN COUNT([table]) > 0 THEN 1 ELSE 0 END
  FROM INSERTED
  WHERE [table] IN (SELECT table_name FROM #referenced_tables);
    
  IF @is_referenced_table = 0 
    BEGIN
      PRINT('INSERTED table is not included in target view');
      RETURN    
    END

  /* check if all tables included in view has been updated */  
  SELECT @update_status = CASE WHEN  COUNT(rt.table_name) = COUNT(ut.table_name) THEN 1 ELSE 0 END
  FROM #referenced_tables rt
  LEFT OUTER JOIN #updated_tables ut
    ON rt.table_name = ut.table_name;

  IF @update_status = 0
    BEGIN
      PRINT('All tables referenced by view have not yet been updated this hour');
      RETURN    
    END

  /* run refresh */
  PRINT('Running refresh')
  BEGIN
    BEGIN TRY
      EXEC utilities.cache_view @schema_name, @view_name
    END TRY
    BEGIN CATCH
      SET @email_subject = @view_name + ' static refresh failed'
      SET @email_body = 'During the trigger, the refresh procedure for ' + @view_name + 'failed.';
      
      EXEC msdb.dbo.sp_send_dbmail  
        @profile_name = 'datarobot',  
        @recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',  
        @subject = @email_subject,
        @body = @email_body;        
    END CATCH
  END

END
GO