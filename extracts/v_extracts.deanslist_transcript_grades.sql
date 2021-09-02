USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_transcript_grades AS

WITH all_grades AS (
  SELECT fg.student_number
        ,fg.schoolid
        ,fg.academic_year
        ,'Y1' AS term
        ,fg.course_number
        ,fg.course_name
        ,fg.credit_hours
        ,fg.y1_grade_percent_adjusted AS y1_grade_percent
        ,fg.y1_grade_letter
        ,sch.[name] AS schoolname
        ,0 AS is_stored
  FROM gabby.powerschool.final_grades_static fg 
  JOIN gabby.powerschool.schools sch
    ON fg.schoolid = sch.school_number
   AND fg.[db_name] = sch.[db_name]
   AND sch.high_grade IN (8, 12)
  WHERE fg.is_curterm = 1
    AND fg.excludefromgpa = 0

  UNION ALL

  SELECT s.student_number
        ,sg.schoolid
        ,sg.academic_year
        ,'Y1' AS term
        ,sg.course_number
        ,sg.course_name
        ,sg.earnedcrhrs AS credit_hours
        ,sg.[percent] AS y1_grade_percent
        ,sg.grade AS y1_grade_letter
        ,sg.schoolname
        ,1 AS is_stored
  FROM gabby.powerschool.storedgrades sg
  JOIN gabby.powerschool.students s
    ON sg.studentid = s.id
   AND sg.[db_name] = s.[db_name]
  WHERE ISNULL(sg.excludefromgpa, 0) = 0
    AND ISNULL(sg.excludefromtranscripts, 0) = 0
    AND sg.storecode = 'Y1'
 )

SELECT student_number
      ,academic_year
      ,schoolid
      ,term      
      ,course_number
      ,course_name
      ,credit_hours
      ,y1_grade_letter
      ,y1_grade_percent
      ,schoolname
      ,is_stored
FROM
    (
     SELECT student_number
           ,academic_year
           ,schoolid
           ,term
           ,course_number
           ,course_name
           ,credit_hours
           ,y1_grade_letter
           ,y1_grade_percent
           ,schoolname
           ,is_stored
           ,ROW_NUMBER() OVER(
              PARTITION BY student_number, course_number, course_name, academic_year, schoolname
                ORDER BY is_stored DESC) AS rn
     FROM all_grades
    ) sub
WHERE rn = 1
