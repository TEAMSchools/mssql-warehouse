USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.course_enrollment_scaffold AS

SELECT student_id
      ,academic_year
      ,entry_date
      ,leave_date
      ,grade_level_id
      ,credittype
      ,subject_area
      ,is_advanced_math_student
FROM
    (
     SELECT student_id
           ,academic_year
           ,grade_level_id
           ,entry_date
           ,DATEADD(DAY, -1, leave_date) AS leave_date
           ,CONVERT(VARCHAR(125), credittype) AS credittype
           ,CONVERT(VARCHAR(125), subject_area) COLLATE Latin1_General_BIN AS subject_area
           ,MAX(is_advanced_math) OVER(PARTITION BY student_id, academic_year, credittype) AS is_advanced_math_student
     FROM
         (
          /* K-12 enrollments */
          SELECT DISTINCT
                 ssc.student_id
                ,ssc.academic_year
                ,ssc.grade_level_id
                ,ssc.entry_date
                ,ssc.leave_date

                ,enr.illuminate_subject AS subject_area
                ,enr.credittype
                ,CASE 
                  WHEN enr.illuminate_subject IN ('Algebra I', 'Geometry', 'Algebra II', 'Algebra IIA', 'Algebra IIB', 'Pre-Calculus') THEN 1 
                  ELSE 0 
                 END AS is_advanced_math
          FROM gabby.powerschool.course_enrollments enr
          JOIN gabby.illuminate_public.students ils
            ON enr.student_number = ils.local_student_id
          JOIN gabby.illuminate_public.courses c
            ON enr.course_number = c.school_course_id COLLATE Latin1_General_BIN
          JOIN gabby.illuminate_matviews.ss_cube ssc
            ON ils.student_id = ssc.student_id
           AND c.course_id = ssc.course_id
           AND (enr.academic_year + 1) = ssc.academic_year
           AND ssc.entry_date <> ssc.leave_date
          WHERE enr.course_enroll_status = 0
            AND enr.section_enroll_status = 0
            AND enr.illuminate_subject IS NOT NULL
            AND enr.rn_illuminate_subject = 1

          UNION ALL

          /* ES Writing */
          SELECT DISTINCT
                 ssc.student_id
                ,ssc.academic_year
                ,ssc.grade_level_id
                ,ssc.entry_date
                ,ssc.leave_date

                ,'Writing' AS subject_area
                ,'RHET' AS credittype
                ,0 AS is_advanced_math
          FROM gabby.powerschool.course_enrollments enr
          JOIN gabby.illuminate_public.students ils
            ON enr.student_number = ils.local_student_id
          JOIN gabby.illuminate_public.courses c
            ON enr.course_number = c.school_course_id COLLATE Latin1_General_BIN
          JOIN gabby.illuminate_matviews.ss_cube ssc
            ON ils.student_id = ssc.student_id
           AND c.course_id = ssc.course_id
           AND (enr.academic_year + 1) = ssc.academic_year
           AND ssc.entry_date <> ssc.leave_date
           AND ssc.grade_level_id <= 5
          WHERE enr.course_enroll_status = 0
            AND enr.section_enroll_status = 0
            AND enr.course_number = 'HR'
            AND enr.rn_course_yr = 1
         ) sub
    ) sub
