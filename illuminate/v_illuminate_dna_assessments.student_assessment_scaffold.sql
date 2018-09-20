USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.student_assessment_scaffold AS

/* standard curriculum -- K-8 */
SELECT a.assessment_id
      ,a.title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,a.academic_year_clean AS academic_year                      
      ,a.module_type
      ,a.module_number
      ,a.scope           
      ,a.subject_area

      ,ssa.student_id           
      
      ,0 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments_identifiers a            
JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
  ON a.assessment_id = agl.assessment_id       
JOIN gabby.illuminate_public.student_session_aff_clean_static ssa
  ON a.academic_year = ssa.academic_year
 AND agl.grade_level_id = ssa.grade_level_id
JOIN gabby.illuminate_dna_assessments.course_enrollment_scaffold_static ce
  ON ssa.student_id = ce.student_id  
 AND a.academic_year = ce.academic_year 
 AND a.subject_area = ce.subject_area
 AND ce.is_advanced_math_student = 0      
WHERE a.subject_area IN ('Text Study','Mathematics','Social Studies','Science')     
  AND a.deleted_at IS NULL
  AND a.normed_scope IS NOT NULL

UNION ALL

/* standard curriculum -- HS */
SELECT a.assessment_id
      ,a.title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,a.academic_year_clean AS academic_year                      
      ,a.module_type
      ,a.module_number
      ,a.scope           
      ,a.subject_area

      ,ce.student_id
      
      ,0 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments_identifiers a            
JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
  ON a.assessment_id = agl.assessment_id      
JOIN gabby.illuminate_dna_assessments.course_enrollment_scaffold_static ce
  ON a.academic_year = ce.academic_year 
 AND agl.grade_level_id = ce.grade_level_id
 AND a.subject_area = ce.subject_area       
WHERE a.subject_area IN ('Algebra I','Geometry','Algebra IIA','Algebra IIB','English 100','English 200','English 300','English 400')  
  AND a.deleted_at IS NULL
  AND a.normed_scope IS NOT NULL

UNION ALL

/* replacement curriculum */
SELECT DISTINCT 
       a.assessment_id
      ,a.title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,a.academic_year_clean AS academic_year                      
      ,a.module_type
      ,a.module_number
      ,a.scope           
      ,a.subject_area

      ,sa.student_id

      ,1 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments_identifiers a            
JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
  ON a.assessment_id = agl.assessment_id      
JOIN gabby.illuminate_dna_assessments.students_assessments sa
  ON a.assessment_id = sa.assessment_id     
JOIN gabby.illuminate_public.student_session_aff_clean_static ssa
  ON sa.student_id = ssa.student_id
 AND a.academic_year = ssa.academic_year
 AND agl.grade_level_id != ssa.grade_level_id      
WHERE a.subject_area NOT IN ('Algebra I','Geometry','Algebra IIA','Algebra IIB','English 100','English 200','English 300','English 400')
  AND a.deleted_at IS NULL
  AND a.normed_scope IS NOT NULL

UNION ALL

/* all other assessments */
SELECT a.assessment_id
      ,a.title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,a.academic_year_clean AS academic_year           
      ,a.module_type
      ,a.module_number     
      ,a.scope      
      ,a.subject_area

      ,sa.student_id

      ,0 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments_identifiers a       
LEFT JOIN gabby.illuminate_dna_assessments.students_assessments sa
  ON a.assessment_id = sa.assessment_id
WHERE a.deleted_at IS NULL
  AND a.normed_scope IS NULL