--CREATE OR ALTER VIEW gabby.payroll.historical_earnings_04deduction AS

--1 - regular deductions:
     SELECT associate_id AS Example
          ,payroll_company_code AS CompanyCode
          ,tax_id_ssn AS SocialSecurityNumber
          ,check_voucher_number AS CheckNumber
          ,pay_date AS CheckDate
          ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
          ,other_deduction_description + ' (' + other_deduction_code_pay_statements + ')' AS DeductionName
          ,'ASK ACCOUNTING' AS IsStatutory
          ,'ASK ACCOUNTING' AS IsPreTax
          ,other_deduction_amount_pay_statements AS Amount
          ,SUM(other_deduction_amount_pay_statements) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator, other_deduction_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD

     FROM gabby.payroll.historical_earnings_deductions 
            WHERE other_deduction_code_pay_statements NOT LIKE 'CK%'
                   AND other_deduction_code_pay_statements NOT LIKE 'SV%'
                   AND other_deduction_amount_pay_statements != 0 

--2 federal taxes
UNION ALL 

     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'Federal Tax' AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,federal_tax_amount AS Amount
           ,SUM(federal_tax_amount) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes

UNION ALL

--3 lived in local
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'lived in local tax: ' + lived_in_local_code_pay_statements AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,lived_in_local_amount_pay_statements AS Amount
           ,SUM(lived_in_local_amount_pay_statements) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator,lived_in_local_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE lived_in_local_amount_pay_statements != 0
     
--4 Lived in state
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'lived in state tax: ' + lived_in_state_tax_code_pay_statements AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,lived_in_state_tax_amount_pay_statements AS Amount
           ,SUM(lived_in_state_tax_amount_pay_statements) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator,lived_in_state_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE lived_in_state_tax_amount_pay_statements != 0
     
--5 Medicare Surtax
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'medicare surtax' AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,medicare_surtax_amount AS Amount
           ,SUM(medicare_surtax_amount) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE medicare_surtax_amount != 0

--6 Medicare tax
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'medicare tax' AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,medicare_tax_amount AS Amount
           ,SUM(medicare_tax_amount) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE medicare_tax_amount != 0
     
--7 school district tax
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'school district tax: ' + school_district_tax_code_pay_statements AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,school_district_tax_amount_pay_statements AS Amount
           ,SUM(school_district_tax_amount_pay_statements) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator,school_district_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE school_district_tax_amount_pay_statements != 0
     
--8 social security tax
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'social security tax' AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,social_security_tax_amount AS Amount
           ,SUM(social_security_tax_amount) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE medicare_tax_amount != 0
     
--9 SUI/SDI tax
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'SUI/SDI tax: ' + sui_sdi_tax_code_pay_statements AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,sui_sdi_tax_amount_pay_statements AS Amount
           ,SUM(sui_sdi_tax_amount_pay_statements) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator,sui_sdi_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE sui_sdi_tax_amount_pay_statements != 0
   
--9 Worked in state tax  
UNION ALL
     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                  THEN 0
                  ELSE 1 END AS IsVoid
           ,'worked in state tax: ' + worked_in_state_tax_code_pay_statements AS DeductionName
           ,'ASK ACCOUNTING' AS IsStatutory
           ,'ASK ACCOUNTING' AS IsPreTax
           ,worked_in_state_tax_amount_pay_statements AS Amount
           ,SUM(worked_in_state_tax_amount_pay_statements) OVER (PARTITION BY associate_id, YEAR(pay_date), void_check_indicator,worked_in_state_tax_code_pay_statements ORDER BY pay_date, check_voucher_number) AS YTD
     FROM payroll.historical_earnings_taxes
     WHERE worked_in_state_tax_amount_pay_statements != 0