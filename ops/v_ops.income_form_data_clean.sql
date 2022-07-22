USE gabby
GO

CREATE OR ALTER VIEW ops.income_form_data_clean AS

SELECT student_number
      ,academic_year
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
      ,ROW_NUMBER() OVER(PARTITION BY student_number, academic_year ORDER BY _row DESC) AS rn
      ,'kippcamden' AS [db_name]
FROM gabby.ops.income_form_data
WHERE student_number  IS NOT NULL

UNION ALL

SELECT student_identifier AS student_number
      ,academic_year_clean AS academic_year
      ,eligibility_name + ' - ' + 'Income Form' COLLATE Latin1_General_BIN AS lunch_app_status
      ,eligibility_name COLLATE Latin1_General_BIN AS lunch_status
      ,rn
      ,'kippnewark' AS [db_name]
FROM kippnewark.titan.income_form_data_clean
