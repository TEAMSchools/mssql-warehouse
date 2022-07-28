USE gabby
GO

CREATE OR ALTER VIEW qa.powerschool_course_enrollment_overlap AS

SELECT [db_name]
      ,student_number
      ,studentid
      ,academic_year
      ,schoolid
      ,course_number
      ,course_name
      ,dateleft
      ,dateleft_prev
FROM
    (
     SELECT [db_name]
           ,student_number
           ,studentid
           ,academic_year
           ,schoolid
           ,course_number
           ,course_name
           ,dateenrolled
           ,dateleft
           ,LAG(dateleft) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY dateleft) AS dateleft_prev
     FROM gabby.powerschool.course_enrollments_current_static
    ) sub
WHERE dateleft <= dateleft_prev
