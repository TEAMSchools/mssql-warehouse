USE gabby
GO

CREATE OR ALTER VIEW tableau.family_contact_dashboard AS

WITH contacts_repivot AS (
  SELECT student_number
        ,family_ident
        ,contact_type AS person
        ,contact_name AS name
        ,contact_relationship AS relation        
        ,registeredtovote
        ,[cell]
        ,[home]              
        ,[day]
  FROM gabby.powerschool.student_contacts_static
  PIVOT(
    MAX(phone)
    FOR phone_type IN ([cell]
                      ,[home]              
                      ,[day])
   ) p      
 )

,contacts_grouped AS (
  SELECT family_ident
        ,person
        ,name
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT cell, CHAR(10)) AS cell
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT home, CHAR(10)) AS home
        ,gabby.dbo.GROUP_CONCAT_D(DISTINCT day, CHAR(10)) AS day        
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
      ,co.guardianemail AS contact_email            
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.students s
  ON co.student_number = s.student_number
 AND co.db_name = s.db_name
LEFT JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
 AND s.db_name = suf.db_name
LEFT JOIN contacts_repivot c
  ON co.student_number = c.student_number
LEFT JOIN contacts_grouped cg
  ON s.family_ident = cg.family_ident
 AND c.person = cg.person
 AND c.name = cg.name
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1