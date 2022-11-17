USE gabby
GO

CREATE OR ALTER VIEW tableau.ekg_big_goals_tracker AS

WITH act AS (
  SELECT student_number
        ,academic_year
        ,composite
        
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number
             ORDER BY composite DESC) AS rn_highest             
  FROM
      (
       SELECT student_number             
             ,academic_year
             ,composite             
       FROM gabby.naviance.act_scores_clean       
       
       UNION ALL
       
       SELECT student_number                
             ,academic_year
             ,scale_score             
       FROM gabby.naviance.sat_act_conversion
      ) sub
 )

,parcc AS (
  SELECT student_number
        ,academic_year
        ,ela AS ela_performance_level
        ,math AS math_performance_level
  FROM
      (
       SELECT local_student_identifier AS student_number
             ,academic_year
             ,CASE
               WHEN subject = 'English Language Arts/Literacy' THEN 'ela'
               ELSE 'math'
              END AS subject
             ,test_performance_level
       FROM gabby.parcc.summative_record_file_clean
      ) sub
  PIVOT(
    MAX(test_performance_level)
    FOR subject IN ([ela], [math])
   ) p
 )

,modules AS (
  SELECT student_number
        ,academic_year
        ,module_type
        ,module_number

        ,ela_percent_correct
        ,ela_is_mastery
        ,ela_performance_band_number
        ,ela_rn_most_recent_subject
        ,math_percent_correct
        ,math_is_mastery
        ,math_performance_band_number
        ,math_rn_most_recent_subject
  FROM
      (
       SELECT local_student_id AS student_number             
             ,academic_year
             ,module_type
             ,module_number
             ,CONCAT(subject_area, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT local_student_id
                  ,academic_year
                  ,module_type
                  ,module_number
                  ,CASE WHEN subject_area = 'Text Study' THEN 'ela' ELSE 'math' END AS subject_area
                  ,CAST(performance_band_number AS FLOAT) AS performance_band_number
                  ,CAST(percent_correct AS FLOAT) AS percent_correct                  
                  ,CAST(is_mastery AS FLOAT) AS is_mastery
      
                  ,CAST(ROW_NUMBER( AS FLOAT) OVER(
                     PARTITION BY local_student_id, academic_year, CASE WHEN subject_area = 'Text Study' THEN 'ela' ELSE 'math' END
                       ORDER BY administered_at DESC)) AS rn_most_recent_subject
            FROM gabby.illuminate_dna_assessments.agg_student_responses_all
            WHERE response_type = 'O'
              AND module_type IN ('QA', 'CRQ')
              AND subject_area IN ('Text Study', 'Mathematics', 'Algebra I', 'Geometry', 'Algebra IIA', 'Algebra IIB')
              AND percent_correct IS NOT NULL
           ) sub
       UNPIVOT(
         value
         FOR field IN (percent_correct, is_mastery, performance_band_number, rn_most_recent_subject)
        ) u
     ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN (ela_percent_correct
                       ,ela_is_mastery
                       ,ela_performance_band_number
                       ,ela_rn_most_recent_subject
                       ,math_percent_correct
                       ,math_is_mastery
                       ,math_performance_band_number
                       ,math_rn_most_recent_subject)
   ) p
 )

,lit_achievement AS (
  SELECT student_number
        ,academic_year
        ,met_goal        
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY end_date DESC) AS rn_most_recent
  FROM gabby.lit.achieved_by_round_static
  WHERE end_date <= CAST(CURRENT_TIMESTAMP AS DATE)
 )

,lit_growth AS (
  SELECT student_number
        ,academic_year      
        ,CASE        
          WHEN MAX(CASE WHEN rn_curr = 1 THEN gleq END) - MAX(CASE WHEN rn_base = 1 THEN gleq END) >= 1 THEN 1.0
          WHEN MAX(CASE WHEN rn_curr = 1 THEN gleq END) - MAX(CASE WHEN rn_base = 1 THEN gleq END) < 1 THEN 0.0
         END AS is_making_1yr_growth
  FROM
      (
       SELECT student_number
             ,academic_year
             ,gleq
             ,ROW_NUMBER() OVER(
                PARTITION BY student_number, academic_year
                  ORDER BY start_date ASC) AS rn_base
             ,ROW_NUMBER() OVER(
                PARTITION BY student_number, academic_year
                  ORDER BY start_date DESC) AS rn_curr
       FROM gabby.lit.achieved_by_round_static
       WHERE gleq IS NOT NULL    
         AND end_date <= CAST(CURRENT_TIMESTAMP AS DATE)
      ) sub
  GROUP BY student_number
          ,academic_year
  HAVING COUNT(gleq) > 1 /* return only students with > 1 term */
 ) 

