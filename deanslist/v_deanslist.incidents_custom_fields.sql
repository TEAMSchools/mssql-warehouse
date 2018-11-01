USE gabby
GO

CREATE OR ALTER VIEW deanslist.incidents_custom_fields AS

SELECT dli.incident_id
      ,dli.custom_fields AS custom_fields_json

      ,cf.CustomFieldID
      ,cf.FieldCategory
      ,cf.FieldKey
      ,cf.FieldName AS field_name
      ,cf.FieldType
      ,cf.InputHTML
      ,cf.InputName
      ,cf.IsFrontEnd
      ,cf.IsRequired
      ,cf.LabelHTML
      ,cf.NumValue
      ,cf.Options
      ,cf.SourceID
      ,cf.SourceType
      ,cf.StringValue
      ,CASE WHEN cf.value != '' THEN cf.Value END AS value
FROM gabby.deanslist.incidents dli
CROSS APPLY OPENJSON(dli.custom_fields, '$')
  WITH (
    CustomFieldID BIGINT
   ,FieldCategory VARCHAR(MAX)
   ,FieldKey VARCHAR(MAX)
   ,FieldName VARCHAR(MAX)
   ,FieldType VARCHAR(MAX)
   ,InputHTML VARCHAR(MAX)
   ,InputName VARCHAR(MAX)
   ,IsFrontEnd VARCHAR(MAX)
   ,IsRequired VARCHAR(MAX)
   ,LabelHTML VARCHAR(MAX)
   ,NumValue FLOAT
   ,Options VARCHAR(MAX)
   ,SourceID BIGINT
   ,SourceType VARCHAR(MAX)
   ,StringValue VARCHAR(MAX)
   ,Value VARCHAR(MAX)
   ) AS cf
WHERE dli.custom_fields != '[]'