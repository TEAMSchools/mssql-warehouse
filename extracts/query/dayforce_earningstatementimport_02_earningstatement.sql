SELECT
  associate_id AS example,
  payroll_company_code AS companycode,
  tax_id_ssn_ AS socialsecuritynumber,
  check_voucher_number AS checknumber,
  pay_date AS checkdate,
  CASE
    WHEN void_check_indicator = 'N' THEN 0
    ELSE 1
  END AS isvoid,
  payroll_name AS name,
  CASE
    WHEN net_pay = 0 THEN 'Direct Deposit'
    WHEN LEN(check_voucher_code) < 6 THEN 'Other'
    ELSE 'Check'
  END AS checktype,
  'Semi-Monthly' AS payfrequency,
  CASE
    WHEN DATEPART(DAY, period_end_date) >= 16 THEN DATEPART(MONTH, period_end_date) * 2
    ELSE (DATEPART(MONTH, period_end_date) * 2) - 1
  END AS payperiod,
  CASE
    WHEN period_beginning_date IS NOT NULL THEN period_beginning_date
    WHEN DATEPART(DAY, period_end_date) >= 16 THEN DATEFROMPARTS(
      DATEPART(YEAR, period_end_date),
      DATEPART(MONTH, period_end_date),
      16
    )
    ELSE DATEFROMPARTS(
      DATEPART(YEAR, period_end_date),
      DATEPART(MONTH, period_end_date),
      1
    )
  END AS payperiodstart,
  period_beginning_date,
  period_end_date AS payperiodend,
  total_hours AS grosshours,
  SUM(
    CASE
      WHEN void_check_indicator = 'Y' THEN NULL
      ELSE total_hours
    END
  ) OVER (
    PARTITION BY
      associate_id,
      YEAR(pay_date)
    ORDER BY
      pay_date,
      check_voucher_number
  ) AS grosshoursytd,
  gross_pay AS grosspay,
  SUM(
    CASE
      WHEN void_check_indicator = 'Y' THEN NULL
      ELSE gross_pay
    END
  ) OVER (
    PARTITION BY
      associate_id,
      YEAR(pay_date)
    ORDER BY
      pay_date,
      check_voucher_number
  ) AS grosspayytd,
  '' AS pretaxdeduction,
  '' AS pretaxdeductionytd,
  '' AS posttaxdeduction,
  '' AS posttaxdeductionytd,
  '' AS totalstatutorydeduction,
  '' AS totalstatutorydeductionytd,
  net_pay AS netpay,
  SUM(
    CASE
      WHEN void_check_indicator = 'Y' THEN NULL
      ELSE net_pay
    END
  ) OVER (
    PARTITION BY
      associate_id,
      YEAR(pay_date)
    ORDER BY
      pay_date,
      check_voucher_number
  ) AS netpayytd,
  '' AS address1,
  '' AS address2,
  '' AS postalcode,
  '' AS city,
  '' AS state,
  '' AS country,
  '' AS languagexrefcode,
  regular_rate_paid AS payrate,
  '' AS department,
  '' AS job,
  '' AS federalfilingstatus,
  '' AS statefilingstatus,
  '' AS federalexemptions,
  '' AS federaltaxadjustment,
  '' AS stateexemptions,
  '' AS statetaxadjustment,
  '' AS localexemptions,
  '' AS message
FROM
  gabby.payroll.historical_earnings_statements
WHERE
  payroll_company_code <> 'ZS1'
