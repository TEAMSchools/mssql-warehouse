USE gabby
GO

CREATE OR ALTER VIEW tableau.pm_teacher_goals AS

WITH reading_level AS (
  SELECT sub.academic_year
        ,sub.schoolid
        ,sub.grade_level
        ,sub.reporting_term
        ,'pct_met_reading_goal' AS metric_name
        ,AVG(CONVERT(FLOAT,sub.met_goal)) AS metric_value
  FROM
      (
       SELECT student_number
             ,academic_year
             ,schoolid
             ,grade_level
             ,reporting_term
             ,met_goal
       FROM gabby.lit.achieved_by_round_static
       WHERE start_date <= CONVERT(DATE,GETDATE())
      ) sub
  GROUP BY sub.academic_year
          ,sub.schoolid
          ,sub.grade_level
          ,sub.reporting_term
 )

,gpa_detail AS (
  SELECT gpa.student_number
        ,gpa.academic_year
        ,gpa.schoolid
        ,gpa.grade_level
        ,gpa.reporting_term      
        ,CASE 
          WHEN gpa.gpa_y1 >= 2.0 THEN 1.0 
          WHEN gpa.gpa_y1 < 2.0 THEN 0.0
         END AS gpa_is_2plus
        ,CASE 
          WHEN gpa.gpa_y1 >= 3.0 THEN 1.0 
          WHEN gpa.gpa_y1 < 3.0 THEN 0.0
         END AS gpa_is_3plus
  FROM gabby.powerschool.gpa_detail gpa
  JOIN gabby.reporting.reporting_terms rt
    ON gpa.academic_year = rt.academic_year
   AND gpa.reporting_term = rt.time_per_name COLLATE Latin1_General_BIN
   AND gpa.schoolid = rt.schoolid
   AND rt.start_date <= CONVERT(DATE,SYSDATETIME())
 )

,gpa AS (
  SELECT sub.academic_year
        ,sub.schoolid
        ,sub.grade_level
        ,sub.reporting_term
        ,'pct_gpa_2plus' AS metric_name
        ,AVG(sub.gpa_is_2plus) AS metric_value              
  FROM gpa_detail sub
  GROUP BY sub.academic_year
          ,sub.schoolid
          ,sub.grade_level
          ,sub.reporting_term

  UNION ALL

  SELECT sub.academic_year
        ,sub.schoolid
        ,sub.grade_level
        ,sub.reporting_term
        ,'pct_gpa_3plus' AS metric_name
        ,AVG(sub.gpa_is_3plus) AS metric_value        
  FROM gpa_detail sub
  GROUP BY sub.academic_year
          ,sub.schoolid
          ,sub.grade_level
          ,sub.reporting_term
 )

,assessment_detail AS (
  SELECT asr.local_student_id
        ,asr.academic_year
        ,asr.subject_area
        ,asr.module_number
        ,asr.date_taken
        ,asr.performance_band_number
        ,asr.is_mastery
        ,'pct_' + LOWER(asr.module_type) + '_mastery_' + REPLACE(LOWER(asr.subject_area), ' ', '_') AS metric_name
  FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr      
  WHERE asr.response_type = 'O'
    AND asr.subject_area IN ('Algebra I','Algebra II','English 100','English 200','English 300','Geometry','Mathematics','Text Study', 'Science')
    AND asr.module_type IN ('QA','CP')
 )

,etr_long AS (  
  SELECT sr.df_employee_number
        
        ,rt.academic_year
        ,rt.time_per_name
        ,'etr_overall_score' AS metric_name
        
        ,wo.score AS metric_value
        
        ,ROW_NUMBER() OVER(
           PARTITION BY sr.df_employee_number, rt.academic_year, rt.time_per_name
             ORDER BY wo.observed_at DESC) AS rn
  FROM gabby.whetstone.observations_clean wo
  JOIN gabby.dayforce.staff_roster sr
    ON wo.teacher_accountingid = sr.df_employee_number
  JOIN gabby.reporting.reporting_terms rt
    ON wo.observed_at BETWEEN rt.start_date AND rt.end_date 
   AND rt.identifier = 'ETR'
   AND rt.schoolid = 0
   AND rt._fivetran_deleted = 0
  LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static ex
    ON sr.df_employee_number = ex.df_employee_number
   AND rt.academic_year = ex.academic_year
   AND rt.time_per_name = REPLACE(ex.pm_term, 'PM', 'ETR')
  WHERE wo.rubric_name = 'Coaching Tool: Coach ETR and Reflection'
    AND wo.score IS NOT NULL
    AND wo.observer_email != wo.teacher_email
    AND ex.exemption IS NULL
 )

