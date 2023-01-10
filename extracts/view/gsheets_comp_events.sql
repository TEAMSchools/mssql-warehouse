CREATE OR ALTER VIEW gsheets_comp_events

-- Roster of School Leaders and Heads of Schools/their managers for School instructional approval loop
WITH school_leader_hos AS (
  SELECT x.primary_site
        ,x.userprincipalname AS first_approver_email
        ,x.manager_userprincipalname AS second_approver_email
        ,x.google_email AS first_approver_google
        
        ,m.google_email AS second_approver_google
        
  FROM gabby.people.staff_crosswalk_static x
  LEFT JOIN gabby.people.staff_crosswalk_static m
    ON (x.manager_df_employee_number = m.df_employee_number)
  WHERE x.primary_job = 'School Leader'
    AND x.status <> 'TERMINATED'
),

-- Roster of MDSOs and MDOs/their managers for School operations approval loop

mdso_mdo AS (
SELECT   x.primary_site
        ,x.manager_userprincipalname AS first_approver_email
        ,m.manager_userprincipalname AS second_approver_email
        ,m.google_email AS first_approver_google
        ,gm.google_email AS second_approver_google
        
  FROM gabby.people.staff_crosswalk_static x
  LEFT JOIN gabby.people.staff_crosswalk_static m
    ON (x.manager_df_employee_number = m.df_employee_number)
LEFT JOIN gabby.people.staff_crosswalk_static gm
    ON (m.manager_df_employee_number = gm.df_employee_number)
  WHERE x.primary_job IN ('Director School Operations', 'Director Campus Operations')
    AND x.status <> 'TERMINATED'

)

,approval_loops AS (
SELECT   x.df_employee_number
        ,s.first_approver_email
        ,s.second_approver_email
        ,s.first_approver_google
        ,s.second_approver_google
        ,'Instructional' AS approval_loop

  FROM gabby.people.staff_crosswalk_static x
  JOIN school_leader_hos s
    ON (x.primary_site = s.primary_site)
  WHERE x.primary_on_site_department <> 'Operations'
    AND x.status <> 'TERMINATED'

UNION ALL

SELECT   x.df_employee_number
        ,s.first_approver_email
        ,s.second_approver_email
        ,s.first_approver_google
        ,s.second_approver_google
        ,'Operations' AS approval_loop

  FROM gabby.people.staff_crosswalk_static x
  JOIN mdso_mdo s
    ON (x.primary_site = s.primary_site)
  WHERE x.primary_on_site_department = 'Operations'
    AND x.primary_site NOT IN ('Room 9 - 60 Park Pl','Room 10 - 121 Market St','Room 11 - 1951 NW 7th Ave')
    AND x.status <> 'TERMINATED'

UNION ALL

-- Manager and Manager of Manager for non-school-based staff

SELECT x.df_employee_number
      ,m.userprincipalname AS first_approver_email
      ,gm.userprincipalname AS second_approver_email
      ,m.google_email AS first_approver_google
      ,gm.google_email AS second_approver_google
      ,'Non-School Based' AS approval_loop

FROM gabby.people.staff_crosswalk_static x
LEFT JOIN gabby.people.staff_crosswalk_static m
  ON (x.manager_df_employee_number = m.df_employee_number)
LEFT JOIN gabby.people.staff_crosswalk_static gm
  ON (m.manager_df_employee_number = gm.df_employee_number)
WHERE x.primary_site IN ('Room 9 - 60 Park Pl','Room 10 - 121 Market St','Room 11 - 1951 NW 7th Ave')
  AND x.status <> 'TERMINATED'

)

SELECT x.df_employee_number
      ,x.adp_associate_id
      ,x.file_number
      ,x.payroll_company_code
      ,x.legal_entity_name
      ,x.primary_site
      ,x.primary_on_site_department
      ,x.primary_job
      ,x.google_email
      ,x.userprincipalname
      ,CONCAT(x.preferred_name, ' - ', x.primary_site) AS preferred_name
      
      ,CASE
       WHEN l.first_approver_google = 'rhill@apps.teamschools.org' THEN 'ssmall@apps.teamschools.org' ELSE l.first_approver_google END AS first_approver_google
      ,CASE
       WHEN l.second_approver_google = 'rhill@apps.teamschools.org' THEN 'ssmall@apps.teamschools.org' ELSE l.second_approver_google END AS second_approver_google
      ,CASE
       WHEN l.first_approver_email = 'rhill@kippteamandfamily.org' THEN 'ssmall@kippteamandfamily.org' ELSE l.first_approver_email END AS first_approver_email
      ,CASE 
       WHEN l.second_approver_email = 'rhill@kippteamandfamily.org' THEN 'ssmall@kippteamandfamily.org' ELSE l.second_approver_email END AS second_approver_email
   
FROM gabby.people.staff_crosswalk_static x
LEFT JOIN approval_loops l
  ON (x.df_employee_number = l.df_employee_number)
WHERE x.status <> 'TERMINATED'