USE gabby
GO

CREATE OR ALTER VIEW dayforce.employee_status_clean AS

SELECT sub.number
      ,sub.position_id
      ,sub.[status]
      ,sub.status_reason_description
      ,sub.base_salary
      ,sub.effective_start
      ,DATEADD(DAY, -1, sub.effective_start_next) AS effective_end
FROM
    (
     SELECT ds.number
           ,ds.[status]
           ,ds.status_reason_description
           ,CONVERT(DATE, ds.effective_start) AS effective_start
           ,CONVERT(MONEY, ds.base_salary) AS base_salary
           ,LEAD(CONVERT(DATE, ds.effective_start), 1) OVER(
              PARTITION BY ds.number 
                ORDER BY CONVERT(DATE, ds.effective_start)) AS effective_start_next

           ,CONCAT(CASE
                    WHEN e.legal_entity_name = 'KIPP New Jersey' THEN '9AM'
                    WHEN e.legal_entity_name = 'TEAM Academy Charter Schools' THEN '2Z3'
                    WHEN e.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN '3LE'
                    WHEN e.legal_entity_name = 'KIPP Miami' THEN '47S'
                   END
                  ,ds.number) AS position_id
     FROM gabby.dayforce.employee_status ds
     JOIN gabby.dayforce.employees e
       ON ds.number = e.df_employee_number
    ) sub
WHERE sub.effective_start <= DATEADD(DAY, -1, sub.effective_start_next)
        OR sub.effective_start_next IS NULL
