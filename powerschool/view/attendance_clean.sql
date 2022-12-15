CREATE OR ALTER VIEW
  powerschool.attendance_clean AS
SELECT
  accs.id,
  accs.studentid,
  accs.schoolid,
  accs.att_date,
  accs.attendance_codeid,
  accs.att_mode_code,
  accs.calendar_dayid,
  accs.att_interval,
  accs.ccid,
  accs.periodid,
  accs.programid,
  accs.total_minutes,
  accs.att_comment
FROM
  powerschool.attendance_clean_current_static AS accs
UNION ALL
SELECT
  aca.id,
  aca.studentid,
  aca.schoolid,
  aca.att_date,
  aca.attendance_codeid,
  aca.att_mode_code,
  aca.calendar_dayid,
  aca.att_interval,
  aca.ccid,
  aca.periodid,
  aca.programid,
  aca.total_minutes,
  aca.att_comment
FROM
  powerschool.attendance_clean_archive AS aca
