CREATE OR ALTER VIEW
  powerschool.ps_membership_reg_current AS
SELECT
  ev.studentid,
  ev.schoolid,
  ev.track AS student_track,
  ev.fteid,
  ev.dflt_att_mode_code,
  ev.dflt_conversion_mode_code,
  ev.att_calccntpresentabsent,
  ev.att_intervalduration,
  ev.grade_level,
  ev.yearid,
  cd.date_value AS calendardate,
  cd.a,
  cd.b,
  cd.c,
  cd.d,
  cd.e,
  cd.f,
  cd.bell_schedule_id,
  cd.cycle_day_id,
  bs.attendance_conversion_id,
  CASE
    WHEN (
      (
        ev.track = 'A'
        AND cd.a = 1
      )
      OR (
        ev.track = 'B'
        AND cd.b = 1
      )
      OR (
        ev.track = 'C'
        AND cd.c = 1
      )
      OR (
        ev.track = 'D'
        AND cd.d = 1
      )
      OR (
        ev.track = 'E'
        AND cd.e = 1
      )
      OR (
        ev.track = 'F'
        AND cd.f = 1
      )
    ) THEN ev.membershipshare
    WHEN ev.track IS NULL THEN ev.membershipshare
    ELSE 0
  END AS studentmembership,
  CASE
    WHEN (
      (
        ev.track = 'A'
        AND cd.a = 1
      )
      OR (
        ev.track = 'B'
        AND cd.b = 1
      )
      OR (
        ev.track = 'C'
        AND cd.c = 1
      )
      OR (
        ev.track = 'D'
        AND cd.d = 1
      )
      OR (
        ev.track = 'E'
        AND cd.e = 1
      )
      OR (
        ev.track = 'F'
        AND cd.f = 1
      )
    ) THEN cd.membershipvalue
    WHEN (ev.track IS NULL) THEN cd.membershipvalue
    ELSE 0
  END AS calendarmembership,
  CASE
    WHEN (
      (
        ev.track = 'A'
        AND cd.a = 1
      )
      OR (
        ev.track = 'B'
        AND cd.b = 1
      )
      OR (
        ev.track = 'C'
        AND cd.c = 1
      )
      OR (
        ev.track = 'D'
        AND cd.d = 1
      )
      OR (
        ev.track = 'E'
        AND cd.e = 1
      )
      OR (
        ev.track = 'F'
        AND cd.f = 1
      )
    ) THEN 1
    WHEN (ev.track IS NULL) THEN 1
    ELSE 0
  END AS ontrack,
  CASE
    WHEN (
      (
        ev.track = 'A'
        AND cd.a = 1
      )
      OR (
        ev.track = 'B'
        AND cd.b = 1
      )
      OR (
        ev.track = 'C'
        AND cd.c = 1
      )
      OR (
        ev.track = 'D'
        AND cd.d = 1
      )
      OR (
        ev.track = 'E'
        AND cd.e = 1
      )
      OR (
        ev.track = 'F'
        AND cd.f = 1
      )
    ) THEN 0
    WHEN ev.track IS NULL THEN 0
    ELSE 1
  END AS offtrack
FROM
  powerschool.ps_enrollment_all_static AS ev
  INNER JOIN powerschool.calendar_day AS cd ON (
    ev.schoolid = cd.schoolid
    AND cd.date_value >= ev.entrydate
    AND cd.date_value < ev.exitdate
    AND cd.insession = 1
  )
  INNER JOIN powerschool.bell_schedule AS bs ON (cd.bell_schedule_id = bs.id)
WHERE
  ev.yearid = (
    gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
  )
