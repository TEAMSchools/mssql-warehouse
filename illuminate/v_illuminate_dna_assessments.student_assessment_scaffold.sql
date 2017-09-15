USE gabby
GO

ALTER VIEW illuminate_dna_assessments.student_assessment_scaffold AS

WITH normed_scopes (scope) AS (
  SELECT 'CMA - End-of-Module' UNION
  SELECT 'CMA - Mid-Module' UNION
  SELECT 'CGI Quiz' UNION
  SELECT 'Cold Read Quizzes' UNION
  SELECT 'Cumulative Review Quizzes' UNION
  SELECT 'Math Facts and Counting Jar'
) 

SELECT sub.assessment_id
      ,sub.title
      ,sub.administered_at
      ,sub.performance_band_set_id
      ,sub.academic_year
      ,CASE
        WHEN sub.scope NOT IN (SELECT scope FROM normed_scopes) THEN NULL
        WHEN sub.scope = 'CMA - End-of-Module' AND sub.academic_year <= 2016 THEN 'End-of-Module'
        WHEN sub.scope = 'CMA - End-of-Module' AND sub.academic_year > 2016 THEN 'Quarterly Assessment'        
        WHEN sub.scope IN ('Cold Read Quizzes', 'Cummulative Review Quizzes') THEN 'CRQ'
        WHEN sub.scope = 'CGI Quiz' THEN 'CGI'
        WHEN sub.scope = 'Math Facts and Counting Jar' THEN 'MFCJ'
        WHEN sub.scope = 'CMA - Mid-Module'
         AND PATINDEX('%Checkpoint [0-9]%', sub.title) = 0
         AND sub.academic_year <= 2016
             THEN 'Mid-Module'        
        WHEN sub.scope = 'CMA - Mid-Module' THEN SUBSTRING(sub.title, PATINDEX('%Checkpoint [0-9]%', sub.title), 12)
       END AS module_type
      ,CASE
        WHEN sub.scope NOT IN (SELECT scope FROM normed_scopes) THEN NULL
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]/[0-9]%', sub.title), 4)
        WHEN PATINDEX('%[MU][0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]%', sub.title), 2)
        WHEN PATINDEX('%QA[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%QA[0-9]%', sub.title), 3)
        WHEN PATINDEX('%CGI[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%CGI[0-9]%', sub.title), 4)        
        WHEN PATINDEX('%CRQ[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%CRQ[0-9]%', sub.title), 4)
       END AS module_number
      ,sub.scope
      ,sub.subject_area
      ,sub.student_id
      ,sub.is_replacement
FROM
    (
     /* standard curriculum */
     SELECT DISTINCT 
            a.assessment_id
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year
           
           ,ds.code_translation AS scope           
           ,dsa.code_translation AS subject_area

           ,ssa.student_id
      
           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
      AND ds.code_translation IN (SELECT scope FROM normed_scopes)
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
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year
           
           ,ds.code_translation AS scope           
           ,dsa.code_translation AS subject_area

           ,ssa.student_id

           ,1 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
      AND ds.code_translation IN (SELECT scope FROM normed_scopes)
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

           ,ds.code_translation AS scope           
           ,dsa.code_translation AS subject_area

           ,sa.student_id

           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     LEFT OUTER JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
     LEFT OUTER JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
     LEFT OUTER JOIN gabby.illuminate_dna_assessments.students_assessments sa
       ON a.assessment_id = sa.assessment_id
     WHERE (ds.code_translation NOT IN (SELECT scope FROM normed_scopes) OR a.code_scope_id IS NULL)
       AND a.deleted_at IS NULL
    ) sub