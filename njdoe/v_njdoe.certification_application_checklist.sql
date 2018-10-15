USE gabby
GO

CREATE OR ALTER VIEW njdoe.certification_application_checklist AS 

SELECT ah.df_employee_number
      ,ah.application_number
      ,ah.checklist AS checklist_json
      
      ,CONVERT(DATETIME2, JSON_VALUE(ah.checklist, '$.filing_date')) AS application_filing_date
      
      ,cl.task
      ,CASE WHEN cl.comment != '' THEN cl.comment END AS comment
      ,cl.complete
FROM njdoe.certification_application_history ah
CROSS APPLY OPENJSON(ah.checklist, '$.tasks')
  WITH (
    task VARCHAR(500),
    comment VARCHAR(500),
    complete BIT
   ) AS cl
WHERE ah.checklist != '[]'