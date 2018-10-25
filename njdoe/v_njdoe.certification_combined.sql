USE gabby;
GO

CREATE OR ALTER VIEW njdoe.certification_combined AS

SELECT df_employee_number
      ,endorsement
      ,certificate_type
      ,status
      ,date_received AS date_received_or_issued
      ,NULL AS expiration_date
      ,'Application' AS application_or_certificate
      ,NULL AS certificate_id
      ,NULL AS is_charter_school_only
      ,request_type      
      ,NULL AS county_code
      ,NULL AS district_code
      
      ,ROW_NUMBER() OVER(
         PARTITION BY df_employee_number, endorsement
           ORDER BY date_received DESC) AS rn
FROM njdoe.certification_application_history

UNION ALL

SELECT df_employee_number
      ,endorsement
      ,certificate_type
      ,'Issued' AS status
      ,issued_date AS date_received_or_issued
      ,expiration_date
      ,'Certificate' AS application_or_certificate
      ,certificate_id
      ,is_charter_school_only
      ,NULL AS request_type            
      ,county_code
      ,district_code
      
      ,ROW_NUMBER() OVER(
         PARTITION BY df_employee_number, endorsement
           ORDER BY issued_date DESC) AS rn
FROM njdoe.certification_certificate_history;