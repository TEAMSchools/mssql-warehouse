USE gabby
GO

CREATE OR ALTER VIEW adp.workers_business_communication AS

SELECT w.associate_oid

      ,bc.itemID AS item_id
      ,bc.emailUri AS email_uri
      ,CONVERT(NVARCHAR(128), JSON_VALUE(bc.nameCode, '$.codeValue')) AS code_value
      ,CONVERT(NVARCHAR(128), JSON_VALUE(bc.nameCode, '$.shortName')) AS short_name
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.business_communication, '$.emails') 
  WITH(
    itemID NVARCHAR(128)
   ,emailUri NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
 ) bc
WHERE w.business_communication <> '{}'
