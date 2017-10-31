USE gabby
GO

CREATE OR ALTER VIEW payroll.salary AS

SELECT a.position_id
      ,a.associate_id
      
      ,o.name
      ,o.most_recent_paydate
      ,o.most_recent_salary
      
      ,r.snapshot_pay_date
      ,r.snapshot_salary
FROM (
     SELECT real_time.position_id
           ,real_time.gross_pay * 24 AS snapshot_salary
           ,real_time.pay_date AS snapshot_pay_date
     FROM gabby.payroll.pr_employeesummary_clean real_time
     ) r
LEFT OUTER JOIN (

     SELECT DISTINCT 
            c.position_id
           ,c.name
           ,c.gross_pay * 24 AS most_recent_salary
           ,s.most_recent_paydate
             
     FROM gabby.payroll.pr_employeesummary_clean c
          INNER JOIN (
          SELECT p.position_id
                ,MAX(p.pay_date) AS most_recent_paydate
     FROM gabby.payroll.pr_employeesummary_clean p         
     GROUP BY p.position_id ) AS s
          ON c.position_id = s.position_id 
          AND s.most_recent_paydate = pay_date
      ) o
ON r.position_id = o.position_id

LEFT OUTER JOIN (
     SELECT associate_id
           ,position_id
     FROM gabby.adp.staff_roster
     ) a
ON a.position_id = r.position_id