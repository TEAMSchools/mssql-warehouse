USE gabby;
GO

CREATE OR ALTER VIEW tableau.compliance_staff_attrition AS

WITH roster AS (
  SELECT r.adp_associate_id
        ,r.preferred_first_name
        ,r.preferred_last_name
        ,r.legal_entity_name
        ,r.primary_site
        ,r.primary_site_reporting_schoolid
        ,r.primary_site_school_level
        ,COALESCE(r.rehire_date, r.original_hire_date) AS position_start_date
        ,COALESCE(s.effective_start, r.termination_date) AS termination_date
        ,COALESCE(s.status_reason_description, r.status_reason) AS status_reason
        ,r.job_family
        ,r.primary_job
        ,r.primary_on_site_department
        ,r.primary_ethnicity
        ,r.original_hire_date
        ,r.rehire_date
        ,gabby.utilities.DATE_TO_SY(COALESCE(r.rehire_date, r.original_hire_date)) AS start_academic_year
        ,gabby.utilities.DATE_TO_SY(COALESCE(s.effective_start, r.termination_date)) AS end_academic_year
        ,r.df_employee_number
  FROM gabby.dayforce.staff_roster r
  LEFT JOIN gabby.dayforce.employee_status s
    ON r.df_employee_number = s.number
   AND s.effective_end IS NULL
   AND s.status = 'Terminated'
 )

,years AS (
  SELECT n AS academic_year
  FROM gabby.utilities.row_generator
  WHERE n BETWEEN 2000 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR()
)

,scaffold AS (
  SELECT df_employee_number
        ,preferred_first_name
        ,preferred_last_name
        ,primary_ethnicity
        ,original_hire_date
        ,rehire_date
        ,legal_entity_name
        ,primary_job
        ,primary_site
        ,primary_site_reporting_schoolid
        ,primary_site_school_level
        ,job_family
        ,primary_on_site_department
        ,academic_year
        ,termination_date
        ,status_reason
        ,academic_year_entrydate
        ,academic_year_exitdate
  FROM 
      (
       SELECT r.df_employee_number
             ,r.legal_entity_name
             ,r.preferred_first_name
             ,r.preferred_last_name
             ,r.primary_ethnicity
             ,r.primary_job
             ,r.primary_on_site_department
             ,r.primary_site
             ,r.primary_site_reporting_schoolid
             ,r.primary_site_school_level
             ,r.job_family
             ,r.status_reason
             ,r.original_hire_date
             ,r.rehire_date
             ,CASE WHEN r.end_academic_year = y.academic_year THEN r.termination_date END AS termination_date
             
             ,y.academic_year
             ,CASE
               WHEN r.start_academic_year = y.academic_year THEN r.position_start_date
               ELSE DATEFROMPARTS(y.academic_year, 7, 1)
              END AS academic_year_entrydate
             ,CASE
               WHEN r.end_academic_year = y.academic_year THEN COALESCE(r.termination_date, DATEFROMPARTS((y.academic_year + 1), 6, 30))
               ELSE DATEFROMPARTS((y.academic_year + 1), 6, 30)
              END AS academic_year_exitdate
             ,ROW_NUMBER() OVER(PARTITION BY r.df_employee_number, y.academic_year
                                  ORDER BY r.position_start_date DESC, COALESCE(r.termination_date, CONVERT(DATE, GETDATE())) DESC) AS rn_dupe_academic_year             
       FROM roster r
       JOIN years y
         ON y.academic_year BETWEEN r.start_academic_year AND COALESCE(r.end_academic_year, gabby.utilities.GLOBAL_ACADEMIC_YEAR())
      ) sub
  WHERE rn_dupe_academic_year = 1
 )

SELECT d.df_employee_number
      ,d.preferred_first_name
      ,d.preferred_last_name
      ,d.primary_ethnicity
      ,CASE 
        WHEN COALESCE(d.rehire_date, d.original_hire_date) > COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30))
         THEN ROUND(DATEDIFF(DAY,d.original_hire_date,COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)))/365,0)
        ELSE ROUND(DATEDIFF(DAY,COALESCE(d.rehire_date, d.original_hire_date),COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)))/365,0)
        END AS years_at_kipp
      ,d.primary_job
      ,d.primary_on_site_department
      ,d.primary_site
      ,d.primary_site_reporting_schoolid
      ,d.primary_site_school_level
      ,d.legal_entity_name
      ,d.job_family
      ,d.academic_year
      ,d.academic_year_entrydate
      ,d.academic_year_exitdate
      ,d.status_reason
      ,d.termination_date
      ,CASE
        WHEN DATEDIFF(DAY, d.academic_year_entrydate, d.academic_year_exitdate) <= 0 THEN 0
        WHEN d.academic_year_exitdate >= DATEFROMPARTS(d.academic_year, 9, 1)
         AND d.academic_year_entrydate <= DATEFROMPARTS((d.academic_year + 1), 4, 30) THEN 1
        ELSE 0
       END AS is_denominator
      
      ,n.academic_year_exitdate AS next_academic_year_exitdate
      
      ,COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)) AS attrition_exitdate
      ,CASE
        WHEN COALESCE(n.academic_year_exitdate, d.termination_date, DATEFROMPARTS(d.academic_year + 2, 6, 30)) < DATEFROMPARTS(d.academic_year + 1, 9, 1) THEN 1
        ELSE 0
       END AS is_attrition
FROM scaffold d
LEFT JOIN scaffold n
  ON d.df_employee_number = n.df_employee_number
 AND d.academic_year = (n.academic_year - 1)