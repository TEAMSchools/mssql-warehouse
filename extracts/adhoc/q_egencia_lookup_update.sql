WITH this AS (
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY location, home_department, job_title
             ORDER BY egencia_traveler_group DESC) AS rn
  FROM
      (
       SELECT [location]
             ,home_department
             ,job_title
             ,egencia_traveler_group
       FROM gabby.egencia.traveler_groups

       UNION ALL

       SELECT DISTINCT 
              scw.[location]
             ,scw.home_department
             ,scw.job_title
             ,NULL
       FROM gabby.people.staff_roster scw
       WHERE (scw.worker_category NOT IN ('Intern', 'Part Time') OR scw.worker_category IS NULL)
         AND COALESCE(scw.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)

       UNION ALL

       SELECT DISTINCT 
              scw.[location]
             ,scw.home_department
             ,'Default'
             ,NULL
       FROM gabby.people.staff_roster scw
       WHERE (scw.worker_category NOT IN ('Intern', 'Part Time') OR scw.worker_category IS NULL)
         AND COALESCE(scw.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)

       UNION ALL

       SELECT DISTINCT 
              scw.[location]
             ,'Default'
             ,'Default'
             ,NULL
       FROM gabby.people.staff_roster scw
       WHERE (scw.worker_category NOT IN ('Intern', 'Part Time') OR scw.worker_category IS NULL)
         AND COALESCE(scw.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
      ) sub
 )

SELECT [location]
      ,home_department
      ,job_title
      ,egencia_traveler_group
FROM this
WHERE rn = 1
  AND [location] IS NOT NULL
  AND home_department IS NOT NULL
  AND job_title IS NOT NULL
ORDER BY [location]
        ,home_department
        ,job_title
