USE gabby
GO

ALTER VIEW illuminate_dna_assessments.student_assessment_scaffold AS

/* standard curriculum */
SELECT DISTINCT 
       a.assessment_id
      ,NULL AS title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,(a.academic_year - 1) AS academic_year
      ,CASE
        WHEN ds.code_translation NOT IN ('CMA - End-of-Module', 'CMA - Mid-Module') THEN NULL
        WHEN ds.code_translation = 'CMA - End-of-Module' THEN 'End-of-Module'
        WHEN ds.code_translation = 'CMA - Mid-Module' 
         AND PATINDEX('%Checkpoint [0-9]%', a.title) = 0
             THEN 'Mid-Module'
        ELSE SUBSTRING(a.title, PATINDEX('%Checkpoint [0-9]%', a.title), 12)
       END AS module_type
      ,CASE
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]/[0-9]%', a.title), 4)
        WHEN PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
        WHEN PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
       END AS module_number
           
      ,ds.code_translation AS scope           
      ,dsa.code_translation AS subject_area

      ,ssa.student_id
      
      ,0 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments a  
JOIN gabby.illuminate_codes.dna_scopes ds
  ON a.code_scope_id = ds.code_id
 AND ds.code_translation IN ('CMA - End-of-Module', 'CMA - Mid-Module')
JOIN gabby.illuminate_codes.dna_subject_areas dsa
  ON a.code_subject_area_id = dsa.code_id    
JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
  ON a.assessment_id = agl.assessment_id
JOIN gabby.illuminate_public.student_session_aff ssa
  ON a.administered_at BETWEEN ssa.entry_date AND ssa.leave_date
 AND agl.grade_level_id = ssa.grade_level_id
WHERE a.deleted_at IS NULL

UNION ALL

/* replacement curriculum */
SELECT DISTINCT 
       a.assessment_id
      ,NULL AS title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,(a.academic_year - 1) AS academic_year
      ,CASE
        WHEN ds.code_translation NOT IN ('CMA - End-of-Module', 'CMA - Mid-Module') THEN NULL
        WHEN ds.code_translation = 'CMA - End-of-Module' THEN 'End-of-Module'
        WHEN ds.code_translation = 'CMA - Mid-Module' 
         AND PATINDEX('%Checkpoint [0-9]%', a.title) = 0
             THEN 'Mid-Module'
        ELSE SUBSTRING(a.title, PATINDEX('%Checkpoint [0-9]%', a.title), 12)
       END AS module_type
      ,CASE
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]/[0-9]%', a.title), 4)
        WHEN PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
        WHEN PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
       END AS module_number
           
      ,ds.code_translation AS scope           
      ,dsa.code_translation AS subject_area

      ,ssa.student_id

      ,1 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments a  
JOIN gabby.illuminate_codes.dna_scopes ds
  ON a.code_scope_id = ds.code_id
 AND ds.code_translation IN ('CMA - End-of-Module', 'CMA - Mid-Module')
JOIN gabby.illuminate_codes.dna_subject_areas dsa
  ON a.code_subject_area_id = dsa.code_id    
JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
  ON a.assessment_id = agl.assessment_id
JOIN gabby.illuminate_public.student_session_aff ssa
  ON a.administered_at BETWEEN ssa.entry_date AND ssa.leave_date
 AND agl.grade_level_id != ssa.grade_level_id
JOIN gabby.illuminate_dna_assessments.students_assessments sa
  ON a.assessment_id = sa.assessment_id
 AND ssa.student_id = sa.student_id
WHERE a.deleted_at IS NULL

UNION ALL

/* all other assessments */
SELECT a.assessment_id
      ,a.title
      ,a.administered_at        
      ,a.performance_band_set_id
      ,(a.academic_year - 1) AS academic_year
      ,ds.code_translation AS module_type
      ,CASE
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]/[0-9]%', a.title), 4)
        WHEN PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
        WHEN PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
       END AS module_number
           
      ,ds.code_translation AS scope           
      ,dsa.code_translation AS subject_area

      ,sa.student_id

      ,0 AS is_replacement
FROM gabby.illuminate_dna_assessments.assessments a  
LEFT OUTER JOIN gabby.illuminate_codes.dna_scopes ds
  ON a.code_scope_id = ds.code_id
 AND ds.code_translation NOT IN ('CMA - End-of-Module', 'CMA - Mid-Module')
LEFT OUTER JOIN gabby.illuminate_codes.dna_subject_areas dsa
  ON a.code_subject_area_id = dsa.code_id    
LEFT OUTER JOIN gabby.illuminate_dna_assessments.students_assessments sa
  ON a.assessment_id = sa.assessment_id
WHERE (ds.code_translation NOT IN ('CMA - End-of-Module', 'CMA - Mid-Module') OR a.code_scope_id IS NULL)
  AND a.deleted_at IS NULL