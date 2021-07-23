USE gabby
GO

CREATE OR ALTER VIEW extracts.egencia_users AS

SELECT CONCAT(sub.employee_number, '@kippnj.org') AS [Username]
      ,sub.[Email]
      ,sub.[Single Sign On ID]
      ,sub.employee_number AS [Employee ID]
      ,CASE WHEN sub.[status] = 'Terminated' THEN 'Disabled' ELSE 'Active' END AS [Status]
      ,sub.[First name]
      ,sub.[Last name]
      ,CASE 
        WHEN sub.employee_number IN (100219, 100412, 100566, 102298) THEN 'Travel Manager'
        ELSE 'Traveler'
       END AS [Role]

      ,COALESCE(tg.egencia_traveler_group
               ,tg2.egencia_traveler_group
               ,tg3.egencia_traveler_group
               ,'General Traveler Group') AS [Traveler Group] -- cascading match on location/dept/job
FROM
    (
     SELECT scw.employee_number
           ,scw.first_name AS [First name] -- legal name
           ,scw.last_name AS [Last name] -- legal name
           ,scw.[status]
           ,COALESCE(scw.rehire_date, scw.original_hire_date) AS hire_date
           ,scw.termination_date
           ,scw.[location]
           ,scw.home_department
           ,scw.job_title

           ,ad.mail AS [Email]
           ,ad.userprincipalname AS [Single Sign On ID]
     FROM gabby.people.staff_roster scw
     --JOIN gabby.adsi.user_attributes_static ad
     JOIN gabby.adsi.user_attributes ad
       ON scw.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     WHERE scw.home_department NOT IN ('Interns')
       AND COALESCE(scw.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
    ) sub
LEFT JOIN gabby.egencia.traveler_groups tg
  ON sub.[location] = tg.[location]
 AND sub.home_department = tg.home_department
 AND sub.job_title = tg.job_title
LEFT JOIN gabby.egencia.traveler_groups tg2
  ON sub.[location] = tg2.[location]
 AND sub.home_department = tg2.home_department
 AND tg2.job_title = 'Default'
LEFT JOIN gabby.egencia.traveler_groups tg3
  ON sub.[location] = tg3.[location]
 AND tg3.home_department = 'Default'
 AND tg3.job_title = 'Default'
