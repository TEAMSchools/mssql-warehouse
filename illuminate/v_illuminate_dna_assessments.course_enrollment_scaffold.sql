USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.course_enrollment_scaffold AS

SELECT student_id
      ,academic_year
      ,grade_level_id
      ,credittype
      ,subject_area
      ,is_advanced_math_student
FROM
    (
     SELECT student_id
           ,academic_year
           ,grade_level_id
           ,CONVERT(VARCHAR(125),credittype) AS credittype
           ,CONVERT(VARCHAR(125),subject_area) AS subject_area
           ,MAX(is_advanced_math) OVER(PARTITION BY student_id, academic_year, credittype) AS is_advanced_math_student
           ,CONVERT(INT,ROW_NUMBER() OVER(        
              PARTITION BY student_id, academic_year, credittype, subject_area
                ORDER BY entry_date DESC, leave_date DESC)) AS rn
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
          WHERE enr.course_enroll_status = 0
            AND enr.section_enroll_status = 0
            AND enr.course_number = 'HR'       
            AND (ssc.grade_level_id <= 5 OR (enr.schoolid = 73258 AND enr.section_number LIKE 'W%')) /* Pathways MS students only enrolled in HR */
       
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
            AND (ssc.grade_level_id <= 5 OR (enr.schoolid = 73258 AND enr.section_number LIKE 'W%')) /* Pathways MS students only enrolled in HR */
       
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
    ) sub
WHERE rn = 1