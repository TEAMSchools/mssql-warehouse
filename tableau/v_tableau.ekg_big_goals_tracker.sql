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
             ,LEFT(assessment_year, 4) AS academic_year
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
  FROM gabby.lit.achieved_by_round_static
  WHERE is_curterm = 1
 )

,lit_growth AS (
  SELECT student_number
        ,academic_year      
        ,CASE        
          WHEN MAX(CASE WHEN rn_curr = 1 THEN gleq END) - MAX(CASE WHEN rn_base = 1 THEN gleq END) >= 1 THEN 1
          WHEN MAX(CASE WHEN rn_curr = 1 THEN gleq END) - MAX(CASE WHEN rn_base = 1 THEN gleq END) < 1 THEN 0
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
         AND start_date <= CONVERT(DATE,GETDATE())
      ) sub
  GROUP BY student_number
          ,academic_year
  HAVING COUNT(gleq) > 1 /* return only students with > 1 term */
 ) 

,ada AS (
  SELECT studentid
        ,(yearid + 1990) AS academic_year
        ,SUM(attendancevalue) AS n_days_attendance
        ,SUM(membershipvalue) AS n_days_membership
  FROM gabby.powerschool.ps_adaadm_daily_ctod_static
  WHERE membershipvalue > 0
  GROUP BY studentid
          ,(yearid + 1990)
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
      
        ,CASE WHEN n.student_number IS NULL THEN 1.0 ELSE 0.0 END AS is_attrition
  FROM
      (
       SELECT student_number     
             ,academic_year
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE DATEFROMPARTS(academic_year, 10, 1) BETWEEN entrydate AND exitdate
      ) d
  LEFT OUTER JOIN gabby.powerschool.cohort_identifiers_static n
    ON d.student_number = n.student_number
   AND d.academic_year = (n.academic_year - 1)
   AND DATEFROMPARTS(n.academic_year, 10, 1) BETWEEN n.entrydate AND n.exitdate
 )

,q12 AS (
  SELECT reporting_schoolid
        ,academic_year
        ,reporting_term
        ,AVG(response_value) AS avg_response_value
      
        ,ROW_NUMBER() OVER(
           PARTITION BY reporting_schoolid, academic_year
             ORDER BY reporting_term DESC) AS rn_most_recent
  FROM
      (
       SELECT CASE 
               WHEN location = 'TEAM' THEN 133570965
               WHEN location = 'Life Lower' THEN 73257
               WHEN location = 'Life Upper' THEN 73257
               WHEN location = 'NCA' THEN 73253
               WHEN location = 'Revolution' THEN 179901
               WHEN location = 'Rise' THEN 73252
               WHEN location = 'Seek' THEN 73256
               WHEN location = 'SPARK' THEN 73254
               WHEN location = 'TEAM' THEN 133570965
               WHEN location = 'THRIVE' THEN 73255
              END AS reporting_schoolid
             ,academic_year
             ,reporting_term
             ,response_value
       FROM gabby.surveys.r9engagement_survey_detail
       WHERE competency = 'Q12'
      ) sub
  WHERE reporting_schoolid IS NOT NULL
  GROUP BY reporting_schoolid, academic_year, reporting_term
 )

