USE gabby
GO

--CREATE OR ALTER VIEW extracts.dayforce_earningstatementimport_05_directdeposit AS

SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'deposit' AS Category
      ,other_deduction_description AS AccountName
      ,'' AS BankNumber
      ,'' AS TransitNumber
      ,other_deduction_code_pay_statements AS AccountNumber
      ,other_deduction_amount_pay_statements AS Amount
FROM gabby.payroll.historical_earnings_deductions
WHERE LEFT(other_deduction_code_pay_statements, 2) IN ('CK', 'SV')
  AND payroll_company_code != 'ZS1'