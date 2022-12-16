 SELECT
  sub.*,
  CASE
    WHEN week_part = '01'
    AND month_part = 12 THEN CAST((year_part + 1) AS NVARCHAR) + CAST(sub.week_part AS NVARCHAR)
    WHEN week_part = '53'
    AND month_part = 12 THEN CAST((year_part + 1) AS NVARCHAR) + '01'
    ELSE CAST(year_part AS NVARCHAR) + CAST(sub.week_part AS NVARCHAR)
  END AS reporting_hash INTO utilities.reporting_days
FROM
  (
    SELECT
      DATE,
      utilities.DATE_TO_SY (DATE) AS academic_year,
      DATENAME(DW, sub.date) AS day_of_week,
      DATEPART(WEEKDAY, sub.date) AS dw_numeric,
      DATEPART(DAY, sub.date) AS day_part,
      DATEPART(MONTH, sub.date) AS month_part,
      DATEPART(YEAR, sub.date) AS year_part,
      RIGHT(CONCAT('0', DATEPART(WEEK, sub.date)), 2) AS week_part
    FROM
      (
        SELECT
          DATEADD(DAY, n, '2002-07-01') AS DATE
        FROM
          gabby.utilities.row_generator
        WHERE
          n < (365 * 40)
      ) AS sub
  ) AS sub
