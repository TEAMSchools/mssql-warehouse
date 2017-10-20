USE gabby
GO

CREATE OR ALTER VIEW payroll.pr_employeesummary_clean AS

WITH ids AS (
   SELECT associate_id
         ,position_id
   FROM gabby.adp.staff_roster
   ),

summary AS ( 
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
    )

SELECT i.associate_id
      ,s.position_id      
      ,s.pay_date
      ,s.company	
      ,s.file_	
      ,s.name	
      ,s.home_department	
      ,s.home_cost_number	
      ,s.clock_	
      ,s.total_reg_hours	
      ,s.total_ot_hours	
      ,s.total_hours_3_4	      
      ,s.total_ot_earnings	
      ,s.total_earnings_3_4_5	
      ,s.gross_pay	
      ,s.total_taxes	
      ,s.total_deductions	
      ,s.total_deposits	
      ,s.net_pay	     
      ,s.total_reg_earnings	
	     ,s.total_reg_earnings_prev
      
      ,total_reg_earnings_prev - total_reg_earnings AS total_reg_earnings_diff
	     ,CASE
        WHEN total_reg_earnings_prev - total_reg_earnings != 0 THEN 1
        ELSE 0
       END AS total_reg_earnings_diff_flag
       
FROM summary s
     LEFT OUTER JOIN ids i
     ON s.position_id = i.position_id
      
     