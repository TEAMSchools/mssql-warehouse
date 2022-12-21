CREATE OR ALTER VIEW
  powerschool.ps_attendance_meeting AS
SELECT
  att.id,
  att.studentid,
  att.schoolid,
  att.att_date,
  att.attendance_codeid,
  att.att_mode_code,
  att.att_interval,
  att.calendar_dayid,
  att.ccid,
  att.periodid,
  att.programid,
  att.total_minutes,
  ac.att_code,
  ac.calculate_ada_yn,
  ac.presence_status_cd,
  ac.course_credit_points,
  cc.schoolid AS cc_schoolid,
  CASE
    WHEN cc.sectionid < 0 THEN 1
    ELSE 0
  END AS dropped,
  per.abbreviation AS period_abbreviation,
  per.period_number,
  s.id AS sectionid,
  s.section_number,
  cd.a,
  cd.b,
  cd.c,
  cd.d,
  cd.e,
  cd.f,
  cd.insession,
  cd.cycle_day_id,
  cy.abbreviation
FROM
  powerschool.attendance_clean AS att
  INNER JOIN powerschool.cc ON (
    att.ccid = cc.id
    AND att.studentid = cc.studentid
  )
  INNER JOIN powerschool.sections AS s ON (ABS(cc.sectionid) = s.id)
  INNER JOIN powerschool.calendar_day AS cd ON (att.calendar_dayid = cd.id)
  INNER JOIN powerschool.attendance_code AS ac ON (att.attendance_codeid = ac.id)
  INNER JOIN powerschool.cycle_day AS cy ON (cd.cycle_day_id = cy.id)
  INNER JOIN powerschool.period AS per ON (att.periodid = per.id)
WHERE
  att.att_mode_code = 'ATT_ModeMeeting'
  AND att.att_date >= cc.dateenrolled
  AND att.att_date < cc.dateleft
