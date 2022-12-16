CREATE OR ALTER VIEW
  payroll.pay_periods AS
SELECT
  fiscal_year,
  year_part,
  month_part AS MONTH,
  pay_period,
  DATEADD(
    DAY,
    1,
    LAG(DATE, 1) OVER (
      ORDER BY
        DATE
    )
  ) AS start_date,
  DATE AS end_date
FROM
  (
    SELECT
      fiscal_year,
      year_part,
      month_part,
      pay_period,
      DATE,
      ROW_NUMBER() OVER (
        PARTITION BY
          fiscal_year,
          month_part,
          pay_period
        ORDER BY
          DATE DESC
      ) AS rn_date_desc
    FROM
      (
        SELECT
          academic_year + 1 AS fiscal_year,
          year_part,
          month_part,
          DATE,
          CASE
            WHEN day_part <= 15 THEN 1
            ELSE 2
          END AS pay_period
        FROM
          gabby.utilities.reporting_days
        WHERE
          dw_numeric NOT IN (1, 7)
      ) AS sub
  ) AS sub
WHERE
  rn_date_desc = 1
