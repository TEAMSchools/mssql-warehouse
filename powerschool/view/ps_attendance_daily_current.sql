CREATE OR ALTER VIEW
  powerschool.ps_attendance_daily_current AS
SELECT
  att.id,
  att.studentid,
  att.schoolid,
  att.att_date,
  att.attendance_codeid,
  att.att_mode_code,
  att.calendar_dayid,
  att.programid,
  att.total_minutes,
  CAST(ac.att_code AS VARCHAR(5)) AS att_code,
  CAST(ac.calculate_ada_yn AS INT) AS count_for_ada,
  CAST(
    ac.presence_status_cd AS VARCHAR(25)
  ) AS presence_status_cd,
  CAST(ac.calculate_adm_yn AS INT) AS count_for_adm,
  CAST(cd.a AS INT) AS a,
  CAST(cd.b AS INT) AS b,
  CAST(cd.c AS INT) AS c,
  CAST(cd.d AS INT) AS d,
  CAST(cd.e AS INT) AS e,
  CAST(cd.f AS INT) AS f,
  CAST(cd.insession AS INT) AS insession,
  CAST(cd.cycle_day_id AS INT) AS cycle_day_id,
  CAST(cy.abbreviation AS VARCHAR(25)) AS abbreviation
FROM
  powerschool.attendance_clean_current_static AS att
  INNER JOIN powerschool.attendance_code AS ac ON att.attendance_codeid = ac.id
  INNER JOIN powerschool.calendar_day AS cd ON att.calendar_dayid = cd.id
  INNER JOIN powerschool.cycle_day AS cy ON cd.cycle_day_id = cy.id
WHERE
  att.att_mode_code = 'ATT_ModeDaily'
