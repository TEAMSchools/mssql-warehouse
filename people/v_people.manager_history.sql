USE gabby
GO

CREATE OR ALTER VIEW people.manager_history AS

SELECT sub.employee_number
      ,sub.associate_id
      ,sub.position_id
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
                               ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1
                              END, 6, 30)) AS reports_to_effective_end_date_eoy
FROM
    (
     /* ADP */
     SELECT mh.associate_id
           ,mh.position_id
           ,mh.reports_to_associate_id
           ,CASE 
             WHEN CONVERT(DATE, mh.reports_to_effective_date) > '2021-01-01' THEN CONVERT(DATE, mh.reports_to_effective_date)
             ELSE '2021-01-01'
            END AS reports_to_effective_date
           ,CONVERT(DATE, mh.reports_to_effective_end_date) AS reports_to_effective_end_date

           ,sre.file_number AS employee_number

           ,srm.file_number AS reports_to_employee_number

           ,'ADP' AS source_system
     FROM gabby.adp.manager_history mh
     JOIN gabby.adp.employees_all sre
       ON mh.associate_id = sre.associate_id
      AND sre.file_number NOT IN (100814, 102496, 101652, 102634) /*  HR incapable of fixing these multiple employee numbers */
     JOIN gabby.adp.employees_all srm
       ON mh.reports_to_associate_id = srm.associate_id
      AND srm.file_number NOT IN (100814, 102496) /*  HR incapable of fixing these multiple employee numbers */
     WHERE '2021-01-01' BETWEEN CONVERT(DATE, mh.reports_to_effective_date) AND COALESCE(CONVERT(DATE, mh.reports_to_effective_end_date), GETDATE())
        OR CONVERT(DATE, mh.reports_to_effective_date) > '2021-01-01'

     UNION ALL

     /* DF */
     SELECT sre.associate_id AS associate_id

           ,dm.position_id

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
     JOIN gabby.adp.employees_all sre
       ON dm.employee_reference_code = sre.file_number
      AND sre.file_number NOT IN (101640, 102602, 400011) /*  HR incapable of fixing these multiple employee numbers */
     JOIN gabby.adp.employees_all srm
       ON dm.manager_employee_number = srm.file_number
      AND srm.file_number NOT IN (101640, 102602) /*  HR incapable of fixing these multiple employee numbers */
     WHERE CONVERT(DATE, dm.manager_effective_start) <= '2020-12-31'
    ) sub
