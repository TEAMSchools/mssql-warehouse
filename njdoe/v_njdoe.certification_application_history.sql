USE gabby
GO

CREATE OR ALTER VIEW njdoe.certification_application_history AS

SELECT cc.df_employee_number
      ,cc.application_history AS application_history_json

      ,ah.application_number
      ,ah.date_received
      ,ah.endorsement
      ,CASE WHEN ah.certificate_type != '' THEN ah.certificate_type END AS certificate_type
      ,CASE WHEN ah.request_type != '' THEN ah.request_type END AS request_type
      ,CASE WHEN ah.status != '' THEN ah.status END AS status
      ,ah.checklist
FROM gabby.njdoe.certification_check_clean cc
CROSS APPLY OPENJSON(cc.application_history, '$')
  WITH (
    application_number INT,
    date_received DATETIME2,
    endorsement VARCHAR(125),
    certificate_type VARCHAR(125),
    request_type VARCHAR(25),
    status VARCHAR(125),
    checklist NVARCHAR(MAX) AS JSON
   ) AS ah
WHERE cc.application_history != '[]'