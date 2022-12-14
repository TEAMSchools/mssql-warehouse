CREATE OR ALTER VIEW
  powerschool.enrollment_identifiers AS
SELECT
  sub.student_number,
  sub.yearid,
  MAX(sub.is_enrolled_y1) AS is_enrolled_y1,
  MAX(sub.is_enrolled_oct01) AS is_enrolled_oct01,
  MAX(sub.is_enrolled_oct15) AS is_enrolled_oct15,
  MAX(sub.is_enrolled_recent) AS is_enrolled_recent,
  MAX(sub.is_enrolled_oct15_week) AS is_enrolled_oct15_week,
  MAX(sub.is_enrolled_jan15_week) AS is_enrolled_jan15_week
FROM
  (
    SELECT
      co.student_number,
      co.yearid,
      CASE
        WHEN co.exitdate IS NOT NULL THEN 1
      END AS is_enrolled_y1
      --  ,CASE WHEN DATEFROMPARTS(co.academic_year, 10, 1) BETWEEN co.entrydate AND co.exitdate THEN 1 END AS is_enrolled_oct01
      --  ,CASE WHEN DATEFROMPARTS(co.academic_year, 10, 15) BETWEEN co.entrydate AND co.exitdate THEN 1 END AS is_enrolled_oct15
,
      CASE
        WHEN co.exitdate >= c.max_calendardate THEN 1
        --  WHEN CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN co.entrydate AND co.exitdate THEN 1
      END AS is_enrolled_recent
      /* enrolled week of 10/15 */
,
      CASE
        WHEN co.entrydate <= DATEADD(
          DAY,
          7 - (
            DATEPART(WEEKDAY, DATEFROMPARTS(co.academic_year, 10, 15))
          ),
          DATEFROMPARTS(co.academic_year, 10, 15)
        ) /* entered before 10/15 week end */
        AND co.exitdate >= DATEADD(
          DAY,
          0 - (
            DATEPART(WEEKDAY, DATEFROMPARTS(co.academic_year, 10, 15)) - 1
          ),
          DATEFROMPARTS(co.academic_year, 10, 15)
        ) /* exited after 10/15 week start */ THEN 1
      END AS is_enrolled_oct15_week
      /* enrolled week of 01/15 */
,
      CASE
        WHEN co.entrydate <= DATEADD(
          DAY,
          7 - (
            DATEPART(
              WEEKDAY,
              DATEFROMPARTS(co.academic_year + 1, 1, 15)
            )
          ),
          DATEFROMPARTS(co.academic_year + 1, 1, 15)
        ) /* entered before 01/15 week end */
        AND co.exitdate >= DATEADD(
          DAY,
          0 - (
            DATEPART(
              WEEKDAY,
              DATEFROMPARTS(co.academic_year + 1, 1, 15)
            ) - 1
          ),
          DATEFROMPARTS(co.academic_year + 1, 1, 15)
        ) /* exited after 01/15 week start */ THEN 1
      END AS is_enrolled_jan15_week
    FROM
      powerschool.cohort_static co
      LEFT JOIN powerschool.calendar_rollup_static c ON co.schoolid = c.schoolid
      AND co.yearid = c.yearid
      AND co.track = c.track
    WHERE
      co.grade_level <> 99
  ) sub
GROUP BY
  sub.student_number,
  sub.yearid
