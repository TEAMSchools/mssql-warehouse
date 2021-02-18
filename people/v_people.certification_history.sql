USE gabby
GO

CREATE OR ALTER VIEW people.certification_history AS

SELECT sub.df_employee_number
      ,sub.adp_associate_id
      ,sub.preferred_name
      ,sub.original_hire_date
      ,sub.primary_job
      ,sub.legal_entity_name
      ,sub.[status]
      ,sub.primary_site
      ,sub.userprincipalname
      ,sub.seq_number
      ,sub.certificate_id
      ,sub.certificate_type
      ,sub.is_charter_school_only
      ,sub.endorsement_or_rank
      ,sub.county_code
      ,sub.basis_code
      ,sub.district_code
      ,sub.month_year_issued
      ,sub.issued_date
      ,sub.month_year_expiration
      ,sub.expiration_date
      ,sub.cert_status
      ,sub.valid_cert
      ,sub.cert_state
      ,sub.schoolstate
      ,CASE WHEN sub.schoolstate = sub.cert_state THEN MAX(sub.valid_cert) OVER(PARTITION BY sub.df_employee_number) END AS is_certified
FROM
    (
     SELECT s.df_employee_number
           ,s.adp_associate_id
           ,s.preferred_name
           ,s.original_hire_date
           ,s.primary_job
           ,s.legal_entity_name
           ,s.[status]
           ,s.primary_site
           ,s.userprincipalname

           ,pss.schoolstate

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
           ,CASE WHEN CONVERT(DATE, GETDATE()) BETWEEN c.issued_date AND COALESCE(c.expiration_date, DATEADD(DAY, 1, GETDATE())) THEN 1 ELSE 0 END AS valid_cert

           ,NULL AS cert_status
           ,'NJ' AS cert_state
     FROM gabby.people.staff_crosswalk_static s
     LEFT JOIN gabby.powerschool.schools pss
       ON s.primary_site_schoolid = pss.school_number
      AND s.[db_name] = pss.[db_name]
     LEFT JOIN gabby.njdoe.certification_certificate_history c
       ON s.df_employee_number = c.df_employee_number
    ) sub
