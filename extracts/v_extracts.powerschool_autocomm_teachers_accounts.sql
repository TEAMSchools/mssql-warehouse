USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_teachers_accounts AS

WITH users_clean AS (
  SELECT df.preferred_first_name AS first_name
        ,df.preferred_last_name AS last_name
        ,sc.region AS legal_entity_name
        ,df.ps_teachernumber AS teachernumber
        ,df.primary_site_schoolid AS homeschoolid
        ,df.birth_date
        ,LOWER(df.samaccountname) AS loginid
        ,LOWER(df.samaccountname) AS teacherloginid
        ,LOWER(df.mail) AS email_addr
        ,CASE
          WHEN DATEDIFF(DAY, ISNULL(df.termination_date, CONVERT(DATE, GETDATE())), GETDATE()) <= 7 THEN 1
          WHEN df.[status] IN ('ACTIVE','INACTIVE','PRESTART', 'PLOA', 'ADMIN_LEAVE') THEN 1
          WHEN df.termination_date >= CONVERT(DATE, GETDATE()) THEN 1
          ELSE 2
         END AS [status]
  FROM gabby.people.staff_crosswalk_static df
  JOIN gabby.people.school_crosswalk sc
    ON df.primary_site = sc.site_name
   AND sc._fivetran_deleted = 0
  JOIN gabby.powerschool.users u
    ON df.ps_teachernumber = u.teachernumber COLLATE Latin1_General_BIN
   AND df.primary_site_schoolid = u.homeschoolid
   AND CASE 
        WHEN sc.region = 'TEAM Academy Charter Schools' THEN 'kippnewark'
        WHEN sc.region = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
        WHEN sc.region = 'KIPP Miami' THEN 'kippmiami'
       END = u.[db_name]
  WHERE DATEDIFF(DAY, ISNULL(df.termination_date, CONVERT(DATE, GETDATE())), GETDATE()) <= 14 /* import terminated staff up to a week after termination date */
    AND df.primary_on_site_department != 'Data'
 )

SELECT df.teachernumber
      ,df.first_name
      ,df.last_name
      ,CASE WHEN df.[status] = 1 THEN df.loginid END AS loginid
      ,CASE WHEN df.[status] = 1 THEN df.teacherloginid END AS teacherloginid
      ,df.email_addr
      ,CONVERT(INT, COALESCE(df.homeschoolid, 0)) AS schoolid
      ,CONVERT(INT, COALESCE(df.homeschoolid, 0)) AS homeschoolid
      ,df.[status]
      ,CASE WHEN df.[status] = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN df.[status] = 1 THEN 1 ELSE 0 END AS adminldapenabled
      ,CASE WHEN df.[status] = 1 THEN 1 ELSE 0 END AS ptaccess
      ,df.birth_date
      ,df.legal_entity_name
FROM users_clean df