,etr AS (
  SELECT etr_long.df_employee_number
        ,etr_long.academic_year
        ,etr_long.time_per_name
        ,etr_long.metric_name
        ,etr_long.metric_value
  FROM etr_long
  WHERE rn = 1

  UNION ALL

  SELECT etr_long.df_employee_number
        ,etr_long.academic_year
        ,'ETRY1' AS time_per_name
        ,etr_long.metric_name
        ,AVG(etr_long.metric_value) AS metric_value
  FROM etr_long
  WHERE rn = 1
    AND etr_long.time_per_name IN ('ETR2', 'ETR3')
  GROUP BY etr_long.df_employee_number
          ,etr_long.academic_year
          ,etr_long.metric_name
 )

,so_survey_long AS (
  SELECT so.subject_employee_number
        ,so.academic_year
        ,so.reporting_term
        ,'so_survey_overall_score' AS metric_name
        ,SUM(so.total_weighted_response_value) / SUM(so.total_response_weight) AS metric_value
  FROM gabby.surveys.self_and_others_survey_rollup_static so
  LEFT JOIN gabby.pm.teacher_goals_exemption_clean_static ex
    ON so.subject_employee_number = ex.df_employee_number
   AND so.academic_year = ex.academic_year
   AND so.reporting_term = REPLACE(ex.pm_term, 'PM', 'SO')
  WHERE ex.exemption IS NULL
  GROUP BY so.subject_employee_number
          ,so.academic_year
          ,so.reporting_term
 )

,so_survey AS (
  SELECT so_survey_long.subject_employee_number
        ,so_survey_long.academic_year
        ,so_survey_long.reporting_term
        ,so_survey_long.metric_name
        ,so_survey_long.metric_value
  FROM so_survey_long

  UNION ALL

  SELECT so_survey_long.subject_employee_number
        ,so_survey_long.academic_year
        ,'SOY1' AS reporting_term
        ,so_survey_long.metric_name
        ,AVG(so_survey_long.metric_value) AS metric_value
  FROM so_survey_long
  WHERE so_survey_long.reporting_term IN ('SO2', 'SO3')
  GROUP BY so_survey_long.subject_employee_number
          ,so_survey_long.academic_year
          ,so_survey_long.metric_name
 )

,glt_goal_data AS (
  SELECT rl.academic_year
        ,rl.schoolid
        ,rl.grade_level        
        ,rl.reporting_term
        ,rl.metric_name
        ,rl.metric_value        
  FROM reading_level rl

  UNION ALL

  SELECT gpa.academic_year
        ,gpa.schoolid
        ,gpa.grade_level
        ,gpa.reporting_term COLLATE Latin1_General_BIN AS reporting_term
        ,gpa.metric_name
        ,gpa.metric_value        
  FROM gpa
 )

,individual_goal_data AS (
  SELECT etr.academic_year
        ,etr.df_employee_number
        ,etr.time_per_name AS reporting_term
        ,etr.metric_name
        ,etr.metric_value
  FROM etr

  UNION ALL

  SELECT so.academic_year        
        ,so.subject_employee_number AS df_employee_number
        ,so.reporting_term
        ,so.metric_name
        ,so.metric_value        
  FROM so_survey so
 )

