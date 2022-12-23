CREATE OR ALTER VIEW
  powerschool.ps_adaadm_daily_ctod AS
SELECT
  studentid,
  schoolid,
  calendardate,
  fteid,
  attendance_conversion_id,
  grade_level,
  ontrack,
  offtrack,
  student_track,
  yearid,
  attendancevalue,
  membershipvalue,
  potential_attendancevalue
FROM
  powerschool.ps_adaadm_daily_ctod_current_static
UNION ALL
SELECT
  studentid,
  schoolid,
  calendardate,
  fteid,
  attendance_conversion_id,
  grade_level,
  ontrack,
  offtrack,
  student_track,
  yearid,
  attendancevalue,
  membershipvalue,
  potential_attendancevalue
FROM
  powerschool.ps_adaadm_daily_ctod_archive
