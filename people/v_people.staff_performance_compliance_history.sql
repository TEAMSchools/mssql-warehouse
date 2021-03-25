USE gabby
GO 

CREATE OR ALTER VIEW people.staff_performance_compliance_history AS

WITH years AS (
  SELECT n AS academic_year
        ,DATEFROMPARTS((n + 1), 4, 30) AS effective_date
  FROM gabby.utilities.row_generator_smallint
  WHERE n BETWEEN 2002 AND (gabby.utilities.GLOBAL_ACADEMIC_YEAR())
 )

,cert_history AS (
  SELECT c.employee_number
        ,y.academic_year
        ,COUNT(c.certificate_type) AS n_certs
  FROM gabby.people.certification_history c
  JOIN years y
    ON y.effective_date > c.issued_date
  WHERE c.valid_cert = 1
  GROUP BY c.employee_number
          ,y.academic_year
 )

SELECT s.df_employee_number
      ,s.adp_associate_id
      ,s.preferred_first_name
      ,s.preferred_last_name
      ,s.[status] AS cur
      ,s.termination_date
      ,s.legal_entity_name AS current_legal_entity
      ,s.primary_site AS current_location
      ,s.primary_job AS current_role
      ,s.primary_on_site_department AS current_dept
      ,s.manager_name AS current_manager
      ,s.primary_ethnicity
      ,s.is_hispanic
      ,s.gender
      ,LOWER(s.samaccountname) AS samaccountname
      ,LOWER(s.manager_samaccountname) AS manager_samaccountname
      ,COALESCE(s.rehire_date, s.original_hire_date) AS hire_date

      ,y.academic_year

      ,CASE WHEN c.n_certs > 0 THEN 1 ELSE 0 END AS is_certified

      ,e.business_unit AS historic_legal_entity
      ,e.[location] AS historic_location
      ,e.job_title AS historic_role
      ,e.home_department AS historic_dept
      ,e.annual_salary AS historic_salary

      ,pm.pm_term
      ,pm.etr_score
      ,pm.etr_tier
      ,pm.so_score
      ,pm.overall_score
      ,pm.overall_tier

      ,a.absenses_approved AS ay_approved_absences
      ,a.absenses_unapproved AS ay_unapproved_absences
      ,a.late_tardy_approved AS ay_approved_tardies
      ,a.late_tardy_unapproved AS ay_unapproved_tardies
      ,a.left_early_approved AS ay_approved_left_early
      ,a.left_early_unapproved AS ay_unapproved_left_early
FROM gabby.people.staff_crosswalk_static s
JOIN years y
  ON y.effective_date BETWEEN s.original_hire_date 
                          AND COALESCE(s.termination_date, DATEFROMPARTS(y.academic_year + 1, 6, 30))
LEFT JOIN cert_history c
  ON s.df_employee_number = c.employee_number
 AND y.academic_year = c.academic_year
LEFT JOIN gabby.people.employment_history e
  ON s.df_employee_number = e.employee_number
 AND y.effective_date BETWEEN e.effective_start_date AND e.effective_end_date
 AND e.job_title IS NOT NULL
LEFT JOIN gabby.pm.teacher_goals_overall_scores_static pm
   ON s.df_employee_number = pm.df_employee_number
  AND y.academic_year = pm.academic_year
LEFT JOIN gabby.people.staff_attendance_rollup a
  ON s.df_employee_number = a.df_employee_number
 AND y.academic_year = a.academic_year
