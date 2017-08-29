USE gabby
GO

ALTER VIEW tableau.stmath_tracker AS 

WITH enrollments AS (
  SELECT enr.student_number
        ,enr.academic_year
        ,enr.course_number
        ,enr.course_name
        ,enr.teacher_name        
        ,enr.section_number
        ,ROW_NUMBER() OVER(
           PARTITION BY enr.student_number, enr.academic_year, enr.credittype
             ORDER BY enr.dateleft DESC) AS rn
  FROM gabby.powerschool.course_enrollments_static enr
  WHERE enr.course_enroll_status = 0
    AND enr.section_enroll_status = 0    
    AND enr.credittype = 'MATH'
    AND enr.schoolid IN (133570965, 73252, 179902, 179903)
    AND enr.academic_year >= 2015

  UNION ALL

  SELECT enr.student_number
        ,enr.academic_year
        ,enr.course_number
        ,enr.course_name
        ,enr.teacher_name        
        ,enr.section_number
        ,1 AS rn
  FROM gabby.powerschool.course_enrollments_static enr
  WHERE enr.course_enroll_status = 0
    AND enr.section_enroll_status = 0    
    AND enr.course_number = 'HR'
    AND enr.schoolid NOT IN (133570965, 73252, 179902, 179903)
    AND enr.academic_year >= 2015
 )

SELECT stm.school_student_id AS student_number                        
      ,stm.start_year AS academic_year
      ,stm.week_end_date AS week_ending_date
      ,stm.gcd      
      ,stm.k_5_progress
      ,stm.k_5_mastery
      ,stm.objective_name      
      ,stm.curr_hurdle_num_tries AS cur_hurdle_num_tries
      ,stm.fluency_progress
      ,stm.fluency_mastery
      ,stm.fluency_path
      ,stm.fluency_time_spent            
      ,stm.num_lab_logins
      ,stm.num_homework_logins      
      ,stm.minutes_logged_last_week      
      ,stm.first_login_date  
      ,stm.last_login_date    
      ,stm.tcd AS stmath_teacher_id
      ,stm.teacher_name AS stmath_teacher_name
      ,ISNULL(stm.num_lab_logins, 0) + ISNULL(stm.num_homework_logins, 0) AS n_logins_total      

      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.iep_status
      
      ,enr.course_number
      ,enr.course_name
      ,enr.teacher_name      
      ,enr.section_number

      ,LAG(stm.K_5_progress, 1) OVER(PARTITION BY stm.school_student_id, stm.start_year, stm.gcd ORDER BY stm.week_end_date) AS prev_week_progress      
      ,ROW_NUMBER() OVER(
         PARTITION BY stm.school_student_id, stm.start_year
           ORDER BY stm.week_end_date DESC) AS rn
      ,ROW_NUMBER() OVER(
         PARTITION BY stm.school_student_id, stm.start_year, stm.GCD
           ORDER BY stm.week_end_date DESC) AS rn_gcd
FROM gabby.stmath.progress_completion_report_clean stm
JOIN gabby.powerschool.cohort_identifiers_static co 
  ON stm.school_student_id = co.student_number
 AND stm.start_year = co.academic_year
 AND co.rn_year = 1
JOIN enrollments enr
  ON co.student_number = enr.student_number
 AND co.academic_Year = enr.academic_year
 AND enr.rn = 1