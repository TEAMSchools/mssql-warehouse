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
      ,'Traveler' AS [Role]

      ,COALESCE(tg.egencia_traveler_group
               ,tg2.egencia_traveler_group
               ,tg3.egencia_traveler_group) AS [Traveler Group] -- cascading match on location/dept/job

      ,sub.home_department
      ,sub.[location]
      ,sub.job_title
      ,sub.hire_date
FROM
    (
     SELECT scw.employee_number
           ,scw.first_name AS [First name] -- legal name
           ,scw.last_name AS [Last name] -- legal name
           ,scw.[status]
           ,COALESCE(scw.rehire_date, scw.original_hire_date) AS hire_date
           ,scw.[location]
           ,CASE 
             WHEN scw.home_department IN ('School Leadership', 'Teaching and Learning', 'Operations', 'KTC', 'New Teacher Development', 'Executive', 'School Support'
                                                    ,'Human Resources', 'Special Projects', 'Special Education', 'Enrollment', 'Recruitment', 'Technology', 'Community Engagement'
                                                    ,'Development', 'Finance and Purchasing', 'Data', 'Accounting and Compliance', 'Real Estate', 'Marketing', 'Facilities', 'Student Support')
                  THEN scw.home_department
             ELSE 'Default'
            END AS home_department
           ,CASE 
             WHEN scw.job_title IN ('School Leader', 'School Leader in Residence', 'Director School Operations', 'Managing Director of Operations', 'Managing Director', 'Assistant Superintendent'
                                     ,'Chief Equity Strategist', 'Executive Director', 'Managing Director of School Operations', 'Manager', 'Fellow School Operations Director', 'Specialist')
                  THEN scw.job_title
             ELSE 'Default'
            END AS job_title

           ,ad.mail AS [Email]
           ,ad.userprincipalname AS [Single Sign On ID]
     FROM gabby.people.staff_roster scw
     JOIN gabby.adsi.user_attributes_static ad
       ON scw.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     WHERE scw.home_department NOT IN ('Interns')
       AND COALESCE(scw.termination_date, GETDATE()) >= '2020-11-01'
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
