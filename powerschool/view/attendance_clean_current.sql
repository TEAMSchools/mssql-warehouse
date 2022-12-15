CREATE OR ALTER VIEW
  powerschool.attendance_clean_current AS
SELECT
  CAST(att.id AS INT) AS id,
  CAST(att.studentid AS INT) AS studentid,
  CAST(att.schoolid AS INT) AS schoolid,
  att.att_date,
  CAST(att.attendance_codeid AS INT) AS attendance_codeid,
  CAST(att.att_mode_code AS VARCHAR(25)) AS att_mode_code,
  CAST(att.calendar_dayid AS INT) AS calendar_dayid,
  CAST(att.att_interval AS INT) AS att_interval,
  CAST(att.ccid AS INT) AS ccid,
  CAST(att.periodid AS INT) AS periodid,
  CAST(att.programid AS INT) AS programid,
  CAST(att.total_minutes AS INT) AS total_minutes,
  CAST(
    CASE
      WHEN att.att_comment <> '' THEN att.att_comment
    END AS VARCHAR(1000)
  ) AS att_comment
FROM
  powerschool.attendance AS att
WHERE
  att.yearid = gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
