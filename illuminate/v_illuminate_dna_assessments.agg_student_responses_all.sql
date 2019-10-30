USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.agg_student_responses_all AS

SELECT assessment_id
      ,academic_year    
      ,administered_at
      ,date_taken
      ,title
      ,scope
      ,subject_area
      ,module_type
      ,module_number    
      ,response_type
      ,standard_id      
      ,points
      ,percent_correct
      ,is_replacement           
      ,local_student_id
      ,standard_code
      ,standard_description
      ,domain_description
      ,term_administered
      ,term_taken
      ,performance_band_set_id
      ,performance_band_number
      ,is_mastery
      ,is_normed_scope
FROM gabby.illuminate_dna_assessments.agg_student_responses_all_current
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT assessment_id
      ,academic_year    
      ,administered_at
      ,date_taken
      ,title
      ,scope
      ,subject_area
      ,module_type
      ,module_number    
      ,response_type
      ,standard_id      
      ,points
      ,percent_correct
      ,is_replacement           
      ,local_student_id
      ,standard_code
      ,standard_description
      ,domain_description
      ,term_administered
      ,term_taken
      ,performance_band_set_id
      ,performance_band_number
      ,is_mastery
      ,is_normed_scope
FROM gabby.illuminate_dna_assessments.agg_student_responses_all_archive