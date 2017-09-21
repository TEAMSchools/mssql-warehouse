USE gabby
GO

CREATE OR ALTER VIEW tableau.state_assessment_dashboard AS

WITH external_prof AS (
  SELECT academic_year        
        ,test_code
        ,grade_level
        ,[NJ]
        ,[NPS]
        ,[CPS]
        ,[PARCC]        
  FROM
      (
       SELECT academic_year
             ,test_code
             ,grade_level
             ,entity
             ,pct_proficient
       FROM gabby.parcc.external_proficiency_rates
       WHERE (test_code IN ('ALG01','ALG02','GEO01') AND grade_level IS NULL)
          OR (test_code NOT IN ('ALG01','ALG02','GEO01') AND grade_level IS NOT NULL)
      ) sub
  PIVOT(
    MAX(pct_proficient)
    FOR entity IN ([NJ]
                  ,[NPS]
                  ,[PARCC]
                  ,[CPS])
   ) p
 ) 

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region      
      ,co.school_level     
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level 
      ,co.enroll_status
      ,co.iep_status
      ,co.lep_status
      ,co.lunchstatus      
      
      ,'PARCC' AS test_type
      ,parcc.test_code
      ,parcc.subject      
      ,parcc.test_scale_score
      ,parcc.test_performance_level
      ,CASE
        WHEN parcc.test_performance_level >= 4 THEN 1
        WHEN parcc.test_performance_level < 4 THEN 0
       END AS is_proficient

      ,ext.nj AS pct_prof_nj
      ,ext.nps AS pct_prof_nps
      ,ext.cps AS pct_prof_cps
      ,ext.parcc AS pct_prof_parcc       
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.parcc.summative_record_file_clean parcc
  ON co.student_number = parcc.local_student_identifier
 AND co.academic_year = LEFT(parcc.assessment_year, 4)
LEFT OUTER JOIN external_prof ext
  ON co.academic_year = ext.academic_year
 AND parcc.test_code = ext.test_code
WHERE co.rn_year = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region      
      ,co.school_level     
      ,co.reporting_schoolid AS schoolid           
      ,co.grade_level 
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
      ,CASE
        WHEN asa.scaled_score = 0 THEN NULL
        WHEN asa.scaled_score >= 200 THEN 1
        WHEN asa.scaled_score < 200 THEN 0
       END AS is_proficient

      ,ext.nj AS pct_prof_nj
      ,ext.nps AS pct_prof_nps
      ,ext.cps AS pct_prof_cps
      ,ext.parcc AS pct_prof_parcc       
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.njsmart.all_state_assessments asa
  ON co.student_number = asa.local_student_id
 AND co.academic_year = asa.academic_year
LEFT OUTER JOIN external_prof ext
  ON co.academic_year = ext.academic_year
 AND CONCAT(LEFT(asa.subject, 3), RIGHT(CONCAT('0', co.grade_level), 2)) = ext.test_code
WHERE co.rn_year = 1