,all_data AS (
  /* individual goals */
  SELECT tgs.df_employee_number
        ,tgs.preferred_name
        ,tgs.primary_site
        ,tgs.primary_on_site_department
        ,tgs.grades_taught
        ,tgs.primary_job
        ,tgs.legal_entity_name
        ,tgs.is_active
        ,tgs.primary_site_schoolid
        ,tgs.manager_df_employee_number
        ,tgs.manager_name
        ,tgs.staff_username
        ,tgs.manager_username
        ,tgs.academic_year
        ,tgs.goal_type
        ,tgs.goal_department
        ,tgs.is_sped_goal
        ,tgs.metric_label
        ,tgs.metric_name
        ,tgs.tier_1
        ,tgs.tier_2
        ,tgs.tier_3
        ,tgs.tier_4
        ,tgs.prior_year_outcome
        ,tgs.pm_term
        ,tgs.data_type
        ,NULL AS grade_level
      
        ,ig.reporting_term      
        ,ig.metric_value            
        ,NULL AS n_students
  FROM gabby.pm.teacher_goal_scaffold_static tgs
  LEFT JOIN individual_goal_data ig
    ON tgs.academic_year = ig.academic_year 
   AND tgs.metric_name = ig.metric_name
   AND tgs.metric_term = ig.reporting_term
   AND tgs.df_employee_number = ig.df_employee_number
  WHERE tgs.goal_type = 'Individual'

  UNION ALL

  /* GLT goals */
  SELECT tgs.df_employee_number
        ,tgs.preferred_name
        ,tgs.primary_site
        ,tgs.primary_on_site_department
        ,tgs.grades_taught
        ,tgs.primary_job
        ,tgs.legal_entity_name
        ,tgs.is_active
        ,tgs.primary_site_schoolid
        ,tgs.manager_df_employee_number
        ,tgs.manager_name
        ,tgs.staff_username
        ,tgs.manager_username
        ,tgs.academic_year
        ,tgs.goal_type
        ,tgs.goal_department
        ,tgs.is_sped_goal
        ,tgs.metric_label
        ,tgs.metric_name
        ,tgs.tier_1
        ,tgs.tier_2
        ,tgs.tier_3
        ,tgs.tier_4
        ,tgs.prior_year_outcome
        ,tgs.pm_term
        ,tgs.data_type
        ,tgs.grade_level
      
        ,glt.reporting_term      
        ,glt.metric_value
        ,NULL AS n_students
  FROM gabby.pm.teacher_goal_scaffold_static tgs
  LEFT JOIN glt_goal_data glt
    ON tgs.academic_year = glt.academic_year 
   AND tgs.metric_name = glt.metric_name
   AND tgs.metric_term = glt.reporting_term
   AND tgs.primary_site_schoolid = glt.schoolid
   AND tgs.grade_level = glt.grade_level
  WHERE tgs.goal_type = 'Team'

  UNION ALL

  /* classroom goals */
  SELECT sub.df_employee_number
        ,sub.preferred_name
        ,sub.primary_site
        ,sub.primary_on_site_department
        ,sub.grades_taught
        ,sub.primary_job
        ,sub.legal_entity_name
        ,sub.is_active
        ,sub.primary_site_schoolid
        ,sub.manager_df_employee_number
        ,sub.manager_name
        ,sub.staff_username
        ,sub.manager_username
        ,sub.academic_year
        ,sub.goal_type
        ,sub.goal_department
        ,sub.is_sped_goal
        ,sub.metric_label
        ,sub.metric_name
        ,sub.tier_1
        ,sub.tier_2
        ,sub.tier_3
        ,sub.tier_4
        ,sub.prior_year_outcome
        ,sub.pm_term
        ,sub.data_type
        ,sub.grade_level

        ,sub.metric_term AS reporting_term
        ,CASE
          WHEN sub.metric_label IN ('Lit Cohort Growth from Last Year', 'Math Cohort Growth from Last Year') THEN AVG(sub.is_mastery) - sub.prior_year_outcome
          ELSE AVG(sub.is_mastery) 
         END AS metric_value      
        ,COUNT(DISTINCT sub.student_number) AS n_students
  FROM
      (
       SELECT tgs.df_employee_number
             ,tgs.preferred_name
             ,tgs.primary_site
             ,tgs.primary_on_site_department
             ,tgs.grades_taught
             ,tgs.primary_job
             ,tgs.legal_entity_name
             ,tgs.is_active
             ,tgs.primary_site_schoolid
             ,tgs.manager_df_employee_number
             ,tgs.manager_name
             ,tgs.staff_username
             ,tgs.manager_username
             ,tgs.academic_year
             ,tgs.goal_type
             ,tgs.goal_department
             ,tgs.is_sped_goal
             ,tgs.metric_label
             ,tgs.metric_name
             ,tgs.tier_1
             ,tgs.tier_2
             ,tgs.tier_3
             ,tgs.tier_4
             ,tgs.prior_year_outcome
             ,tgs.pm_term
             ,tgs.data_type
             ,tgs.metric_term
             ,tgs.student_number
             ,tgs.student_grade_level AS grade_level
           
             ,CASE
               WHEN tgs.is_sped_goal = 0 THEN am.is_mastery
               WHEN tgs.is_sped_goal = 1 AND tgs.metric_name LIKE '%iep345' AND am.performance_band_number >= 3 THEN 1.0
               WHEN tgs.is_sped_goal = 1 AND tgs.metric_name LIKE '%iep345' AND am.performance_band_number < 3 THEN 0.0
               WHEN tgs.is_sped_goal = 1 AND tgs.metric_name LIKE '%iep45' AND am.performance_band_number >= 4 THEN 1.0
               WHEN tgs.is_sped_goal = 1 AND tgs.metric_name LIKE '%iep45' AND am.performance_band_number < 4 THEN 0.0
               WHEN tgs.is_sped_goal = 1 AND am.performance_band_number >= 3 THEN 1.0
               WHEN tgs.is_sped_goal = 1 AND am.performance_band_number < 3 THEN 0.0
              END AS is_mastery
       FROM gabby.pm.teacher_goal_scaffold_static tgs
       LEFT JOIN assessment_detail am
         ON tgs.academic_year = am.academic_year
        AND tgs.metric_name = am.metric_name
        AND tgs.metric_term = am.module_number
        AND tgs.student_number = am.local_student_id
        AND am.date_taken BETWEEN tgs.dateenrolled AND tgs.dateleft
       WHERE tgs.goal_type = 'Class'
      ) sub
  GROUP BY sub.df_employee_number
          ,sub.preferred_name
          ,sub.primary_site
          ,sub.primary_on_site_department
          ,sub.grades_taught
          ,sub.primary_job
          ,sub.legal_entity_name
          ,sub.is_active
          ,sub.primary_site_schoolid
          ,sub.manager_df_employee_number
          ,sub.manager_name
          ,sub.staff_username
          ,sub.manager_username
          ,sub.academic_year
          ,sub.goal_type
          ,sub.goal_department
          ,sub.is_sped_goal
          ,sub.metric_label
          ,sub.metric_name
          ,sub.tier_1
          ,sub.tier_2
          ,sub.tier_3
          ,sub.tier_4
          ,sub.prior_year_outcome
          ,sub.metric_term
          ,sub.grade_level
          ,sub.pm_term
          ,sub.data_type
 )

