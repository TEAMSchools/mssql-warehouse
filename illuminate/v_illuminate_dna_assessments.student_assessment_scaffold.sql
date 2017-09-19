USE gabby
GO

ALTER VIEW illuminate_dna_assessments.student_assessment_scaffold AS

WITH advanced_math AS (
  SELECT ssc.student_id
        ,ssc.academic_year      
        ,ssc.grade_level_id

        ,CASE
          WHEN c.school_course_id IN ('MATH10','MATH15','MATH71','MATH10ICS','MATH12','MATH12ICS','MATH14','MATH16','M415') THEN 'Algebra I'        
          WHEN c.school_course_id IN ('MATH20','MATH25','MATH31','MATH73','MATH20ICS') THEN 'Geometry'
          WHEN c.school_course_id IN ('MATH32','MATH35','MATH32A','MATH32B','MATH32HA') THEN 'Algebra II'
         END AS subject_area
        
        ,ROW_NUMBER() OVER(        
           PARTITION BY ssc.student_id, ssc.academic_year, CASE
                                                            WHEN c.school_course_id IN ('MATH10','MATH15','MATH71','MATH10ICS','MATH12','MATH12ICS','MATH14','MATH16','M415') THEN 'Algebra I'        
                                                            WHEN c.school_course_id IN ('MATH20','MATH25','MATH31','MATH73','MATH20ICS') THEN 'Geometry'
                                                            WHEN c.school_course_id IN ('MATH32','MATH35','MATH32A','MATH32B','MATH32HA') THEN 'Algebra II'
                                                           END
             ORDER BY entry_date DESC, leave_date DESC) AS rn
  FROM gabby.illuminate_matviews.ss_cube ssc  
  JOIN gabby.illuminate_public.courses c
    ON ssc.course_id = c.course_id 
   AND c.department_id = 1   
 )

SELECT sub.assessment_id
      ,sub.title
      ,sub.administered_at
      ,sub.performance_band_set_id
      ,sub.academic_year
      ,CASE
        WHEN sub.scope NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes) THEN NULL
        WHEN sub.scope = 'CMA - End-of-Module' AND sub.academic_year <= 2016 THEN 'End-of-Module'
        WHEN sub.scope = 'CMA - End-of-Module' AND sub.academic_year > 2016 THEN 'Quarterly Assessment'        
        WHEN sub.scope IN ('Cold Read Quizzes', 'Cumulative Review Quizzes') THEN 'CRQ'
        WHEN sub.scope = 'CGI Quiz' THEN 'CGI'
        WHEN sub.scope = 'Math Facts and Counting Jar' THEN 'MFCJ'
        WHEN sub.scope = 'CMA - Mid-Module'
         AND PATINDEX('%Checkpoint [0-9]%', sub.title) = 0
         AND sub.academic_year <= 2016
             THEN 'Mid-Module'        
        WHEN sub.scope = 'CMA - Mid-Module' THEN SUBSTRING(sub.title, PATINDEX('%Checkpoint [0-9]%', sub.title), 12)
       END AS module_type
      ,CASE
        WHEN sub.scope NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes) THEN NULL
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]/[0-9]%', sub.title), 4)
        WHEN PATINDEX('%[MU][0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%[MU][0-9]%', sub.title), 2)
        WHEN PATINDEX('%QA[0-9]%', sub.title) > 0 THEN SUBSTRING(sub.title, PATINDEX('%QA[0-9]%', sub.title), 3)
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
     /* standard curriculum -- not math */
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
      AND ds.code_translation IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation NOT IN ('Mathematics','Algebra I','Geometry','Algebra II')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id
     JOIN gabby.illuminate_public.student_session_aff ssa
       ON a.administered_at BETWEEN ssa.entry_date AND ssa.leave_date
      AND agl.grade_level_id = ssa.grade_level_id
     WHERE a.deleted_at IS NULL

     UNION ALL

     /* standard curriculum -- K-8 math */
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
      AND ds.code_translation IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation = 'Mathematics'
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id
     JOIN gabby.illuminate_public.student_session_aff ssa
       ON a.administered_at BETWEEN ssa.entry_date AND ssa.leave_date
      AND agl.grade_level_id = ssa.grade_level_id     
      AND ssa.student_id NOT IN (SELECT student_id FROM advanced_math WHERE rn = 1 AND subject_area IS NOT NULL)
     WHERE a.deleted_at IS NULL

     UNION ALL

     /* standard curriculum -- advanced math */
     SELECT DISTINCT 
            a.assessment_id
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year
           
           ,ds.code_translation AS scope           
           ,dsa.code_translation AS subject_area

           ,am.student_id
      
           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
      AND ds.code_translation IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation IN ('Algebra I','Geometry','Algebra II')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id
     JOIN advanced_math am
       ON a.academic_year = am.academic_year
      AND agl.grade_level_id = am.grade_level_id
      AND dsa.code_translation = am.subject_area
      AND am.rn = 1
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
      AND ds.code_translation IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
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
     WHERE (ds.code_translation NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes) OR a.code_scope_id IS NULL)
       AND a.deleted_at IS NULL
    ) sub