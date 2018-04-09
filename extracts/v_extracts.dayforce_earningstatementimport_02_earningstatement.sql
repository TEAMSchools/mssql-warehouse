USE gabby
GO

CREATE OR ALTER VIEW extracts.dayforce_earningstatementimport_02_earningstatement AS

SELECT associate_id AS Example
      ,payroll_company_code AS CompanyCode
      ,tax_id_ssn_ AS SocialSecurityNumber
      ,check_voucher_number AS CheckNumber
      ,pay_date AS CheckDate
      ,CASE WHEN void_check_indicator = 'N' THEN 0 ELSE 1 END AS IsVoid
      ,payroll_name AS Name
      ,'ASK ACCOUNTING'AS CheckType
      ,'semi-monthly' AS PayFrequency
      ,week_number AS PayPeriod
      ,period_beginning_date AS PayPeriodStart
      ,period_end_date AS PayPeriodEnd
      ,total_hours AS GrossHours
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE total_hours END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS GrossHoursYTD
      ,gross_pay AS GrossPay
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE gross_pay END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS GrossPayYTD
      ,'ASK ACCOUNTING' AS PreTaxDeduction
      ,NULL AS PreTaxDeductionYTD
      ,'ASK ACCOUNTING' AS PostTaxDeduction
      ,NULL AS PostTaxDeductionYTD
      ,'ASK ACCOUNTING' AS TotalStatutoryDeduction
      ,NULL AS TotalStatutoryDeductionYTD
      ,net_pay AS NetPay
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE net_pay END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS NetPayYTD
      ,NULL AS Address1
      ,NULL AS Address2
      ,NULL AS PostalCode
      ,NULL AS City
      ,NULL AS State
      ,NULL AS Country
      ,NULL AS LanguageXrefCode
      ,regular_rate_paid AS PayRate
      ,NULL AS Department
      ,NULL AS Job
      ,NULL AS FederalFilingStatus
      ,NULL AS StateFilingStatus
      ,NULL AS FederalExemptions
      ,NULL AS FederalTaxAdjustment
      ,NULL AS StateExemptions
      ,NULL AS StateTaxAdjustment
      ,NULL AS LocalExemptions
      ,NULL AS Message
FROM gabby.payroll.historical_earnings_statements