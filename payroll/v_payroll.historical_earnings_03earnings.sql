--CREATE OR ALTER VIEW gabby.payroll.historical_earnings_03earnings AS

--1 - Regular Earnings
      SELECT associate_id AS Example
            ,payroll_company_code AS CompanyCode
            ,tax_id_ssn AS SocialSecurityNumber
            ,check_voucher_number AS CheckNumber
            ,pay_date AS CheckDate
            ,CASE WHEN void_check_indicator = 'N'
                         THEN 0
                         ELSE 1 END AS IsVoid
            ,'regular earnings' AS EarningCodeName
            ,regular_hours_detail AS Hours
            ,regular_rate_paid AS Rate
            ,regular_earnings_detail AS Amount
            ,SUM(regular_hours_detail) OVER (PARTITION BY associate_id,YEAR(pay_date),void_check_indicator ORDER BY pay_date,check_voucher_number) AS HoursYTD
            ,SUM(regular_earnings_detail) OVER (PARTITION BY associate_id,YEAR(pay_date),void_check_indicator ORDER BY pay_date,check_voucher_number) AS AmountYTD
            ,'ASK ACCOUNTING' AS EarningType

      FROM payroll.historical_earnings_earnings
      WHERE regular_earnings_detail IS NOT NULL


UNION ALL

--2 - Overtime Earnings
      SELECT associate_id AS Example
            ,payroll_company_code AS CompanyCode
            ,tax_id_ssn AS SocialSecurityNumber
            ,check_voucher_number AS CheckNumber
            ,pay_date AS CheckDate
            ,CASE WHEN void_check_indicator = 'N'
                         THEN 0
                         ELSE 1 END AS IsVoid
            ,'overtime earnings' AS EarningCodeName
            ,overtime_hours_detail AS Hours
            ,overtime_rate_paid AS Rate
            ,overtime_earnings_detail AS Amount
            ,SUM(overtime_hours_detail) OVER (PARTITION BY associate_id,YEAR(pay_date),void_check_indicator ORDER BY pay_date) AS HoursYTD
            ,SUM(overtime_earnings_detail) OVER (PARTITION BY associate_id,YEAR(pay_date),void_check_indicator  ORDER BY pay_date) AS AmountYTD
            ,'ASK ACCOUNTING' AS EarningType

      FROM payroll.historical_earnings_earnings
      WHERE overtime_earnings_detail IS NOT NULL
      
UNION ALL

--3 - Additional Earnings
SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N'
                   THEN 0
                   ELSE 1 END AS IsVoid
      ,additional_earnings_description + ' (' + additional_earnings_code_pay_statements + ')' AS EarningCodeName
      ,additional_hours AS Hours
      ,additional_earnings_rate_paid AS Rate
      ,additional_earnings AS Amount
      ,SUM(additional_hours) OVER (PARTITION BY associate_id,YEAR(pay_date),additional_earnings_code_pay_statements, void_check_indicator  ORDER BY pay_date) AS HoursYTD
      ,SUM(additional_earnings) OVER (PARTITION BY associate_id,YEAR(pay_date),additional_earnings_code_pay_statements, void_check_indicator  ORDER BY pay_date) AS AmountYTD
      ,'ASK ACCOUNTING' AS EarningType

      FROM payroll.historical_earnings_earnings
      WHERE additional_earnings IS NOT NULL
        AND additional_earnings != 0
        
--4 - Memo

UNION ALL

     SELECT associate_id AS Example
           ,payroll_company_code AS CompanyCode
           ,tax_id_ssn AS SocialSecurityNumber
           ,check_voucher_number AS CheckNumber
           ,pay_date AS CheckDate
           ,CASE WHEN void_check_indicator = 'N'
                        THEN 0
                        ELSE 1 END AS IsVoid
           ,memo_description + ' (' + memo_code_pay_statements + ')' AS EarningCodeName
           ,NULL AS Hours
           ,NULL AS Rate
           ,memo_amount AS Amount
           ,NULL AS HoursYTD
           ,SUM(memo_amount) OVER (PARTITION BY associate_id,YEAR(pay_date), memo_code_pay_statements, void_check_indicator  ORDER BY pay_date) AS AmountYTD
           ,'ASK ACCOUNTING' AS EarningType

           FROM payroll.historical_earnings_earnings
           WHERE memo_amount IS NOT NULL
             AND memo_amount != 0