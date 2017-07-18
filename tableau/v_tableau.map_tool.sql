USE gabby
GO

ALTER VIEW tableau.map_tool AS

WITH map_long AS (  
  SELECT base.student_number
        ,base.academic_year
        ,'Baseline' AS term                
        ,base.measurementscale
        ,base.test_id
        ,base.test_ritscore AS base_rit
        ,base.testpercentile AS base_pct        
        ,CONVERT(INT,CASE
          WHEN base.lexile_score IN ('BR','<100') THEN 0
          ELSE base.lexile_score
         END) AS base_lexile_score
        ,base.testpercentile AS pct
        ,base.test_ritscore AS rit      
        ,CONVERT(INT,CASE
          WHEN base.lexile_score IN ('BR','<100') THEN 0
          ELSE base.lexile_score
         END) AS lexile_score
        ,NULL AS testdurationminutes
  FROM gabby.nwea.best_baseline base
  
  UNION ALL
  
  SELECT base.student_number
        ,base.academic_year                   
        ,map.term
        ,base.measurementscale
        ,map.test_id
        ,base.test_ritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,CONVERT(INT,CASE
          WHEN base.lexile_score IN ('BR','<100') THEN 0
          ELSE base.lexile_score
         END) AS base_lexile_score
        ,map.percentile_2015_norms AS pct
        ,map.test_ritscore AS rit      
        ,CONVERT(INT,CASE
          WHEN map.ritto_reading_score IN ('BR','<100') THEN 0
          ELSE map.ritto_reading_score
         END) AS lexile_score
        ,map.test_duration_minutes
  FROM gabby.nwea.best_baseline base
  LEFT OUTER JOIN nwea.assessment_result_identifiers map
    ON base.student_number = map.student_id
   AND base.academic_year = map.academic_year
   AND base.measurementscale = map.measurement_scale
   AND map.rn_term_subj = 1
 )

SELECT r.academic_year
      ,r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.reporting_schoolid AS schoolid
      ,r.school_level
      ,r.grade_level
      ,r.cohort
      ,r.team        
      ,r.iep_status
      ,r.enroll_status      
      
      ,map_long.test_id
      ,map_long.term      
      ,map_long.measurementscale            
      ,map_long.base_rit
      ,map_long.base_pct
      ,map_long.base_lexile_score                 
      ,map_long.rit       
      ,map_long.pct       
      ,map_long.lexile_score
      ,map_long.testdurationminutes                 
           
      ,pct50.testritscore AS testritscore_50th_percentile
      ,pct75.testritscore AS testritscore_75th_percentile

      ,domain.test_name AS domain_testname
      ,ISNULL(domain.goal_number, 1) AS goal_number
      ,domain.name AS domain_name
      ,domain.ritscore
      ,domain.range      
      ,domain.adjective

      ,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY map_long.rit)
         OVER(PARTITION BY r.reporting_schoolid
                          ,r.grade_level
                          ,r.academic_year
                          ,map_long.term
                          ,map_long.measurementscale) AS median_rit
      ,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY map_long.pct)
         OVER(PARTITION BY r.reporting_schoolid
                          ,r.grade_level
                          ,r.academic_year
                          ,map_long.term
                          ,map_long.measurementscale) AS median_pct
      ,CASE 
        WHEN map_long.pct BETWEEN 0 AND 24 THEN 1
        WHEN map_long.pct BETWEEN 25 AND 49 THEN 2
        WHEN map_long.pct BETWEEN 50 AND 74 THEN 3
        WHEN map_long.pct >= 75 THEN 4                
       END AS term_quartile
FROM gabby.powerschool.cohort_identifiers_static r
LEFT OUTER JOIN map_long
  ON r.student_number = map_long.student_number
 AND r.academic_year = map_long.academic_year      
LEFT OUTER JOIN gabby.nwea.percentile_norms_dense pct50
  ON r.grade_level = pct50.grade_level
 AND CASE WHEN map_long.term = 'Baseline' THEN 'Fall' ELSE map_long.term END = pct50.term
 AND map_long.measurementscale = pct50.measurementscale
 AND pct50.testpercentile = 50
LEFT OUTER JOIN gabby.nwea.percentile_norms_dense pct75
  ON r.grade_level = pct75.grade_level
 AND CASE WHEN map_long.term = 'Baseline' THEN 'Fall' ELSE map_long.term END = pct75.term
 AND map_long.measurementscale = pct75.measurementscale
 AND pct75.testpercentile = 75
LEFT OUTER JOIN gabby.nwea.learning_continuum_goals domain
  ON r.student_number = domain.student_number
 AND map_long.test_id = domain.test_id
WHERE r.academic_year >= 2008 /* first year of MAP data */
  AND r.schoolid != 999999
  AND r.rn_year = 1