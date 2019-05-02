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
      ,ada_running
      ,pct_ontime_running
      ,is_oss_running
      ,is_iss_running
      ,is_suspended_running      
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
      ,ada_running
      ,pct_ontime_running
      ,is_oss_running
      ,is_iss_running
      ,is_suspended_running
FROM tableau.attendance_dashboard_archive
WHERE academic_year = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)