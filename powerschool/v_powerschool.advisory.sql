USE gabby
GO

CREATE OR ALTER VIEW powerschool.advisory AS

SELECT sub.studentid
      ,sub.student_number                      
      ,sub.academic_year           
      ,sub.teachernumber
      ,sub.advisor_name
      ,sub.dateenrolled
      ,sub.dateleft
      
      ,adp.personal_contact_personal_mobile AS advisor_phone

      ,dir.mail AS advisor_email

      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year
           ORDER BY sub.dateleft DESC, sub.dateenrolled DESC) AS rn_year
FROM
    (
     SELECT enr.studentid
           ,enr.student_number                      
           ,enr.academic_year           
           ,enr.teachernumber
           ,enr.teacher_name AS advisor_name
           ,enr.dateenrolled
           ,enr.dateleft           

           ,COALESCE(link.associate_id, enr.teachernumber) AS associate_id
     FROM gabby.powerschool.course_enrollments_static enr           
     LEFT OUTER JOIN gabby.people.adp_ps_id_link link
       ON enr.teachernumber = CONVERT(VARCHAR(125),link.teachernumber)
      AND link.is_master = 1          
     WHERE enr.course_number = 'HR'
       AND enr.sectionid > 0
       AND enr.schoolid != 133570965

     UNION ALL

     SELECT enr.studentid
           ,enr.student_number                      
           ,enr.academic_year           
           ,enr.teachernumber
           ,enr.teacher_name AS advisor_name        
           ,enr.dateenrolled
           ,enr.dateleft
           
           ,COALESCE(link.associate_id, enr.teachernumber) AS associate_id
     FROM gabby.powerschool.course_enrollments_static enr           
     LEFT OUTER JOIN gabby.people.adp_ps_id_link link
       ON enr.teachernumber = CONVERT(VARCHAR(125),link.teachernumber)
      AND link.is_master = 1     
     WHERE enr.course_number = 'ADV'
       AND enr.sectionid > 0
       AND enr.schoolid = 133570965
    ) sub
LEFT OUTER JOIN gabby.adp.staff_roster adp
  ON sub.associate_id = adp.associate_id
 AND adp.rn_curr = 1
LEFT OUTER JOIN gabby.adsi.user_attributes_static dir
  ON adp.position_id = dir.employeenumber
 AND dir.is_active = 1