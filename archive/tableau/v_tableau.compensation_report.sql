USE gabby GO
CREATE OR ALTER VIEW
  tableau.compensation_report AS
WITH
  salary AS (
    SELECT
      pp.fiscal_year,
      pp.year_part,
      pp.month,
      pp.pay_period,
      pp.end_date AS pay_date,
      ea.df_employee_number,
      ea.adp_associate_id,
      ea.status,
      ea.annual_salary,
      ea.termination_date,
      ea.first_name,
      ea.last_name,
      adp.adp_position_id,
      adp.adp_position_start_date,
      adp.adp_position_end_date,
      ROW_NUMBER() OVER (
        PARTITION BY
          ea.df_employee_number,
          adp.adp_position_id,
          pp.fiscal_year,
          pp.month,
          pp.pay_period
        ORDER BY
          ea._modified DESC
      ) AS rn_salary_desc
    FROM
      gabby.payroll.pay_periods pp
      JOIN gabby.dayforce.employees_archive ea ON CAST(ea._modified AS DATE) BETWEEN pp.start_date AND pp.end_date
      LEFT JOIN gabby.people.id_crosswalk_adp adp ON ea.adp_associate_id = adp.adp_associate_id
  )
SELECT
  cr.fund_code,
  cr.program_code,
  cr.function_code,
  cr.object_code,
  cr.school_code,
  cr.dept_group_code,
  cr.subject_code,
  cr.employee_code,
  cr.fund_title,
  cr.program_title,
  cr.function_title,
  cr.object_title,
  cr.school_title,
  cr.dept_group_title,
  cr.subject_title,
  cr.employee_title,
  cr.revised_budget,
  cr.available_budget,
  cr.encumbrance,
  cr.actual,
  s.fiscal_year,
  s.month,
  s.pay_period,
  s.pay_date,
  s.df_employee_number,
  s.adp_associate_id,
  s.status,
  s.adp_position_start_date AS position_start_date,
  COALESCE(s.adp_position_end_date, s.termination_date) AS position_end_date,
  s.annual_salary
FROM
  gabby.mip.compensation_report cr
  LEFT JOIN salary s ON cr.employee_code = s.adp_position_id
  AND CAST(SUBSTRING(cr._file, PATINDEX('%[0-9][0-9][0-9][0-9]-%', cr._file), 4) AS INT) = s.year_part
  AND CAST(SUBSTRING(cr._file, PATINDEX('%-[0-9][0-9]-%', cr._file) + 1, 2) AS INT) = s.month
  AND CAST(SUBSTRING(cr._file, PATINDEX('%PP[0-9]%', cr._file) + 2, 1) AS INT) = s.pay_period
  AND s.rn_salary_desc = 1
WHERE
  cr.employee_code <> '0'
