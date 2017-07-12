USE gabby
GO

IF OBJECT_ID ('powerschool.TR_cohort_identifiers_refresh_AI','TR') IS NOT NULL
   DROP TRIGGER powerschool.TR_cohort_identifiers_refresh_AI;
GO

CREATE TRIGGER powerschool.TR_cohort_identifiers_refresh_AI ON powerschool.fivetran_audit
  AFTER INSERT
AS

DECLARE @schema_name NVARCHAR(MAX)
       ,@view_name NVARCHAR(MAX)
       ,@is_referenced_table INT
       ,@update_status INT
       ,@email_subject NVARCHAR(MAX)
       ,@email_body NVARCHAR(MAX)
       ,@stage NVARCHAR(MAX);

SET @schema_name = 'powerschool'
SET @view_name = 'cohort_identifiers'

BEGIN
  BEGIN TRY
    /* get list of tables referenced by view */  
    /* only include non-static table objects */
    SET @stage = 'referenced tables'
    IF OBJECT_ID(N'tempdb..#referenced_tables') IS NOT NULL
		    BEGIN
		      DROP TABLE #referenced_tables;
		    END;
      
    WITH dependentobjects AS (
      SELECT DISTINCT 
             b.object_id AS UsedByObjectId        
            ,SCHEMA_NAME(b.schema_id) AS UsedBySchemaName
            ,b.name AS UsedByObjectName
            ,b.type AS UsedByObjectType
            ,c.object_id AS DependentObjectId
            ,SCHEMA_NAME(c.schema_id) AS DependentSchemaName
            ,c.name AS DependentObjectName
            ,c.type AS DependentObjectType        
      FROM  sys.sysdepends a
      INNER JOIN sys.objects b 
         ON a.id = b.object_id
      INNER JOIN sys.objects c 
         ON a.depid = c.object_id
        AND c.type IN ('U', 'P', 'V', 'FN')
      WHERE b.type IN ('P','V', 'FN')
     )
 
    ,dependentobjects2 AS (
       SELECT UsedByObjectId
             ,UsedByObjectName
             ,UsedByObjectType
             ,DependentObjectId
             ,DependentObjectName
             ,DependentObjectType 
             ,1 AS Level
       FROM DependentObjects a
       WHERE a.UsedBySchemaName = @schema_name
         AND a.UsedByObjectName = @view_name

       UNION ALL 

       SELECT a.UsedByObjectId, 
              a.UsedByObjectName, 
              a.UsedByObjectType,
              a.DependentObjectId, 
              a.DependentObjectName, 
              a.DependentObjectType, 
              (b.Level + 1) AS Level
       FROM DependentObjects a
       INNER JOIN DependentObjects2 b 
          ON a.UsedByObjectId = b.DependentObjectId
    )

    SELECT DISTINCT dependentobjectname AS table_name  
    INTO #referenced_tables
    FROM dependentobjects2
    WHERE dependentobjecttype = 'U'
      AND dependentobjectname NOT LIKE '%_static';

    /* get list of tables updated during current hour */  
    SET @stage = 'updated tables'
    IF OBJECT_ID(N'tempdb..#updated_tables') IS NOT NULL
		    BEGIN
		      DROP TABLE #updated_tables;
		    END

    SELECT [table] AS table_name
    INTO #updated_tables
    FROM powerschool.fivetran_audit /* change schema name for each trigger */
    WHERE update_started >= DATETIMEFROMPARTS(DATEPART(YEAR,GETUTCDATE()), DATEPART(MONTH,GETUTCDATE()), DATEPART(DAY,GETUTCDATE())
                                             ,DATEPART(HOUR,GETUTCDATE()), 0, 0, 0);
  
    /* check if updated table is included in view */  
    SET @stage = 'referenced table check'
    SELECT @is_referenced_table = CASE WHEN COUNT([table]) > 0 THEN 1 ELSE 0 END
    FROM INSERTED
    WHERE [table] IN (SELECT table_name FROM #referenced_tables);
    
    IF @is_referenced_table = 0 
      BEGIN
        PRINT('INSERTED table is not included in target view');
        RETURN    
      END

    /* check if all tables included in view has been updated */  
    SET @stage = 'updated table check'
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
    SET @stage = 'refresh'
    PRINT('Running refresh')
    BEGIN
        EXEC utilities.cache_view @schema_name, @view_name    
    END
  END TRY

  BEGIN CATCH
    SET @email_subject = @view_name + ' static refresh failed'
    SET @email_body = 'During the trigger, the refresh procedure for ' + @view_name + 'failed during the ' + @stage + 'stage.';
      
    EXEC msdb.dbo.sp_send_dbmail  
      @profile_name = 'datarobot',  
      @recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',  
      @subject = @email_subject,
      @body = @email_body;        
  END CATCH

END
GO