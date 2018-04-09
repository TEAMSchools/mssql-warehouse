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
        ,ela_percent_correct
        ,ela_is_mastery
        ,math_percent_correct
        ,math_is_mastery
  FROM
      (
       SELECT local_student_id AS student_number
             ,academic_year
             ,CONCAT(subject_area, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT local_student_id
                  ,academic_year
                  ,CASE
                    WHEN subject_area = 'Text Study' THEN 'ela'
                    ELSE 'math'
                   END AS subject_area
                  ,CONVERT(FLOAT,percent_correct) AS percent_correct
                  ,CONVERT(FLOAT,is_mastery) AS is_mastery
      
                  ,ROW_NUMBER() OVER(
                     PARTITION BY local_student_id, academic_year, CASE WHEN subject_area = 'Text Study' THEN 'ela' ELSE 'math' END
                       ORDER BY administered_at DESC) AS rn_subject_most_recent
            FROM gabby.illuminate_dna_assessments.agg_student_responses_all
            WHERE response_type = 'O'
              AND scope = 'CMA - End-of-Module'
              AND subject_area IN ('Text Study', 'Mathematics', 'Algebra I', 'Geometry', 'Algebra IIA', 'Algebra IIB')
              AND percent_correct IS NOT NULL
           ) sub
       UNPIVOT(
         value
         FOR field IN (percent_correct, is_mastery)
        ) u
       WHERE rn_subject_most_recent = 1
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN (ela_percent_correct, ela_is_mastery, math_percent_correct, math_is_mastery)
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
  WHERE end_date <= CONVERT(DATE,GETDATE())
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
         AND end_date <= CONVERT(DATE,GETDATE())
      ) sub
  GROUP BY student_number
          ,academic_year
  HAVING COUNT(gleq) > 1 /* return only students with > 1 term */
 ) 

,ada AS (
  SELECT studentid
        ,(yearid + 1990) AS academic_year
        ,SUM(CONVERT(FLOAT,attendancevalue)) AS n_days_attendance
        ,SUM(CONVERT(FLOAT,membershipvalue)) AS n_days_membership
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue > 0
    AND calendardate <= CONVERT(DATE,GETDATE())
  GROUP BY studentid
          ,yearid
 )

,suspensions AS (
  SELECT student_number
        ,academic_year
        ,[OSS]
        ,[ISS]
  FROM
      (
       SELECT student_number
             ,academic_year
             ,CASE 
               WHEN att_code IN ('OS','OSS','OSSP') THEN 'OSS'
               WHEN att_code IN ('ISS','S') THEN 'ISS'
              END AS att_code
             ,COUNT(student_number) AS N
       FROM gabby.powerschool.attendance_streak
       WHERE att_code IN ('OS','OSS','OSSP','ISS','S')
       GROUP BY student_number
               ,academic_year
               ,CASE 
                 WHEN att_code IN ('OS','OSS','OSSP') THEN 'OSS'
                 WHEN att_code IN ('ISS','S') THEN 'ISS'
                END
      ) sub
  PIVOT(
    MAX(N)
    FOR att_code IN ([OSS],[ISS])
   ) p
 )

,student_attrition AS (
  SELECT d.student_number AS denominator_student_number
        ,d.academic_year AS denominator_academic_year
      
        ,CASE 
          WHEN d.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND n.student_number IS NULL THEN 1.0 
          WHEN d.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND CONVERT(DATE,GETDATE()) >= d.exitdate THEN 1.0          
          ELSE 0.0 
         END AS is_attrition
  FROM
      (
       SELECT student_number     
             ,academic_year
             ,entrydate
             ,exitdate
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE DATEFROMPARTS(academic_year, 10, 1) BETWEEN entrydate AND exitdate
      ) d
  LEFT OUTER JOIN gabby.powerschool.cohort_identifiers_static n
    ON d.student_number = n.student_number
   AND d.academic_year = (n.academic_year - 1)
   AND DATEFROMPARTS(n.academic_year, 10, 1) BETWEEN n.entrydate AND n.exitdate
 )

