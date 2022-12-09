CREATE OR ALTER VIEW
  deanslist.incidents_custom_fields AS
SELECT
  dli.incident_id,
  cf.CustomFieldID,
  cf.FieldCategory,
  cf.FieldKey,
  cf.FieldName AS field_name,
  cf.FieldType,
  cf.InputHTML,
  cf.InputName,
  cf.IsFrontEnd,
  cf.IsRequired,
  cf.LabelHTML,
  cf.NumValue,
  cf.Options,
  cf.SourceID,
  cf.SourceType,
  CASE
    WHEN cf.StringValue <> '' THEN cf.StringValue
  END AS StringValue,
  CASE
    WHEN cf.[Value] <> '' THEN cf.[Value]
  END AS [Value]
FROM
  deanslist.incidents dli
  CROSS APPLY OPENJSON (dli.custom_fields, '$')
WITH
  (
    CustomFieldID BIGINT,
    FieldCategory NVARCHAR(8),
    FieldKey NVARCHAR(16),
    FieldName NVARCHAR(64),
    FieldType NVARCHAR(8),
    InputHTML NVARCHAR(8),
    InputName NVARCHAR(16),
    IsFrontEnd NVARCHAR(1),
    IsRequired NVARCHAR(1),
    LabelHTML NVARCHAR(8),
    NumValue FLOAT,
    Options NVARCHAR(8),
    SourceID BIGINT,
    SourceType NVARCHAR(8),
    StringValue NVARCHAR(MAX),
    [Value] NVARCHAR(MAX)
  ) AS cf
WHERE
  dli.custom_fields <> '[]'
