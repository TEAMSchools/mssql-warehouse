USE gabby
GO

CREATE OR ALTER VIEW tableau.whetstone_observations_detail AS

WITH boxes AS (
  SELECT tb.observation_id
        ,tb.score_measurement_id
        ,tb.text_box_label AS [label]
        ,tb.text_box_text AS [value]
        ,tb.text_box_text
        ,NULL AS checkbox_value
        ,'textbox' AS [type]
  FROM gabby.whetstone.observations_scores_text_boxes_static tb

  UNION ALL

  SELECT cc.observation_id
        ,cc.score_measurement_id
        ,cc.checkbox_label AS [label]
        ,CONVERT(NVARCHAR, cc.checkbox_value) AS [value]
        ,NULL AS text_box_text
        ,CONVERT(FLOAT, cc.checkbox_value) AS checkbox_value
        ,'checkbox' AS [type]
  FROM gabby.whetstone.observations_scores_checkboxes_static cc
 )

SELECT sub.*

      ,wos.score_measurement_id
      ,wos.score_percentage
      ,CASE
        WHEN wos.score_value_text = 'Yes' THEN 3
        WHEN wos.score_value_text = 'Almost' THEN 2
        WHEN wos.score_value_text = 'No' THEN 1
        WHEN wos.score_value_text = 'On Track' THEN 3
        WHEN wos.score_value_text = 'Off Track' THEN 1
        ELSE wos.score_value
       END AS measure_value

      ,wm.[name] AS measurement_name
      ,wm.scale_min AS measurement_scale_min
      ,wm.scale_max AS measurement_scale_max

      ,MAX(CASE
            WHEN sub.rubric_name <> 'School Leader Moments' THEN NULL
            WHEN wm.[name] NOT LIKE '%- type' THEN NULL
            WHEN wos.score_value = 1 THEN 'Observed' 
            WHEN wos.score_value = 2 THEN 'Co-Led/Planned'
            WHEN wos.score_value = 3 THEN 'Led'
            ELSE NULL
           END) OVER(PARTITION BY sub.observation_id, LTRIM(RTRIM(REPLACE(wm.[name], '- type', '')))) AS score_type

      ,CASE
        WHEN (sub.rubric_name = 'School Leader Moments' AND wm.[name] LIKE '%- type' AND wos.score_value = 1) THEN 'Observed'
        WHEN (sub.rubric_name = 'School Leader Moments' AND wm.[name] LIKE '%- type' AND wos.score_value = 2) THEN 'Co-Led/Planned'
        WHEN (sub.rubric_name = 'School Leader Moments' AND wm.[name] LIKE '%- type' AND wos.score_value = 3) THEN 'Led'
        WHEN b.[type] IS NOT NULL THEN b.[value]
        ELSE wos.score_value_text
       END AS score_value_text
      ,CASE
        WHEN b.[type] = 'checkbox' THEN wm.[name] + ' - ' + b.[label]
        ELSE wm.[name]
       END AS measurement_label
      ,COALESCE(CASE WHEN SUM(b.checkbox_value) OVER(PARTITION BY sub.observation_id, wos.score_measurement_id) > 0 THEN b.checkbox_value END
               ,wos.score_value) AS score_value
      ,CASE 
        WHEN b.[type] <> 'checkbox' THEN NULL
        WHEN SUM(b.checkbox_value) OVER(PARTITION BY sub.observation_id, b.score_measurement_id) > 0 THEN 1
        ELSE 0 
       END AS checkbox_observed
FROM
    (
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

           ,osr.gender AS observer_gender
           ,osr.primary_ethnicity AS observer_ethnicity

           ,wo.observation_id
           ,wo.observed_at
           ,wo.created
           ,wo.observer_name
           ,wo.observer_email
           ,wo.rubric_name
           ,wo.list_two_column_a AS glows
           ,wo.list_two_column_b AS grows
           ,wo.score

           ,rt.academic_year
           ,rt.time_per_name AS reporting_term

           ,ROW_NUMBER() OVER(
              PARTITION BY sr.df_employee_number, wo.rubric_name
                ORDER BY wo.observed_at DESC) AS rn_observation
     FROM gabby.people.staff_crosswalk_static sr
     JOIN gabby.whetstone.observations_clean wo
       ON CONVERT(VARCHAR(25), sr.df_employee_number) = wo.teacher_internal_id
      AND wo.rubric_name IN ('Development Roadmap','Shadow Session','Assistant Principal PM Rubric','School Leader Moments'
                            ,'Readiness Reflection','Monthly Triad Meeting Form','New Leader Talent Review'
                            ,'Extraordinary Focus Areas Ratings','O3 Form', 'O3 Form v2','O3 Form v3'
                            ,'Extraordinary Focus Areas Ratings v.1')
     LEFT JOIN gabby.people.staff_crosswalk_static osr
       ON wo.observer_internal_id = osr.df_employee_number
     JOIN gabby.reporting.reporting_terms rt
       ON wo.observed_at BETWEEN rt.[start_date] AND rt.end_date 
      AND rt.identifier = 'ETR'
      AND rt.schoolid = 0
      AND rt._fivetran_deleted = 0
     WHERE ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
    ) sub
LEFT JOIN gabby.whetstone.observations_scores_static wos
  ON sub.observation_id = wos.observation_id
LEFT JOIN gabby.whetstone.measurements wm
  ON wos.score_measurement_id = wm._id
LEFT JOIN boxes b
  ON sub.observation_id = b.observation_id
 AND wos.score_measurement_id = b.score_measurement_id
