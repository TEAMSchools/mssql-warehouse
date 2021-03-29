CREATE OR ALTER VIEW tableau.attendance_dashboard_current AS

SELECT sub.student_number
      ,sub.studentid
      ,sub.lastfirst
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_level
      ,sub.region
      ,sub.school_level
      ,sub.team
      ,sub.enroll_status
      ,sub.iep_status
      ,sub.lep_status
      ,sub.c_504_status
      ,sub.is_pathways
      ,sub.gender
      ,sub.ethnicity
      ,sub.section_number
      ,sub.teacher_name
      ,sub.calendardate
      ,sub.membershipvalue
      ,sub.is_present
      ,sub.is_absent
      ,sub.att_code
      ,sub.term
      ,NULL AS ada_running
      ,sub.is_ontime AS pct_ontime_running
      ,sub.is_oss AS is_oss_running
      ,sub.is_iss AS is_iss_running
      ,sub.is_suspended AS is_suspended_running
      ,sub.is_counselingservices
FROM
    (
     SELECT co.academic_year
           ,co.studentid
           ,co.student_number
           ,co.lastfirst
           ,co.reporting_schoolid AS schoolid
           ,co.grade_level
           ,co.region
           ,co.school_level
           ,co.team
           ,co.enroll_status
           ,co.iep_status
           ,co.lep_status
           ,co.c_504_status
           ,NULL AS is_pathways
           ,co.gender
           ,co.ethnicity

           ,enr.section_number
           ,enr.teacher_name

           ,mem.calendardate
           ,mem.membershipvalue
           ,CONVERT(FLOAT, mem.attendancevalue) AS is_present
           ,ABS(mem.attendancevalue - 1) AS is_absent

           ,att.att_code
           ,CASE WHEN att.att_code IN ('T', 'T10') THEN 0.0 ELSE 1.0 END AS is_ontime
           ,CASE WHEN att.att_code IN ('OS', 'OSS', 'OSSP') THEN 1.0 ELSE 0.0 END AS is_oss
           ,CASE WHEN att.att_code IN ('S', 'ISS') THEN 1.0 ELSE 0.0 END AS is_iss
           ,CASE WHEN att.att_code IN ('OS', 'OSS', 'OSSP', 'S', 'ISS') THEN 1.0 ELSE 0.0 END AS is_suspended

           ,CONVERT(VARCHAR(25), dt.alt_name) AS term

           ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices
     FROM powerschool.ps_adaadm_daily_ctod_current_static mem
     JOIN powerschool.cohort_identifiers_static co
       ON mem.studentid = co.studentid
      AND mem.schoolid = co.schoolid
      AND mem.calendardate BETWEEN co.entrydate AND co.exitdate
     LEFT JOIN powerschool.course_enrollments_static enr
       ON co.studentid = enr.studentid
      AND co.academic_year = enr.academic_year 
      AND co.schoolid = enr.schoolid
      AND enr.course_number = 'HR' 
      AND enr.rn_course_yr = 1
     LEFT JOIN powerschool.ps_attendance_daily_current_static att
       ON mem.studentid = att.studentid
      AND mem.calendardate = att.att_date
     LEFT JOIN gabby.reporting.reporting_terms dt 
       ON mem.schoolid = dt.schoolid
      AND mem.calendardate BETWEEN dt.[start_date] AND dt.end_date
      AND dt.identifier = 'RT'
      AND dt._fivetran_deleted = 0
     LEFT JOIN powerschool.spenrollments_gen_static sp
       ON mem.studentid = sp.studentid
      AND mem.calendardate BETWEEN sp.enter_date AND sp.exit_date
      AND sp.specprog_name = 'Counseling Services'
     WHERE mem.attendancevalue IS NOT NULL
       AND mem.calendardate <= GETDATE()
       AND mem.membershipvalue > 0
    ) sub
