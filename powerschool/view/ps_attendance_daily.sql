CREATE OR ALTER VIEW
  powerschool.ps_attendance_daily AS
SELECT
  padcs.id,
  padcs.studentid,
  padcs.schoolid,
  padcs.att_date,
  padcs.attendance_codeid,
  padcs.att_mode_code,
  padcs.calendar_dayid,
  padcs.programid,
  padcs.total_minutes,
  padcs.att_code,
  padcs.count_for_ada,
  padcs.presence_status_cd,
  padcs.count_for_adm,
  padcs.a,
  padcs.b,
  padcs.c,
  padcs.d,
  padcs.e,
  padcs.f,
  padcs.insession,
  padcs.cycle_day_id,
  padcs.abbreviation
FROM
  powerschool.ps_attendance_daily_current_static AS padcs
UNION ALL
SELECT
  pada.id,
  pada.studentid,
  pada.schoolid,
  pada.att_date,
  pada.attendance_codeid,
  pada.att_mode_code,
  pada.calendar_dayid,
  pada.programid,
  pada.total_minutes,
  pada.att_code,
  pada.count_for_ada,
  pada.presence_status_cd,
  pada.count_for_adm,
  pada.a,
  pada.b,
  pada.c,
  pada.d,
  pada.e,
  pada.f,
  pada.insession,
  pada.cycle_day_id,
  pada.abbreviation
FROM
  powerschool.ps_attendance_daily_archive AS pada
