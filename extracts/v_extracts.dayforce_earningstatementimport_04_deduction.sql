USE gabby
GO

--CREATE OR ALTER VIEW extracts.dayforce_earningstatementimport_04_deduction AS

/* 1 - regular deductions: */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,other_deduction_description + ' (' + other_deduction_code_pay_statements + ')' AS DeductionName
      ,'0' AS IsStatutory
      ,CASE WHEN other_deduction_code_pay_statements IN ('L','D42','HCP','P','E','HSA','D31','Q','D40','D30','30') THEN 1 ELSE 0 END AS IsPreTax
      ,other_deduction_amount_pay_statements AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE other_deduction_amount_pay_statements END) OVER(PARTITION BY associate_id, YEAR(pay_date), other_deduction_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_deductions 
WHERE LEFT(other_deduction_code_pay_statements, 2) NOT IN ('CK', 'SV')
  AND other_deduction_amount_pay_statements != 0
  AND payroll_company_code != 'ZS1'

/* 2 federal taxes */
UNION ALL 

SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'Federal Tax' AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,federal_tax_amount AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE federal_tax_amount END) OVER (PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE federal_tax_amount != 0
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 3 lived in local */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'lived in local tax: ' + lived_in_local_code_pay_statements AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,lived_in_local_amount_pay_statements AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE lived_in_local_amount_pay_statements END) OVER (PARTITION BY associate_id, YEAR(pay_date), lived_in_local_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE lived_in_local_amount_pay_statements != 0
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 4 Lived in state */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'lived in state tax: ' + lived_in_state_tax_code_pay_statements AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,lived_in_state_tax_amount_pay_statements AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE lived_in_state_tax_amount_pay_statements END) OVER (PARTITION BY associate_id, YEAR(pay_date), lived_in_state_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE lived_in_state_tax_amount_pay_statements != 0
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 5 Medicare Surtax */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'medicare surtax' AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,medicare_surtax_amount AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE medicare_surtax_amount END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE medicare_surtax_amount != 0
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 6 Medicare tax */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'medicare tax' AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,medicare_tax_amount AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE medicare_tax_amount END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE medicare_tax_amount != 0
  AND payroll_company_code != 'ZS1'
     
UNION ALL

/* 7 school district tax */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'school district tax: ' + school_district_tax_code_pay_statements AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,school_district_tax_amount_pay_statements AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE school_district_tax_amount_pay_statements END) OVER(PARTITION BY associate_id, YEAR(pay_date), school_district_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE school_district_tax_amount_pay_statements != 0
  AND payroll_company_code != 'ZS1'
     
UNION ALL

/* 8 social security tax */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'social security tax' AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,social_security_tax_amount AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE social_security_tax_amount END) OVER (PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE social_security_tax_amount != 0
  AND payroll_company_code != 'ZS1'
     

UNION ALL

/* 9 SUI/SDI tax */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'SUI/SDI tax: ' + sui_sdi_tax_code_pay_statements AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,sui_sdi_tax_amount_pay_statements AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE sui_sdi_tax_amount_pay_statements END) OVER(PARTITION BY associate_id, YEAR(pay_date), sui_sdi_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE sui_sdi_tax_amount_pay_statements != 0
  AND payroll_company_code != 'ZS1'

UNION ALL

/* 9 Worked in state tax */
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,'worked in state tax: ' + worked_in_state_tax_code_pay_statements AS DeductionName
      ,'1' AS IsStatutory
      ,'0' AS IsPreTax
      ,worked_in_state_tax_amount_pay_statements AS Amount
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE worked_in_state_tax_amount_pay_statements END) OVER(PARTITION BY associate_id, YEAR(pay_date), worked_in_state_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
FROM gabby.payroll.historical_earnings_taxes
WHERE worked_in_state_tax_amount_pay_statements != 0
  AND payroll_company_code != 'ZS1'