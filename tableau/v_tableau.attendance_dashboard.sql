CREATE OR ALTER VIEW tableau.attendance_dashboard AS

SELECT academic_year
      ,schoolid
      ,studentid
      ,student_number
      ,lastfirst
      ,grade_level
      ,region
      ,school_level
      ,team
      ,enroll_status
      ,iep_status
      ,lep_status
      ,c_504_status
      ,is_pathways
      ,gender
      ,ethnicity
      ,section_number
      ,teacher_name
      ,calendardate
      ,membershipvalue
      ,is_present
      ,is_absent
      ,att_code
      ,term
      ,is_counselingservices
      ,is_studentathlete
      ,AVG(is_present) OVER(PARTITION BY studentid, academic_year ORDER BY calendardate) AS ada_running
      ,AVG(pct_ontime_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS pct_ontime_running
      ,MAX(is_oss_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS is_oss_running
      ,MAX(is_iss_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS is_iss_running
      ,MAX(is_suspended_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS is_suspended_running
FROM tableau.attendance_dashboard_current_static

UNION ALL

SELECT academic_year
      ,schoolid
      ,studentid
      ,student_number
      ,lastfirst
      ,grade_level
      ,region
      ,school_level
      ,team
      ,enroll_status
      ,iep_status
      ,lep_status
      ,c_504_status
      ,is_pathways
      ,gender
      ,ethnicity
      ,section_number
      ,teacher_name
      ,calendardate
      ,membershipvalue
      ,is_present
      ,is_absent
      ,att_code
      ,term
      ,NULL AS is_counselingservices
      ,NULL AS is_studentathlete
      ,AVG(is_present) OVER(PARTITION BY studentid, academic_year ORDER BY calendardate) AS ada_running
      ,AVG(pct_ontime_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS pct_ontime_running
      ,MAX(is_oss_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS is_oss_running
      ,MAX(is_iss_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS is_iss_running
      ,MAX(is_suspended_running) OVER(PARTITION BY student_number, academic_year ORDER BY calendardate) AS is_suspended_running
FROM tableau.attendance_dashboard_archive
WHERE academic_year = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)