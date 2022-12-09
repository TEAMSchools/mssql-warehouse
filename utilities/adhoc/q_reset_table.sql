DECLARE @schema_name NVARCHAR(MAX) = '',
@view_name NVARCHAR(MAX) = '',
@db_name NVARCHAR(MAX) = DB_NAME(),
@objname NVARCHAR(MAX),
@table_name NVARCHAR(MAX),
@table_name_old NVARCHAR(MAX),
@drop_sql NVARCHAR(MAX);

set
  @table_name = @view_name + '_static';

set
  @objname = concat(@schema_name, '.', @table_name);

set
  @table_name_old = @table_name + '_OLD';

set
  @drop_sql = 'IF OBJECT_ID(N''' + @db_name + '.' + @schema_name + '.' + @table_name_old + ''') IS NOT NULL
  BEGIN
    DROP TABLE ' + @db_name + '.' + @schema_name + '.' + @table_name_old + ';
  END';

exec sp_sqlexec @drop_sql;

exec sp_rename @objname = @objname,
@newname = @table_name_old;

exec gabby.utilities.cache_view @db_name = @db_name,
@schema_name = @schema_name,
@view_name = @view_name;

select
  *
from
  gabby.utilities.generate_gabby_unions
where
  [schema_name] = @schema_name
  and table_name in (@view_name, @view_name + '_static')
