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
      ,CASE
        WHEN DB_NAME() = 'kippnewark' THEN 'TEAM'
        WHEN DB_NAME() = 'kippcamden' THEN 'KCNA'
        WHEN DB_NAME() = 'kippmiami' THEN 'KMS'
       END AS region
      ,school_level
      ,team
      ,enroll_status
      ,iep_status
      ,NULL AS lep_status
      ,NULL AS c_504_status
      ,NULL AS is_pathways
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
      ,NULL AS ada_running
      ,NULL AS pct_ontime_running
      ,is_oss_running
      ,is_iss_running
      ,is_suspended_running
FROM tableau.attendance_dashboard_archive