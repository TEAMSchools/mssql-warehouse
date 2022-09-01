USE gabby
GO

CREATE OR ALTER VIEW adp.workers_business_communication AS

SELECT w.associate_oid
      ,JSON_VALUE(w.worker_id, '$.idValue') AS worker_id

      ,bc.itemID AS item_id
      ,bc.emailUri AS email_uri
      ,CAST(JSON_VALUE(bc.nameCode, '$.codeValue') AS NVARCHAR(128)) AS code_value
      ,CAST(JSON_VALUE(bc.nameCode, '$.shortName') AS NVARCHAR(128)) AS short_name
FROM gabby.adp.workers w
CROSS APPLY OPENJSON(w.business_communication, '$.emails') 
  WITH(
    itemID NVARCHAR(128)
   ,emailUri NVARCHAR(128)
   ,nameCode NVARCHAR(MAX) AS JSON
 ) bc
WHERE w.business_communication <> '{}'
