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
       ,@destination_table_name NVARCHAR(MAX);

SET @source_view = @schema_name + '.' + @view_name
SET @temp_table_name = '#' + @view_name + '_temp'
SET @destination_table_name = @source_view + '_static';

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
    BEGIN
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
      '
      PRINT(@sql);
      EXEC(@sql);
    END
END