CREATE OR ALTER VIEW
  tableau.pm_etr_dashboard AS
SELECT
  sr.df_employee_number,
  sr.preferred_name,
  sr.primary_site,
  sr.primary_on_site_department AS dayforce_department,
  sr.grades_taught AS dayforce_grade_team,
  sr.primary_job AS dayforce_role,
  sr.legal_entity_name,
  sr.is_active,
  sr.primary_site_schoolid,
  sr.manager_name,
  sr.original_hire_date,
  sr.primary_ethnicity AS observee_ethnicity,
  sr.gender AS observee_gender,
  sr.primary_race_ethnicity_reporting AS observee_race_ethnicity,
  LEFT(
    sr.userprincipalname,
    CHARINDEX('@', sr.userprincipalname) - 1
  ) AS staff_username,
  LEFT(
    sr.manager_userprincipalname,
    CHARINDEX(
      '@',
      sr.manager_userprincipalname
    ) - 1
  ) AS manager_username,
  wo.observation_id,
  wo.observed_at,
  wo.created,
  wo.observer_name,
  wo.observer_email,
  wo.rubric_name,
  wo.score,
  NULL AS score_averaged_by_strand,
  NULL AS percentage_averaged_by_strand,
  osr.primary_ethnicity AS observer_ethnicity,
  osr.gender AS observer_gender,
  osr.primary_race_ethnicity_reporting AS observer_race_ethnicity,
  wos.score_percentage,
  wos.score_value,
  wm.[name] AS measurement_name,
  wm.scale_min AS measurement_scale_min,
  wm.scale_max AS measurement_scale_max,
  tb.text_box_label,
  tb.text_box_text,
  rt.academic_year,
  rt.time_per_name AS reporting_term,
  ex.exemption
FROM
  people.staff_crosswalk_static AS sr
  INNER JOIN whetstone.observations_clean AS wo ON (
    CAST(
      sr.df_employee_number AS VARCHAR(25)
    ) = wo.teacher_internal_id
    AND sr.samaccountname != LEFT(
      wo.observer_email,
      CHARINDEX('@', wo.observer_email) - 1
    )
    AND wo.rubric_name IN (
      'Coaching Tool: Coach ETR and Reflection',
      'Coaching Tool: Coach ETR and Reflection 20-21',
      'Coaching Tool: Coach ETR and Reflection 19-20'
    )
  )
  INNER JOIN reporting.reporting_terms AS rt ON (
    (
      wo.observed_at BETWEEN rt.[start_date] AND rt.end_date
    )
    AND rt.identifier = 'ETR'
    AND rt.schoolid = 0
    AND rt._fivetran_deleted = 0
  )
  LEFT JOIN people.staff_crosswalk_static AS osr ON (
    wo.observer_internal_id = CAST(
      osr.df_employee_number AS VARCHAR(25)
    )
  )
  LEFT JOIN whetstone.observations_scores AS wos ON (
    wo.observation_id = wos.observation_id
  )
  LEFT JOIN whetstone.measurements AS wm ON (
    wos.score_measurement_id = wm._id
  )
  LEFT JOIN whetstone.observations_scores_text_boxes AS tb ON (
    wos.score_measurement_id = tb.score_measurement_id
    AND wo.observation_id = tb.observation_id
  )
  LEFT JOIN pm.teacher_goals_exemption_clean_static AS ex ON (
    sr.df_employee_number = ex.df_employee_number
    AND rt.academic_year = ex.academic_year
    AND rt.time_per_name = REPLACE(ex.pm_term, 'PM', 'ETR')
  )
WHERE
  ISNULL(
    sr.termination_date,
    CURRENT_TIMESTAMP
  ) >= DATEFROMPARTS(
    utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
