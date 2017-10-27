USE gabby
GO

CREATE OR ALTER VIEW payroll.pr_employeesummary_clean AS

SELECT sub.position_id      
      ,sub.pay_date
      ,sub.company	
      ,sub.file_	
      ,sub.name	
      ,sub.home_department	
      ,sub.home_cost_number	
      ,sub.clock_	
      ,sub.total_reg_hours	
      ,sub.total_ot_hours	
      ,sub.total_hours_3_4	            
      ,sub.gross_pay	
      ,sub.total_taxes	
      ,sub.total_deductions	
      ,sub.total_deposits	
      ,sub.net_pay
      ,sub.total_reg_earnings	
	     ,sub.total_reg_earnings_prev
      ,sub.total_ot_earnings
      ,sub.total_ot_earnings_prev
      ,sub.total_earnings_3_4_5
      ,sub.total_earnings_3_4_5_prev
      ,sub.total_reg_earnings_prev - sub.total_reg_earnings AS total_reg_earnings_diff
	     ,CASE
        WHEN sub.total_reg_earnings_prev - sub.total_reg_earnings != 0 THEN 1
        ELSE 0
       END AS total_reg_earnings_diff_flag
      ,sub.total_ot_earnings_prev - sub.total_ot_earnings AS total_ot_earnings_diff
	     ,CASE
        WHEN sub.total_ot_earnings_prev - sub.total_ot_earnings != 0 THEN 1
        ELSE 0
       END AS total_ot_earnings_diff_flag
      ,sub.total_earnings_3_4_5_prev - sub.total_earnings_3_4_5 AS total_earnings_3_4_5_diff
	     ,CASE
        WHEN sub.total_earnings_3_4_5_prev - sub.total_earnings_3_4_5 != 0 THEN 1
        ELSE 0
       END AS total_earnings_3_4_5_diff_flag
       
      ,sr.associate_id
FROM
    (
     SELECT pr.file_	
           ,pr.name	
           ,pr.home_department	
           ,pr.home_cost_number	
           ,pr.clock_	
           ,pr.total_reg_hours	
           ,pr.total_ot_hours	
           ,pr.total_hours_3_4	
           ,pr.total_reg_earnings	
           ,pr.total_ot_earnings	
           ,pr.total_earnings_3_4_5	
           ,pr.gross_pay	
           ,pr.total_taxes	
           ,pr.total_deductions	
           ,pr.total_deposits	
           ,pr.net_pay	
           ,pr.company	
           ,pr.pay_date
	          
           ,CONCAT(pr.company, pr.file_) AS position_id
           ,LAG(pr.total_reg_earnings, 1, 0) OVER(PARTITION BY CONCAT(pr.company, pr.file_) ORDER BY pr.pay_date) AS total_reg_earnings_prev
           ,LAG(pr.total_ot_earnings, 1, 0) OVER(PARTITION BY CONCAT(pr.company, pr.file_) ORDER BY pr.pay_date) AS total_ot_earnings_prev
           ,LAG(pr.total_earnings_3_4_5, 1, 0) OVER(PARTITION BY CONCAT(pr.company, pr.file_) ORDER BY pr.pay_date) AS total_earnings_3_4_5_prev                      
     FROM gabby.adp.pr_employeesummary pr
    ) sub
JOIN gabby.adp.staff_roster sr
  ON sub.position_id = sr.position_id