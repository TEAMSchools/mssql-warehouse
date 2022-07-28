USE gabby
GO

CREATE OR ALTER VIEW payroll.additional_annual_earnings_report AS

WITH annual_additional_earnings AS (
  /*sum up total additional earnings by year. Current year will add up as additional earnings are committed to payroll*/
  SELECT academic_year
        ,position_id
        ,additional_earnings_code
        ,additional_earnings_description
        ,SUM(gross_pay) AS ay_additional_earnings_amount
  FROM
      (
       SELECT gabby.utilities.DATE_TO_SY(pay_date) AS academic_year
             ,payroll_company_code + CONVERT(NVARCHAR(8), file_number_pay_statements_) AS position_id
             ,additional_earnings_code
             ,additional_earnings_description
             ,CONVERT(MONEY, gross_pay) AS gross_pay
       FROM gabby.adp.additional_earnings_report
       WHERE additional_earnings_description NOT IN ('Sick', 'C-SICK')
      ) sub
  GROUP BY position_id, additional_earnings_code, additional_earnings_description, academic_year
 )

SELECT ade.academic_year
      ,ade.additional_earnings_code
      ,ade.additional_earnings_description
      ,ade.ay_additional_earnings_amount

      ,eh.employee_number
      ,eh.business_unit
      ,eh.[location]
      ,eh.home_department
      ,eh.job_title
      ,eh.annual_salary

      ,sr.preferred_name
      ,sr.race_ethnicity_reporting
      ,sr.gender_reporting
      ,ROUND(sr.total_professional_experience, 0) - (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - ade.academic_year) AS years_professional_experience
      ,ROUND(sr.years_at_kipp_total, 0) - (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - ade.academic_year) AS years_at_kipp
FROM annual_additional_earnings ade
INNER JOIN gabby.people.employment_history_static eh
  ON ade.position_id = eh.position_id
 AND DATEFROMPARTS((ade.academic_year + 1), 4, 30) BETWEEN eh.effective_start_date AND eh.effective_end_date /* April 30 is the reporting date */
INNER JOIN gabby.people.staff_roster sr
  ON eh.employee_number = sr.employee_number
