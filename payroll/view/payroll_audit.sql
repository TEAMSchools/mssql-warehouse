USE gabby GO
CREATE OR ALTER VIEW
  payroll.payroll_audit AS
WITH
  pas AS (
    SELECT
      pas.position_id,
      pas.fiscal_year,
      pas.payroll_week,
      pas.preview_or_final,
      pas.preview_number,
      pas.payroll_run,
      pas.company_code,
      pas.payroll_date,
      pas.file_nbr,
      pas.dept,
      pas.cost_nbr,
      pas.fli_code,
      pas.rt,
      pas.state_cd_1,
      pas.state_cd_2,
      pas.sui_sdi_code,
      pas.void_ind,
      pas.code,
      pas.code_value,
      pas.max_final_payroll_date,
      pas.audit_type,
      pas.code_display,
      pas.employee_number,
      pas.business_unit_paydate,
      pas.location_paydate,
      pas.department_paydate,
      pas.job_title_paydate,
      pas.salary_paydate,
      pas.status_paydate,
      pas.preferred_name,
      pas.business_unit_curr,
      pas.location_curr,
      pas.department_curr,
      pas.job_title_curr,
      pas.salary_curr,
      pas.status_curr,
      LAG(pas.code_value, 1) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS prev_code_value,
      LAG(pas.payroll_date, 1) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS prev_payroll_date
    FROM
      gabby.payroll.payroll_audit_scaffold AS pas
    WHERE
      pas.preview_or_final = 'Final'
  ),
  final_data AS (
    SELECT
      pas.position_id,
      pas.fiscal_year,
      pas.payroll_week,
      pas.preview_or_final,
      pas.preview_number,
      pas.payroll_run,
      pas.company_code,
      pas.payroll_date,
      pas.file_nbr,
      pas.dept,
      pas.cost_nbr,
      pas.fli_code,
      pas.rt,
      pas.state_cd_1,
      pas.state_cd_2,
      pas.sui_sdi_code,
      pas.void_ind,
      pas.code,
      pas.code_value,
      pas.max_final_payroll_date,
      pas.code_display,
      pas.employee_number,
      pas.business_unit_paydate,
      pas.location_paydate,
      pas.department_paydate,
      pas.job_title_paydate,
      pas.salary_paydate,
      pas.status_paydate,
      pas.preferred_name,
      pas.business_unit_curr,
      pas.location_curr,
      pas.department_curr,
      pas.job_title_curr,
      pas.salary_curr,
      pas.status_curr,
      pas.prev_code_value,
      pas.prev_payroll_date,
      pas.code_value - pas.prev_code_value AS code_value_diff,
      CASE
        WHEN pas.payroll_date = pas.prev_payroll_date THEN 'New Payroll Code'
        ELSE pas.audit_type
      END AS audit_type,
      LAG(
        pas.business_unit_paydate,
        1,
        pas.business_unit_paydate
      ) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS business_unit_prev_paydate,
      LAG(
        pas.location_paydate,
        1,
        pas.location_paydate
      ) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS location_prev_paydate,
      LAG(
        pas.department_paydate,
        1,
        pas.department_paydate
      ) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS department_prev_paydate,
      LAG(
        pas.job_title_paydate,
        1,
        pas.job_title_paydate
      ) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS job_title_prev_paydate,
      LAG(pas.salary_paydate, 1, pas.salary_paydate) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS salary_prev_paydate,
      LAG(pas.status_paydate, 1, pas.status_paydate) OVER (
        PARTITION BY
          pas.fiscal_year,
          pas.code,
          pas.employee_number
        ORDER BY
          pas.payroll_date
      ) AS status_prev_paydate
    FROM
      pas
  ),
  preview_data AS (
    SELECT
      pas.position_id,
      pas.fiscal_year,
      pas.payroll_week,
      pas.preview_or_final,
      pas.preview_number,
      pas.payroll_run,
      pas.company_code,
      pas.payroll_date,
      pas.file_nbr,
      pas.dept,
      pas.cost_nbr,
      pas.fli_code,
      pas.rt,
      pas.state_cd_1,
      pas.state_cd_2,
      pas.sui_sdi_code,
      pas.void_ind,
      pas.code,
      pas.code_value,
      pas.max_final_payroll_date,
      pas.code_display,
      pas.employee_number,
      pas.business_unit_paydate,
      pas.location_paydate,
      pas.department_paydate,
      pas.job_title_paydate,
      pas.salary_paydate,
      pas.status_paydate,
      pas.preferred_name,
      pas.business_unit_curr,
      pas.location_curr,
      pas.department_curr,
      pas.job_title_curr,
      pas.salary_curr,
      pas.status_curr,
      fd.code_value AS prev_code_value,
      fd.payroll_date AS prev_payroll_date,
      fd.business_unit_paydate AS business_unit_prev_paydate,
      fd.location_paydate AS location_prev_paydate,
      fd.department_paydate AS department_prev_paydate,
      fd.job_title_paydate AS job_title_prev_paydate,
      fd.salary_paydate AS salary_prev_paydate,
      fd.status_paydate AS status_prev_paydate,
      pas.code_value - fd.code_value AS code_value_diff,
      CASE
        WHEN pas.payroll_date = fd.payroll_date THEN 'New Payroll Code'
        ELSE pas.audit_type
      END AS audit_type
    FROM
      gabby.payroll.payroll_audit_scaffold AS pas
      LEFT JOIN final_data AS fd ON fd.employee_number = pas.employee_number
      AND fd.code = pas.code
    WHERE
      pas.preview_or_final = 'Prev'
      AND fd.max_final_payroll_date = fd.payroll_date /* compare to the most recent final payroll date */
  )
SELECT
  position_id,
  fiscal_year,
  payroll_week,
  preview_or_final,
  preview_number,
  payroll_run,
  company_code,
  payroll_date,
  file_nbr,
  dept,
  cost_nbr,
  fli_code,
  rt,
  state_cd_1,
  state_cd_2,
  sui_sdi_code,
  void_ind,
  code,
  code_value,
  max_final_payroll_date,
  code_display,
  employee_number,
  business_unit_paydate,
  location_paydate,
  department_paydate,
  job_title_paydate,
  salary_paydate,
  status_paydate,
  preferred_name,
  business_unit_curr,
  location_curr,
  department_curr,
  job_title_curr,
  salary_curr,
  status_curr,
  prev_code_value,
  prev_payroll_date,
  code_value_diff,
  audit_type,
  business_unit_prev_paydate,
  location_prev_paydate,
  department_prev_paydate,
  job_title_prev_paydate,
  salary_prev_paydate,
  status_prev_paydate
FROM
  final_data AS
UNION
SELECT
  position_id,
  fiscal_year,
  payroll_week,
  preview_or_final,
  preview_number,
  payroll_run,
  company_code,
  payroll_date,
  file_nbr,
  dept,
  cost_nbr,
  fli_code,
  rt,
  state_cd_1,
  state_cd_2,
  sui_sdi_code,
  void_ind,
  code,
  code_value,
  max_final_payroll_date,
  code_display,
  employee_number,
  business_unit_paydate,
  location_paydate,
  department_paydate,
  job_title_paydate,
  salary_paydate,
  status_paydate,
  preferred_name,
  business_unit_curr,
  location_curr,
  department_curr,
  job_title_curr,
  salary_curr,
  status_curr,
  prev_code_value,
  prev_payroll_date,
  code_value_diff,
  audit_type,
  business_unit_prev_paydate,
  location_prev_paydate,
  department_prev_paydate,
  job_title_prev_paydate,
  salary_prev_paydate,
  status_prev_paydate
FROM
  preview_data
