USE gabby
GO

CREATE OR ALTER VIEW people.certification_history AS

SELECT sub.employee_number
      ,sub.seq_number
      ,sub.certificate_id
      ,sub.certificate_type
      ,sub.is_charter_school_only
      ,sub.endorsement_or_rank
      ,sub.county_code
      ,sub.basis_code
      ,sub.district_code
      ,sub.month_year_issued
      ,sub.academic_year
      ,sub.issued_date
      ,sub.month_year_expiration
      ,sub.expiration_date
      ,sub.cert_status
      ,sub.valid_cert
      ,sub.cert_state
      ,sub.schoolstate
      ,CASE WHEN sub.schoolstate = sub.cert_state THEN MAX(sub.valid_cert) OVER(PARTITION BY sub.employee_number) END AS is_certified
FROM
    (
     SELECT s.df_employee_number AS employee_number

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
           ,CASE 
             WHEN certificate_type IS NULL THEN 0
             WHEN certificate_type IN ('CE - Charter School - Temp' ,'CE - Temp' ,'Provisional - Temp') THEN 0 
             ELSE 1 
            END AS valid_cert
           ,gabby.utilities.DATE_TO_SY(c.issued_date) AS academic_year

           ,NULL AS cert_status
           ,'NJ' AS cert_state
     FROM gabby.people.staff_crosswalk_static s
     LEFT JOIN gabby.powerschool.schools pss
       ON s.primary_site_schoolid = pss.school_number
      AND s.[db_name] = pss.[db_name]
     LEFT JOIN gabby.njdoe.certification_certificate_history_static c
       ON s.df_employee_number = c.df_employee_number
    ) sub
