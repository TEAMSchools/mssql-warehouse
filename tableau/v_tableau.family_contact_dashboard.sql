USE gabby
GO

CREATE OR ALTER VIEW tableau.family_contact_dashboard AS

WITH contacts_unpivot AS (
  SELECT studentid        
        ,family_ident
        ,LEFT(field, CHARINDEX('_', field) - 1) AS person
        ,RIGHT(field, LEN(field) - CHARINDEX('_', field)) AS type
        ,value      
  FROM
      (
       SELECT CONVERT(INT,s.id) AS studentid
             ,s.family_ident      

             ,CONVERT(VARCHAR(250),s.home_phone) AS home_home
             ,CONVERT(VARCHAR(250),s.guardianemail) AS home_email
             ,CONVERT(VARCHAR(250),s.mother) AS parent1_name
             ,CONVERT(VARCHAR(250),s.guardianemail) AS parent1_email
             ,CONVERT(VARCHAR(250),s.father) AS parent2_name             
             ,CONVERT(VARCHAR(250),s.guardianemail) AS parent2_email
             ,CONVERT(VARCHAR(250),s.doctor_name) AS doctor_name      
             ,CONVERT(VARCHAR(250),s.doctor_phone) AS doctor_cell
             ,CONVERT(VARCHAR(250),s.emerg_contact_1) AS emerg1_name
             ,CONVERT(VARCHAR(250),s.emerg_phone_1) AS emerg1_cell
             ,CONVERT(VARCHAR(250),s.emerg_contact_2) AS emerg2_name
             ,CONVERT(VARCHAR(250),s.emerg_phone_2) AS emerg2_cell
             ,CONVERT(VARCHAR(250),CONCAT(LTRIM(RTRIM(s.street)), ', ', LTRIM(RTRIM(s.city)), ' ', LTRIM(RTRIM(s.zip)))) AS home_name
             ,CONVERT(VARCHAR(250),CASE WHEN CONCAT(s.doctor_name, s.doctor_phone) != '' THEN 'Doctor' END) COLLATE Latin1_General_BIN AS doctor_relation      
      
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

             ,CONVERT(VARCHAR(250),CASE WHEN CONCAT(scf.mother_home_phone, suf.mother_cell, suf.parent_motherdayphone) != '' THEN 'Mother' END) COLLATE Latin1_General_BIN AS parent1_relation
             ,CONVERT(VARCHAR(250),CASE WHEN CONCAT(scf.father_home_phone, suf.father_cell, suf.parent_fatherdayphone) != '' THEN 'Father' END) COLLATE Latin1_General_BIN AS parent2_relation
       FROM gabby.powerschool.students s
       LEFT OUTER JOIN gabby.powerschool.studentcorefields scf
         ON s.dcid = scf.studentsdcid
       LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
         ON s.dcid = suf.studentsdcid
      ) sub
  UNPIVOT(
    value
    FOR field IN (home_name
                 ,home_home
                 ,home_email
                 ,parent1_name
                 ,parent1_relation
                 ,parent1_home
                 ,parent1_cell
                 ,parent1_day
                 ,parent1_registeredtovote
                 ,parent1_email
                 ,parent2_name
                 ,parent2_relation
                 ,parent2_home
                 ,parent2_cell
                 ,parent2_day
                 ,parent2_registeredtovote
                 ,parent2_email
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
  SELECT studentid
        ,family_ident
        ,person
        ,name
        ,relation
        ,cell
        ,home
        ,day
        ,email
        ,registeredtovote
  FROM contacts_unpivot
  PIVOT(
    MAX(value)
    FOR type IN ([name]
                ,[relation]
                ,[cell]
                ,[home]              
                ,[day]
                ,[email]
                ,[registeredtovote])
   ) p      
 )

,contacts_grouped AS (
  SELECT family_ident
        ,person
        ,name
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT cell, CHAR(10)) AS cell
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT home, CHAR(10)) AS home
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT day, CHAR(10)) AS day
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT email, CHAR(10)) AS email
  FROM contacts_repivot
  WHERE family_ident IS NOT NULL
  GROUP BY family_ident
          ,person
          ,name
 )

SELECT co.student_number
      ,co.lastfirst AS student_name
      ,co.reporting_schoolid AS schoolid
      ,co.school_name
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,CONCAT(co.STREET, ' - ', co.city, ', ', co.state, ' ', co.zip) AS street_address
      
      ,s.family_ident
      
      ,suf.infosnap_opt_in      

      ,c.person AS contact_type
      ,c.name AS contact_name
      ,c.registeredtovote AS contact_registered_to_vote      
      ,ISNULL(c.relation, c.person) AS contact_relation
      
      ,cg.cell AS contact_cell_phone
      ,cg.home AS contact_home_phone
      ,cg.day AS contact_day_phone
      ,cg.email AS contact_email            
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN gabby.powerschool.students s
  ON co.studentid = s.id
LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT OUTER JOIN contacts_repivot c
  ON co.studentid = c.studentid
LEFT OUTER JOIN contacts_grouped cg
  ON s.family_ident = cg.family_ident
 AND c.person = cg.person
 AND c.name = cg.name
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1