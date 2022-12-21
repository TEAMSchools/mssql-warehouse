CREATE OR ALTER VIEW
  powerschool.attendance_clean_current AS
SELECT
  CAST(id AS INT) AS id,
  CAST(studentid AS INT) AS studentid,
  CAST(schoolid AS INT) AS schoolid,
  att_date,
  CAST(attendance_codeid AS INT) AS attendance_codeid,
  CAST(att_mode_code AS VARCHAR(25)) AS att_mode_code,
  CAST(calendar_dayid AS INT) AS calendar_dayid,
  CAST(att_interval AS INT) AS att_interval,
  CAST(ccid AS INT) AS ccid,
  CAST(periodid AS INT) AS periodid,
  CAST(programid AS INT) AS programid,
  CAST(total_minutes AS INT) AS total_minutes,
  CAST(
    CASE
      WHEN att_comment != '' THEN att_comment
    END AS VARCHAR(1000)
  ) AS att_comment
FROM
  powerschool.attendance
WHERE
  yearid = gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
