DECLARE @schema_name NVARCHAR(MAX) = ''
       ,@view_name NVARCHAR(MAX) = ''
       ,@db_name NVARCHAR(MAX) = DB_NAME()
       ,@objname NVARCHAR(MAX)
       ,@table_name NVARCHAR(MAX)
       ,@table_name_old NVARCHAR(MAX)
       ,@drop_sql NVARCHAR(MAX);

SET @table_name = @view_name + '_static';
SET @objname = CONCAT(@schema_name, '.', @table_name);
SET @table_name_old = @table_name + '_OLD';
SET @drop_sql = 'IF OBJECT_ID(N''' + @db_name + '.' + @schema_name + '.' + @table_name_old + ''') IS NOT NULL
  BEGIN
    DROP TABLE ' + @db_name + '.' + @schema_name + '.' + @table_name_old + ';
  END';

EXEC sp_sqlexec @drop_sql;

EXEC sp_rename @objname=@objname, @newname=@table_name_old;

EXEC gabby.utilities.cache_view @db_name=@db_name, @schema_name=@schema_name, @view_name=@view_name;

SELECT *
FROM gabby.utilities.generate_gabby_unions
WHERE [schema_name] = @schema_name
  AND table_name IN (@view_name, @view_name + '_static')