,tntp AS (
  SELECT reporting_schoolid
        ,academic_year
        ,[ICI Percentile] AS ici_percentile
        ,CASE WHEN [Learning Environment Score] >= [Learning Environment Score: Top-Quartile] THEN 1 ELSE 0 END AS is_top_quartile_learning_environment_score

        ,ROW_NUMBER() OVER(
           PARTITION BY reporting_schoolid, academic_year
             ORDER BY survey_round DESC) AS rn_most_recent
  FROM
      (
       SELECT CASE
               WHEN school IN ('KIPP Rise Academy', 'Rise Academy') THEN 73252
               WHEN school IN ('KIPP Newark Collegiate Academy', 'Newark Collegiate Academy') THEN 73253
               WHEN school IN ('KIPP SPARK Academy', 'SPARK Academy') THEN 73254
               WHEN school IN ('KIPP THRIVE Academy', 'THRIVE Academy') THEN 73255
               WHEN school IN ('KIPP Seek Academy', 'Seek Academy') THEN 73256
               WHEN school IN ('KIPP Life Academy', 'Life Academy - Lower', 'Life Academy - Upper', 'Life Academy at Bragaw') THEN 73257
               WHEN school IN ('BOLD Academy', 'KIPP BOLD Academy') THEN 73258
               WHEN school IN ('KIPP Lanning Square Primary', 'KIPP Lanning Square Primary School', 'Revolution Primary') THEN 179901
               WHEN school IN ('KIPP TEAM Academy', 'TEAM Academy') THEN 133570965
               WHEN school = 'KIPP Lanning Square Middle School' THEN 179902
               WHEN school = 'KIPP Whittier Middle School' THEN 179903
               WHEN school = 'KIPP Whittier Elementary' THEN 1799015075        
               WHEN school = 'KIPP Pathways' THEN 732574573
              END AS reporting_schoolid
             ,academic_year
             ,survey_round      
             ,field
             ,value      
       FROM gabby.tntp.teacher_survey_school_sorter
       WHERE field IN ('Learning Environment Score', 'ICI Percentile')

       UNION ALL

       SELECT CASE
               WHEN school IN ('KIPP Rise Academy', 'Rise Academy') THEN 73252
               WHEN school IN ('KIPP Newark Collegiate Academy', 'Newark Collegiate Academy') THEN 73253
               WHEN school IN ('KIPP SPARK Academy', 'SPARK Academy') THEN 73254
               WHEN school IN ('KIPP THRIVE Academy', 'THRIVE Academy') THEN 73255
               WHEN school IN ('KIPP Seek Academy', 'Seek Academy') THEN 73256
               WHEN school IN ('KIPP Life Academy', 'Life Academy - Lower', 'Life Academy - Upper', 'Life Academy at Bragaw') THEN 73257
               WHEN school IN ('BOLD Academy', 'KIPP BOLD Academy') THEN 73258
               WHEN school IN ('KIPP Lanning Square Primary', 'KIPP Lanning Square Primary School', 'Revolution Primary') THEN 179901
               WHEN school IN ('KIPP TEAM Academy', 'TEAM Academy') THEN 133570965
               WHEN school = 'KIPP Lanning Square Middle School' THEN 179902
               WHEN school = 'KIPP Whittier Middle School' THEN 179903
               WHEN school = 'KIPP Whittier Elementary' THEN 1799015075        
               WHEN school = 'KIPP Pathways' THEN 732574573
              END AS reporting_schoolid
             ,academic_year
             ,survey_round      
             ,CONCAT(field, ': Top-Quartile')
             ,MAX(CASE 
                   WHEN school IN ('National Charter Top-Quartile Average'
                                  ,'National Charters Top Quartile Average'
                                  ,'KIPP Foundation Top Quartile'
                                  ,'KIPP Top Quartile Schools'
                                  ,'KIPP Network Top Quartile')
                          THEN value 
                  END) OVER(PARTITION BY academic_year, survey_round, field) AS value
       FROM gabby.tntp.teacher_survey_school_sorter
       WHERE field = 'Learning Environment Score'
      ) sub
  PIVOT(
    MAX(value)
    FOR field IN ([ICI Percentile], [Learning Environment Score], [Learning Environment Score: Top-Quartile])
   ) p
  WHERE reporting_schoolid IS NOT NULL
 )

,teacher_attrition AS (
  SELECT reporting_schoolid
        ,academic_year
        ,AVG(CONVERT(FLOAT,is_attrition)) AS pct_attrition
  FROM
      (
       SELECT CASE
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
             ,academic_year
             ,is_attrition
       FROM gabby.tableau.compliance_staff_attrition
       WHERE is_denominator = 1
      ) sub
  WHERE reporting_schoolid IS NOT NULL
  GROUP BY reporting_schoolid, academic_year
 )

,manager_survey AS (
  SELECT reporting_schoolid
        ,academic_year      
        ,AVG(is_agree) AS pct_agree
        ,ROW_NUMBER() OVER(
           PARTITION BY reporting_schoolid, academic_year
             ORDER BY reporting_term DESC) AS rn_most_recent
  FROM
      (
       SELECT CASE
               WHEN subject_location = 'Rise Academy' THEN 73252
               WHEN subject_location = 'Newark Collegiate Academy' THEN 73253
               WHEN subject_location = 'SPARK Academy' THEN 73254
               WHEN subject_location = 'THRIVE Academy' THEN 73255
               WHEN subject_location = 'Seek Academy' THEN 73256
               WHEN subject_location = 'Life Academy' THEN 73257
               WHEN subject_location = 'Bold Academy' THEN 73258
               WHEN subject_location = 'Lanning Square Primary' THEN 179901
               WHEN subject_location = 'Lanning Square MS' THEN 179902
               WHEN subject_location = 'Whittier Middle' THEN 179903
               WHEN subject_location = 'TEAM Academy' THEN 133570965
               WHEN subject_location = 'Pathways' THEN 732574573
              END AS reporting_schoolid
             ,academic_year
             ,reporting_term
             ,CASE 
               WHEN response_value >= 4 THEN 1.0
               WHEN response_value < 4 THEN 0.0
              END AS is_agree
       FROM gabby.surveys.manager_survey_detail
      ) sub
  WHERE reporting_schoolid IS NOT NULL
  GROUP BY reporting_schoolid, academic_year, reporting_term
 )

