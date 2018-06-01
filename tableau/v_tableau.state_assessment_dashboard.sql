USE gabby
GO

CREATE OR ALTER VIEW tableau.state_assessment_dashboard AS

WITH promo AS (
  SELECT student_number
        ,CASE WHEN [ES] IS NOT NULL THEN 1 ELSE 0 END AS attended_es
        ,CASE WHEN [MS] IS NOT NULL THEN 1 ELSE 0 END AS attended_ms
  FROM
      (
       SELECT student_number
             ,school_level
             ,grade_level
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE rn_school = 1
      ) sub
  PIVOT(
    MAX(grade_level)
    FOR school_level IN ([ES],[MS])
   ) p
 )

,external_prof AS (
  SELECT academic_year        
        ,test_code
        --,grade_level
        ,[NJ]
        ,[NPS]
        ,[CPS]
        ,[PARCC]        
  FROM
      (
       SELECT academic_year
             ,test_code COLLATE SQL_Latin1_General_CP1_CI_AS AS test_code
             --,grade_level
             ,entity COLLATE SQL_Latin1_General_CP1_CI_AS AS entity                          
             ,(SUM(proficient_count) / SUM(valid_scores)) * 100 AS pct_proficient
       FROM
           (
            SELECT academic_year                                    
                  ,test_code                                    
                  --,CASE
                  --  WHEN subgroup_type = 'GRADE - 06' THEN 6
                  --  WHEN subgroup_type = 'GRADE - 07' THEN 7
                  --  WHEN subgroup_type = 'GRADE - 08' THEN 8
                  --  WHEN subgroup_type = 'GRADE - 09' THEN 9
                  --  WHEN subgroup_type = 'GRADE - 10' THEN 10
                  --  WHEN subgroup_type = 'GRADE - 11' THEN 11
                  --  WHEN subgroup_type = 'GRADE - 12' THEN 12                    
                  --  WHEN test_code IN ('ELA03', 'MAT03') THEN 3
                  --  WHEN test_code IN ('ELA04', 'MAT04') THEN 4
                  --  WHEN test_code IN ('ELA05', 'MAT05') THEN 5
                  --  WHEN test_code IN ('ELA06', 'MAT06') THEN 6
                  --  WHEN test_code IN ('ELA07', 'MAT07') THEN 7
                  --  WHEN test_code IN ('ELA08', 'MAT08') THEN 8
                  --  WHEN test_code IN ('ELA09', 'MAT09') THEN 9
                  --  WHEN test_code IN ('ELA10', 'MAT10') THEN 10
                  --  WHEN test_code IN ('ELA11', 'MAT11') THEN 11
                  --  WHEN test_code IN ('ELA12', 'MAT12') THEN 12
                  -- END AS grade_level
                  ,CASE
                    WHEN district_code IS NULL THEN 'NJ'
                    WHEN district_code = 0680 THEN 'CPS'
                    WHEN district_code = 3570 THEN 'NPS'
                   END AS entity                  
                  ,valid_scores
                  ,((l_4_percent / 100) * valid_scores) + ((l_5_percent / 100) * valid_scores) AS proficient_count
            FROM gabby.njdoe.parcc
            WHERE school_code IS NULL
              AND (district_code IN (3570, 0680) OR district_code IS NULL)
              AND ((LEFT(test_code, 3) IN ('ELA', 'MAT') AND subgroup = 'TOTAL') OR ((LEFT(test_code, 3) IN ('ALG', 'GEO') AND subgroup = 'GRADE')))
           ) sub       
       GROUP BY academic_year
               ,test_code
               --,grade_level
               ,entity
      ) sub
  PIVOT(
    MAX(pct_proficient)
    FOR entity IN ([NJ]
                  ,[NPS]
                  ,[PARCC]
                  ,[CPS])
   ) p
 ) 

,ms_grad AS (
  SELECT student_number
        ,ms_attended
  FROM
      (
       SELECT student_number
             ,school_name AS ms_attended
             ,ROW_NUMBER() OVER(
                PARTITION BY student_number
                  ORDER BY exitdate DESC) AS rn
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE school_level = 'MS'
      ) sub
  WHERE rn = 1
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region      
      ,co.school_level     
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level 
      ,co.cohort
      ,co.entry_schoolid
      ,co.entry_grade_level
      ,co.enroll_status
      ,co.iep_status
      ,co.lep_status
      ,co.lunchstatus      
      
      ,'PARCC' AS test_type
      ,parcc.test_code
      ,parcc.subject      
      ,parcc.test_scale_score
      ,parcc.test_performance_level
      ,parcc.test_reading_csem AS test_standard_error
      ,CASE
        WHEN parcc.test_performance_level >= 4 THEN 1
        WHEN parcc.test_performance_level < 4 THEN 0
       END AS is_proficient

      ,ext.nj AS pct_prof_nj
      ,ext.nps AS pct_prof_nps
      ,ext.cps AS pct_prof_cps
      ,ext.parcc AS pct_prof_parcc       

      ,promo.attended_es
      ,promo.attended_ms

      ,ms.ms_attended
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.parcc.summative_record_file_clean parcc
  ON co.student_number = parcc.local_student_identifier
 AND co.academic_year = parcc.academic_year
LEFT OUTER JOIN external_prof ext
  ON co.academic_year = ext.academic_year
 AND parcc.test_code = ext.test_code
LEFT OUTER JOIN promo
  ON co.student_number = promo.student_number
LEFT JOIN ms_grad ms
  ON co.student_number = ms.student_number
WHERE co.rn_year = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region      
      ,co.school_level     
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level 
      ,co.cohort
      ,co.entry_schoolid
      ,co.entry_grade_level
      ,co.enroll_status
      ,co.iep_status
      ,co.lep_status
      ,co.lunchstatus      
      
      ,asa.test_type
      ,CONCAT(LEFT(asa.subject, 3), RIGHT(CONCAT('0', co.grade_level), 2)) AS test_code
      ,asa.subject      
      ,asa.scaled_score
      ,CASE
        WHEN asa.performance_level = 'Advanced Proficient' THEN 5
        WHEN asa.performance_level = 'Proficient' THEN 4
        WHEN asa.performance_level = 'Partially Proficient' THEN 1
       END AS performance_level
      ,NULL AS test_standard_error
      ,CASE
        WHEN asa.scaled_score = 0 THEN NULL
        WHEN asa.scaled_score >= 200 THEN 1
        WHEN asa.scaled_score < 200 THEN 0
       END AS is_proficient

      ,ext.nj AS pct_prof_nj
      ,ext.nps AS pct_prof_nps
      ,ext.cps AS pct_prof_cps
      ,ext.parcc AS pct_prof_parcc       

      ,promo.attended_es
      ,promo.attended_ms

      ,ms.ms_attended
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.njsmart.all_state_assessments asa
  ON co.student_number = asa.local_student_id
 AND co.academic_year = asa.academic_year
LEFT JOIN external_prof ext
  ON co.academic_year = ext.academic_year
 AND CONCAT(LEFT(asa.subject, 3), RIGHT(CONCAT('0', co.grade_level), 2)) = ext.test_code
LEFT JOIN promo
  ON co.student_number = promo.student_number
LEFT JOIN ms_grad ms
  ON co.student_number = ms.student_number
WHERE co.rn_year = 1