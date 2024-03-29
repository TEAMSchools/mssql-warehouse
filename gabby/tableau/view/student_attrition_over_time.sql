CREATE OR ALTER VIEW
  tableau.student_attrition_over_time AS
WITH
  enrolled_oct1 AS (
    SELECT
      student_number,
      lastfirst,
      academic_year,
      school_level,
      reporting_schoolid,
      grade_level,
      entrydate,
      exitdate,
      exitcode,
      exitcomment,
      [db_name]
    FROM
      powerschool.cohort_identifiers_static
    WHERE
      (
        DATEFROMPARTS(academic_year, 10, 1) BETWEEN entrydate AND exitdate
      )
      AND academic_year >= (
        utilities.GLOBAL_ACADEMIC_YEAR () - 2
      )
  ),
  attrition_dates AS (
    SELECT
      [date],
      CASE
        WHEN DATEPART(MONTH, [date]) >= 10 THEN DATEPART(YEAR, [date])
        ELSE DATEPART(YEAR, [date]) - 1
      END AS attrition_year
    FROM
      utilities.reporting_days
  )
SELECT
  y1.student_number,
  y1.lastfirst,
  y1.academic_year AS [year],
  y1.school_level,
  y1.reporting_schoolid,
  y1.grade_level,
  y1.entrydate,
  y1.exitdate AS y1_exitdate,
  y1.[db_name],
  s.exitdate,
  s.exitcode,
  s.exitcomment,
  d.[date],
  y2.entrydate AS y2_entrydate,
  CASE
  /* graduates != attrition */
    WHEN y1.exitcode = 'G1' THEN 0
    /* handles re-enrollments during the school year */
    WHEN (
      s.exitdate >= y1.exitdate
      AND s.exitdate >= d.[date]
    ) THEN 0
    /* was not enrolled on 10/1 next year */
    WHEN (
      y1.exitdate <= d.[date]
      AND y2.entrydate IS NULL
    ) THEN 1
    ELSE 0
  END AS is_attrition
FROM
  enrolled_oct1 AS y1
  LEFT JOIN powerschool.students AS s ON (
    y1.student_number = s.student_number
  )
  INNER JOIN attrition_dates AS d ON (
    y1.academic_year = d.attrition_year
    AND d.[date] <= CURRENT_TIMESTAMP
  )
  LEFT JOIN powerschool.cohort_identifiers_static AS y2 ON (
    y1.student_number = y2.student_number
    AND y1.academic_year = (y2.academic_year - 1)
    AND (
      DATEFROMPARTS(y2.academic_year, 10, 1) BETWEEN y2.entrydate AND y2.exitdate
    )
  )
