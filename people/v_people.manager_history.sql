USE gabby
GO

CREATE OR ALTER VIEW people.manager_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
      ,sub.file_number
      ,sub.reports_to_associate_id
      ,sub.reports_to_employee_number
      ,sub.reports_to_effective_date
      ,sub.source_system
      ,COALESCE(
           sub.reports_to_effective_end_date
          ,DATEADD(DAY, -1, LEAD(sub.reports_to_effective_date, 1) OVER(PARTITION BY sub.associate_id ORDER BY sub.reports_to_effective_date))
         ) AS reports_to_effective_end_date
      ,COALESCE(sub.reports_to_effective_end_date
               ,DATEADD(DAY, -1, LEAD(sub.reports_to_effective_date, 1) OVER(PARTITION BY sub.associate_id ORDER BY sub.reports_to_effective_date))
               ,DATEFROMPARTS(CASE
                               WHEN DATEPART(YEAR, sub.reports_to_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                AND DATEPART(MONTH, sub.reports_to_effective_date) >= 7
                                    THEN DATEPART(YEAR, sub.reports_to_effective_date) + 1
                               WHEN DATEPART(YEAR, GETDATE()) = gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                                AND DATEPART(MONTH, GETDATE()) >= 7
                                    THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 2
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS reports_to_effective_end_date_eoy
FROM
    (
     /* ADP */
     SELECT mh.associate_id
           ,mh.position_id
           --,sre.employee_number AS file_number
           ,NULL AS file_number
           ,mh.reports_to_associate_id
           ,CASE 
             WHEN CONVERT(DATE, mh.reports_to_effective_date) > '2021-01-01' THEN CONVERT(DATE, mh.reports_to_effective_date)
             ELSE '2021-01-01'
            END AS reports_to_effective_date
           ,CONVERT(DATE, mh.reports_to_effective_end_date) AS reports_to_effective_end_date

           ,sre.employee_number

           ,srm.employee_number AS reports_to_employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.manager_history mh
     JOIN gabby.people.employee_numbers sre
       ON mh.associate_id = sre.associate_id
      AND sre.is_active = 1
     JOIN gabby.people.employee_numbers srm
       ON mh.reports_to_associate_id = srm.associate_id
      AND srm.is_active = 1
     WHERE '2021-01-01' BETWEEN CONVERT(DATE, mh.reports_to_effective_date) AND COALESCE(CONVERT(DATE, mh.reports_to_effective_end_date), GETDATE())
        OR CONVERT(DATE, mh.reports_to_effective_date) > '2021-01-01'

     UNION ALL

     /* DF */
     SELECT sre.associate_id AS associate_id

           ,dm.position_id
           --,dm.employee_reference_code AS file_number
           ,NULL AS file_number

           ,srm.associate_id AS reports_to_associate_id

           ,dm.manager_effective_start AS reports_to_effective_date
           ,CASE 
             WHEN dm.manager_effective_end < '2020-12-31' THEN dm.manager_effective_end
             ELSE '2020-12-31'
            END AS reports_to_effective_end_date
           ,dm.employee_reference_code AS employee_number
           ,dm.manager_employee_number AS reports_to_employee_number
           ,'DF' AS source_system
     FROM gabby.dayforce.employee_manager_clean dm
     JOIN gabby.people.employee_numbers sre
       ON dm.employee_reference_code = sre.employee_number
      AND sre.is_active = 1
     JOIN gabby.people.employee_numbers srm
       ON dm.manager_employee_number = srm.employee_number
      AND srm.is_active = 1
     WHERE CONVERT(DATE, dm.manager_effective_start) <= '2020-12-31'
    ) sub
