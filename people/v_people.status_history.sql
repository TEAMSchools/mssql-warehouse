USE gabby
GO

CREATE OR ALTER VIEW people.status_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.position_status
      ,sub.termination_reason_description
      ,sub.leave_reason_description
      ,sub.paid_leave_of_absence
      ,sub.source_system
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
     SELECT sh.associate_id
           ,sh.position_id
           ,sh.position_status
           ,CASE 
             WHEN CONVERT(DATE, status_effective_date) > '2021-01-01' THEN CONVERT(DATE, status_effective_date)
             ELSE '2021-01-01'
            END AS status_effective_date
           ,CONVERT(DATE, sh.status_effective_end_date) AS status_effective_end_date
           ,sh.termination_reason_description
           ,sh.leave_reason_description
           ,sh.paid_leave_of_absence

           ,sr.file_number AS employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.status_history sh
     JOIN gabby.adp.employees_all sr
       ON sh.associate_id = sr.associate_id
     WHERE CONVERT(DATE, sh.status_effective_date) > '2021-01-01'
             OR COALESCE(CONVERT(DATE, sh.status_effective_end_date), GETDATE()) > '2021-01-01'

     UNION ALL

     SELECT sub.associate_id
           ,sub.position_id
           ,sub.position_status
           ,sub.status_effective_date
           ,COALESCE(DATEADD(DAY, -1, sub.effective_start_next), '2020-12-31') AS status_effective_end_date
           ,sub.termination_reason_description
           ,sub.leave_reason_description
           ,sub.paid_leave_of_absence
           ,sub.employee_number
           ,sub.source_system
     FROM
         (
          SELECT sr.associate_id
                ,ds.[status] AS position_status
                ,CONVERT(DATE, ds.effective_start) AS status_effective_date
                ,CASE WHEN ds.[status] = 'Terminated' THEN ds.status_reason_description END AS termination_reason_description
                ,CASE WHEN ds.[status] IN ('Administrative Leave', 'Medical Leave of Absence', 'Personal Leave of Absence') THEN ds.status_reason_description END AS leave_reason_description
                ,NULL AS paid_leave_of_absence
                ,LEAD(CONVERT(DATE, ds.effective_start), 1) OVER(PARTITION BY ds.number ORDER BY CONVERT(DATETIME2, ds.effective_start)) AS effective_start_next

                ,CONCAT(CASE
                         WHEN e.legal_entity_name = 'KIPP New Jersey' THEN '9AM'
                         WHEN e.legal_entity_name = 'TEAM Academy Charter Schools' THEN '2Z3'
                         WHEN e.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN '3LE'
                         WHEN e.legal_entity_name = 'KIPP Miami' THEN '47S'
                        END
                       ,ds.number) AS position_id

                ,sr.file_number AS employee_number

                ,'DF' AS source_system
          FROM gabby.dayforce.employee_status ds
          JOIN gabby.dayforce.employees e
            ON ds.number = e.df_employee_number
          JOIN gabby.adp.employees_all sr
            ON ds.number = sr.file_number
          WHERE CONVERT(DATE, ds.effective_start) <= '2020-12-31'
         ) sub
    ) sub