,hsr AS (
  SELECT schoolid
        ,academic_year
        ,[parent] AS parent_pct_responded_positive
        ,[student] AS student_pct_responded_positive
  FROM
      (
       SELECT schoolid
             ,academic_year
             ,role      
             ,SUM(school_responsed_positive) / SUM(school_responded) AS pct_responded_positive
       FROM
           (
            SELECT CASE
                    WHEN school IN ('KIPP Rise Academy','Rise Academy, a KIPP school') THEN 73252
                    WHEN school IN ('KIPP Newark Collegiate Academy','Newark Collegiate Academy, a KIPP school') THEN 73253
                    WHEN school IN ('KIPP SPARK Academy','SPARK Academy, a KIPP school') THEN 73254
                    WHEN school IN ('KIPP THRIVE Academy','THRIVE Academy, a KIPP school') THEN 73255
                    WHEN school IN ('KIPP Seek Academy','Seek Academy, a KIPP school') THEN 73256
                    WHEN school IN ('KIPP Life Academy','Life Academy at Bragaw, a KIPP school') THEN 73257
                    WHEN school IN ('KIPP BOLD Academy') THEN 73258
                    WHEN school IN ('KIPP Lanning Square Primary','Revolution Primary, a KIPP school') THEN 179901
                    WHEN school IN ('KIPP Lanning Square Middle School') THEN 179902
                    WHEN school IN ('KIPP TEAM Academy','TEAM Academy, a KIPP school') THEN 133570965
                   END AS schoolid
                  ,CONVERT(INT,LEFT(school_year, 4)) AS academic_year
                  ,role                  
                  ,school_responded
                  ,ROUND((likert_4_ * school_responded) + (likert_5_ * school_responded), 0) AS school_responsed_positive      
            FROM gabby.surveys.hsr_surveys
            WHERE role IN ('Parent','Student')
           ) sub
       GROUP BY schoolid
               ,academic_year
               ,role
      ) sub
  PIVOT(
    MAX(pct_responded_positive)
    FOR role IN ([parent],[student])
   ) p
 )

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
      ,CASE WHEN parcc.ela_performance_level >= 4 THEN 1.0 ELSE 0.0 END AS parcc_ela_proficient
      ,CASE WHEN parcc.math_performance_level >= 4 THEN 1.0 ELSE 0.0 END AS parcc_math_proficient
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
      ,modules.ela_is_mastery AS module_ela_is_mastery 
      ,modules.math_is_mastery AS module_math_is_mastery 
      ,CASE 
        WHEN modules.ela_percent_correct >= 65 THEN 1.0 
        WHEN modules.ela_percent_correct < 65 THEN 0.0 
       END AS module_ela_is_parcc_predictive
      ,CASE 
        WHEN modules.math_percent_correct >= 65 THEN 1.0 
        WHEN modules.math_percent_correct < 65 THEN 0.0 
       END AS module_math_is_parcc_predictive

      /*Literacy */
      ,la.met_goal AS lit_meeting_goal

      ,lg.is_making_1yr_growth AS lit_making_1yr_growth

      /* Attendance */
      ,ada.n_days_attendance
      ,ada.n_days_membership

      ,sus.OSS AS n_OSS
      ,sus.ISS AS n_ISS

      /* Attrition */
      ,sa.is_attrition AS is_student_attrition

      ,ta.pct_attrition AS pct_teacher_attrition

      /* Surveys */
      ,q12.avg_response_value
      
      ,hsr.parent_pct_responded_positive
      ,hsr.student_pct_responded_positive

      ,tntp.ici_percentile
      ,tntp.is_top_quartile_learning_environment_score
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
LEFT OUTER JOIN lit_achievement la
  ON co.student_number = la.student_number
 AND co.academic_year = la.academic_year
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
LEFT OUTER JOIN teacher_attrition ta
  ON co.reporting_schoolid = ta.reporting_schoolid
 AND co.academic_year = ta.academic_year
LEFT OUTER JOIN q12
  ON co.reporting_schoolid = q12.reporting_schoolid
 AND co.academic_year = q12.academic_year
 AND q12.rn_most_recent = 1
LEFT OUTER JOIN hsr
  ON co.reporting_schoolid = hsr.schoolid
 AND co.academic_year = hsr.academic_year
LEFT OUTER JOIN tntp
  ON co.reporting_schoolid = tntp.reporting_schoolid
 AND co.academic_year = tntp.academic_year
 AND tntp.rn_most_recent = 1
WHERE co.schoolid != 999999
  AND co.rn_year = 1