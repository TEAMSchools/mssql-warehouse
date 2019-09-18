CREATE OR ALTER VIEW powerschool.advisory AS

SELECT studentid
      ,student_number
      ,academic_year
      ,teachernumber
      ,advisor_name
      ,dateenrolled
      ,dateleft      
      ,advisor_phone
      ,advisor_email
      ,1 AS rn_year
FROM
    (
     SELECT enr.studentid
           ,enr.student_number
           ,enr.academic_year
           ,enr.teachernumber
           ,enr.teacher_name AS advisor_name
           ,enr.dateenrolled
           ,enr.dateleft

           ,scw.mobile_number AS advisor_phone
           ,scw.mail AS advisor_email

           ,CONVERT(INT,ROW_NUMBER() OVER(
                          PARTITION BY enr.student_number, enr.academic_year
                            ORDER BY enr.dateleft DESC, enr.dateenrolled DESC)) AS rn_year
     FROM powerschool.course_enrollments_static enr
     LEFT JOIN gabby.people.staff_crosswalk_static scw
       ON enr.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
     WHERE enr.course_number = 'HR'
       AND enr.sectionid > 0
    ) sub
WHERE rn_year = 1