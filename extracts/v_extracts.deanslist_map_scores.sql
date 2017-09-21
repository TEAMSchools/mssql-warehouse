USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_map_scores AS

SELECT co.student_number      
      
      ,terms.term
      ,CASE 
        WHEN terms.term = 'Fall' THEN co.academic_year 
        ELSE (co.academic_year + 1)
       END AS test_year
      
      ,subjects.subject  
      
      ,map.percentile_2015_norms AS map_percentile
      ,map.test_ritscore AS map_ritscore
      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number
                     ,subjects.subject
           ORDER BY CASE 
                     WHEN terms.term = 'Fall' THEN co.academic_year 
                     ELSE (co.academic_year + 1)
                    END
                   ,CASE                      
                     WHEN terms.term = 'Winter' THEN 1
                     WHEN terms.term = 'Spring' THEN 2
                     WHEN terms.term = 'Fall' THEN 3
                    END) AS map_index
FROM gabby.powerschool.cohort_identifiers_static co
CROSS JOIN (
  SELECT 'Fall' UNION  
  SELECT 'Winter' UNION
  SELECT 'Spring'
 ) terms (term)
CROSS JOIN (
  SELECT 'Mathematics' UNION  
  SELECT 'Reading' UNION
  SELECT 'Science - General Science' UNION
  SELECT 'Language Usage'
 ) subjects (subject)
LEFT OUTER JOIN gabby.nwea.assessment_result_identifiers map 
  ON co.student_number = map.student_id
 AND co.academic_year  = map.student_id
 AND terms.term = map.term
 AND subjects.subject = map.measurement_scale
 AND map.rn_term_subj = 1
WHERE co.grade_level <= 8
  AND co.enroll_status = 0
  AND co.rn_year = 1