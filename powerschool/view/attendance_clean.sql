CREATE OR ALTER VIEW
  powerschool.attendance_clean AS
SELECT
  id,
  studentid,
  schoolid,
  att_date,
  attendance_codeid,
  att_mode_code,
  calendar_dayid,
  att_interval,
  ccid,
  periodid,
  programid,
  total_minutes,
  att_comment
FROM
  powerschool.attendance_clean_current_static
UNION ALL
SELECT
  id,
  studentid,
  schoolid,
  att_date,
  attendance_codeid,
  att_mode_code,
  calendar_dayid,
  att_interval,
  ccid,
  periodid,
  programid,
  total_minutes,
  att_comment
FROM
  powerschool.attendance_clean_archive