,ada AS (
  SELECT studentid
        ,db_name
        ,(yearid + 1990) AS academic_year
        ,SUM(CAST(attendancevalue AS FLOAT)) AS n_days_attendance
        ,SUM(CAST(membershipvalue AS FLOAT)) AS n_days_membership
        ,ROUND(AVG(CAST(attendancevalue AS FLOAT)), 2) AS ada
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue > 0
    AND calendardate <= CAST(CURRENT_TIMESTAMP AS DATE)
  GROUP BY studentid
          ,yearid
          ,db_name
 )

,suspensions AS (
  SELECT studentid
        ,yearid
        ,db_name
        ,MAX(CASE WHEN sub.att_code_group = 'OSS' THEN sub.n_streaks END) AS [OSS]
        ,MAX(CASE WHEN sub.att_code_group = 'ISS' THEN sub.n_streaks END) AS [ISS]
        ,MAX(CASE WHEN sub.att_code_group = 'T' THEN sub.n_days END) AS n_days_tardy
  FROM
      (
       SELECT sub.studentid
             ,sub.yearid
             ,sub.att_code_group
             ,sub.db_name      
             ,COUNT(studentid) AS n_streaks
             ,SUM(sub.streak_length_membership) AS n_days
       FROM
           (
            SELECT studentid
                  ,yearid
                  ,streak_length_membership
                  ,db_name             
                  ,CASE 
                    WHEN att_code IN ('OS','OSS','OSSP') THEN 'OSS'
                    WHEN att_code IN ('ISS','S') THEN 'ISS'
                    WHEN att_code IN ('T', 'T10') THEN 'T'
                   END AS att_code_group
            FROM gabby.powerschool.attendance_streak
            WHERE att_code IN ('OS','OSS','OSSP','ISS','S', 'T', 'T10')
           ) sub
       GROUP BY studentid
               ,yearid
               ,sub.att_code_group
               ,db_name
             ) sub
  GROUP BY studentid
          ,yearid
          ,db_name
 )

,student_attrition AS (
  SELECT d.student_number AS denominator_student_number
        ,d.academic_year AS denominator_academic_year
      
        ,CASE 
          WHEN d.enroll_status = 3 THEN 0.0
          WHEN d.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND n.student_number IS NULL THEN 1.0 
          WHEN d.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND CAST(CURRENT_TIMESTAMP AS DATE) >= d.exitdate THEN 1.0          
          ELSE 0.0 
         END AS is_attrition
  FROM
      (
       SELECT student_number     
             ,academic_year
             ,entrydate
             ,exitdate
             ,enroll_status
             ,db_name
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE DATEFROMPARTS(academic_year, 10, 1) BETWEEN entrydate AND exitdate
      ) d
  LEFT JOIN gabby.powerschool.cohort_identifiers_static n
    ON d.student_number = n.student_number
   AND d.db_name = n.db_name
   AND d.academic_year = (n.academic_year - 1)
   AND DATEFROMPARTS(n.academic_year, 10, 1) BETWEEN n.entrydate AND n.exitdate
 )

,teacher_attrition AS (
  SELECT ISNULL(region, 'All') AS region
        ,ISNULL(CAST(school_level AS VARCHAR(5)), 'All') AS school_level
        ,ISNULL(reporting_schoolid, 0) AS reporting_schoolid
        ,academic_year
        ,AVG(CAST(is_attrition AS FLOAT)) AS pct_attrition
        ,AVG(CAST(is_attrition_termination AS FLOAT)) AS pct_attrition_termination
        ,AVG(CAST(is_attrition_resignation AS FLOAT)) AS pct_attrition_resignation
        ,AVG(CAST(is_attrition_other AS FLOAT)) AS pct_attrition_other
  FROM
      (
       SELECT primary_site
             ,primary_site_reporting_schoolid AS reporting_schoolid
             ,CASE
               WHEN legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
               WHEN legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
               WHEN legal_entity_name = 'KIPP Miami' THEN 'KMS'               
              END AS region
             ,primary_site_school_level AS school_level
             ,academic_year
             ,is_attrition
             ,CASE WHEN status_reason = 'Termination' THEN is_attrition ELSE 0 END AS is_attrition_termination
             ,CASE WHEN status_reason = 'Resignation' THEN is_attrition ELSE 0 END AS is_attrition_resignation
             ,CASE WHEN status_reason NOT IN ('Termination', 'Resignation') THEN is_attrition ELSE 0 END AS is_attrition_other
       FROM gabby.tableau.compliance_staff_attrition
       WHERE is_denominator = 1         
         AND legal_entity_name <> 'KIPP New Jersey'
         AND primary_site_reporting_schoolid <> 0
      ) sub  
  GROUP BY academic_year
          ,ROLLUP(school_level, region, reporting_schoolid)
 )

