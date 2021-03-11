USE gabby
GO

CREATE OR ALTER VIEW extracts.egencia_users AS

SELECT CONCAT(sub.df_employee_number, '@kippnj.org') AS [Username]
      ,sub.[Email]
      ,sub.[Single Sign On ID]
      ,sub.[Employee ID]
      ,CASE WHEN sub.[status] = 'Terminated' THEN 'Disabled' ELSE 'Active' END AS [Status]
      ,sub.[First name]
      ,sub.[Last name]
      ,sub.hire_date
      ,sub.match_department
      ,sub.match_site
      ,sub.match_title
      ,'Traveler' AS [Role]

      ,tg.egencia_traveler_group AS [Traveler Group] -- cascading match on location/dept/job
FROM
    (
     SELECT scw.df_employee_number
           ,scw.mail AS [Email]
           ,scw.userprincipalname AS [Single Sign On ID]
           ,scw.df_employee_number AS [Employee ID]
           ,scw.first_name AS [First name] -- legal name
           ,scw.last_name AS [Last name] -- legal name
           ,scw.[status]
           ,COALESCE(scw.rehire_date, scw.original_hire_date) AS hire_date
           ,scw.primary_site AS match_site
           ,CASE 
             WHEN scw.primary_on_site_department IN ('School Leadership', 'Teaching and Learning', 'Operations', 'KTC', 'New Teacher Development', 'Executive', 'School Support'
                                                    ,'Human Resources', 'Special Projects', 'Special Education', 'Enrollment', 'Recruitment', 'Technology', 'Community Engagement'
                                                    ,'Development', 'Finance and Purchasing', 'Data', 'Accounting and Compliance', 'Real Estate', 'Marketing', 'Facilities', 'Student Support')
                  THEN scw.primary_on_site_department
             ELSE 'All others'
            END AS match_department
           ,CASE 
             WHEN scw.primary_job IN ('School Leader', 'School Leader in Residence', 'Director School Operations', 'Managing Director of Operations', 'Managing Director', 'Assistant Superintendent'
                                     ,'Chief Equity Strategist', 'Executive Director', 'Managing Director of School Operations', 'Manager', 'Fellow School Operations Director', 'Specialist')
                  THEN scw.primary_job
             ELSE 'All'
            END AS match_title
     FROM gabby.people.staff_crosswalk_static scw
     WHERE scw.primary_on_site_department NOT IN ('Interns')
       AND COALESCE(scw.termination_date, GETDATE()) >= '2020-11-01'
    ) sub
LEFT JOIN gabby.egencia.traveler_groups tg
  ON sub.match_site = tg.physicaldeliveryofficename
 AND sub.match_department = tg.department
 AND sub.match_title = tg.title
