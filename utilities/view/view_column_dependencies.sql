CREATE OR ALTER VIEW
  utilities.view_column_dependencies AS
SELECT
  (
    [VIEW_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_catalog,
  (
    [VIEW_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_schema,
  (
    [VIEW_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_name,
  (
    [TABLE_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_catalog,
  (
    [TABLE_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_schema,
  (
    [TABLE_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  (
    [COLUMN_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name
FROM
  kippnewark.[INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE]
UNION ALL
SELECT
  (
    [VIEW_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_catalog,
  (
    [VIEW_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_schema,
  (
    [VIEW_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_name,
  (
    [TABLE_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_catalog,
  (
    [TABLE_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_schema,
  (
    [TABLE_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  (
    [COLUMN_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name
FROM
  kippcamden.[INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE]
UNION ALL
SELECT
  (
    [VIEW_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_catalog,
  (
    [VIEW_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_schema,
  (
    [VIEW_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_name,
  (
    [TABLE_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_catalog,
  (
    [TABLE_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_schema,
  (
    [TABLE_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  (
    [COLUMN_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name
FROM
  kippmiami.[INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE]
UNION ALL
SELECT
  (
    [VIEW_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_catalog,
  (
    [VIEW_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_schema,
  (
    [VIEW_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_name,
  (
    [TABLE_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_catalog,
  (
    [TABLE_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_schema,
  (
    [TABLE_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  (
    [COLUMN_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name
FROM
  kipptaf.[INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE]
UNION ALL
SELECT
  (
    [VIEW_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_catalog,
  (
    [VIEW_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_schema,
  (
    [VIEW_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS view_name,
  (
    [TABLE_CATALOG]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_catalog,
  (
    [TABLE_SCHEMA]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_schema,
  (
    [TABLE_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS table_name,
  (
    [COLUMN_NAME]
    COLLATE LATIN1_GENERAL_BIN
  ) AS column_name
FROM
  gabby.[INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE]
