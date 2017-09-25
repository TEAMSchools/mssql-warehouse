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
        ,CASE
          WHEN fg.schoolid = 73252 THEN 'Rise Academy'
          WHEN fg.schoolid = 73253 THEN 'Newark Collegiate Academy'
          WHEN fg.schoolid = 73258 THEN 'BOLD Academy'
          WHEN fg.schoolid = 179902 THEN 'Lanning Sq Middle School'
          WHEN fg.schoolid = 179903 THEN 'Whittier Middle School'
          WHEN fg.schoolid = 133570965 THEN 'TEAM Academy'
         END AS schoolname        
        ,0 AS is_stored
  FROM gabby.powerschool.final_grades_static fg 
  WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND is_curterm = 1
    AND ISNULL(excludefromgpa, 0) = 0

  UNION ALL

  SELECT s.student_number
        ,sg.schoolid
        ,(LEFT(sg.termid, 2) + 1990) AS academic_year
        ,'Y1' AS term      
        ,sg.course_number
        ,sg.course_name      
        ,sg.earnedcrhrs AS credit_hours      
        ,sg.[percent] AS y1_grade_percent
        ,CASE WHEN sg.grade = 'false' THEN 'F' ELSE sg.grade END AS y1_grade_letter
        ,sg.schoolname
        ,1 AS is_stored
  FROM gabby.powerschool.storedgrades sg
  JOIN gabby.powerschool.students s
    ON sg.studentid = s.id
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
              PARTITION BY student_number, course_name, academic_year
                ORDER BY is_stored DESC) AS rn
     FROM all_grades
    ) sub
WHERE rn = 1