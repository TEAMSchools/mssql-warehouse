USE gabby
GO

CREATE OR ALTER VIEW adp.status_history_clean AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_status
      ,sub.termination_reason_description
      ,sub.leave_reason_description
      ,sub.paid_leave_of_absence
      ,sub.status_effective_date
      ,COALESCE(sub.status_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.status_effective_date, 1) OVER(PARTITION BY sub.associate_id ORDER BY sub.status_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.status_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.status_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.status_effective_date) + 1
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS status_effective_end_date
FROM
    (
     SELECT sh.associate_id
           ,sh.position_status
           ,CONVERT(DATE, sh.status_effective_date) AS status_effective_date
           ,CONVERT(DATE, sh.status_effective_end_date) AS status_effective_end_date
           ,sh.termination_reason_description
           ,sh.leave_reason_description
           ,sh.paid_leave_of_absence

           ,sr.df_employee_number AS employee_number
     FROM gabby.adp.status_history sh
     JOIN gabby.adp.staff_roster sr
       ON sh.associate_id = sr.adp_associate_id
     WHERE CONVERT(DATE, sh.status_effective_date) < CONVERT(DATE, sh.status_effective_end_date)
             OR sh.status_effective_end_date IS NULL
    ) sub
