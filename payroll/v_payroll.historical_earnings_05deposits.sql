--CREATE OR ALTER VIEW gabby.payroll.historical_earnings_05deposits AS

SELECT associate_id AS Example
     ,payroll_company_code AS CompanyCode
     ,tax_id_ssn AS SocialSecurityNumber
     ,check_voucher_number AS CheckNumber
     ,pay_date AS CheckDate
     ,CASE WHEN void_check_indicator = 'N'
             THEN 0
             ELSE 1 END AS IsVoid
     ,'deposit' AS Category
     ,other_deduction_description AS AccountName
     ,NULL AS BankNumber
     ,NULL AS TransitNumber
     ,other_deduction_code_pay_statements AS AccountNumber
     ,other_deduction_amount_pay_statements AS Amount

FROM payroll.historical_earnings_deductions
       WHERE other_deduction_code_pay_statements LIKE 'CK%'
              OR other_deduction_code_pay_statements LIKE 'SV%'