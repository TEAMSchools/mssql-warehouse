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

           ,df.mobile_number COLLATE Latin1_General_BIN AS advisor_phone

           ,dir.mail COLLATE Latin1_General_BIN AS advisor_email

           ,CONVERT(INT,ROW_NUMBER() OVER(
                          PARTITION BY enr.student_number, enr.academic_year
                            ORDER BY enr.dateleft DESC, enr.dateenrolled DESC)) AS rn_year
     FROM powerschool.course_enrollments_static enr           
     LEFT JOIN gabby.people.id_crosswalk_powerschool psid
       ON enr.teachernumber = psid.ps_teachernumber COLLATE Latin1_General_BIN
     LEFT JOIN gabby.dayforce.staff_roster df
       ON COALESCE(psid.df_employee_number, enr.teachernumber) = df.df_employee_number
     LEFT JOIN gabby.adsi.user_attributes_static dir
       ON df.df_employee_number = dir.employeenumber
      AND dir.is_active = 1
      AND ISNUMERIC(dir.employeenumber) = 1
     WHERE enr.course_number = 'HR'
       AND enr.sectionid > 0
    ) sub
WHERE rn_year = 1