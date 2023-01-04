CREATE OR ALTER VIEW
  utilities.view_column_dependencies AS
SELECT
  [VIEW_CATALOG] AS view_catalog,
  [VIEW_SCHEMA] AS view_schema,
  [VIEW_NAME] AS view_name,
  [TABLE_CATALOG] AS table_catalog,
  [TABLE_SCHEMA] AS table_schema,
  [TABLE_NAME] AS table_name,
  [COLUMN_NAME] AS column_name
FROM
  [INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE]
