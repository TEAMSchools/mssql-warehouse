USE gabby
GO

CREATE OR ALTER VIEW payroll.pr_employeesummary_clean AS

SELECT position_id      
      ,pay_date
      ,company	
      ,file_	
      ,name	
      ,home_department	
      ,home_cost_number	
      ,clock_	
      ,total_reg_hours	
      ,total_ot_hours	
      ,total_hours_3_4	      
      ,total_ot_earnings	
      ,total_earnings_3_4_5	
      ,gross_pay	
      ,total_taxes	
      ,total_deductions	
      ,total_deposits	
      ,net_pay	     
      ,total_reg_earnings	
	     ,total_reg_earnings_prev
      
      ,total_reg_earnings_prev - total_reg_earnings AS total_reg_earnings_diff
	     ,CASE
        WHEN total_reg_earnings_prev - total_reg_earnings != 0 THEN 1
        ELSE 0
       END AS total_reg_earnings_diff_flag
FROM 
    (
     SELECT file_	
           ,name	
           ,home_department	
           ,home_cost_number	
           ,clock_	
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
           ,company	
           ,pay_date
	          
           ,CONCAT(company, file_) AS position_id
           ,LAG(total_reg_earnings, 1, 0) OVER(PARTITION BY CONCAT(company, file_) ORDER BY pay_date) AS total_reg_earnings_prev
     FROM gabby.adp.pr_employeesummary
    ) sub