,teacher_attrition AS (
  SELECT ISNULL(region, 'All') AS region
        ,ISNULL(CONVERT(NVARCHAR(3),school_level), 'All') AS school_level
        ,ISNULL(reporting_schoolid, 0) AS reporting_schoolid
        ,academic_year
        ,AVG(CONVERT(FLOAT,is_attrition)) AS pct_attrition
  FROM
      (
       SELECT location
             ,CASE
               WHEN location = 'Rise Academy' THEN 73252
               WHEN location = 'Newark Collegiate Academy' THEN 73253
               WHEN location = 'SPARK Academy' THEN 73254
               WHEN location = 'THRIVE Academy' THEN 73255
               WHEN location = 'Seek Academy' THEN 73256
               WHEN location = 'Life Academy' THEN 73257
               WHEN location = 'Pathways' THEN 732574573
               WHEN location = 'Bold Academy' THEN 73258
               WHEN location = 'Lanning Square Primary' THEN 179901
               WHEN location = 'Whittier Elementary' THEN 1799015075
               WHEN location = 'Lanning Square MS' THEN 179902
               WHEN location = 'Whittier Middle' THEN 179903
               WHEN location = 'TEAM Academy' THEN 133570965
              END AS reporting_schoolid
             ,CASE
               WHEN location IN ('Rise Academy','Newark Collegiate Academy','SPARK Academy','THRIVE Academy','Seek Academy','Life Academy','Pathways','Bold Academy','TEAM Academy') THEN 'TEAM'
               WHEN location IN ('Lanning Square Primary','Whittier Elementary','Lanning Square MS','Whittier Middle') THEN 'KCNA'               
              END AS region
             ,CASE
               WHEN location IN ('SPARK Academy','THRIVE Academy','Seek Academy','Life Academy','Pathways','Lanning Square Primary','Whittier Elementary') THEN 'ES'
               WHEN location IN ('TEAM Academy','Rise Academy','Bold Academy','Lanning Square MS','Whittier Middle') THEN 'MS'
               WHEN location IN ('Newark Collegiate Academy') THEN 'HS'
              END AS school_level
             ,academic_year
             ,is_attrition
       FROM gabby.tableau.compliance_staff_attrition
       WHERE is_denominator = 1
      ) sub
  WHERE reporting_schoolid IS NOT NULL
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
             ,ISNULL(CONVERT(NVARCHAR(3),school_level), 'All') AS school_level
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
        ,ISNULL(CONVERT(NVARCHAR(3),school_level), 'All') AS school_level
        ,academic_year      
        ,reporting_term
        ,AVG(is_agree) AS pct_agree
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
             ,CASE 
               WHEN response_value >= 4 THEN 1.0
               WHEN response_value < 4 THEN 0.0
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
             ,ISNULL(CONVERT(VARCHAR(5),school_level), 'All') AS school_level
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

,student_level_rollup AS (  
  SELECT sub.academic_year
        ,ISNULL(sub.region,'All') AS region
        ,ISNULL(CONVERT(NVARCHAR(3),sub.school_level),'All') AS school_level
        ,ISNULL(sub.reporting_schoolid, 0) AS reporting_schoolid

        /* student-level percentages */
        ,CONVERT(FLOAT,AVG(sub.is_free_or_reduced)) AS free_or_reduced_pct
        ,CONVERT(FLOAT,AVG(sub.highest_act_composite_seniors)) AS act_composite_seniors_avg
        ,CONVERT(FLOAT,AVG(sub.highest_act_composite_juniors)) AS act_composite_juniors_avg
        ,CONVERT(FLOAT,AVG(sub.parcc_ela_proficient)) AS parcc_ela_proficient_pct
        ,CONVERT(FLOAT,AVG(sub.parcc_math_proficient)) AS parcc_math_proficient_pct
        ,CONVERT(FLOAT,AVG(sub.parcc_ela_proficient_iep)) AS parcc_ela_proficient_iep_pct
        ,CONVERT(FLOAT,AVG(sub.parcc_math_proficient_iep)) AS parcc_math_proficient_iep_pct
        ,CONVERT(FLOAT,AVG(sub.parcc_ela_approaching_iep)) AS parcc_ela_approaching_iep_pct
        ,CONVERT(FLOAT,AVG(sub.parcc_math_approaching_iep)) AS parcc_math_approaching_iep_pct
        ,CONVERT(FLOAT,AVG(sub.module_ela_is_mastery)) AS module_ela_mastery_pct
        ,CONVERT(FLOAT,AVG(sub.module_math_is_mastery)) AS module_math_mastery_pct
        ,CONVERT(FLOAT,AVG(sub.module_ela_is_parcc_predictive)) AS module_ela_parcc_predictive_pct
        ,CONVERT(FLOAT,AVG(sub.module_math_is_parcc_predictive)) AS module_math_parcc_predictive_pct
        ,CONVERT(FLOAT,AVG(sub.lit_meeting_goal)) AS lit_meeting_goal_pct
        ,CONVERT(FLOAT,AVG(sub.lit_making_1yr_growth)) AS lit_making_1yr_growth_pct
        ,CONVERT(FLOAT,AVG(sub.is_student_attrition)) AS student_attrition_pct

        /* student-level totals */
        ,CONVERT(FLOAT,SUM(sub.n_days_attendance) / SUM(sub.n_days_membership)) AS ada
        ,CONVERT(FLOAT,SUM(sub.n_OSS)) AS n_oss
        ,CONVERT(FLOAT,SUM(sub.n_ISS)) AS n_iss
  FROM
      (
       SELECT co.student_number      
             ,co.academic_year
             ,co.region
             ,co.school_level
             ,co.reporting_schoolid
             ,co.grade_level
             ,co.iep_status
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
             ,CASE WHEN co.grade_level <= 2 THEN modules.ela_is_mastery END AS module_ela_is_mastery 
             ,CASE WHEN co.grade_level <= 2 THEN modules.math_is_mastery END AS module_math_is_mastery 
             ,CASE 
               WHEN co.grade_level > 2 THEN NULL
               WHEN modules.ela_percent_correct >= 65 THEN 1.0 
               WHEN modules.ela_percent_correct < 65 THEN 0.0 
              END AS module_ela_is_parcc_predictive
             ,CASE 
               WHEN co.grade_level > 2 THEN NULL
               WHEN modules.math_percent_correct >= 65 THEN 1.0 
               WHEN modules.math_percent_correct < 65 THEN 0.0 
              END AS module_math_is_parcc_predictive

             /*Literacy */
             ,CONVERT(FLOAT,la.met_goal) AS lit_meeting_goal

             ,lg.is_making_1yr_growth AS lit_making_1yr_growth

             /* Attendance */
             ,ada.n_days_attendance
             ,ada.n_days_membership

             ,sus.OSS AS n_OSS
             ,sus.ISS AS n_ISS

             /* Attrition */
             ,sa.is_attrition AS is_student_attrition
       FROM gabby.powerschool.cohort_identifiers_static co
       LEFT OUTER JOIN act
         ON co.student_number = act.student_number
        AND co.academic_year >= act.academic_year
        AND act.rn_highest = 1
       LEFT OUTER JOIN parcc
         ON co.student_number = parcc.student_number
        AND co.academic_year = parcc.academic_year
       LEFT OUTER JOIN modules
         ON co.student_number = modules.student_number
        AND co.academic_year = modules.academic_year
        AND co.grade_level <= 2
       LEFT OUTER JOIN lit_achievement la
         ON co.student_number = la.student_number
        AND co.academic_year = la.academic_year
        AND la.rn_most_recent = 1
       LEFT OUTER JOIN lit_growth lg
         ON co.student_number = lg.student_number
        AND co.academic_year = lg.academic_year
       LEFT OUTER JOIN ada
         ON co.studentid = ada.studentid
        AND co.academic_year = ada.academic_year
       LEFT OUTER JOIN suspensions sus
         ON co.student_number = sus.student_number
        AND co.academic_year = sus.academic_year
       LEFT OUTER JOIN student_attrition sa
         ON co.student_number = sa.denominator_student_number
        AND co.academic_year = sa.denominator_academic_year
       WHERE co.reporting_schoolid NOT IN (999999, 5173)
         AND co.rn_year = 1
      ) sub
  GROUP BY sub.academic_year                              
          ,ROLLUP(sub.school_level, sub.region, sub.reporting_schoolid)
 )

,rollup_unpivoted AS (
  SELECT academic_year
        ,region
        ,school_level
        ,reporting_schoolid
        ,field
        ,value
  FROM
      (
       SELECT slr.academic_year
             ,slr.region
             ,slr.school_level
             ,slr.reporting_schoolid
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
             ,CONVERT(FLOAT,ta.pct_attrition) AS teacher_attrition_pct
             
             ,CONVERT(FLOAT,ekg.overallaverage) AS ekg_walkthough_overall_avg
             ,CONVERT(FLOAT,ekg.threecsaverage) AS ekg_walkthough_three_cs_avg

             /* Surveys */
             ,CONVERT(FLOAT,q12.avg_response_value) AS q12_response_avg      
     
             ,CONVERT(FLOAT,hsr.parent_pct_responded_positive) AS hsr_parent_positive_pct
             ,CONVERT(FLOAT,hsr.student_pct_responded_positive) AS hsr_student_positive_pct
     
             ,CONVERT(FLOAT,tntp.ici_percentile) AS ici_percentile
             ,CONVERT(FLOAT,tntp.is_top_quartile_learning_environment_score) AS learning_environment_score_top_quartile             
       FROM student_level_rollup slr
       LEFT OUTER JOIN teacher_attrition ta
         ON slr.reporting_schoolid = ta.reporting_schoolid
        AND slr.region = ta.region
        AND slr.school_level = ta.school_level
        AND slr.academic_year = ta.academic_year 
       LEFT OUTER JOIN q12
         ON slr.reporting_schoolid = q12.reporting_schoolid
        AND slr.region = q12.region
        AND slr.school_level = q12.school_level
        AND slr.academic_year = q12.academic_year
        AND q12.rn_most_recent = 1
       LEFT OUTER JOIN hsr
         ON slr.reporting_schoolid = hsr.reporting_schoolid
        AND slr.region = hsr.region
        AND slr.school_level = hsr.school_level
        AND slr.academic_year = hsr.academic_year
       LEFT OUTER JOIN tntp
         ON slr.reporting_schoolid = tntp.reporting_schoolid
        AND slr.region = tntp.region
        AND slr.school_level = tntp.school_level
        AND slr.academic_year = tntp.academic_year
        AND tntp.rn_most_recent = 1
       LEFT OUTER JOIN ekg_walkthrough ekg
         ON slr.reporting_schoolid = ekg.reporting_schoolid
        AND slr.region = ekg.region
        AND slr.school_level = ekg.school_level
        AND slr.academic_year = ekg.academic_year
      ) sub
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
      ,ru.field AS ekg_metric_field
      ,ru.value AS ekg_metric_value
      
      ,g.metric AS ekg_metric_label
      ,g.domain AS ekg_domain
      ,g.strand AS ekg_strand
      ,g.meeting
      ,g.unit
      ,g.direction
FROM rollup_unpivoted ru
LEFT OUTER JOIN gabby.ekg.goals g
  ON ru.field = g.field