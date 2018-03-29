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
      
      ,df.mobile_number AS advisor_phone

      ,dir.mail AS advisor_email

      ,CONVERT(INT,ROW_NUMBER() OVER(
                     PARTITION BY sub.student_number, sub.academic_year
                       ORDER BY sub.dateleft DESC, sub.dateenrolled DESC)) AS rn_year
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
LEFT JOIN gabby.dayforce.staff_roster df
  ON sub.associate_id = df.adp_associate_id
LEFT JOIN gabby.adsi.user_attributes_static dir
  ON df.adp_associate_id = dir.idautopersonalternateid
 AND dir.is_active = 1