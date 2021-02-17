USE gabby
GO

CREATE OR ALTER VIEW people.certification_history AS

WITH certs AS (
  SELECT c.df_employee_number AS employee_number
        ,c.seq_number
        ,c.certificate_id
        ,c.certificate_type
        ,c.is_charter_school_only
        ,c.endorsement AS endorsement_or_rank
        ,c.county_code
        ,c.basis_code
        ,c.district_code
        ,c.month_year_issued
        ,c.issued_date
        ,c.month_year_expiration
        ,c.expiration_date
        ,NULL AS cert_status
        ,CASE 
          WHEN GETDATE() BETWEEN c.issued_date AND COALESCE(expiration_date,DATEADD(day,1,GETDATE())) THEN 1
          ELSE 0
         END AS valid_cert
        ,'NJ' AS cert_state
  FROM gabby.njdoe.certification_certificate_history c
  )

SELECT s.df_employee_number
      ,s.adp_associate_id
      ,s.preferred_name
      ,s.original_hire_date
      ,s.primary_job
      ,s.legal_entity_name
      ,s.[status]
      ,s.primary_site
      ,s.userprincipalname

      ,c.seq_number
      ,c.certificate_id
      ,c.certificate_type
      ,c.is_charter_school_only
      ,c.endorsement_or_rank
      ,c.county_code
      ,c.basis_code
      ,c.district_code
      ,c.month_year_issued
      ,c.issued_date
      ,c.month_year_expiration
      ,c.expiration_date
      ,cert_status
      ,c.valid_cert
      ,c.cert_state

      ,pss.schoolstate

      ,CASE 
        WHEN pss.schoolstate = c.cert_state
        THEN MAX(c.valid_cert) OVER(PARTITION BY s.df_employee_number)
        ELSE NULL
       END AS is_certified

FROM gabby.people.staff_crosswalk_static s

LEFT JOIN gabby.powerschool.schools pss
  ON pss.school_number = s.primary_site_schoolid
LEFT JOIN certs c
  ON s.df_employee_number = c.employee_number