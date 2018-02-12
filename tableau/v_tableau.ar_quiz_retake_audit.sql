USE gabby
GO

CREATE OR ALTER VIEW tableau.ar_quiz_retake_audit AS

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name

      ,ar.i_quiz_number      
      ,ar.vch_content_title
      ,ar.vch_lexile_display      
      ,ar.ch_fiction_non_fiction
      ,ar.dt_taken
      ,ar.d_percent_correct
      ,ar.i_word_count
      ,CONVERT(INT,ar.rn_quiz) AS rn_quiz
      
      ,CONVERT(VARCHAR(25),dts.alt_name) AS term
      ,CASE 
        WHEN CONVERT(DATE,GETDATE()) BETWEEN dts.start_date AND dts.end_date THEN 1 
        WHEN MAX(dts.start_date) OVER(PARTITION BY co.schoolid, co.academic_year, co.student_number) BETWEEN dts.start_date AND dts.end_date THEN 1 
        ELSE 0 
       END AS is_curterm    
           
      ,enr.teacher_name           
           
      ,hr.teacher_name AS homeroom_teacher
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.renaissance.ar_studentpractice_identifiers_static ar
  ON co.student_number = ar.student_number
 AND co.academic_year = ar.academic_year
 AND ar.ti_passed = 1
 AND ar.rn_quiz > 1
LEFT JOIN gabby.reporting.reporting_terms dts
  ON co.schoolid = dts.schoolid
 AND ar.dt_taken BETWEEN dts.start_date AND dts.end_date
 AND dts.identifier = 'AR'
 AND dts.time_per_name != 'ARY'
LEFT JOIN gabby.powerschool.course_enrollments_static enr 
  ON co.student_number = enr.student_number
 AND co.academic_year = enr.academic_year
 AND enr.credittype = 'ENG'
 AND enr.section_enroll_status = 0
 AND enr.rn_subject = 1
LEFT JOIN gabby.powerschool.course_enrollments_static hr
  ON co.student_number = hr.student_number
 AND co.academic_year = hr.academic_year
 AND hr.course_number = 'HR'
 AND hr.section_enroll_status = 0      
 AND hr.rn_subject = 1
WHERE co.reporting_schoolid NOT IN (999999, 5173)
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.enroll_status = 0