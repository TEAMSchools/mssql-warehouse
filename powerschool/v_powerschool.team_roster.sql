USE gabby
GO

CREATE OR ALTER VIEW powerschool.team_roster AS

SELECT enr.studentid
      ,enr.student_number                      
      ,enr.academic_year                       
      ,CASE
        WHEN gabby.utilities.STRIP_CHARACTERS(enr.section_number,'0-9') = '' THEN enr.teacher_name
        ELSE gabby.utilities.STRIP_CHARACTERS(enr.section_number,'0-9')
       END AS team

      ,ROW_NUMBER() OVER(
         PARTITION BY enr.student_number, enr.academic_year
           ORDER BY enr.dateleft DESC, enr.dateenrolled DESC) AS rn_year
FROM gabby.powerschool.course_enrollments_static enr           
WHERE enr.course_number = 'HR'
  AND enr.sectionid > 0