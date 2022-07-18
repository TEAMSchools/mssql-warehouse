USE gabby
GO

CREATE OR ALTER VIEW ops.income_form_data_clean AS

SELECT student_number
      ,student_name
      ,[status] AS raw_status
      ,CASE 
        WHEN [status] IS NULL OR [status] = 'No App' THEN 'No Application'
        WHEN [status] = 'Direct Cert' THEN 'Direct Certification'
        ELSE LEFT([status], 1) + ' - ' + 'Income Form'
       END AS lunch_app_status
      ,CASE
        WHEN [status] IN ('No App', 'App Rec''d') THEN NULL
        WHEN [status] = 'Direct Cert' THEN 'F'
        ELSE LEFT([status], 1)
       END AS lunch_status
      ,ROW_NUMBER() OVER(PARTITION BY student_number ORDER BY _row DESC) AS rn
      ,2021 AS academic_year
FROM gabby.ops.income_form_data
WHERE student_number  IS NOT NULL
