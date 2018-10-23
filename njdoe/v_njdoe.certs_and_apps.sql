USE gabby
GO

--CREATE OR ALTER VIEW njdoe.certs_and_apps AS

SELECT df_employee_number
      ,endorsement
      ,certificate_type
      ,null AS certificate_id
      ,null AS is_charter_school_only
      ,request_type
      ,status
      ,date_received AS date_of_issue_or_app_last_step
      ,null as expiration_date
      ,null as county_code
      ,null as district_code
      ,'application' AS app_or_cert 
FROM njdoe.certification_application_history

UNION ALL

SELECT df_employee_number
      ,endorsement
      ,certificate_type
      ,certificate_id
      ,is_charter_school_only
      ,null AS request_type
      ,'certification issued' AS status
      ,issued_date AS date_of_issue_or_app_last_step
      ,expiration_date
      ,county_code
      ,district_code
      ,'certification' AS app_or_cert 
FROM njdoe.certification_certificate_history