,q12 AS (
  SELECT ISNULL(reporting_schoolid, 0) AS reporting_schoolid
        ,ISNULL(region, 'All') AS region
        ,ISNULL(school_level, 'All') AS school_level
        ,academic_year
        ,reporting_term
        ,AVG(response_value) AS avg_response_value
      
        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year, reporting_schoolid, region, school_level
             ORDER BY reporting_term DESC) AS rn_most_recent
  FROM
      (
       SELECT reporting_schoolid
             ,region
             ,school_level
             ,academic_year
             ,reporting_term
             ,response_value
       FROM gabby.surveys.r9engagement_survey_detail
       WHERE competency = 'Q12'
      ) sub
  WHERE reporting_schoolid IS NOT NULL
  GROUP BY academic_year
          ,reporting_term
          ,ROLLUP(school_level, region, reporting_schoolid)
 )

,tntp AS (
  SELECT reporting_schoolid
        ,region
        ,school_level
        ,academic_year
        ,survey_round

        ,[ICI Percentile] AS ici_percentile
        ,CASE WHEN [Learning Environment Score] >= [Learning Environment Score: Top-Quartile] THEN 1 ELSE 0 END AS is_top_quartile_learning_environment_score

        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year, reporting_schoolid, region, school_level
             ORDER BY survey_round DESC) AS rn_most_recent
  FROM
      (
       SELECT ISNULL(reporting_schoolid, 0) AS reporting_schoolid
             ,ISNULL(region, 'All') AS region
             ,ISNULL(CAST(school_level AS VARCHAR(5)), 'All') AS school_level
             ,academic_year
             ,survey_round      
             ,field
             ,AVG(value) AS avg_value
       FROM gabby.tntp.teacher_survey_school_sorter_identifiers
       WHERE field IN ('Learning Environment Score', 'Learning Environment Score: Top-Quartile', 'ICI Percentile')
       GROUP BY academic_year
               ,survey_round      
               ,field
               ,ROLLUP(school_level, region, reporting_schoolid)
      ) sub
  PIVOT(
    MAX(avg_value)
    FOR field IN ([ICI Percentile], [Learning Environment Score], [Learning Environment Score: Top-Quartile])
   ) p
 )

,manager_survey AS (
  SELECT ISNULL(reporting_schoolid, 0) AS reporting_schoolid
        ,ISNULL(region, 'All') AS region
        ,ISNULL(CAST(school_level AS VARCHAR(5)), 'All') AS school_level
        ,academic_year      
        ,reporting_term
        ,AVG(is_agree) AS pct_agree
        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year, reporting_schoolid, region, school_level
             ORDER BY reporting_term DESC) AS rn_most_recent
  FROM
      (
       SELECT subject_primary_site_schoolid AS reporting_schoolid
             ,subject_legal_entity_name AS region
             ,subject_primary_site_school_level AS school_level
             ,campaign_academic_year AS academic_year
             ,campaign_reporting_term AS reporting_term
             ,CASE 
               WHEN answer_value >= 4 THEN 1.0
               WHEN answer_value < 4 THEN 0.0
              END AS is_agree
       FROM gabby.surveys.manager_survey_detail
      ) sub
  WHERE reporting_schoolid IS NOT NULL
  GROUP BY academic_year
          ,reporting_term
          ,ROLLUP(school_level, region, reporting_schoolid)
 )

