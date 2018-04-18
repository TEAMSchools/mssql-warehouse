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
      ,CASE 
        WHEN net_pay = 0 THEN 'Direct Deposit'
        WHEN LEN(check_voucher_code) < 6 THEN 'Other' 
        ELSE 'Check' 
       END AS CheckType 
      ,'Semi-Monthly' AS PayFrequency
      ,CASE 
        WHEN DATEPART(DAY, period_end_date) >= 16 THEN DATEPART(MONTH, period_end_date) * 2
        ELSE (DATEPART(MONTH, period_end_date) * 2) - 1
       END AS PayPeriod
      ,CASE
        WHEN period_beginning_date IS NOT NULL THEN period_beginning_date
        WHEN DATEPART(DAY, period_end_date) >= 16 THEN DATEFROMPARTS(DATEPART(YEAR, period_end_date), DATEPART(MONTH, period_end_date), 16)
        ELSE DATEFROMPARTS(DATEPART(YEAR, period_end_date), DATEPART(MONTH, period_end_date), 1)
       END AS PayPeriodStart
      ,period_beginning_date
      ,period_end_date AS PayPeriodEnd
      ,total_hours AS GrossHours
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE total_hours END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS GrossHoursYTD
      ,gross_pay AS GrossPay
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE gross_pay END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS GrossPayYTD
      ,'' AS PreTaxDeduction
      ,'' AS PreTaxDeductionYTD
      ,'' AS PostTaxDeduction
      ,'' AS PostTaxDeductionYTD
      ,'' AS TotalStatutoryDeduction
      ,'' AS TotalStatutoryDeductionYTD
      ,net_pay AS NetPay
      ,SUM(CASE WHEN void_check_indicator = 'Y' THEN NULL ELSE net_pay END) OVER(PARTITION BY associate_id, YEAR(pay_date) ORDER BY pay_date, check_voucher_number) AS NetPayYTD
      ,'' AS Address1
      ,'' AS Address2
      ,'' AS PostalCode
      ,'' AS City
      ,'' AS State
      ,'' AS Country
      ,'' AS LanguageXrefCode
      ,regular_rate_paid AS PayRate
      ,'' AS Department
      ,'' AS Job
      ,'' AS FederalFilingStatus
      ,'' AS StateFilingStatus
      ,'' AS FederalExemptions
      ,'' AS FederalTaxAdjustment
      ,'' AS StateExemptions
      ,'' AS StateTaxAdjustment
      ,'' AS LocalExemptions
      ,'' AS Message
FROM gabby.payroll.historical_earnings_statements
WHERE payroll_company_code != 'ZS1'