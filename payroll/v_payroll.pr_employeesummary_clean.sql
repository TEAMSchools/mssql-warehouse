USE gabby
GO

CREATE OR ALTER VIEW payroll.pr_employeesummary_clean AS

SELECT dates.position_id      
      ,dates.pay_date
      ,pay.company
      ,pay.file_
      ,COALESCE(pay.name,dates.last_name + ', ' + dates.first_name) AS Name
      ,pay.home_department
      ,pay.home_cost_number
      ,pay.clock_
      ,pay.total_reg_hours
      ,pay.total_ot_hours
      ,pay.total_hours_3_4
      ,pay.gross_pay
      ,pay.total_taxes
      ,pay.total_deductions
      ,pay.total_deposits
      ,pay.net_pay
      ,pay.total_reg_earnings
      ,pay.total_reg_earnings_prev
      ,pay.total_ot_earnings
      ,pay.total_ot_earnings_prev
      ,pay.total_earnings_3_4_5
      ,pay.total_earnings_3_4_5_prev
      ,pay.total_reg_earnings_prev - pay.total_reg_earnings AS total_reg_earnings_diff
      ,CASE
        WHEN (pay.total_reg_earnings_prev - pay.total_reg_earnings != 0 OR pay.total_reg_earnings IS NULL) THEN 1
        ELSE 0
       END AS total_reg_earnings_diff_flag
      ,pay.total_ot_earnings_prev - pay.total_ot_earnings AS total_ot_earnings_diff
      ,CASE
        WHEN (pay.total_ot_earnings_prev - pay.total_ot_earnings != 0 OR pay.total_ot_earnings IS NULL)THEN 1
        ELSE 0
       END AS total_ot_earnings_diff_flag
      ,pay.total_earnings_3_4_5_prev - pay.total_earnings_3_4_5 AS total_earnings_3_4_5_diff
      ,CASE
        WHEN (pay.total_earnings_3_4_5_prev - pay.total_earnings_3_4_5 != 0 OR pay.total_earnings_3_4_5 IS NULL) THEN 1
        ELSE 0
       END AS total_earnings_3_4_5_diff_flag
       
      ,pay.associate_id


FROM (

      SELECT p.associate_id
             ,p.position_id
             ,p.first_name
             ,p.last_name
             ,COALESCE(p.rehire_date, p.hire_date) AS hire_date
             ,p.termination_date
             ,p.position_status
             ,e.pay_date

      FROM gabby.adp.staff_roster p 
           LEFT JOIN 
                (SELECT DISTINCT pay_date
                FROM gabby.payroll.pr_employeesummary_clean) e
      ON e.pay_date BETWEEN COALESCE(p.rehire_date, p.hire_date) AND COALESCE(DATEADD(day,16,p.termination_date),DATEADD(day,16,GETDATE()))

      WHERE p.termination_date IS NULL
            OR p.termination_date >= DATEADD(day,-30,GETDATE())
            
           ) dates

LEFT OUTER JOIN

(SELECT sub.position_id      
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
  ON sub.position_id = sr.position_id) pay
  
ON dates.position_id = pay.position_id   
   AND dates.pay_date = pay.pay_date

WHERE dates.position_id IS NOT NULL