,hsr AS (
  SELECT reporting_schoolid
        ,region
        ,school_level
        ,academic_year
        ,[parent] AS parent_pct_responded_positive
        ,[student] AS student_pct_responded_positive
  FROM
      (
       SELECT ISNULL(reporting_schoolid, 0) AS reporting_schoolid
             ,ISNULL(region, 'All') AS region
             ,ISNULL(CAST(school_level AS VARCHAR(5)), 'All') AS school_level
             ,academic_year
             ,role      
             ,SUM(n_responses_positive) / SUM(n_responses) AS pct_responded_positive
       FROM gabby.surveys.hsr_survey_detail       
       WHERE role IN ('Parent','Student')
       GROUP BY academic_year
               ,role
               ,ROLLUP(school_level, region, reporting_schoolid)
      ) sub
  PIVOT(
    MAX(pct_responded_positive)
    FOR role IN ([parent],[student])
   ) p
 )

,ekg_walkthrough AS (
  SELECT reporting_schoolid
        ,region
        ,school_level
        ,academic_year
        ,reporting_term
        ,[threecsaverage]
        ,[overallaverage]  
  FROM
      (
       SELECT reporting_schoolid
             ,region
             ,school_level
             ,academic_year
             ,reporting_term
             ,rubric_strand_field
             ,pct_of_classrooms_proficient      
       FROM gabby.ekg.walkthrough_scores_detail
       WHERE rubric_strand_field IN ('threecsaverage','overallaverage')
         AND rn_most_recent_yr = 1
      ) sub
  PIVOT(
    MAX(pct_of_classrooms_proficient)
    FOR rubric_strand_field IN ([threecsaverage],[overallaverage])
    ) p
 )

