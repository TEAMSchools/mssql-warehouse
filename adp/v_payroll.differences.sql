
USE gabby
GO

--CREATE OR ALTER VIEW v_payroll_differences

WITH lead_payroll AS 
(

SELECT pay_date
	   ,file_
	   ,company
	   ,name
	   ,total_reg_earnings AS current_total_reg_earnings
	   ,ISNULL(LEAD(total_reg_earnings,1) OVER (PARTITION BY position_id ORDER BY pay_date DESC),0) AS last_total_reg_earnings 

FROM gabby.adp.v_payroll_summary
)

SELECT pay_date
	   ,file_
	   ,company
	   ,name
	   ,current_total_reg_earnings
	   ,last_total_reg_earnings
	   ,last_total_reg_earnings - current_total_reg_earnings AS difference
	   ,CASE WHEN last_total_reg_earnings - current_total_reg_earnings != 0 THEN 'FLAG' ELSE 'Looks Okay' END AS FLAG
	   
FROM lead_payroll
ORDER BY pay_date DESC
