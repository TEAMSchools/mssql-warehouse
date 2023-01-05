SELECT
  *,
  CASE
    WHEN (
      week_part = '01'
      AND month_part = 12
    ) THEN CAST((year_part + 1) AS NVARCHAR) + CAST(week_part AS NVARCHAR)
    WHEN (
      week_part = '53'
      AND month_part = 12
    ) THEN CAST((year_part + 1) AS NVARCHAR) + '01'
    ELSE CAST(year_part AS NVARCHAR) + CAST(week_part AS NVARCHAR)
  END AS reporting_hash INTO utilities.reporting_days
FROM
  (
    SELECT
      [date],
      utilities.DATE_TO_SY ([date]) AS academic_year,
      DATENAME(DW, [date]) AS day_of_week,
      DATEPART(WEEKDAY, [date]) AS dw_numeric,
      DATEPART(DAY, [date]) AS day_part,
      DATEPART(MONTH, [date]) AS month_part,
      DATEPART(YEAR, [date]) AS year_part,
      RIGHT(
        CONCAT('0', DATEPART(WEEK, [date])),
        2
      ) AS week_part
    FROM
      (
        SELECT
          DATEADD(DAY, [n], '2002-07-01') AS [date]
        FROM
          utilities.row_generator
        WHERE
          n < (365 * 40)
      ) AS sub
  ) AS sub
