DECLARE @db_name NVARCHAR(MAX) = DB_NAME()
       ,@schema_name NVARCHAR(MAX) = ''
       ,@view_name NVARCHAR(MAX) = ''
       ,@objname NVARCHAR(MAX)
       ,@table_name NVARCHAR(MAX)
       ,@table_name_old NVARCHAR(MAX);

SET @table_name = @view_name + '_static'
SET @objname = CONCAT(@schema_name, '.', @table_name);
SET @table_name_old = @table_name + '_OLD';

EXEC sp_rename @objname=@objname, @newname=@table_name_old;

EXEC gabby.utilities.cache_view @db_name=@db_name, @schema_name=@schema_name, @view_name=@view_name;

SELECT *
FROM gabby.utilities.generate_gabby_unions
WHERE [schema_name] = @schema_name
  AND table_name IN (@view_name, @view_name + '_static')