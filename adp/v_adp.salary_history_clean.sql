USE gabby
GO

CREATE OR ALTER VIEW adp.salary_history_clean AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.annual_salary
      ,sub.regular_pay_rate_amount
      ,sub.compensation_change_reason_description
      ,sub.regular_pay_effective_date
      ,COALESCE(sub.regular_pay_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.regular_pay_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.regular_pay_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.regular_pay_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.regular_pay_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.regular_pay_effective_date) + 1
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS regular_pay_effective_end_date
FROM
    (
     SELECT sh.associate_id
           ,sh.position_id
           ,CONVERT(DATE, sh.regular_pay_effective_date) AS regular_pay_effective_date
           ,CONVERT(DATE, sh.regular_pay_effective_end_date) AS regular_pay_effective_end_date
           ,CONVERT(MONEY, sh.annual_salary) AS annual_salary
           ,CONVERT(MONEY, sh.regular_pay_rate_amount) AS regular_pay_rate_amount
           ,sh.compensation_change_reason_description

           ,sr.file_number AS employee_number
     FROM gabby.adp.salary_history sh
     JOIN gabby.adp.employees_all sr
       ON sh.associate_id = sr.associate_id
     WHERE (CONVERT(DATE, sh.regular_pay_effective_date) < CONVERT(DATE, sh.regular_pay_effective_end_date) OR sh.regular_pay_effective_end_date IS NULL)
    ) sub
WHERE sub.annual_salary > 0
