USE gabby
GO

CREATE OR ALTER VIEW tableau.whetstone_observations_lookfors AS

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
      ,sr.[status]
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
      ,wos.score_checkboxes_json
      
      ,cc.checkbox_label
      ,cc.checkbox_value

      ,osr.primary_ethnicity AS observer_ethnicity
      ,osr.gender AS observer_gender

      ,wm.[name] AS measurement_name
      ,wm.scale_min AS measurement_scale_min
      ,wm.scale_max AS measurement_scale_max
      ,CASE 
        WHEN cc.checkbox_label IS NULL THEN wm.[name]
        ELSE wm.[name] + ' - ' + cc.checkbox_label
       END AS measurement_label
      
      ,CASE 
        WHEN SUM(CONVERT(INT,cc.checkbox_value)) OVER( PARTITION BY wo.observation_id, wm.[name]) > 0 THEN 1
        ELSE cc.checkbox_value
       END AS observation_observed_measurement

      ,SUM(CONVERT(INT,cc.checkbox_value)) OVER( PARTITION BY gabby.utilities.DATE_TO_SY(wo.observed_at), sr.df_employee_number, wm.[name], cc.checkbox_label) AS n_sy_checkbox_observed

      ,tb.text_box_text

      ,ROW_NUMBER() OVER( PARTITION BY gabby.utilities.DATE_TO_SY(wo.observed_at), sr.df_employee_number, wm.[name], cc.checkbox_label ORDER BY wo.observed_at DESC) AS rn_observation

FROM gabby.people.staff_crosswalk_static sr
JOIN gabby.whetstone.observations_clean wo
  ON CONVERT(VARCHAR(25), sr.df_employee_number) = wo.teacher_internal_id
 AND wo.rubric_name ='O3 Form'
LEFT JOIN gabby.people.staff_crosswalk_static osr
  ON wo.observer_internal_id = osr.df_employee_number
LEFT JOIN gabby.whetstone.observations_scores wos
  ON wo.observation_id = wos.observation_id
LEFT JOIN whetstone.observations_scores_checkboxes cc
  ON wo.observation_id = cc.observation_id
 AND wos.score_measurement_id = cc.score_measurement_id
LEFT JOIN gabby.whetstone.measurements wm
  ON wos.score_measurement_id = wm._id
LEFT JOIN gabby.whetstone.observations_scores_text_boxes tb
  ON wos.score_measurement_id = tb.score_measurement_id
 AND wo.observation_id = tb.observation_id