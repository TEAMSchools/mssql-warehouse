USE gabby
GO

--CREATE OR ALTER VIEW extracts.dayforce_earningstatementimport_03_earning AS

/* 1 - Regular Earnings */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'regular earnings' AS EarningCodeName
      ,regular_hours_detail AS Hours
      ,regular_rate_paid AS Rate
      ,regular_earnings_detail AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE regular_hours_detail END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS HoursYTD
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE regular_earnings_detail END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS AmountYTD
      ,'ASK ACCOUNTING' AS EarningType
FROM payroll.historical_earnings_earnings
WHERE regular_earnings_detail IS NOT NULL
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 2 - Overtime Earnings */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'overtime earnings' AS EarningCodeName
      ,overtime_hours_detail AS Hours
      ,overtime_rate_paid AS Rate
      ,overtime_earnings_detail AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE overtime_hours_detail END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date) AS HoursYTD
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE overtime_earnings_detail END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date) AS AmountYTD
      ,'ASK ACCOUNTING' AS EarningType
FROM payroll.historical_earnings_earnings
WHERE overtime_earnings_detail IS NOT NULL
  AND payroll_company_code != 'ZS1'
      
UNION ALL

/* 3 - Additional Earnings */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,additional_earnings_description + ' (' + additional_earnings_code_pay_statements + ')' AS EarningCodeName
      ,additional_hours AS Hours
      ,additional_earnings_rate_paid AS Rate
      ,additional_earnings AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE additional_hours END) OVER(PARTITION BY associate_id, YEAR(pay_date), additional_earnings_code_pay_statements ORDER BY pay_date) AS HoursYTD
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE additional_earnings END) OVER(PARTITION BY associate_id, YEAR(pay_date), additional_earnings_code_pay_statements ORDER BY pay_date) AS AmountYTD
      ,'ASK ACCOUNTING' AS EarningType
FROM payroll.historical_earnings_earnings
WHERE additional_earnings != 0
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 4 - Memo */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,memo_description + ' (' + memo_code_pay_statements + ')' AS EarningCodeName
      ,'' AS Hours
      ,'' AS Rate
      ,memo_amount AS Amount
      ,'' AS HoursYTD
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE memo_amount END) OVER (PARTITION BY associate_id, YEAR(pay_date), memo_code_pay_statements ORDER BY pay_date) AS AmountYTD
      ,'ASK ACCOUNTING' AS EarningType
FROM payroll.historical_earnings_earnings
WHERE memo_amount != 0
  AND payroll_company_code != 'ZS1'
  AND memo_code_pay_statements NOT IN ('#','&','7','8') 