
USE gabby
GO

--CREATE OR ALTER VIEW v_payroll_summary

SELECT company + file_ AS position_id
	   ,name
	   ,total_reg_hours
	   ,total_ot_hours
	   ,total_hours_3_4
	   ,total_reg_earnings
	   ,total_ot_earnings
	   ,total_earnings_3_4_5
	   ,gross_pay
	   ,total_taxes
	   ,total_deductions
	   ,total_deposits
	   ,net_pay
	   ,pay_date



FROM adp.pr_employeesummary

ORDER BY pay_date DESC, company ASC