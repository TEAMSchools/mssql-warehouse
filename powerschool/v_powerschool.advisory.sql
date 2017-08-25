USE gabby
GO

ALTER VIEW powerschool.advisory AS

SELECT sub.studentid
      ,sub.yearid
      ,sub.advisory_name
      ,sub.teachernumber
      ,sub.teacher_name AS advisor_name
      
      ,adp.personal_contact_personal_mobile AS advisor_phone
      
      ,dir.mail AS advisor_email

      ,ROW_NUMBER() OVER(
         PARTITION BY sub.studentid, sub.yearid
           ORDER BY sub.dateleft DESC) AS rn_year
FROM
    (
     SELECT enr.studentid           
           ,enr.yearid
           ,enr.schoolid
           ,enr.dateleft           
           ,enr.teachernumber
           ,enr.teacher_name
           ,utilities.STRIP_CHARACTERS(enr.section_number,'0-9') AS advisory_name
     FROM powerschool.course_enrollments_static enr
     WHERE enr.course_number = 'HR'
       AND enr.schoolid NOT IN (133570965, 73253)
       AND enr.sectionid > 0

     UNION ALL

     SELECT enr.studentid           
           ,enr.yearid
           ,enr.schoolid
           ,enr.dateleft           
           ,enr.teachernumber
           ,enr.teacher_name
           ,utilities.STRIP_CHARACTERS(enr.section_number,'0-9') AS advisory_name
     FROM powerschool.course_enrollments_static enr
     WHERE enr.course_number = 'ADV'
       AND enr.schoolid IN (133570965, 73253)
       AND enr.sectionid > 0
    ) sub
LEFT OUTER JOIN gabby.people.adp_ps_id_link link
  ON sub.teachernumber = CONVERT(NVARCHAR(MAX),link.teachernumber)
 AND link.is_master = 1
LEFT OUTER JOIN gabby.adp.staff_roster adp
  ON COALESCE(link.associate_id, sub.teachernumber) = adp.associate_id
 AND adp.rn_curr = 1
LEFT OUTER JOIN gabby.adsi.user_attributes dir
  ON adp.position_id = dir.employeenumber
 AND dir.is_active = 1