CREATE OR ALTER VIEW powerschool.student_contacts AS

WITH contacts_unpivot AS (
  SELECT student_number
        ,family_ident
        ,LEFT(field, CHARINDEX('_', field) - 1) AS person
        ,RIGHT(field, LEN(field) - CHARINDEX('_', field)) AS [type]
        ,CASE WHEN [value] = '' THEN NULL ELSE [value] END AS [value]
  FROM
      (
       SELECT CONVERT(INT,s.student_number) AS student_number
             ,CONVERT(INT,s.family_ident) AS family_ident

             ,CONVERT(VARCHAR(250),s.home_phone) AS home_home
             ,CONVERT(VARCHAR(250),s.mother) AS parent1_name
             ,CONVERT(VARCHAR(250),s.father) AS parent2_name
             ,CONVERT(VARCHAR(250),s.doctor_name) AS doctor_name
             ,CONVERT(VARCHAR(250),s.doctor_phone) AS doctor_cell
             ,CONVERT(VARCHAR(250),s.emerg_contact_1) AS emerg1_name
             ,CONVERT(VARCHAR(250),s.emerg_phone_1) AS emerg1_cell
             ,CONVERT(VARCHAR(250),s.emerg_contact_2) AS emerg2_name
             ,CONVERT(VARCHAR(250),s.emerg_phone_2) AS emerg2_cell
             ,CONVERT(VARCHAR(250),CONCAT(LTRIM(RTRIM(s.street)), ', ', LTRIM(RTRIM(s.city)), ' ', LTRIM(RTRIM(s.zip)))) AS home_name
             ,CONVERT(VARCHAR(250),CASE WHEN CONCAT(s.doctor_name, s.doctor_phone) != '' THEN 'Doctor' END) AS doctor_relation

             ,CONVERT(VARCHAR(250),scf.mother_home_phone) AS parent1_home      
             ,CONVERT(VARCHAR(250),scf.father_home_phone) AS parent2_home      
             ,CONVERT(VARCHAR(250),scf.emerg_1_rel) AS emerg1_relation      
             ,CONVERT(VARCHAR(250),scf.emerg_2_rel) AS emerg2_relation      
             ,CONVERT(VARCHAR(250),scf.emerg_contact_3) AS emerg3_name
             ,CONVERT(VARCHAR(250),scf.emerg_3_rel) AS emerg3_relation
             ,CONVERT(VARCHAR(250),scf.emerg_3_phone) AS emerg3_cell

             ,CONVERT(VARCHAR(250),suf.mother_cell) AS parent1_cell      
             ,CONVERT(VARCHAR(250),suf.parent_motherdayphone) AS parent1_day                       
             ,CONVERT(VARCHAR(250),suf.mother_registered_to_vote) AS parent1_registeredtovote            
             ,CONVERT(VARCHAR(250),suf.father_cell) AS parent2_cell      
             ,CONVERT(VARCHAR(250),suf.parent_fatherdayphone) AS parent2_day
             ,CONVERT(VARCHAR(250),suf.father_registered_to_vote) AS parent2_registeredtovote            
             ,CONVERT(VARCHAR(250),suf.emerg_4_name) AS emerg4_name
             ,CONVERT(VARCHAR(250),suf.emerg_4_rel) AS emerg4_relation
             ,CONVERT(VARCHAR(250),suf.emerg_4_phone) AS emerg4_cell
             ,CONVERT(VARCHAR(250),suf.emerg_5_name) AS emerg5_name
             ,CONVERT(VARCHAR(250),suf.emerg_5_rel) AS emerg5_relation
             ,CONVERT(VARCHAR(250),suf.emerg_5_phone) AS emerg5_cell
             ,CONVERT(VARCHAR(250),suf.release_1_name) AS release1_name
             ,CONVERT(VARCHAR(250),suf.release_1_relation) AS release1_relation
             ,CONVERT(VARCHAR(250),suf.release_1_phone) AS release1_cell
             ,CONVERT(VARCHAR(250),suf.release_2_name) AS release2_name
             ,CONVERT(VARCHAR(250),suf.release_2_relation) AS release2_relation
             ,CONVERT(VARCHAR(250),suf.release_2_phone) AS release2_cell
             ,CONVERT(VARCHAR(250),suf.release_3_name) AS release3_name
             ,CONVERT(VARCHAR(250),suf.release_3_relation) AS release3_relation
             ,CONVERT(VARCHAR(250),suf.release_3_phone) AS release3_cell
             ,CONVERT(VARCHAR(250),suf.release_4_name) AS release4_name
             ,CONVERT(VARCHAR(250),suf.release_4_relation) AS release4_relation
             ,CONVERT(VARCHAR(250),suf.release_4_phone) AS release4_cell           
             ,CONVERT(VARCHAR(250),suf.release_5_name) AS release5_name
             ,CONVERT(VARCHAR(250),suf.release_5_relation) AS release5_relation
             ,CONVERT(VARCHAR(250),suf.release_5_phone) AS release5_cell

             ,CONVERT(VARCHAR(250),CASE WHEN CONCAT(scf.mother_home_phone, suf.mother_cell, suf.parent_motherdayphone) != '' THEN 'Mother' END) AS parent1_relation
             ,CONVERT(VARCHAR(250),CASE WHEN CONCAT(scf.father_home_phone, suf.father_cell, suf.parent_fatherdayphone) != '' THEN 'Father' END) AS parent2_relation
       FROM powerschool.students s
       LEFT JOIN powerschool.studentcorefields scf
         ON s.dcid = scf.studentsdcid        
       LEFT JOIN powerschool.u_studentsuserfields suf
         ON s.dcid = suf.studentsdcid        
      ) sub
  UNPIVOT(
    value
    FOR field IN (home_name
                 ,home_home
                 ,parent1_name
                 ,parent1_relation
                 ,parent1_home
                 ,parent1_cell
                 ,parent1_day
                 ,parent1_registeredtovote
                 ,parent2_name
                 ,parent2_relation
                 ,parent2_home
                 ,parent2_cell
                 ,parent2_day
                 ,parent2_registeredtovote
                 ,doctor_name
                 ,doctor_relation
                 ,doctor_cell
                 ,emerg1_name
                 ,emerg1_relation
                 ,emerg1_cell
                 ,emerg2_name
                 ,emerg2_relation
                 ,emerg2_cell
                 ,emerg3_name
                 ,emerg3_relation
                 ,emerg3_cell
                 ,emerg4_name
                 ,emerg4_relation
                 ,emerg4_cell
                 ,emerg5_name
                 ,emerg5_relation
                 ,emerg5_cell
                 ,release1_name
                 ,release1_relation
                 ,release1_cell
                 ,release2_name
                 ,release2_relation
                 ,release2_cell
                 ,release3_name
                 ,release3_relation
                 ,release3_cell
                 ,release4_name
                 ,release4_relation
                 ,release4_cell
                 ,release5_name
                 ,release5_relation
                 ,release5_cell)
   ) u
 )

,contacts_repivot AS (
  SELECT student_number
        ,family_ident
        ,person
        ,[name]
        ,relation
        ,registeredtovote
        ,cell
        ,home
        ,[day]
  FROM contacts_unpivot
  PIVOT(
    MAX([value])
    FOR [type] IN ([name]
                  ,[relation]
                  ,[cell]
                  ,[home]
                  ,[day]
                  ,[registeredtovote])
   ) p
 )

SELECT u.student_number
      ,u.family_ident
      ,CONVERT(VARCHAR(250),u.person) AS contact_type
      ,u.relation AS contact_relationship
      ,u.[name] AS contact_name
      ,u.registeredtovote
      ,CONVERT(VARCHAR(250),u.phone_type) AS phone_type
      ,u.phone
FROM contacts_repivot
UNPIVOT(
  phone
  FOR phone_type IN (cell, home, [day])
 ) u