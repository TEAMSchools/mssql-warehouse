USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.course_enrollment_scaffold_current AS

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
           ,credittype
           ,subject_area
           ,DATEADD(DAY, -1, leave_date) AS leave_date
           ,MAX(is_advanced_math) OVER(PARTITION BY student_id, academic_year, credittype) AS is_advanced_math_student
     FROM
         (
          /* K-12 enrollments */
          SELECT enr.academic_year + 1 AS academic_year
                ,enr.dateenrolled AS entry_date
                ,enr.dateleft AS leave_date
                ,enr.illuminate_subject COLLATE Latin1_General_BIN AS subject_area
                ,enr.credittype
                ,CASE 
                  WHEN enr.illuminate_subject IN ('Algebra I', 'Geometry', 'Algebra II', 'Algebra IIA', 'Algebra IIB', 'Pre-Calculus') THEN 1 
                  ELSE 0 
                 END AS is_advanced_math

                ,co.grade_level + 1 AS grade_level_id

                ,ils.student_id
          FROM gabby.powerschool.course_enrollments_current_static enr
          INNER JOIN gabby.powerschool.cohort_identifiers_static co
            ON enr.student_number = co.student_number
           AND enr.academic_year = co.academic_year
           AND enr.[db_name] = co.[db_name]
           AND co.rn_year = 1
          INNER JOIN gabby.illuminate_public.students ils
            ON enr.student_number = ils.local_student_id
          WHERE enr.course_enroll_status = 0
            AND enr.illuminate_subject IS NOT NULL

          UNION ALL

          /* ES Writing */
          SELECT co.academic_year + 1 AS academic_year
                ,co.entrydate AS entry_date
                ,co.exitdate AS leave_date
                ,'Writing' COLLATE Latin1_General_BIN AS subject_area
                ,'RHET' AS credittype
                ,0 AS is_advanced_math
                ,co.grade_level + 1 AS grade_level_id

                ,ils.student_id
          FROM gabby.powerschool.cohort_identifiers_static co
          INNER JOIN gabby.illuminate_public.students ils
            ON co.student_number = ils.local_student_id
          WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
            AND co.grade_level <= 4
         ) sub
    ) sub