,student_level_rollup_y1 AS (
  SELECT sub.academic_year
        ,ISNULL(sub.region,'All') AS region
        ,ISNULL(CAST(sub.school_level AS VARCHAR(5)),'All') AS school_level
        ,ISNULL(sub.reporting_schoolid, 0) AS reporting_schoolid
        ,ISNULL(CAST(sub.grade_level AS VARCHAR(5)), 'All') AS grade_level

        /* student-level percentages */
        ,CAST(AVG(sub.is_free_or_reduced) AS FLOAT) AS free_or_reduced_pct
        ,CAST(AVG(sub.highest_act_composite_seniors) AS FLOAT) AS act_composite_seniors_avg
        ,CAST(AVG(sub.highest_act_composite_juniors) AS FLOAT) AS act_composite_juniors_avg
        ,CAST(AVG(sub.parcc_ela_proficient) AS FLOAT) AS parcc_ela_proficient_pct
        ,CAST(AVG(sub.parcc_math_proficient) AS FLOAT) AS parcc_math_proficient_pct
        ,CAST(AVG(sub.parcc_ela_proficient_iep) AS FLOAT) AS parcc_ela_proficient_iep_pct
        ,CAST(AVG(sub.parcc_math_proficient_iep) AS FLOAT) AS parcc_math_proficient_iep_pct
        ,CAST(AVG(sub.parcc_ela_approaching_iep) AS FLOAT) AS parcc_ela_approaching_iep_pct
        ,CAST(AVG(sub.parcc_math_approaching_iep) AS FLOAT) AS parcc_math_approaching_iep_pct
        ,CAST(AVG(sub.module_ela_is_mastery) AS FLOAT) AS module_ela_mastery_pct
        ,CAST(AVG(sub.module_math_is_mastery) AS FLOAT) AS module_math_mastery_pct
        ,CAST(AVG(sub.module_ela_is_parcc_predictive) AS FLOAT) AS module_ela_parcc_predictive_pct
        ,CAST(AVG(sub.module_math_is_parcc_predictive) AS FLOAT) AS module_math_parcc_predictive_pct
        ,CAST(AVG(sub.lit_meeting_goal) AS FLOAT) AS lit_meeting_goal_pct
        ,CAST(AVG(sub.lit_making_1yr_growth) AS FLOAT) AS lit_making_1yr_growth_pct
        ,CAST(AVG(sub.is_student_attrition) AS FLOAT) AS student_attrition_pct
        ,CAST(SUM(sub.n_days_attendance) / SUM(sub.n_days_membership) AS FLOAT) AS ada
        ,CAST(AVG(sub.is_chronically_absent) AS FLOAT) AS chronically_absent_pct
        ,CAST(SUM(sub.n_days_tardy) / SUM(sub.n_days_membership) AS FLOAT) AS tardy_pct
        ,CAST(AVG(sub.is_OSS) AS FLOAT) AS oss_pct
        ,CAST(AVG(sub.is_ISS) AS FLOAT) AS iss_pct
        ,CAST(AVG(sub.is_OSS_iep) AS FLOAT) AS oss_iep_pct
        ,CAST(AVG(sub.is_ISS_iep) AS FLOAT) AS iss_iep_pct

        /* student-level totals */
        ,CAST(SUM(sub.n_OSS) AS FLOAT) AS n_oss
        ,CAST(SUM(sub.n_ISS) AS FLOAT) AS n_iss  
  FROM
      (
       SELECT co.student_number      
             ,co.academic_year
             ,co.region COLLATE SQL_Latin1_General_CP1_CI_AS AS region
             ,co.school_level COLLATE SQL_Latin1_General_CP1_CI_AS AS school_level
             ,co.reporting_schoolid
             ,co.grade_level
             ,CASE WHEN co.lunchstatus IN ('F', 'R') THEN 1.0 ELSE 0.0 END AS is_free_or_reduced
      
             /* ACT */
             ,CASE WHEN co.grade_level = 12 THEN act.composite END AS highest_act_composite_seniors
             ,CASE WHEN co.grade_level = 11 THEN act.composite END AS highest_act_composite_juniors

             /* PARCC */
             ,CASE 
               WHEN parcc.ela_performance_level >= 4 THEN 1.0 
               WHEN parcc.ela_performance_level < 4 THEN 0.0 
              END AS parcc_ela_proficient
             ,CASE 
               WHEN parcc.math_performance_level >= 4 THEN 1.0 
               WHEN parcc.math_performance_level < 4 THEN 0.0 
              END AS parcc_math_proficient
             ,CASE 
               WHEN parcc.ela_performance_level = 3 THEN 1.0 
               WHEN parcc.ela_performance_level <> 3 THEN 0.0 
              END AS parcc_ela_approaching
             ,CASE 
               WHEN parcc.math_performance_level = 3 THEN 1.0 
               WHEN parcc.math_performance_level <> 3 THEN 0.0 
              END AS parcc_math_approaching
             ,CASE 
               WHEN parcc.ela_performance_level <= 2 THEN 1.0 
               WHEN parcc.ela_performance_level > 2 THEN 0.0 
              END AS parcc_ela_below
             ,CASE 
               WHEN parcc.math_performance_level <= 2 THEN 1.0 
               WHEN parcc.math_performance_level > 2 THEN 0.0 
              END AS parcc_math_below
             ,CASE 
               WHEN co.iep_status = 'SPED' AND parcc.ela_performance_level >= 4 THEN 1.0
               WHEN co.iep_status = 'SPED' AND parcc.ela_performance_level < 4 THEN 0.0 
              END AS parcc_ela_proficient_iep
             ,CASE 
               WHEN co.iep_status = 'SPED' AND parcc.math_performance_level >= 4 THEN 1.0
               WHEN co.iep_status = 'SPED' AND parcc.math_performance_level < 4 THEN 0.0 
              END AS parcc_math_proficient_iep
             ,CASE 
               WHEN co.iep_status = 'SPED' AND parcc.ela_performance_level >= 3 THEN 1.0
               WHEN co.iep_status = 'SPED' AND parcc.ela_performance_level < 3 THEN 0.0 
              END AS parcc_ela_approaching_iep
             ,CASE 
               WHEN co.iep_status = 'SPED' AND parcc.math_performance_level >= 3 THEN 1.0
               WHEN co.iep_status = 'SPED' AND parcc.math_performance_level < 3 THEN 0.0 
              END AS parcc_math_approaching_iep      

             /* T&L assessments */
             ,CASE WHEN co.grade_level <= 2 THEN modela.ela_is_mastery END AS module_ela_is_mastery 
             ,CASE 
               WHEN co.grade_level > 2 THEN NULL
               WHEN modela.ela_percent_correct >= 65 THEN 1.0 
               WHEN modela.ela_percent_correct < 65 THEN 0.0 
              END AS module_ela_is_parcc_predictive

             ,CASE WHEN co.grade_level <= 2 THEN modmath.math_is_mastery END AS module_math_is_mastery              
             ,CASE 
               WHEN co.grade_level > 2 THEN NULL
               WHEN modmath.math_percent_correct >= 65 THEN 1.0 
               WHEN modmath.math_percent_correct < 65 THEN 0.0 
              END AS module_math_is_parcc_predictive

             /*Literacy */
             ,CAST(la.met_goal AS FLOAT) AS lit_meeting_goal

             ,lg.is_making_1yr_growth AS lit_making_1yr_growth

             /* ADA */
             ,ada.n_days_attendance
             ,ada.n_days_membership
             ,CASE WHEN ada.ada < 0.9 THEN 1.0 ELSE 0.0 END AS is_chronically_absent

             /* Attendance Codes */
             ,sus.n_days_tardy
             ,sus.OSS AS n_oss
             ,sus.ISS AS n_iss
             ,CASE WHEN sus.OSS > 0 THEN 1.0 ELSE 0.0 END AS is_oss
             ,CASE WHEN sus.ISS > 0 THEN 1.0 ELSE 0.0 END AS is_iss
             ,CASE WHEN co.iep_status = 'SPED' AND sus.OSS > 0 THEN 1.0 ELSE 0.0 END AS is_oss_iep
             ,CASE WHEN co.iep_status = 'SPED' AND sus.ISS > 0 THEN 1.0 ELSE 0.0 END AS is_iss_iep

             /* Attrition */
             ,sa.is_attrition AS is_student_attrition
       FROM gabby.powerschool.cohort_identifiers_static co
       LEFT JOIN act
         ON co.student_number = act.student_number
        AND co.academic_year >= act.academic_year
        AND act.rn_highest = 1
       LEFT JOIN parcc
         ON co.student_number = parcc.student_number
        AND co.academic_year = parcc.academic_year
       LEFT JOIN modules modela
         ON co.student_number = modela.student_number
        AND co.academic_year = modela.academic_year
        AND modela.ela_rn_most_recent_subject = 1
        AND co.grade_level <= 2
       LEFT JOIN modules modmath
         ON co.student_number = modmath.student_number
        AND co.academic_year = modmath.academic_year
        AND modmath.math_rn_most_recent_subject = 1
        AND co.grade_level <= 2
       LEFT JOIN lit_achievement la
         ON co.student_number = la.student_number
        AND co.academic_year = la.academic_year
        AND la.rn_most_recent = 1
       LEFT JOIN lit_growth lg
         ON co.student_number = lg.student_number
        AND co.academic_year = lg.academic_year
       LEFT JOIN ada
         ON co.studentid = ada.studentid
        AND co.db_name = ada.db_name
        AND co.academic_year = ada.academic_year
       LEFT JOIN suspensions sus
         ON co.studentid = sus.studentid
        AND co.yearid = sus.yearid
        AND co.db_name = sus.db_name
       LEFT JOIN student_attrition sa
         ON co.student_number = sa.denominator_student_number
        AND co.academic_year = sa.denominator_academic_year
       WHERE co.reporting_schoolid NOT IN (999999, 5173)
         AND co.rn_year = 1
      ) sub
  GROUP BY sub.academic_year                              
          ,ROLLUP(sub.school_level, sub.region, sub.reporting_schoolid, sub.grade_level)
 )

