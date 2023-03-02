CREATE OR ALTER VIEW gsheets_comp_events

WITH approval_pivot AS (
SELECT 
    primary_site
   ,legal_entity_name
   ,[School Leader] AS school_leader
   ,COALESCE([Director School Operations],[Director Campus Operations]) AS dso_dco 
   FROM
      ( SELECT  primary_site
               ,legal_entity_name
               ,primary_job
               ,df_employee_number
         FROM gabby.people.staff_crosswalk_static x
         WHERE status <> 'TERMINATED' ) AS sub
         PIVOT (
         MAX(df_employee_number) FOR primary_job IN (
         [School Leader]
        ,[Director School Operations]
        ,[Director Campus Operations]
        )
         ) AS p
)

,school_approval_loops AS (
SELECT
    l.primary_site
   ,l.legal_entity_name
   ,l.school_leader
   ,l.dso_dco 
   
   ,a.userprincipalname AS sl_email
   ,a.google_email AS sl_google
   
   
   ,b.df_employee_number AS hos_ed
   ,b.preferred_name AS hos_ed_name
   ,b.userprincipalname AS hos_ed_email
   ,b.google_email AS hos_ed_google
   
   ,c.df_employee_number AS ed
   ,c.preferred_name AS ed_name
   ,c.userprincipalname AS ed_email
   ,c.google_email AS ed_google

   ,d.userprincipalname AS dso_email
   ,d.google_email AS dso_google

   ,e.df_employee_number AS mdso
   ,e.preferred_name AS mdso_name
   ,e.userprincipalname AS mdso_email
   ,e.google_email AS mdso_google

   ,f.df_employee_number AS coo
   ,f.preferred_name AS coo_name
   ,f.userprincipalname AS coo_email
   ,f.google_email AS coo_google
   
FROM approval_pivot l
--School Leaders
LEFT JOIN gabby.people.staff_crosswalk_static a
ON l.school_leader = a.df_employee_number
--School Leader Managers (HsOS)
LEFT JOIN gabby.people.staff_crosswalk_static b
ON a.manager_df_employee_number = b.df_employee_number
--HOS Managers (Executive Directors)
LEFT JOIN gabby.people.staff_crosswalk_static c
ON b.manager_df_employee_number = c.df_employee_number
--DSO/DCO
LEFT JOIN gabby.people.staff_crosswalk_static d
ON l.dso_dco = d.df_employee_number
--DSO/DCO Managers (MDSOs)
LEFT JOIN gabby.people.staff_crosswalk_static e
ON d.manager_df_employee_number = e.df_employee_number
--MDSO Managers (COOs)
LEFT JOIN gabby.people.staff_crosswalk_static f
ON e.manager_df_employee_number = f.df_employee_number 
)

SELECT x.df_employee_number
      ,x.payroll_company_code
      ,x.adp_associate_id
      ,x.file_number
      ,x.primary_job
      ,x.primary_site
      ,x.primary_on_site_department
      ,CASE
       WHEN primary_job IN ('School Leader','DSO')
       THEN l.hos_ed_email
       WHEN primary_on_site_department <> 'Operations'
       THEN l.sl_email
       WHEN primary_on_site_department = 'Operations'
       THEN l.mdso_email 
       ELSE NULL
       END AS first_approver_email
      ,CASE
       WHEN primary_job IN ('School Leader','DSO')
       THEN l.hos_ed_google
       WHEN primary_on_site_department <> 'Operations'
       THEN l.sl_google
       WHEN primary_on_site_department = 'Operations'
       THEN l.mdso_google
       ELSE NULL 
       END AS first_approver_google 
      ,CASE
       WHEN primary_job IN ('School Leader','DSO') 
       THEN l.ed_email
       WHEN primary_on_site_department <> 'Operations' 
       THEN l.hos_ed_email
       WHEN primary_on_site_department = 'Operations' THEN l.coo_email
       ELSE NULL
       END AS second_approver_email
      ,CASE
       WHEN primary_job IN ('School Leader','DSO')
       THEN l.ed_google
       WHEN primary_on_site_department <> 'Operations'
       THEN l.hos_ed_google
       WHEN primary_on_site_department = 'Operations' THEN l.coo_google
       ELSE NULL
       END AS second_approver_email
      ,l.dso_email AS notify
FROM gabby.people.staff_crosswalk_static x
JOIN school_approval_loops l
  ON x.primary_site = l.primary_site
WHERE x.primary_site NOT IN ('Room 9 - 60 Park Pl','Room 10 - 121 Market St','Room 11 - 1951 NW 7th Ave')
AND x.status <> 'TERMINATED'
