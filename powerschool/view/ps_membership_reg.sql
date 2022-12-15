CREATE OR ALTER VIEW
  powerschool.ps_membership_reg AS
SELECT
  pmrc.studentid,
  pmrc.schoolid,
  pmrc.student_track,
  pmrc.fteid,
  pmrc.dflt_att_mode_code,
  pmrc.dflt_conversion_mode_code,
  pmrc.att_calccntpresentabsent,
  pmrc.att_intervalduration,
  pmrc.grade_level,
  pmrc.yearid,
  pmrc.calendardate,
  pmrc.a,
  pmrc.b,
  pmrc.c,
  pmrc.d,
  pmrc.e,
  pmrc.f,
  pmrc.bell_schedule_id,
  pmrc.cycle_day_id,
  pmrc.attendance_conversion_id,
  pmrc.studentmembership,
  pmrc.calendarmembership,
  pmrc.ontrack,
  pmrc.offtrack
FROM
  powerschool.ps_membership_reg_current_static AS pmrc
UNION ALL
SELECT
  pmra.studentid,
  pmra.schoolid,
  pmra.student_track,
  pmra.fteid,
  pmra.dflt_att_mode_code,
  pmra.dflt_conversion_mode_code,
  pmra.att_calccntpresentabsent,
  pmra.att_intervalduration,
  pmra.grade_level,
  pmra.yearid,
  pmra.calendardate,
  pmra.a,
  pmra.b,
  pmra.c,
  pmra.d,
  pmra.e,
  pmra.f,
  pmra.bell_schedule_id,
  pmra.cycle_day_id,
  pmra.attendance_conversion_id,
  pmra.studentmembership,
  pmra.calendarmembership,
  pmra.ontrack,
  pmra.offtrack
FROM
  powerschool.ps_membership_reg_archive AS pmra
