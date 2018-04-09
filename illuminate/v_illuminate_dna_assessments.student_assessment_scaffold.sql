USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.student_assessment_scaffold AS

SELECT sub.assessment_id
      ,sub.title
      ,sub.administered_at
      ,sub.performance_band_set_id
      ,sub.academic_year
      ,CASE        
        WHEN sub.scope = 'Process Piece' THEN 'PP'        
        WHEN sub.normed_scope IS NULL THEN NULL
        WHEN sub.scope = 'CMA - End-of-Module' AND sub.academic_year <= 2016 THEN 'EOM'
        WHEN sub.scope = 'CMA - End-of-Module' AND sub.academic_year > 2016 THEN 'QA'
        WHEN sub.scope IN ('Cold Read Quizzes', 'Cumulative Review Quizzes') THEN 'CRQ'
        WHEN sub.scope = 'CGI Quiz' THEN 'CGI'
        WHEN sub.scope = 'Math Facts and Counting Jar' THEN 'MFCJ'
        WHEN sub.scope = 'Checkpoint' THEN 'CP'
        WHEN sub.scope = 'CMA - Mid-Module' AND PATINDEX('%Checkpoint [0-9]%', sub.title) = 0 THEN 'MM'
        WHEN sub.scope = 'CMA - Mid-Module' AND PATINDEX('%Checkpoint [0-9]%', sub.title) > 0 
               THEN 'CP' + SUBSTRING(sub.title, PATINDEX('%Checkpoint [0-9]%', sub.title) + 11, 1)
       END AS module_type
      ,CASE
        WHEN sub.scope = 'Process Piece' AND PATINDEX('%QA[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%QA[0-9]%', sub.title), 3)
        WHEN sub.scope = 'Process Piece' AND PATINDEX('%[MU][0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]%', sub.title), 2)
        WHEN sub.normed_scope IS NULL THEN NULL
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]/[0-9]%', sub.title), 4)
        WHEN PATINDEX('%[MU][0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]%', sub.title), 2)
        WHEN PATINDEX('%QA[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%QA[0-9]%', sub.title), 3)
        WHEN PATINDEX('%CP[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%CP[0-9]%', sub.title), 3)
        WHEN PATINDEX('%MQ[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%MQ[0-9]%', sub.title), 3)
        WHEN PATINDEX('%CGI[0-9][0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%CGI[0-9]%', sub.title), 5)))
        WHEN PATINDEX('%CGI[0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%CGI[0-9]%', sub.title), 4)))
        WHEN PATINDEX('%CRQ[0-9][0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%CRQ[0-9]%', sub.title), 5)))
        WHEN PATINDEX('%CRQ[0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%CRQ[0-9]%', sub.title), 4)))
        WHEN PATINDEX('%MF[0-9][0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%MF[0-9]%', sub.title), 4)))
        WHEN PATINDEX('%MF[0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%MF[0-9]%', sub.title), 3)))
        WHEN PATINDEX('%CJ[0-9][0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%CJ[0-9]%', sub.title), 4)))
        WHEN PATINDEX('%CJ[0-9]%', sub.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(sub.title, PATINDEX('%CJ[0-9]%', sub.title), 3)))
       END AS module_number
      ,sub.scope
      ,sub.subject_area
      ,sub.student_id
      ,sub.is_replacement
FROM
    (
     /* standard curriculum -- K-8 */
     SELECT a.assessment_id
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year
           
           ,ds.code_translation AS scope           
           
           ,ns.scope AS normed_scope

           ,dsa.code_translation AS subject_area

           ,ssa.student_id           
      
           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id      
     JOIN gabby.illuminate_dna_assessments.normed_scopes ns
       ON ds.code_translation = ns.scope
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation IN ('Text Study','Mathematics','Social Studies','Science')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id       
     JOIN gabby.illuminate_public.student_session_aff_clean_static ssa
       ON a.academic_year = ssa.academic_year
      AND agl.grade_level_id = ssa.grade_level_id
      AND ssa.rn = 1
     JOIN gabby.illuminate_dna_assessments.course_enrollment_scaffold_static ce
       ON ssa.student_id = ce.student_id  
      AND a.academic_year = ce.academic_year 
      AND dsa.code_translation = ce.subject_area
      AND ce.is_advanced_math_student = 0      
     WHERE a.deleted_at IS NULL       

     UNION ALL

     /* standard curriculum -- HS */
     SELECT a.assessment_id
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year
           
           ,ds.code_translation AS scope           

           ,ns.scope AS normed_scope
      
           ,dsa.code_translation AS subject_area

           ,ce.student_id
      
           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
     JOIN gabby.illuminate_dna_assessments.normed_scopes ns
       ON ds.code_translation = ns.scope
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation IN ('Algebra I','Geometry','Algebra IIA','Algebra IIB','English 100','English 200','English 300','English 400')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id      
     JOIN gabby.illuminate_dna_assessments.course_enrollment_scaffold_static ce
       ON a.academic_year = ce.academic_year 
      AND agl.grade_level_id = ce.grade_level_id
      AND dsa.code_translation = ce.subject_area       
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
           
           ,ns.scope AS normed_scope

           ,dsa.code_translation AS subject_area

           ,sa.student_id

           ,1 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
     JOIN gabby.illuminate_dna_assessments.normed_scopes ns
       ON ds.code_translation = ns.scope
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation NOT IN ('Algebra I','Geometry','Algebra IIA','Algebra IIB','English 100','English 200','English 300','English 400')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id      
     JOIN gabby.illuminate_dna_assessments.students_assessments sa
       ON a.assessment_id = sa.assessment_id     
     JOIN gabby.illuminate_public.student_session_aff_clean_static ssa
       ON sa.student_id = ssa.student_id
      AND a.academic_year = ssa.academic_year
      AND agl.grade_level_id != ssa.grade_level_id            
      AND ssa.rn = 1
     WHERE a.deleted_at IS NULL       

     UNION ALL

     /* all other assessments */
     SELECT a.assessment_id
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year

           ,ds.code_translation AS scope           

           ,NULL AS normed_scope

           ,dsa.code_translation AS subject_area

           ,sa.student_id

           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     LEFT JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
     LEFT JOIN gabby.illuminate_dna_assessments.normed_scopes ns
       ON ds.code_translation = ns.scope
     LEFT JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
     LEFT JOIN gabby.illuminate_dna_assessments.students_assessments sa
       ON a.assessment_id = sa.assessment_id
     WHERE (ns.scope IS NULL OR a.code_scope_id IS NULL)
       AND a.deleted_at IS NULL
    ) sub