USE gabby
GO

ALTER VIEW nwea.best_baseline AS

WITH roster AS (
  SELECT student_number
        ,academic_year        
  FROM gabby.powerschool.cohort_identifiers_static
  WHERE schoolid != 999999
    AND rn_year = 1    
 )
 
,subj (measurementscale) AS (
  SELECT 'Mathematics' UNION
  SELECT 'Reading' UNION
  SELECT 'Language Usage' UNION
  SELECT 'Science - General Science'
 )

,roster_subj_scaffold AS ( 
  SELECT roster.student_number
        ,roster.academic_year
        ,subj.measurementscale
  FROM roster
  CROSS JOIN subj       
 )
  
SELECT sub.student_number
      ,sub.academic_year
      ,sub.measurementscale
      ,CASE
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.test_id
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.test_id
        ELSE map_spr.test_id
       END AS test_id
      ,CASE
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.term_name
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.term_name
        ELSE map_spr.term_name
       END AS term_name
      ,CASE
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN CAST(map_fall.test_ritscore AS INT)
        WHEN map_spr.test_ritscore IS NULL THEN CAST(map_fall.test_ritscore AS INT)
        ELSE CAST(map_spr.test_ritscore AS INT)
       END AS test_ritscore
      ,CASE 
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN CAST(map_fall.percentile_2015_norms AS INT)
        WHEN map_spr.test_ritscore IS NULL THEN CAST(map_fall.percentile_2015_norms AS INT)
        ELSE CAST(map_spr.percentile_2015_norms AS INT)
       END AS testpercentile
      ,CASE 
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.fall_to_spring_projected_growth
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.fall_to_spring_projected_growth
        ELSE map_spr.fall_to_spring_projected_growth
       END AS typical_growth_fallorspring_to_spring
      ,CASE 
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.ritto_reading_score
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.ritto_reading_score
        ELSE map_spr.ritto_reading_score
       END AS lexile_score
FROM roster_subj_scaffold sub
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers map_fall /* CURRENT YEAR FALL */
  ON sub.student_number = map_fall.student_id
 AND sub.academic_year = map_fall.academic_year 
 AND sub.measurementscale = map_fall.measurement_scale
 AND map_fall.rn_term_subj = 1 
 AND map_fall.term = 'Fall'
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers map_spr /* PREVIOUS YEAR SPRING */
  ON sub.student_number = map_spr.student_id
 AND sub.academic_year = map_spr.test_year 
 AND sub.measurementscale = map_spr.measurement_scale
 AND map_spr.rn_term_subj = 1
 AND map_spr.term = 'Spring'