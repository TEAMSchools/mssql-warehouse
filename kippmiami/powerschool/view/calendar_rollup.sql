CREATE OR ALTER VIEW
  powerschool.calendar_rollup AS
WITH
  cal_long AS (
    SELECT
      schoolid,
      date_value,
      yearid,
      CAST(UPPER(field) AS NVARCHAR(1)) AS track,
      [value]
    FROM
      (
        SELECT
          cd.schoolid,
          cd.date_value,
          cd.a,
          cd.b,
          cd.c,
          cd.d,
          cd.e,
          cd.f,
          t.yearid
        FROM
          powerschool.calendar_day AS cd
          INNER JOIN powerschool.schools AS s ON (cd.schoolid = s.school_number)
          INNER JOIN powerschool.cy_day AS cy ON (cd.cy_day_id = cy.id)
          INNER JOIN powerschool.terms AS t ON (
            cd.schoolid = t.schoolid
            AND (
              cd.date_value BETWEEN t.firstday AND t.lastday
            )
            AND t.isyearrec = 1
          )
          INNER JOIN powerschool.bell_schedule AS bs ON (
            t.schoolid = bs.schoolid
            AND t.yearid = bs.year_id
            AND cd.bell_schedule_id = bs.id
          )
        WHERE
          cd.insession = 1
          AND cd.membershipvalue > 0
      ) AS sub UNPIVOT (
        [value] FOR field IN (a, b, c, d, e, f)
      ) AS u
  )
SELECT
  schoolid,
  yearid,
  track,
  MIN(date_value) AS min_calendardate,
  MAX(date_value) AS max_calendardate,
  COUNT(date_value) AS days_total,
  SUM(
    CASE
      WHEN date_value > CURRENT_TIMESTAMP THEN 1
      ELSE 0
    END
  ) AS days_remaining
FROM
  cal_long
WHERE
  [value] = 1
GROUP BY
  schoolid,
  yearid,
  track