,school_level_rollup_y1 AS (
  SELECT slr.academic_year
        ,slr.region
        ,slr.school_level
        ,slr.reporting_schoolid
        ,slr.grade_level
        ,slr.free_or_reduced_pct
        ,slr.act_composite_seniors_avg
        ,slr.act_composite_juniors_avg
        ,slr.parcc_ela_proficient_pct
        ,slr.parcc_math_proficient_pct
        ,slr.parcc_ela_proficient_iep_pct
        ,slr.parcc_math_proficient_iep_pct
        ,slr.parcc_ela_approaching_iep_pct
        ,slr.parcc_math_approaching_iep_pct
        ,slr.module_ela_mastery_pct
        ,slr.module_math_mastery_pct
        ,slr.module_ela_parcc_predictive_pct
        ,slr.module_math_parcc_predictive_pct
        ,slr.lit_meeting_goal_pct
        ,slr.lit_making_1yr_growth_pct
        ,slr.student_attrition_pct
        ,slr.ada
        ,slr.n_oss
        ,slr.n_iss      

        /* school-level metrics */
        ,CAST(ta.pct_attrition AS FLOAT) AS teacher_attrition_pct
        ,CAST(ta.pct_attrition_termination AS FLOAT) AS teacher_attrition_termination_pct
        ,CAST(ta.pct_attrition_resignation AS FLOAT) AS teacher_attrition_resignation_pct
        ,CAST(ta.pct_attrition_other AS FLOAT) AS teacher_attrition_other_pct
             
        ,CAST(ekg.overallaverage AS FLOAT) AS ekg_walkthough_overall_avg
        ,CAST(ekg.threecsaverage AS FLOAT) AS ekg_walkthough_three_cs_avg

        /* Surveys */
        ,CAST(q12.avg_response_value AS FLOAT) AS q12_response_avg      
     
        ,CAST(hsr.parent_pct_responded_positive AS FLOAT) AS hsr_parent_positive_pct
        ,CAST(hsr.student_pct_responded_positive AS FLOAT) AS hsr_student_positive_pct
     
        ,CAST(tntp.ici_percentile AS FLOAT) AS ici_percentile
        ,CAST(tntp.is_top_quartile_learning_environment_score AS FLOAT) AS learning_environment_score_top_quartile             
  FROM student_level_rollup_y1 slr
  LEFT JOIN teacher_attrition ta
    ON slr.reporting_schoolid = ta.reporting_schoolid
   AND slr.region = ta.region
   AND slr.school_level = ta.school_level
   AND slr.academic_year = ta.academic_year 
  LEFT JOIN q12
    ON slr.reporting_schoolid = q12.reporting_schoolid
   AND slr.region = q12.region
   AND slr.school_level = q12.school_level
   AND slr.academic_year = q12.academic_year
   AND q12.rn_most_recent = 1
  LEFT JOIN hsr
    ON slr.reporting_schoolid = hsr.reporting_schoolid
   AND slr.region = hsr.region
   AND slr.school_level = hsr.school_level
   AND slr.academic_year = hsr.academic_year
  LEFT JOIN tntp
    ON slr.reporting_schoolid = tntp.reporting_schoolid
   AND slr.region = tntp.region
   AND slr.school_level = tntp.school_level
   AND slr.academic_year = tntp.academic_year
   AND tntp.rn_most_recent = 1
  LEFT JOIN ekg_walkthrough ekg
    ON slr.reporting_schoolid = ekg.reporting_schoolid
   AND slr.region = ekg.region
   AND slr.school_level = ekg.school_level
   AND slr.academic_year = ekg.academic_year
)

