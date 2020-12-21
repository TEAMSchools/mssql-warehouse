USE gabby;
GO

CREATE OR ALTER VIEW njdoe.certification_combined AS

SELECT cah.df_employee_number
      ,cah.endorsement
      ,cah.certificate_type
      ,cah.[status]
      ,cah.date_received AS date_received_or_issued
      ,NULL AS expiration_date
      ,'Application' AS application_or_certificate
      ,NULL AS certificate_id
      ,NULL AS is_charter_school_only
      ,cah.request_type
      ,NULL AS county_code
      ,NULL AS district_code

      ,s.preferred_name
      ,s.primary_job
      ,s.legal_entity_name
      ,s.[status] AS position_status
      ,s.primary_site

      ,ROW_NUMBER() OVER(
         PARTITION BY cah.df_employee_number, cah.endorsement
           ORDER BY cah.date_received DESC) AS rn
FROM njdoe.certification_application_history_static cah
JOIN gabby.people.staff_crosswalk_static s
  ON cah.df_employee_number = s.df_employee_number

UNION ALL

SELECT cch.df_employee_number
      ,cch.endorsement
      ,cch.certificate_type
      ,'Issued' AS [status]
      ,cch.issued_date AS date_received_or_issued
      ,cch.expiration_date
      ,'Certificate' AS application_or_certificate
      ,cch.certificate_id
      ,cch.is_charter_school_only
      ,NULL AS request_type
      ,cch.county_code
      ,cch.district_code

      ,s.preferred_name
      ,s.primary_job
      ,s.legal_entity_name
      ,s.[status] AS position_status
      ,s.primary_site

      ,ROW_NUMBER() OVER(
         PARTITION BY cch.df_employee_number, cch.endorsement
           ORDER BY cch.issued_date DESC) AS rn
FROM njdoe.certification_certificate_history_static cch
JOIN gabby.people.staff_crosswalk_static s
  ON cch.df_employee_number = s.df_employee_number
