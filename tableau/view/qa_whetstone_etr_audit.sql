USE gabby GO
CREATE OR ALTER VIEW
  tableau.qa_whetstone_etr_audit AS
SELECT
  r.df_employee_number,
  r.preferred_name,
  r.primary_site AS location_description,
  r.primary_job AS job_title_description,
  r.legal_entity_name,
  r.manager_df_employee_number,
  r.manager_name,
  r.[status] AS position_status,
  rt.time_per_name AS reporting_term,
  rt.academic_year,
  rt.alt_name,
  ex.exemption,
  wo.observer_name,
  wo.score
FROM
  gabby.people.staff_crosswalk_static AS r
  INNER JOIN gabby.reporting.reporting_terms AS rt ON rt.identifier = 'ETR'
  AND rt.schoolid = 0
  AND rt._fivetran_deleted = 0
  LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static AS ex ON r.df_employee_number = ex.df_employee_number
  AND rt.academic_year = ex.academic_year
  AND rt.time_per_name = REPLACE(ex.pm_term, 'PM', 'ETR')
  LEFT JOIN gabby.whetstone.observations_clean AS wo ON CAST(r.df_employee_number AS VARCHAR(25)) = wo.teacher_internal_id
  AND (
    wo.observed_at BETWEEN rt.[start_date] AND rt.end_date
  )
  AND wo.rubric_name IN (
    'Coaching Tool: Coach ETR and Reflection',
    'Coaching Tool: Coach ETR and Reflection 20-21',
    'Coaching Tool: Teacher Reflection 19-20'
  )
  AND r.samaccountname != LEFT(
    wo.observer_email,
    CHARINDEX('@', wo.observer_email) - 1
  )
WHERE
  r.is_active = 1
