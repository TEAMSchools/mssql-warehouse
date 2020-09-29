USE gabby
GO

CREATE OR ALTER VIEW tableau.whetstone_observations_detail AS

WITH sl_moments_type AS(
  SELECT wo.observation_id
        ,LEFT(wm.[name],LEN(wm.[name])-LEN(' -type')) AS measurement_name
        ,CASE
          WHEN wos.score_value = 1 THEN 'Observed'
          WHEN wos.score_value = 2 THEN 'Co-Led/Planned'
          WHEN wos.score_value = 3 THEN 'Led'
         ELSE NULL
         END AS score_type
  FROM gabby.whetstone.observations_clean wo
  LEFT JOIN gabby.whetstone.observations_scores wos
    ON wo.observation_id = wos.observation_id
  LEFT JOIN gabby.whetstone.measurements wm
    ON wos.score_measurement_id = wm._id
  WHERE wo.rubric_name = 'School Leader Moments' 
    AND wm.[name] LIKE '%- type'
  )

SELECT sr.df_employee_number
      ,sr.preferred_name
      ,sr.primary_site
      ,sr.primary_on_site_department AS dayforce_department
      ,sr.grades_taught AS dayforce_grade_team
      ,sr.primary_job AS dayforce_role
      ,sr.legal_entity_name
      ,sr.is_active
      ,sr.primary_site_schoolid
      ,sr.manager_name
      ,sr.original_hire_date
      ,sr.primary_ethnicity AS observee_ethnicity
      ,sr.gender AS observee_gender
      ,LEFT(sr.userprincipalname, CHARINDEX('@', sr.userprincipalname) - 1) AS staff_username
      ,LEFT(sr.manager_userprincipalname, CHARINDEX('@', sr.manager_userprincipalname) - 1) AS manager_username

      ,wo.observation_id
      ,wo.observed_at
      ,wo.created
      ,wo.observer_name
      ,wo.observer_email
      ,wo.rubric_name
      ,wo.list_two_column_a AS glows
      ,wo.list_two_column_b AS grows
      ,wo.score

      ,wos.score_value
      ,wos.score_percentage
      ,CASE
        WHEN wos.score_value_text = 'Yes' THEN 3
        WHEN wos.score_value_text = 'Almost' THEN 2
        WHEN wos.score_value_text = 'No' THEN 1
        WHEN wos.score_value_text = 'On Track' THEN 3
        WHEN wos.score_value_text = 'Off Track' THEN 1
        ELSE wos.score_value
       END AS measure_value
      ,CASE
        WHEN (wo.rubric_name = 'School Leader Moments' AND wm.[name] LIKE '%- type' AND wos.score_value = 1) THEN 'Observed'
        WHEN (wo.rubric_name = 'School Leader Moments' AND wm.[name] LIKE '%- type' AND wos.score_value = 2) THEN 'Co-Led/Planned'
        WHEN (wo.rubric_name = 'School Leader Moments' AND wm.[name] LIKE '%- type' AND wos.score_value = 3) THEN 'Led'
        ELSE wos.score_value_text
       END AS score_value_text

      ,sl.score_type

      ,osr.primary_ethnicity AS observer_ethnicity
      ,osr.gender AS observer_gender

      ,wm.[name] AS measurement_name
      ,wm.scale_min AS measurement_scale_min
      ,wm.scale_max AS measurement_scale_max

      ,tb.text_box_text

      ,rt.academic_year
      ,rt.time_per_name AS reporting_term
FROM gabby.people.staff_crosswalk_static sr
JOIN gabby.whetstone.observations_clean wo
  ON CONVERT(VARCHAR(25), sr.df_employee_number) = wo.teacher_internal_id
 AND sr.samaccountname <> LEFT(wo.observer_email, CHARINDEX('@', wo.observer_email) - 1)
 AND wo.rubric_name IN ('Development Roadmap','Shadow Session','Assistant Principal PM Rubric','School Leader Moments','Readiness Reflection'
                       ,'Monthly Triad Meeting Form','New Leader Talent Review','Extraordinary Focus Areas Ratings','O3 Form'
                       ,'O3 Form v.1', 'Extraordinary Focus Areas Ratings v.1')
LEFT JOIN gabby.people.staff_crosswalk_static osr
  ON wo.observer_internal_id = osr.df_employee_number
LEFT JOIN gabby.whetstone.observations_scores wos
  ON wo.observation_id = wos.observation_id
LEFT JOIN gabby.whetstone.measurements wm
  ON wos.score_measurement_id = wm._id
LEFT JOIN gabby.whetstone.observations_scores_text_boxes tb
  ON wos.score_measurement_id = tb.score_measurement_id
 AND wo.observation_id = tb.observation_id
LEFT JOIN sl_moments_type sl
  ON wo.observation_id = sl.observation_id
 AND wm.[name] = sl.measurement_name
JOIN gabby.reporting.reporting_terms rt
  ON wo.observed_at BETWEEN rt.[start_date] AND rt.end_date 
 AND rt.identifier = 'ETR'
 AND rt.schoolid = 0
 AND rt._fivetran_deleted = 0
WHERE ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
  AND (wos.score_value IS NOT NULL
        OR wos.score_value_text IS NOT NULL
        OR tb.text_box_text IS NOT NULL)