USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_teachers_accounts AS

SELECT sub.teachernumber
      ,sub.first_name
      ,sub.last_name
      ,CASE WHEN sub.status = 1 THEN sub.loginid END AS loginid
      ,CASE WHEN sub.status = 1 THEN sub.teacherloginid END AS teacherloginid
      ,sub.email_addr
      ,CONVERT(INT,COALESCE(t.schoolid, sub.homeschoolid, 0)) AS schoolid
      ,CONVERT(INT,COALESCE(sub.homeschoolid, 0)) AS homeschoolid
      ,sub.status      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS ptaccess            
      ,sub.legal_entity_name
FROM
    (
     SELECT COALESCE(psid.ps_teachernumber
                    ,df.adp_associate_id
                    ,CONVERT(VARCHAR(25),df.df_employee_number)) AS teachernumber
           ,df.preferred_first_name AS first_name
           ,df.preferred_last_name AS last_name
           ,df.primary_site_schoolid AS homeschoolid
           ,df.legal_entity_name
           ,CASE
             WHEN df.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
             WHEN df.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
             WHEN df.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
            END AS db_name
           
           ,LOWER(dir.samaccountname) AS loginid
           ,LOWER(dir.samaccountname) AS teacherloginid
           ,LOWER(dir.mail) AS email_addr
           
           ,CASE
             WHEN psid.is_master = 0 THEN 2
             WHEN df.termination_date < GETDATE() THEN 2
             WHEN df.status IN ('ACTIVE','INACTIVE','PRESTART') OR df.termination_date >= CONVERT(DATE,GETDATE()) THEN 1
             ELSE 2
            END AS status
     FROM gabby.dayforce.staff_roster df
     LEFT JOIN gabby.adsi.user_attributes_static dir
       ON CONVERT(VARCHAR(25),df.df_employee_number) = dir.employeenumber
     LEFT JOIN gabby.people.id_crosswalk_powerschool psid
       ON df.adp_associate_id = psid.adp_associate_id
      AND psid.is_master = 1
     WHERE df.primary_on_site_department != 'Data'
       AND df.legal_entity_name != 'KIPP New Jersey'
    ) sub
LEFT JOIN gabby.powerschool.teachers_static t
  ON sub.teachernumber COLLATE Latin1_General_BIN = t.teachernumber 
 AND sub.db_name = t.db_name

UNION ALL

SELECT sub.teachernumber
      ,sub.first_name
      ,sub.last_name
      ,CASE WHEN sub.status = 1 THEN sub.loginid END AS loginid
      ,CASE WHEN sub.status = 1 THEN sub.teacherloginid END AS teacherloginid
      ,sub.email_addr
      ,0 AS schoolid
      ,0 AS homeschoolid
      ,sub.status      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS ptaccess            
      ,sub.legal_entity_name
FROM
    (
     SELECT COALESCE(psid.ps_teachernumber
                    ,df.adp_associate_id
                    ,CONVERT(VARCHAR(25),df.df_employee_number)) AS teachernumber
           ,df.preferred_first_name AS first_name
           ,df.preferred_last_name AS last_name           
           ,df.legal_entity_name           
           
           ,LOWER(dir.samaccountname) AS loginid
           ,LOWER(dir.samaccountname) AS teacherloginid
           ,LOWER(dir.mail) AS email_addr
           
           ,CASE
             WHEN psid.is_master = 0 THEN 2
             WHEN df.termination_date < GETDATE() THEN 2
             WHEN df.primary_job = 'Intern' THEN 2
             WHEN df.status IN ('ACTIVE','INACTIVE','PRESTART') OR df.termination_date >= CONVERT(DATE,GETDATE()) THEN 1
             ELSE 2
            END AS status
     FROM gabby.dayforce.staff_roster df
     LEFT JOIN gabby.adsi.user_attributes_static dir
       ON CONVERT(VARCHAR(25),df.df_employee_number) = dir.employeenumber
     LEFT JOIN gabby.people.id_crosswalk_powerschool psid
       ON df.adp_associate_id = psid.adp_associate_id
      AND psid.is_master = 1
     WHERE df.primary_on_site_department != 'Data'
       AND df.legal_entity_name = 'KIPP New Jersey'
    ) sub