USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_teachers_accounts AS

WITH users_clean AS (
  SELECT df.preferred_first_name AS first_name
        ,df.preferred_last_name AS last_name
        ,df.legal_entity_name
        ,COALESCE(psid.ps_teachernumber, df.adp_associate_id, CONVERT(VARCHAR(25),df.df_employee_number)) AS teachernumber
        ,CASE
          WHEN df.primary_site = '18th Ave Campus' THEN 73255
          WHEN df.primary_site = 'KIPP Lanning Sq Campus' THEN 179901
          ELSE df.primary_site_schoolid 
         END AS homeschoolid        
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
          WHEN df.status IN ('ACTIVE','INACTIVE','PRESTART') THEN 1
          WHEN df.termination_date >= CONVERT(DATE,GETDATE()) THEN 1
          ELSE 2
         END AS status
  FROM gabby.dayforce.staff_roster df 
  LEFT JOIN gabby.adsi.user_attributes_static dir
    ON CONVERT(VARCHAR(25),df.df_employee_number) = dir.employeenumber
  LEFT JOIN gabby.people.id_crosswalk_powerschool psid
    ON df.df_employee_number = psid.df_employee_number
   AND psid.is_master = 1
  WHERE DATEDIFF(DAY, ISNULL(df.termination_date, CONVERT(DATE,GETDATE())), GETDATE()) <= 7 /* import terminated staff up to a week after termination date */
    AND df.primary_on_site_department != 'Data'
 )

/* Home School Record */       
SELECT df.teachernumber
      ,df.first_name
      ,df.last_name
      ,CASE WHEN df.status = 1 THEN df.loginid END AS loginid
      ,CASE WHEN df.status = 1 THEN df.teacherloginid END AS teacherloginid
      ,df.email_addr
      ,CONVERT(INT,COALESCE(df.homeschoolid, 0)) AS schoolid
      ,CONVERT(INT,COALESCE(df.homeschoolid, 0)) AS homeschoolid
      ,df.status      
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS ptaccess            
      ,df.legal_entity_name
FROM users_clean df
WHERE df.legal_entity_name != 'KIPP New Jersey'

UNION ALL

/* KNJ Admins */
SELECT df.teachernumber
      ,df.first_name
      ,df.last_name
      ,CASE WHEN df.status = 1 THEN df.loginid END AS loginid
      ,CASE WHEN df.status = 1 THEN df.teacherloginid END AS teacherloginid
      ,df.email_addr
      ,0 AS schoolid
      ,0 AS homeschoolid
      ,df.status      
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS ptaccess            
      ,df.legal_entity_name
FROM users_clean df
WHERE df.legal_entity_name = 'KIPP New Jersey'

UNION ALL

/* Additional School Records */
SELECT df.teachernumber
      ,df.first_name
      ,df.last_name
      ,CASE WHEN df.status = 1 THEN df.loginid END AS loginid
      ,CASE WHEN df.status = 1 THEN df.teacherloginid END AS teacherloginid
      ,df.email_addr
      ,CONVERT(INT,COALESCE(t.schoolid, df.homeschoolid, 0)) AS schoolid
      ,CONVERT(INT,COALESCE(df.homeschoolid, 0)) AS homeschoolid
      ,df.status      
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN df.status = 1 THEN 1 ELSE 0 END AS ptaccess            
      ,df.legal_entity_name
FROM users_clean df
JOIN gabby.powerschool.teachers_static t
  ON df.teachernumber = t.teachernumber COLLATE Latin1_General_BIN
 AND df.db_name = t.db_name 
 AND df.homeschoolid != t.schoolid
 AND t.schoolid != 0
WHERE df.legal_entity_name != 'KIPP New Jersey'