USE gabby
GO

CREATE OR ALTER VIEW powerschool.advisory AS

SELECT enr.studentid
      ,enr.student_number                      
      ,enr.academic_year           
      ,enr.teachernumber
      ,enr.teacher_name AS advisor_name
      ,gabby.utilities.STRIP_CHARACTERS(enr.section_number,'0-9') AS advisory_name

      ,adp.personal_contact_personal_mobile AS advisor_phone
      
      ,dir.mail AS advisor_email

      ,ROW_NUMBER() OVER(
         PARTITION BY enr.student_number, enr.academic_year
           ORDER BY enr.dateleft DESC, enr.dateenrolled DESC) AS rn_year
FROM gabby.powerschool.course_enrollments_static enr           
LEFT OUTER JOIN gabby.people.adp_ps_id_link link
  ON enr.teachernumber = CONVERT(NVARCHAR(MAX),link.teachernumber)
 AND link.is_master = 1
LEFT OUTER JOIN gabby.adp.staff_roster adp
  ON COALESCE(link.associate_id, enr.teachernumber) = adp.associate_id
 AND adp.rn_curr = 1
LEFT OUTER JOIN gabby.adsi.user_attributes dir
  ON adp.position_id = dir.employeenumber
 AND dir.is_active = 1
WHERE enr.course_number = 'HR'
  AND enr.sectionid > 0