USE gabby
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE utilities.cache_view 
  @schema_name NVARCHAR(MAX),
  @view_name NVARCHAR(MAX)
AS

BEGIN

DECLARE @sql NVARCHAR(MAX)
       ,@source_view NVARCHAR(MAX)
       ,@temp_table_name NVARCHAR(MAX)
       ,@destination_table_name NVARCHAR(MAX)
       ,@email_subject NVARCHAR(MAX)
       ,@email_body NVARCHAR(MAX);

SET @source_view = @schema_name + '.' + @view_name
SET @temp_table_name = '#' + @view_name + '_temp'
SET @destination_table_name = @source_view + '_static';

  /* if source view does not exist, exit */
		IF OBJECTPROPERTYEX(OBJECT_ID(@source_view), 'IsTable') != 0
		  BEGIN    
      PRINT('View does not exist')

      RETURN
    END
  
  /* if destination table does not exist, create and exit */
		IF OBJECT_ID(@destination_table_name) IS NULL
		  BEGIN
      SET @sql = N'
        SELECT *
        INTO ' + @destination_table_name + '
        FROM ' + @source_view + ';
      '
      EXEC(@sql);
      PRINT(@sql);        

      RETURN
    END

  /* otherwise, drop temp table, if exists... */
  /* load data from view into temp table... */
  /* truncate destination table... */
  /* insert into destination table */
  ELSE 
    BEGIN TRY
      SET @sql = N'
        IF OBJECT_ID(N''' + @temp_table_name + ''') IS NOT NULL
		      BEGIN
						    DROP TABLE ' + @temp_table_name + ';
		      END
    
        SELECT *
		      INTO ' + @temp_table_name + '
        FROM ' + @source_view + '; 

        EXEC(''TRUNCATE TABLE ' + @destination_table_name + ''');

        INSERT INTO ' + @destination_table_name + '
        SELECT *
        FROM ' + @temp_table_name + ';
        
        INSERT INTO [utilities].[cache_view_log]
         ([view_name]
         ,[timestamp])
        VALUES
              (''' + @source_view + '''
              ,GETUTCDATE());        
      '
      PRINT(@sql);
      EXEC(@sql);
    END TRY
    
    BEGIN CATCH
      PRINT(ERROR_MESSAGE());
      
      SET @email_subject = @view_name + ' static refresh failed'
      SET @email_body = 'During the trigger, the refresh procedure for ' + @view_name + 'failed during the refresh stage.' + CHAR(10) + ERROR_MESSAGE();
      
      EXEC msdb.dbo.sp_send_dbmail  
        @profile_name = 'datarobot',  
        @recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',  
        @subject = @email_subject,
        @body = @email_body;        
    END CATCH
END