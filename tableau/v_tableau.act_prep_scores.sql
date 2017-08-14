USE gabby
GO

ALTER VIEW tableau.act_prep_scores AS

WITH real_tests AS (
  SELECT student_number      
        ,test_date
        ,scale_score
        ,CONCAT(LEFT(DATENAME(MONTH,test_date),3), ' ''', RIGHT(DATEPART(YEAR,test_date),2)) AS administration_round        
        ,CASE WHEN act_subject = 'math' THEN 'Mathematics' ELSE act_subject END AS act_subject        
  FROM gabby.naviance.act_scores_clean
  UNPIVOT(
    scale_score
    FOR act_subject IN (English
                       ,Math
                       ,Reading
                       ,Science
                       ,Composite)
   ) u
  WHERE rn_highest = 1
 )

SELECT co.academic_year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.iep_status
      ,co.enroll_status
	     ,co.advisor_name

      ,'PREP' AS ACT_type
      ,act.assessment_id
      ,act.assessment_title      
      ,act.administration_round
      ,act.administered_at AS test_date
      ,act.subject_area
      ,act.overall_percent_correct
      ,act.overall_number_correct
      ,act.scale_score      
      ,act.prev_scale_score
      ,act.pretest_scale_score
      ,act.growth_from_pretest
      ,act.overall_performance_band
      ,act.standard_code
      ,act.standard_description
      ,act.standard_percent_correct      
      ,act.standard_strand      
      ,act.rn_dupe AS rn_assessment /* 1 row per student, per test (overall) */      
      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year, act.administration_round, act.subject_area, act.standard_code
           ORDER BY act.student_number) AS rn_assessment_standard /* 1 row per student, per test (by standard) */      
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT OUTER JOIN gabby.act.test_prep_scores act 
  ON co.student_number = act.student_number
 AND co.academic_year = act.academic_year 
WHERE co.rn_year = 1
  AND co.schoolid = 73253
  AND co.grade_level != 99
  AND co.academic_year >= 2015 /* 1st year with ACT prep */  

UNION ALL

SELECT co.academic_year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.iep_status
      ,co.enroll_status
	     ,co.advisor_name

      ,'REAL' AS ACT_type
      ,NULL AS assessment_id
      ,NULL AS assessment_title
      ,CONVERT(NVARCHAR,co.cohort) AS administration_round
      ,r.test_date
      ,r.act_subject AS subject_area
      ,NULL AS overall_percent_correct
      ,NULL AS overall_number_correct
      ,r.scale_score
      ,NULL AS prev_scale_score
      ,NULL AS pretest_scale_score
      ,NULL AS growth_from_pretest
      ,NULL AS overall_performance_band
      ,NULL AS standard_code
      ,NULL AS standard_description
      ,NULL AS standard_percent_correct      
      ,NULL AS standard_strand
      
      ,1 AS rn_assessment
      ,1 AS rn_assessment_standard
FROM gabby.powerschool.cohort_identifiers_static co
JOIN real_tests r
  ON co.student_number = r.student_number
WHERE co.schoolid = 73253
  AND co.rn_school = 1