,rollup_unpivoted_y1 AS (
  SELECT academic_year
        ,region
        ,school_level
        ,reporting_schoolid
        ,grade_level
        ,field
        ,value
  FROM school_level_rollup_y1
  UNPIVOT(
    value
    FOR field IN (free_or_reduced_pct
                 ,act_composite_seniors_avg
                 ,act_composite_juniors_avg
                 ,parcc_ela_proficient_pct
                 ,parcc_math_proficient_pct
                 ,parcc_ela_proficient_iep_pct
                 ,parcc_math_proficient_iep_pct
                 ,parcc_ela_approaching_iep_pct
                 ,parcc_math_approaching_iep_pct
                 ,module_ela_mastery_pct
                 ,module_math_mastery_pct
                 ,module_ela_parcc_predictive_pct
                 ,module_math_parcc_predictive_pct
                 ,lit_meeting_goal_pct
                 ,lit_making_1yr_growth_pct
                 ,student_attrition_pct
                 ,ada
                 ,n_oss
                 ,n_iss
                 ,teacher_attrition_pct
                 ,q12_response_avg
                 ,hsr_parent_positive_pct
                 ,hsr_student_positive_pct
                 ,ici_percentile
                 ,learning_environment_score_top_quartile
                 ,ekg_walkthough_overall_avg
                 ,ekg_walkthough_three_cs_avg)
   ) u
 )

SELECT ru.academic_year
      ,ru.region
      ,ru.school_level
      ,ru.reporting_schoolid
      ,ru.grade_level
      ,ru.field AS ekg_metric_field
      ,ru.value AS ekg_metric_value
      ,'Y1' AS term_name
      ,CAST(SYSDATETIME() AS DATE) AS week_of_date
      
      ,g.metric AS ekg_metric_label
      ,g.domain AS ekg_domain
      ,g.strand AS ekg_strand
      ,g.meeting
      ,g.unit
      ,g.direction     
      ,CASE
        WHEN ru.school_level = 'ES' THEN g.points_es
        WHEN ru.school_level = 'MS' THEN g.points_ms
        WHEN ru.school_level = 'HS' THEN g.points_hs
       END AS points
FROM rollup_unpivoted_y1 ru
LEFT JOIN gabby.ekg.goals g
  ON ru.field = g.field