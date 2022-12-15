USE gabby GO
CREATE OR ALTER VIEW
  payroll.salary_projection AS
WITH
  o AS (
    SELECT
      c.position_id,
      c.name,
      c.pay_date,
      c.total_reg_earnings * 24 AS most_recent_salary,
      ROW_NUMBER() OVER (
        PARTITION BY
          c.position_id
        ORDER BY
          c.pay_date DESC
      ) AS rn_most_recent_paydate
    FROM
      gabby.payroll.pr_employeesummary_clean AS c
  )
SELECT
  r.position_id,
  r.pay_date AS snapshot_pay_date,
  (r.total_reg_earnings * 24) AS snapshot_salary,
  o.pay_date AS most_recent_paydate,
  o.most_recent_salary,
  a.associate_id,
  a.preferred_first,
  a.preferred_last
FROM
  gabby.payroll.pr_employeesummary_clean AS r
  LEFT OUTER JOIN o ON r.position_id = o.position_id
  AND o.rn_most_recent_paydate = 1
  LEFT OUTER JOIN gabby.adp.staff_roster AS a ON a.position_id = r.position_id
