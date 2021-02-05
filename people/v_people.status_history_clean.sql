USE gabby
GO

--CREATE OR ALTER VIEW people.status_history_clean AS

WITH adp_status_history_clean AS (
     SELECT sh.associate_id
           ,sh.position_id
           ,sh.position_status
           ,CASE 
             WHEN CONVERT(DATE,status_effective_date) < CONVERT(DATE, '2021-01-01') THEN CONVERT(DATE, '2021-01-01') ELSE CONVERT(DATE,status_effective_date)
            END AS status_effective_date           
            ,CONVERT(DATE, sh.status_effective_end_date) AS status_effective_end_date
           ,sh.termination_reason_description
           ,sh.leave_reason_description
           ,sh.paid_leave_of_absence

           ,sr.file_number AS employee_number
     FROM gabby.adp.status_history sh
     JOIN gabby.adp.employees_all sr
       ON sh.associate_id = sr.associate_id
     WHERE CONVERT(DATE, sh.status_effective_date) < CONVERT(DATE, sh.status_effective_end_date)
             OR sh.status_effective_end_date IS NULL
  )

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.position_status
      ,sub.termination_reason_description
      ,sub.leave_reason_description
      ,sub.paid_leave_of_absence
      ,CONVERT(DATE,sub.status_effective_date) AS status_effective_date
      ,COALESCE(
           sub.status_effective_end_date
          ,DATEADD(DAY, -1, LEAD(sub.status_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.status_effective_date))
         ) AS status_effective_end_date
      ,COALESCE(CONVERT(DATE,sub.status_effective_end_date)
               ,DATEADD(DAY, -1, LEAD(sub.status_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.status_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.status_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.status_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.status_effective_date) + 1
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS status_effective_end_date_eoy
FROM
    (
    SELECT *
    FROM adp_status_history_clean
    WHERE CONVERT(DATE, status_effective_date) < CONVERT(DATE, status_effective_end_date)
       OR CONVERT(DATE, status_effective_end_date) IS NULL

     UNION ALL

     SELECT sr.associate_id
           ,NULL AS position_id
           ,ds.[status] AS position_status
           ,CONVERT(DATE,ds.effective_start) AS status_effective_date
           ,CASE 
             WHEN CONVERT(DATE,ds.effective_end) > CONVERT(DATE,'2020-12-31') THEN CONVERT(DATE,'2020-12-31') ELSE COALESCE(CONVERT(DATE, ds.effective_end),CONVERT(DATE,'2020-12-31'))
            END AS status_effective_end_date
           ,CASE WHEN ds.[status] = 'Terminated' THEN ds.status_reason_description ELSE NULL END AS termination_reason_description
           ,CASE WHEN ds.[status] NOT IN ('Pre-Start', 'Active', 'Terminated') THEN ds.status_reason_description ELSE NULL END AS termination_reason_description
           ,NULL AS paid_leave_of_absence

           ,sr.file_number AS employee_number
     FROM gabby.dayforce.employee_status ds
     JOIN gabby.adp.employees_all sr
       ON ds.number = sr.file_number
     WHERE (CONVERT(DATE, ds.effective_start) < CONVERT(DATE, ds.effective_end)
              OR ds.effective_end IS NULL)
    ) sub