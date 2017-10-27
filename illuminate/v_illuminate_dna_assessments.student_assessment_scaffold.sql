USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.student_assessment_scaffold AS

WITH course_enrollments AS (
  SELECT student_id
        ,academic_year
        ,grade_level_id
        ,credittype
        ,subject_area
        ,MAX(is_advanced_math) OVER(PARTITION BY student_id, academic_year, credittype) AS is_advanced_math_student
        ,ROW_NUMBER() OVER(        
           PARTITION BY student_id, academic_year, credittype, subject_area
             ORDER BY entry_date DESC, leave_date DESC) AS rn
  FROM
      (
       /* K-4 enrollments */
       SELECT ssc.student_id
             ,ssc.academic_year      
             ,ssc.grade_level_id
             ,ssc.entry_date
             ,ssc.leave_date
             
             ,'Text Study' AS subject_area
             ,'ENG' AS credittype
             ,0 AS is_advanced_math
       FROM gabby.powerschool.course_enrollments_static enr
       JOIN gabby.illuminate_public.students ils
         ON enr.student_number = ils.local_student_id
       JOIN gabby.illuminate_public.courses c
         ON enr.course_number = c.school_course_id
       JOIN gabby.illuminate_matviews.ss_cube ssc
         ON ils.student_id = ssc.student_id
        AND c.course_id = ssc.course_id
        AND (enr.academic_year + 1) = ssc.academic_year
        AND ssc.grade_level_id <= 5
       WHERE enr.course_enroll_status = 0
         AND enr.section_enroll_status = 0
         AND enr.course_number = 'HR'       
       UNION ALL       
       SELECT ssc.student_id
             ,ssc.academic_year      
             ,ssc.grade_level_id
             ,ssc.entry_date
             ,ssc.leave_date
             
             ,'Mathematics' AS subject_area
             ,'MATH' AS credittype
             ,0 AS is_advanced_math
       FROM gabby.powerschool.course_enrollments_static enr
       JOIN gabby.illuminate_public.students ils
         ON enr.student_number = ils.local_student_id
       JOIN gabby.illuminate_public.courses c
         ON enr.course_number = c.school_course_id
       JOIN gabby.illuminate_matviews.ss_cube ssc
         ON ils.student_id = ssc.student_id
        AND c.course_id = ssc.course_id
        AND (enr.academic_year + 1) = ssc.academic_year
        AND ssc.grade_level_id <= 5
       WHERE enr.course_enroll_status = 0
         AND enr.section_enroll_status = 0
         AND enr.course_number = 'HR'
       
       UNION ALL

       /* 5-12 enrollments */
       SELECT ssc.student_id
             ,ssc.academic_year      
             ,ssc.grade_level_id
             ,ssc.entry_date
             ,ssc.leave_date
             
             ,enr.illuminate_subject AS subject_area
             ,enr.credittype             
             ,CASE WHEN enr.illuminate_subject IN ('Algebra I', 'Geometry', 'Algebra IIA', 'Algebra IIB') THEN 1 ELSE 0 END AS is_advanced_math
       FROM gabby.powerschool.course_enrollments_static enr
       JOIN gabby.illuminate_public.students ils
         ON enr.student_number = ils.local_student_id
       JOIN gabby.illuminate_public.courses c
         ON enr.course_number = c.school_course_id
       JOIN gabby.illuminate_matviews.ss_cube ssc
         ON ils.student_id = ssc.student_id
        AND c.course_id = ssc.course_id
        AND (enr.academic_year + 1) = ssc.academic_year
       WHERE enr.course_enroll_status = 0
         AND enr.section_enroll_status = 0
         AND enr.illuminate_subject IN ('Mathematics','Algebra I','Geometry','Algebra IIA','Algebra IIB'
                                       ,'Text Study','English 100','English 200','English 300','English 400'
                                       ,'Science','Social Studies') 
      ) sub
 )

SELECT sub.assessment_id
      ,sub.title
      ,sub.administered_at
      ,sub.performance_band_set_id
      ,sub.academic_year
      ,CASE
        WHEN sub.scope = 'Process Piece' THEN 'PP'
        WHEN sub.scope NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes) THEN NULL
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
     /* standard curriculum -- K-8 */
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
      AND dsa.code_translation IN ('Text Study','Mathematics','Social Studies','Science')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id 
      AND agl.assessment_grade_level_id IN (SELECT assessment_grade_level_id FROM gabby.illuminate_dna_assessments.assessment_grade_levels_validation_static) 
     JOIN gabby.illuminate_public.student_session_aff ssa
       ON a.administered_at BETWEEN ssa.entry_date AND ssa.leave_date
      AND agl.grade_level_id = ssa.grade_level_id
      AND ssa.stu_sess_id IN (SELECT stu_sess_id FROM gabby.illuminate_public.student_session_aff_validation_static) 
     LEFT OUTER JOIN course_enrollments ce
       ON ssa.student_id = ce.student_id  
      AND a.academic_year = ce.academic_year 
      AND dsa.code_translation = ce.subject_area
      AND ce.is_advanced_math_student = 0
      AND ce.rn = 1
     WHERE a.deleted_at IS NULL  
       AND ce.student_id IS NOT NULL

     UNION ALL

     /* standard curriculum -- HS */
     SELECT DISTINCT 
            a.assessment_id
           ,a.title
           ,a.administered_at        
           ,a.performance_band_set_id
           ,(a.academic_year - 1) AS academic_year
           
           ,ds.code_translation AS scope           
      
           ,dsa.code_translation AS subject_area

           ,ce.student_id
      
           ,0 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
      AND ds.code_translation IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation IN ('Algebra I','Geometry','Algebra IIA','Algebra IIB'
                                  ,'English 100','English 200','English 300','English 400')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id
      AND agl.assessment_grade_level_id IN (SELECT assessment_grade_level_id FROM gabby.illuminate_dna_assessments.assessment_grade_levels_validation_static) 
     JOIN course_enrollments ce
       ON a.academic_year = ce.academic_year 
      AND agl.grade_level_id = ce.grade_level_id
      AND dsa.code_translation = ce.subject_area 
      AND ce.rn = 1
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

           ,sa.student_id

           ,1 AS is_replacement
     FROM gabby.illuminate_dna_assessments.assessments a  
     JOIN gabby.illuminate_codes.dna_scopes ds
       ON a.code_scope_id = ds.code_id
      AND ds.code_translation IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
     JOIN gabby.illuminate_codes.dna_subject_areas dsa
       ON a.code_subject_area_id = dsa.code_id    
      AND dsa.code_translation NOT IN ('Algebra I','Geometry','Algebra IIA','Algebra IIB'
                                      ,'English 100','English 200','English 300','English 400')
     JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
       ON a.assessment_id = agl.assessment_id
      AND agl.assessment_grade_level_id IN (SELECT assessment_grade_level_id FROM gabby.illuminate_dna_assessments.assessment_grade_levels_validation_static) 
     JOIN gabby.illuminate_dna_assessments.students_assessments sa
       ON a.assessment_id = sa.assessment_id
     JOIN gabby.illuminate_public.student_session_aff ssa
       ON sa.date_taken BETWEEN ssa.entry_date AND ssa.leave_date
      AND sa.student_id = ssa.student_id
      AND agl.grade_level_id != ssa.grade_level_id      
      AND ssa.stu_sess_id IN (SELECT stu_sess_id FROM gabby.illuminate_public.student_session_aff_validation_static)
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