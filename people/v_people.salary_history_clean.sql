USE gabby
GO

CREATE OR ALTER VIEW people.salary_history_clean AS

WITH adp_salary_history_clean AS (
     SELECT sh.associate_id
           ,sh.position_id
           ,CASE 
             WHEN sh.regular_pay_effective_date < CONVERT(DATE, '2021-01-01') THEN CONVERT(DATE, '2021-01-01') ELSE CONVERT(DATE,sh.regular_pay_effective_date)
            END AS regular_pay_effective_date
            ,CONVERT(DATE, sh.regular_pay_effective_end_date) AS regular_pay_effective_end_date
           ,CONVERT(MONEY, sh.annual_salary) AS annual_salary
           ,CONVERT(MONEY, sh.regular_pay_rate_amount) AS regular_pay_rate_amount
           ,sh.compensation_change_reason_description

           ,sr.file_number AS employee_number
     FROM gabby.adp.salary_history sh
     JOIN gabby.adp.employees_all sr
       ON sh.associate_id = sr.associate_id
     WHERE (CONVERT(DATE, sh.regular_pay_effective_date) < CONVERT(DATE, sh.regular_pay_effective_end_date) OR sh.regular_pay_effective_end_date IS NULL)
  )

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.annual_salary
      ,sub.regular_pay_rate_amount
      ,sub.compensation_change_reason_description
      ,sub.regular_pay_effective_date
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
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS regular_pay_effective_end_date_eoy
FROM
    (SELECT *
     FROM adp_salary_history_clean
     WHERE CONVERT(DATE, regular_pay_effective_date) < CONVERT(DATE, regular_pay_effective_end_date)
        OR CONVERT(DATE, regular_pay_effective_end_date) IS NULL
     
     UNION ALL
     
     SELECT sr.associate_id
           ,NULL AS position_id
           ,CONVERT(DATE,ds.effective_start) AS regular_pay_effective_date
           ,CASE 
             WHEN CONVERT(DATE,ds.effective_end) > CONVERT(DATE,'2020-12-31') THEN CONVERT(DATE,'2020-12-31') ELSE COALESCE(CONVERT(DATE, ds.effective_end),CONVERT(DATE,'2020-12-31'))
            END AS regular_pay_effective_end_date
           ,CONVERT(MONEY, ds.base_salary) AS annual_salary
           ,NULL AS regular_pay_rate_amount
           ,ds.status_reason_description AS compensation_change_reason_description

           ,sr.file_number AS employee_number
     FROM gabby.dayforce.employee_status ds
     JOIN gabby.adp.employees_all sr
       ON ds.number = sr.file_number
     WHERE (CONVERT(DATE, ds.effective_start) < CONVERT(DATE, ds.effective_end)
              OR ds.effective_end IS NULL)

    ) sub
WHERE sub.annual_salary > 0