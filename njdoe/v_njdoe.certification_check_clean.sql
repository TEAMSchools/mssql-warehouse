USE gabby
GO

CREATE OR ALTER VIEW njdoe.certification_check_clean AS

SELECT df_employee_number
      ,JSON_VALUE(applicant, '$.tracking_number') AS applicant_tracking_number
      ,JSON_VALUE(applicant, '$.email') AS applicant_email
      ,JSON_VALUE(applicant, '$.phone_number') AS applicant_phone_number      
      ,application_history
      ,certificate_history
      
      ,ROW_NUMBER() OVER(
        PARTITION BY df_employee_number
          ORDER BY _modified DESC) AS rn_employee_current
FROM gabby.njdoe.certification_check