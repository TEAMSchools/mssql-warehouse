USE gabby GO
CREATE OR ALTER VIEW
  payroll.pr_employeesummary_clean AS
WITH
  dates AS (
    SELECT DISTINCT
      pay_date
    FROM
      gabby.adp.pr_employeesummary
  ),
  scaffold AS (
    SELECT
      sr.associate_id,
      sr.preferred_first,
      sr.preferred_last,
      sr.hire_date,
      sr.rehire_date,
      sr.position_id,
      sr.position_status,
      sr.position_start_date,
      sr.termination_date,
      d.pay_date
    FROM
      gabby.adp.staff_roster sr
      JOIN dates d ON d.pay_date BETWEEN sr.position_start_date AND DATEADD(
        DAY,
        16,
        COALESCE(
          sr.termination_date,
          CAST(CURRENT_TIMESTAMP AS DATE)
        )
      )
  )
SELECT
  sub.associate_id,
  sub.position_id,
  sub.position_start_date,
  sub.termination_date,
  sub.pay_date,
  sub.company,
  sub.file_,
  sub.[name],
  sub.home_department,
  sub.home_cost_number,
  sub.clock_,
  sub.total_reg_hours,
  sub.total_ot_hours,
  sub.total_hours_3_4,
  sub.gross_pay,
  sub.total_taxes,
  sub.total_deductions,
  sub.total_deposits,
  sub.net_pay,
  sub.total_reg_earnings,
  sub.total_reg_earnings_prev,
  sub.total_ot_earnings,
  sub.total_ot_earnings_prev,
  sub.total_earnings_3_4_5,
  sub.total_earnings_3_4_5_prev,
  sub.total_reg_earnings_prev - sub.total_reg_earnings AS total_reg_earnings_diff,
  CASE
    WHEN sub.total_reg_earnings_prev - sub.total_reg_earnings <> 0 THEN 1
    WHEN sub.total_reg_earnings IS NULL THEN 1
    ELSE 0
  END AS total_reg_earnings_diff_flag,
  sub.total_ot_earnings_prev - sub.total_ot_earnings AS total_ot_earnings_diff,
  CASE
    WHEN sub.total_ot_earnings_prev - sub.total_ot_earnings <> 0 THEN 1
    WHEN sub.total_ot_earnings IS NULL THEN 1
    ELSE 0
  END AS total_ot_earnings_diff_flag,
  sub.total_earnings_3_4_5_prev - sub.total_earnings_3_4_5 AS total_earnings_3_4_5_diff,
  CASE
    WHEN sub.total_earnings_3_4_5_prev - sub.total_earnings_3_4_5 <> 0 THEN 1
    WHEN sub.total_earnings_3_4_5 IS NULL THEN 1
    ELSE 0
  END AS total_earnings_3_4_5_diff_flag
FROM
  (
    SELECT
      s.associate_id,
      s.position_id,
      s.position_start_date,
      s.termination_date,
      s.pay_date,
      LEFT(s.position_id, 3) AS company,
      RIGHT(s.position_id, LEN(s.position_id) - 3) AS file_,
      CONCAT(s.preferred_last, ', ', s.preferred_first) AS [name],
      pr.home_department,
      pr.home_cost_number,
      pr.clock_,
      pr.total_reg_hours,
      pr.total_ot_hours,
      pr.total_hours_3_4,
      pr.total_reg_earnings,
      pr.total_ot_earnings,
      pr.total_earnings_3_4_5,
      pr.gross_pay,
      pr.total_taxes,
      pr.total_deductions,
      pr.total_deposits,
      pr.net_pay,
      LAG(pr.total_reg_earnings, 1, 0) OVER (
        PARTITION BY
          CONCAT(pr.company, pr.file_)
        ORDER BY
          pr.pay_date
      ) AS total_reg_earnings_prev,
      LAG(pr.total_ot_earnings, 1, 0) OVER (
        PARTITION BY
          CONCAT(pr.company, pr.file_)
        ORDER BY
          pr.pay_date
      ) AS total_ot_earnings_prev,
      LAG(pr.total_earnings_3_4_5, 1, 0) OVER (
        PARTITION BY
          CONCAT(pr.company, pr.file_)
        ORDER BY
          pr.pay_date
      ) AS total_earnings_3_4_5_prev
    FROM
      scaffold s
      LEFT JOIN gabby.adp.pr_employeesummary pr ON s.position_id = CONCAT(pr.company, pr.file_)
      AND s.pay_date = pr.pay_date
  ) sub
