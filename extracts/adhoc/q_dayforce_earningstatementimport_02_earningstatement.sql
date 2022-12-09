select
  associate_id as example,
  payroll_company_code as companycode,
  tax_id_ssn_ as socialsecuritynumber,
  check_voucher_number as checknumber,
  pay_date as checkdate,
  case
    when void_check_indicator = 'N' then 0
    else 1
  end as isvoid,
  payroll_name as name,
  case
    when net_pay = 0 then 'Direct Deposit'
    when len(check_voucher_code) < 6 then 'Other'
    else 'Check'
  end as checktype,
  'Semi-Monthly' as payfrequency,
  case
    when datepart(day, period_end_date) >= 16 then datepart(month, period_end_date) * 2
    else (datepart(month, period_end_date) * 2) - 1
  end as payperiod,
  case
    when period_beginning_date is not null then period_beginning_date
    when datepart(day, period_end_date) >= 16 then datefromparts(datepart(year, period_end_date), datepart(month, period_end_date), 16)
    else datefromparts(datepart(year, period_end_date), datepart(month, period_end_date), 1)
  end as payperiodstart,
  period_beginning_date,
  period_end_date as payperiodend,
  total_hours as grosshours,
  sum(
    case
      when void_check_indicator = 'Y' then null
      else total_hours
    end
  ) over (
    partition by
      associate_id,
      year(pay_date)
    order by
      pay_date,
      check_voucher_number
  ) as grosshoursytd,
  gross_pay as grosspay,
  sum(
    case
      when void_check_indicator = 'Y' then null
      else gross_pay
    end
  ) over (
    partition by
      associate_id,
      year(pay_date)
    order by
      pay_date,
      check_voucher_number
  ) as grosspayytd,
  '' as pretaxdeduction,
  '' as pretaxdeductionytd,
  '' as posttaxdeduction,
  '' as posttaxdeductionytd,
  '' as totalstatutorydeduction,
  '' as totalstatutorydeductionytd,
  net_pay as netpay,
  sum(
    case
      when void_check_indicator = 'Y' then null
      else net_pay
    end
  ) over (
    partition by
      associate_id,
      year(pay_date)
    order by
      pay_date,
      check_voucher_number
  ) as netpayytd,
  '' as address1,
  '' as address2,
  '' as postalcode,
  '' as city,
  '' as state,
  '' as country,
  '' as languagexrefcode,
  regular_rate_paid as payrate,
  '' as department,
  '' as job,
  '' as federalfilingstatus,
  '' as statefilingstatus,
  '' as federalexemptions,
  '' as federaltaxadjustment,
  '' as stateexemptions,
  '' as statetaxadjustment,
  '' as localexemptions,
  '' as message
from
  gabby.payroll.historical_earnings_statements
where
  payroll_company_code <> 'ZS1'
