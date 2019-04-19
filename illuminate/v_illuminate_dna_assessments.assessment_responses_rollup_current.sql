USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.assessment_responses_rollup_current AS

SELECT sub.student_id
      ,sub.academic_year
      ,sub.scope
      ,sub.subject_area
      ,sub.module_type
      ,sub.module_number
      ,sub.is_replacement
      ,sub.response_type
      ,sub.standard_id
      ,sub.standard_code
      ,sub.standard_description
      ,sub.domain_description

      ,MIN(sub.title) OVER(PARTITION BY sub.academic_year, sub.scope, sub.subject_area, sub.module_number, sub.grade_level_id) AS title
      ,MIN(sub.assessment_id) OVER(PARTITION BY sub.academic_year, sub.scope, sub.subject_area, sub.module_number, sub.grade_level_id) AS assessment_id
      ,MIN(sub.administered_at) OVER(PARTITION BY sub.academic_year, sub.scope, sub.subject_area, sub.module_number, sub.grade_level_id) AS administered_at      
      ,MIN(sub.performance_band_set_id) OVER(PARTITION BY sub.academic_year, sub.scope, sub.subject_area, sub.module_number, sub.grade_level_id, sub.response_type, sub.standard_id) AS performance_band_set_id
      
      ,sub.date_taken
      ,sub.points
      ,sub.percent_correct
FROM
    (
     SELECT student_id
           ,academic_year
           ,scope
           ,subject_area
           ,module_type
           ,module_number
           ,is_replacement
           ,response_type
           ,standard_id
           ,standard_code
           ,standard_description
           ,domain_description
        
           ,MIN(title) AS title
           ,MIN(assessment_id) AS assessment_id
           ,MIN(administered_at) AS administered_at
           ,MIN(performance_band_set_id) AS performance_band_set_id
           ,MIN(date_taken) AS date_taken
           ,MIN(grade_level_id) AS grade_level_id

           ,SUM(points) AS points
           ,ROUND((SUM(points) / SUM(points_possible)) * 100, 1) AS percent_correct
     FROM gabby.illuminate_dna_assessments.assessment_responses_long
     WHERE is_normed_scope = 1
       AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
     GROUP BY student_id
             ,academic_year
             ,scope
             ,subject_area
             ,module_type
             ,module_number
             ,is_replacement
             ,response_type
             ,standard_id
             ,standard_code
             ,standard_description
             ,domain_description
    ) sub