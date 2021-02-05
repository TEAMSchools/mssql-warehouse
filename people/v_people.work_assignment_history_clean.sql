USE gabby
GO

CREATE OR ALTER VIEW people.work_assignment_history_clean AS

WITH adp_work_assignment_history_clean AS (

     SELECT wah.associate_id
           ,wah.position_id
           ,wah.business_unit_description
           ,wah.home_department_description
           ,wah.location_description
           ,wah.job_title_code
           ,wah.job_title_description
           ,wah.job_change_reason_code
           ,wah.job_change_reason_description
           ,CASE 
             WHEN position_effective_date < CONVERT(DATE, '2021-01-01') THEN CONVERT(DATE, '2021-01-01') ELSE CONVERT(DATE,position_effective_date)
            END AS position_effective_date
           ,CONVERT(DATE, wah.position_effective_end_date) AS position_effective_end_date

           ,sr.file_number AS employee_number
     FROM gabby.adp.work_assignment_history wah
     JOIN gabby.adp.employees_all sr
       ON wah.associate_id = sr.associate_id
     WHERE (CONVERT(DATE, wah.position_effective_date) 
                           < CONVERT(DATE, wah.position_effective_end_date)
             OR wah.position_effective_end_date IS NULL)
  )

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.business_unit_description
      ,sub.location_description
      ,sub.home_department_description
      ,sub.job_title_code
      ,sub.job_title_description
      ,sub.job_change_reason_code
      ,sub.job_change_reason_description
      ,sub.position_effective_date
      ,COALESCE(
           sub.position_effective_end_date
          ,DATEADD(DAY, -1, LEAD(sub.position_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.position_effective_date))
         ) AS position_effective_end_date
      ,COALESCE(sub.position_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.position_effective_date, 1) OVER(PARTITION BY sub.position_id ORDER BY sub.position_effective_date))
               ,DATEFROMPARTS(CASE 
                               WHEN DATEPART(YEAR,sub.position_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH,sub.position_effective_date) >= 7
                                    THEN DATEPART(YEAR,sub.position_effective_date) + 1
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS position_effective_end_date_eoy
FROM
    (
    SELECT *
    FROM adp_work_assignment_history_clean
    WHERE CONVERT(DATE, position_effective_date) < CONVERT(DATE, position_effective_end_date)
       OR CONVERT(DATE, position_effective_end_date) IS NULL

     UNION ALL

     SELECT sr.associate_id
           ,NULL AS position_id

           ,dwa.legal_entity_name AS business_unit_description
           ,dwa.department_name AS home_department_description
           ,dwa.physical_location_name AS location_description
           ,NULL AS job_title_code
           ,dwa.job_name AS job_title_description
           ,NULL AS job_change_reason_code
           ,NULL AS job_change_reason_description
           ,CONVERT(DATE, dwa.work_assignment_effective_start) AS position_effective_date
           ,CASE 
             WHEN CONVERT(DATE,dwa.work_assignment_effective_end) > CONVERT(DATE,'2020-12-31') THEN CONVERT(DATE,'2020-12-31') ELSE COALESCE(CONVERT(DATE, dwa.work_assignment_effective_end),CONVERT(DATE,'2020-12-31'))
            END AS position_effective_end_date
           ,sr.file_number AS employee_number
     FROM gabby.dayforce.employee_work_assignment dwa
     JOIN gabby.adp.employees_all sr
       ON dwa.employee_reference_code = sr.file_number
     WHERE (CONVERT(DATE, dwa.work_assignment_effective_start) < CONVERT(DATE, dwa.work_assignment_effective_end)
              OR dwa.work_assignment_effective_end IS NULL)
           AND primary_work_assignment = 1

    ) sub