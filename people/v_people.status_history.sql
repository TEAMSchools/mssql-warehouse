USE gabby
GO

CREATE OR ALTER VIEW people.status_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.file_number
      ,sub.position_status
      ,sub.leave_reason_description
      ,sub.paid_leave_of_absence
      ,sub.source_system
      ,CONVERT(DATE,sub.status_effective_date) AS status_effective_date
      ,CASE
        WHEN sub.termination_reason_description = 'Import Created Action'
             THEN LAG(termination_reason_description, 1) OVER(
                    PARTITION BY associate_id
                      ORDER BY status_effective_date)
        ELSE sub.termination_reason_description
       END AS termination_reason_description -- cover ADP Import status with terminal DF reason
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
                               WHEN DATEPART(YEAR, GETDATE()) = gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                AND DATEPART(MONTH, GETDATE()) >= 7
                                    THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 2
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS status_effective_end_date_eoy
FROM
    (
     /* ADP */
     SELECT sh.associate_id
           ,sh.position_id
           --,sh.file_number
           ,NULL AS file_number
           ,sh.position_status
           ,CASE 
             WHEN CONVERT(DATE, status_effective_date) > '2021-01-01' THEN CONVERT(DATE, status_effective_date)
             ELSE '2021-01-01'
            END AS status_effective_date
           ,CONVERT(DATE, sh.status_effective_end_date) AS status_effective_end_date
           ,sh.termination_reason_description
           ,sh.leave_reason_description
           ,sh.paid_leave_of_absence

           ,sr.employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.status_history sh
     JOIN gabby.people.employee_numbers sr
       ON sh.associate_id = sr.associate_id
      AND sr.is_active = 1
     WHERE CONVERT(DATE, sh.status_effective_date) > '2021-01-01'
             OR COALESCE(CONVERT(DATE, sh.status_effective_end_date), GETDATE()) > '2021-01-01'

     UNION ALL

     /* DF */
     SELECT sr.associate_id

           ,ds.position_id
           --,ds.number AS file_number
           ,NULL AS file_number
           ,ds.[status] AS position_status
           ,ds.effective_start AS status_effective_date
           ,CASE
             WHEN ds.effective_end < '2020-12-31' THEN ds.effective_end
             ELSE '2020-12-31'
            END AS status_effective_end_date
           ,CASE WHEN ds.[status] = 'Terminated' THEN ds.status_reason_description END AS termination_reason_description
           ,CASE WHEN ds.[status] IN ('Administrative Leave', 'Medical Leave of Absence', 'Personal Leave of Absence') THEN ds.status_reason_description END AS leave_reason_description
           ,NULL AS paid_leave_of_absence
           ,ds.number AS employee_number
           ,'DF' AS source_system
     FROM gabby.dayforce.employee_status_clean ds
     JOIN gabby.people.employee_numbers sr
       ON ds.number = sr.employee_number
      AND sr.is_active = 1
     WHERE ds.effective_start <= '2020-12-31'
    ) sub
