CREATE OR ALTER VIEW
  tableau.attendance_dashboard_current AS
SELECT
  sub.student_number,
  sub.studentid,
  sub.lastfirst,
  sub.academic_year,
  sub.reporting_schoolid AS schoolid,
  sub.grade_level,
  sub.region,
  sub.school_level,
  sub.team,
  sub.enroll_status,
  sub.iep_status,
  sub.lep_status,
  sub.c_504_status,
  sub.is_pathways,
  sub.gender,
  sub.ethnicity,
  sub.section_number,
  sub.teacher_name,
  sub.calendardate,
  sub.membershipvalue,
  sub.is_present,
  sub.is_absent,
  sub.att_code,
  sub.term,
  NULL AS ada_running,
  sub.is_ontime AS pct_ontime_running,
  sub.is_oss AS is_oss_running,
  sub.is_iss AS is_iss_running,
  sub.is_suspended AS is_suspended_running,
  sub.is_counselingservices,
  sub.is_studentathlete
FROM
  (
    SELECT
      mem.studentid,
      mem.calendardate,
      mem.membershipvalue,
      CAST(mem.attendancevalue AS FLOAT) AS is_present,
      ABS(mem.attendancevalue - 1) AS is_absent,
      co.student_number,
      co.lastfirst,
      co.enroll_status,
      co.academic_year,
      co.region,
      co.school_level,
      co.reporting_schoolid,
      co.grade_level,
      co.team,
      co.iep_status,
      co.lep_status,
      co.c_504_status,
      co.gender,
      co.ethnicity,
      0 AS is_pathways,
      enr.section_number,
      enr.teacher_name,
      att.att_code,
      CASE
        WHEN att.att_code IN ('T', 'T10') THEN 0.0
        ELSE 1.0
      END AS is_ontime,
      CASE
        WHEN att.att_code IN ('OS', 'OSS', 'OSSP') THEN 1.0
        ELSE 0.0
      END AS is_oss,
      CASE
        WHEN att.att_code IN ('S', 'ISS') THEN 1.0
        ELSE 0.0
      END AS is_iss,
      CASE
        WHEN att.att_code IN ('OS', 'OSS', 'OSSP', 'S', 'ISS') THEN 1.0
        ELSE 0.0
      END AS is_suspended,
      dt.alt_name AS term,
      CASE
        WHEN sp.studentid IS NOT NULL THEN 1
      END AS is_counselingservices,
      CASE
        WHEN sa.studentid IS NOT NULL THEN 1
      END AS is_studentathlete
    FROM
      powerschool.ps_adaadm_daily_ctod_current_static mem
      INNER JOIN powerschool.cohort_identifiers_static co ON mem.studentid = co.studentid
      AND mem.schoolid = co.schoolid
      AND mem.calendardate (BETWEEN co.entrydate AND co.exitdate)
      INNER JOIN powerschool.calendar_day cal ON mem.schoolid = cal.schoolid
      AND mem.calendardate = cal.date_value
      LEFT JOIN powerschool.course_enrollments_current_static enr ON co.studentid = enr.studentid
      AND co.academic_year = enr.academic_year
      AND co.schoolid = enr.schoolid
      AND enr.course_number = 'HR'
      AND enr.rn_course_yr = 1
      LEFT JOIN powerschool.ps_attendance_daily_current_static att ON mem.studentid = att.studentid
      AND mem.calendardate = att.att_date
      LEFT JOIN gabby.reporting.reporting_terms dt ON mem.schoolid = dt.schoolid
      AND mem.calendardate (BETWEEN dt.[start_date] AND dt.end_date)
      AND dt.identifier = 'RT'
      AND dt._fivetran_deleted = 0
      LEFT JOIN powerschool.spenrollments_gen_static sp ON mem.studentid = sp.studentid
      AND mem.calendardate (BETWEEN sp.enter_date AND sp.exit_date)
      AND sp.specprog_name = 'Counseling Services'
      LEFT JOIN powerschool.spenrollments_gen_static sa ON mem.studentid = sa.studentid
      AND mem.calendardate (BETWEEN sa.enter_date AND sa.exit_date)
      AND sa.specprog_name = 'Student Athlete'
    WHERE
      mem.attendancevalue IS NOT NULL
      AND mem.calendardate <= CURRENT_TIMESTAMP
      AND mem.membershipvalue > 0
  ) sub
