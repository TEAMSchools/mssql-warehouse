CREATE OR ALTER VIEW
  powerschool.attendance_streak AS
WITH
  streaks AS (
    SELECT
      studentid,
      yearid,
      calendardate,
      attendancevalue,
      att_code,
      day_number,
      streak_rn,
      CONCAT(
        studentid,
        '_',
        yearid,
        '_',
        att_code,
        '_',
        (day_number - streak_rn)
      ) AS streak_id,
      CONCAT(
        studentid,
        '_',
        yearid,
        '_',
        attendancevalue,
        '_',
        (day_number - streak_att_rn)
      ) AS streak_att_id
    FROM
      (
        SELECT
          mem.studentid,
          mem.yearid,
          mem.calendardate,
          mem.attendancevalue,
          ISNULL(att.att_code, 'P') AS att_code,
          CAST(
            ROW_NUMBER(AS INT) OVER (
              PARTITION BY
                mem.studentid,
                mem.yearid
              ORDER BY
                mem.calendardate ASC
            )
          ) AS day_number,
          CAST(
            ROW_NUMBER(AS INT) OVER (
              PARTITION BY
                mem.studentid,
                mem.yearid,
                att.att_code
              ORDER BY
                mem.calendardate
            )
          ) AS streak_rn,
          CAST(
            ROW_NUMBER(AS INT) OVER (
              PARTITION BY
                mem.studentid,
                mem.yearid,
                mem.attendancevalue
              ORDER BY
                mem.calendardate
            )
          ) AS streak_att_rn
        FROM
          powerschool.ps_adaadm_daily_ctod AS mem
          LEFT JOIN powerschool.ps_attendance_daily AS att ON (
            mem.studentid = att.studentid
            AND mem.calendardate = att.att_date
          )
        WHERE
          mem.membershipvalue = 1
      ) AS sub
  )
SELECT
  studentid,
  yearid,
  att_code,
  streak_id,
  MIN(calendardate) AS streak_start,
  MAX(calendardate) AS streak_end,
  DATEDIFF(
    DAY,
    MIN(calendardate),
    MAX(calendardate)
  ) + 1 AS streak_length_calendar,
  COUNT(calendardate) AS streak_length_membership
FROM
  streaks
GROUP BY
  studentid,
  yearid,
  att_code,
  streak_id
UNION ALL
SELECT
  studentid,
  yearid,
  CAST(attendancevalue AS VARCHAR) AS att_code,
  streak_att_id AS streak_id,
  MIN(calendardate) AS streak_start,
  MAX(calendardate) AS streak_end,
  DATEDIFF(
    DAY,
    MIN(calendardate),
    MAX(calendardate)
  ) + 1 AS streak_length_calendar,
  COUNT(calendardate) AS streak_length_membership
FROM
  streaks
GROUP BY
  studentid,
  yearid,
  attendancevalue,
  streak_att_id