SELECT d.df_employee_number
      ,d.academic_year
      ,d.pm_term
      ,d.grade_level
      ,d.is_sped_goal
      ,d.metric_name
      ,d.metric_label
      ,d.preferred_name
      ,d.primary_site
      ,d.primary_on_site_department
      ,d.grades_taught
      ,d.primary_job
      ,d.legal_entity_name
      ,d.is_active
      ,d.primary_site_schoolid
      ,d.manager_df_employee_number
      ,d.manager_name
      ,d.staff_username
      ,d.manager_username
      ,d.goal_type
      ,d.goal_department
      ,d.tier_1
      ,d.tier_2
      ,d.tier_3
      ,d.tier_4
      ,d.prior_year_outcome
      ,d.data_type
      ,d.reporting_term
      ,d.metric_value
      ,d.n_students

      ,lb.metric_value AS metric_value_stored
      ,lb.score AS score_stored
      ,lb.grade_level_weight AS grade_level_weight_stored
      ,lb.bucket_weight AS bucket_weight_stored
      ,lb.bucket_score AS bucket_score_stored
FROM all_data d
LEFT JOIN gabby.pm.teacher_goals_lockbox_wide lb
  ON d.df_employee_number = lb.df_employee_number
 AND d.academic_year = lb.academic_year
 AND d.pm_term = lb.pm_term
 AND ISNULL(d.grade_level, -1) = lb.grade_level
 AND d.is_sped_goal = lb.is_sped_goal
 AND d.metric_name = lb.metric_name
 AND d.metric_label = lb.metric_label;