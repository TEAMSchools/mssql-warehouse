USE gabby
GO

CREATE OR ALTER VIEW adp.work_assignment_history_clean AS

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
     SELECT wah.associate_id
           ,wah.position_id
           ,wah.business_unit_description
           ,wah.home_department_description
           ,wah.location_description
           ,wah.job_title_code
           ,wah.job_title_description
           ,wah.job_change_reason_code
           ,wah.job_change_reason_description
           ,CAST(wah.position_effective_date AS DATE) AS position_effective_date
           ,CAST(wah.position_effective_end_date AS DATE) AS position_effective_end_date

           ,sr.file_number AS employee_number
     FROM gabby.adp.work_assignment_history wah
     JOIN gabby.adp.employees_all sr
       ON wah.associate_id = sr.associate_id
     WHERE CAST(wah.position_effective_date AS DATE) < CAST(wah.position_effective_end_date AS DATE)
             OR wah.position_effective_end_date IS NULL
    ) sub
