USE gabby
GO

--CREATE OR ALTER VIEW payroll.payroll_audit AS

WITH final_data AS (

  SELECT sub.position_id
        ,sub.fiscal_year
        ,sub.payroll_week
        ,sub.preview_or_final
        ,sub.preview_number
        ,sub.payroll_run
        ,sub.company_code
        ,sub.payroll_date
        ,sub.file_nbr
        ,sub.dept
        ,sub.cost_nbr
        ,sub.fli_code
        ,sub.rt
        ,sub.state_cd_1
        ,sub.state_cd_2
        ,sub.sui_sdi_code
        ,sub.void_ind
        ,sub.code
        ,sub.code_value
        ,sub.max_final_payroll_date
        ,sub.code_display
        ,sub.employee_number
        ,sub.business_unit_paydate
        ,sub.location_paydate
        ,sub.department_paydate
        ,sub.job_title_paydate
        ,sub.salary_paydate
        ,sub.status_paydate
        ,sub.preferred_name
        ,sub.business_unit_curr
        ,sub.location_curr
        ,sub.department_curr
        ,sub.job_title_curr
        ,sub.salary_curr
        ,sub.status_curr
        ,sub.prev_code_value
        ,sub.prev_payroll_date
        ,sub.code_value - sub.prev_code_value AS code_value_diff
        ,CASE 
          WHEN sub.payroll_date = sub.prev_payroll_date THEN 'New Payroll Code'
          ELSE sub.audit_type
         END AS audit_type
        ,LAG(sub.business_unit_paydate, 1, sub.business_unit_paydate) OVER(
           PARTITION BY sub.fiscal_year, sub.code, sub.employee_number
             ORDER BY sub.payroll_date) AS business_unit_prev_paydate
        ,LAG(sub.location_paydate, 1, sub.location_paydate) OVER(
           PARTITION BY sub.fiscal_year, sub.code, sub.employee_number
             ORDER BY sub.payroll_date) AS location_prev_paydate
        ,LAG(sub.department_paydate, 1, sub.department_paydate) OVER(
           PARTITION BY sub.fiscal_year, sub.code, sub.employee_number
             ORDER BY sub.payroll_date) AS department_prev_paydate
        ,LAG(sub.job_title_paydate, 1, sub.job_title_paydate) OVER(
           PARTITION BY sub.fiscal_year, sub.code, sub.employee_number
             ORDER BY sub.payroll_date) AS job_title_prev_paydate
        ,LAG(sub.salary_paydate, 1, sub.salary_paydate) OVER(
           PARTITION BY sub.fiscal_year, sub.code, sub.employee_number
             ORDER BY sub.payroll_date) AS salary_prev_paydate
        ,LAG(sub.status_paydate, 1, sub.status_paydate) OVER(
           PARTITION BY sub.fiscal_year, sub.code, sub.employee_number
             ORDER BY sub.payroll_date) AS status_prev_paydate
  FROM (
        SELECT pas.position_id
              ,pas.fiscal_year
              ,pas.payroll_week
              ,pas.preview_or_final
              ,pas.preview_number
              ,pas.payroll_run
              ,pas.company_code
              ,pas.payroll_date
              ,pas.file_nbr
              ,pas.dept
              ,pas.cost_nbr
              ,pas.fli_code
              ,pas.rt
              ,pas.state_cd_1
              ,pas.state_cd_2
              ,pas.sui_sdi_code
              ,pas.void_ind
              ,pas.code
              ,pas.code_value
              ,pas.max_final_payroll_date

              ,pas.audit_type
              ,pas.code_display

              ,pas.employee_number
              ,pas.business_unit_paydate
              ,pas.location_paydate
              ,pas.department_paydate
              ,pas.job_title_paydate
              ,pas.salary_paydate
              ,pas.status_paydate

              ,pas.preferred_name
              ,pas.business_unit_curr
              ,pas.location_curr
              ,pas.department_curr
              ,pas.job_title_curr
              ,pas.salary_curr
              ,pas.status_curr
              ,LAG(pas.code_value, 1) OVER(
                 PARTITION BY pas.fiscal_year, pas.code, pas.employee_number
                   ORDER BY pas.payroll_date) AS prev_code_value
              ,LAG(pas.payroll_date, 1) OVER(
                 PARTITION BY pas.fiscal_year, pas.code, pas.employee_number
                   ORDER BY pas.payroll_date) AS prev_payroll_date
        FROM gabby.payroll.payroll_audit_scaffold pas
        WHERE pas.preview_or_final = 'Final'
         ) sub
  )

,preview_data AS (
  SELECT pas.position_id
        ,pas.fiscal_year
        ,pas.payroll_week
        ,pas.preview_or_final
        ,pas.preview_number
        ,pas.payroll_run
        ,pas.company_code
        ,pas.payroll_date
        ,pas.file_nbr
        ,pas.dept
        ,pas.cost_nbr
        ,pas.fli_code
        ,pas.rt
        ,pas.state_cd_1
        ,pas.state_cd_2
        ,pas.sui_sdi_code
        ,pas.void_ind
        ,pas.code
        ,pas.code_value

        ,pas.code_display

        ,pas.employee_number
        ,pas.business_unit_paydate
        ,pas.location_paydate
        ,pas.department_paydate
        ,pas.job_title_paydate
        ,pas.salary_paydate
        ,pas.status_paydate

        ,pas.preferred_name
        ,pas.business_unit_curr
        ,pas.location_curr
        ,pas.department_curr
        ,pas.job_title_curr
        ,pas.salary_curr
        ,pas.status_curr

        ,fd.code_value AS prev_code_value
        ,fd.payroll_date AS prev_payroll_date

        ,pas.code_value - fd.code_value AS code_value_diff
        ,CASE 
          WHEN pas.payroll_date = fd.payroll_date THEN 'New Payroll Code'
          ELSE pas.audit_type
         END AS audit_type

        ,fd.business_unit_paydate AS business_unit_prev_paydate
        ,fd.location_paydate AS location_prev_paydate
        ,fd.department_paydate AS department_prev_paydate
        ,fd.job_title_paydate AS job_title_prev_paydate
        ,fd.salary_paydate AS salary_prev_paydate
        ,fd.status_paydate AS status_prev_paydate
  FROM gabby.payroll.payroll_audit_scaffold pas
  LEFT JOIN final_data fd
    ON fd.max_final_payroll_date = fd.payroll_date --compare to the most recent final payroll date
   AND fd.employee_number = pas.employee_number
   AND fd.code = pas.code
  WHERE pas.preview_or_final = 'Prev'
  )

SELECT *
FROM final_data

UNION ALL

SELECT *
FROM preview_data