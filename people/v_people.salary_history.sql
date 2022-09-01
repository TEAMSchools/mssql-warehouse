USE gabby
GO

CREATE OR ALTER VIEW people.salary_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.file_number
      ,sub.annual_salary
      ,sub.regular_pay_rate_amount
      ,sub.compensation_change_reason_description
      ,sub.regular_pay_effective_date
      ,sub.source_system
      ,COALESCE(
           sub.regular_pay_effective_end_date
          ,DATEADD(DAY, -1, LEAD(sub.regular_pay_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.regular_pay_effective_date))
         ) AS regular_pay_effective_end_date
      ,COALESCE(sub.regular_pay_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.regular_pay_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.regular_pay_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.regular_pay_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.regular_pay_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.regular_pay_effective_date) + 1
                               WHEN DATEPART(YEAR, CURRENT_TIMESTAMP) = gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                AND DATEPART(MONTH, CURRENT_TIMESTAMP) >= 7
                                    THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 2
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS regular_pay_effective_end_date_eoy
FROM
    (
     /* ADP */
     SELECT sh.associate_id
           ,sh.position_id
           ,sh.file_number
           ,CASE 
             WHEN CAST(sh.regular_pay_effective_date AS DATE) > '2021-01-01' THEN CAST(sh.regular_pay_effective_date AS DATE)
             ELSE '2021-01-01'
            END AS regular_pay_effective_date
           ,CAST(sh.regular_pay_effective_end_date AS DATE) AS regular_pay_effective_end_date
           ,CAST(sh.annual_salary AS MONEY) AS annual_salary
           ,CAST(sh.regular_pay_rate_amount AS MONEY) AS regular_pay_rate_amount
           ,sh.compensation_change_reason_description

           ,sr.employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.salary_history sh
     JOIN gabby.people.employee_numbers sr
       ON sh.associate_id = sr.associate_id
      AND sr.is_active = 1
     WHERE (CAST(sh.regular_pay_effective_date AS DATE) < CAST(sh.regular_pay_effective_end_date AS DATE)
              OR sh.regular_pay_effective_end_date IS NULL)
       AND ('2021-01-01' BETWEEN CAST(sh.regular_pay_effective_date AS DATE) AND COALESCE(CAST(sh.regular_pay_effective_end_date AS DATE), CURRENT_TIMESTAMP)
              OR CAST(sh.regular_pay_effective_date AS DATE) > '2021-01-01')

     UNION ALL

     /* DF */
     SELECT sr.associate_id

           ,ds.position_id
           ,ds.number AS file_number
           ,ds.effective_start AS regular_pay_effective_date
           ,CASE 
             WHEN ds.effective_end < '2020-12-31' THEN ds.effective_end
             ELSE '2020-12-31'
            END AS regular_pay_effective_end_date
           ,ds.base_salary AS annual_salary
           ,NULL AS regular_pay_rate_amount
           ,ds.status_reason_description AS compensation_change_reason_description
           ,ds.number AS employee_number

           ,'DF' AS source_system
     FROM gabby.dayforce.employee_status_clean ds
     JOIN gabby.people.employee_numbers sr
       ON ds.number = sr.employee_number
      AND sr.is_active = 1
     WHERE CAST(ds.effective_start AS DATE) <= '2020-12-31'
    ) sub
WHERE sub.annual_salary > 0
