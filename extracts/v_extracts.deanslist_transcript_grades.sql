USE KIPP_NJ
GO

ALTER VIEW DL$transcript_grades#extract AS

WITH all_grades AS (
  SELECT CONVERT(INT,o.student_number) AS student_number        
        ,o.schoolid
        ,o.academic_year
        ,'Y1' AS term      
        ,o.course_number
        ,o.course_name      
        ,o.credit_hours      
      
        /* final grades */      
        ,fg.y1_grade_percent_adjusted AS y1_grade_percent
        ,fg.y1_grade_letter

        ,CASE
          WHEN o.schoolid = 73252 THEN 'Rise Academy'
          WHEN o.schoolid = 73253 THEN 'Newark Collegiate Academy'
          WHEN o.schoolid = 73258 THEN 'BOLD Academy'
          WHEN o.schoolid = 179902 THEN 'Lanning Sq Middle School'
          WHEN o.schoolid = 179903 THEN 'Whittier Middle School'
          WHEN o.schoolid = 133570965 THEN 'TEAM Academy'
         END AS schoolname
        ,0 AS is_stored
  FROM KIPP_NJ..PS$course_order_scaffold#static o WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_long#static fg WITH(NOLOCK)
    ON o.student_number = fg.student_number
   AND o.academic_year = fg.academic_year
   AND o.course_number = fg.course_number
   AND o.term = fg.term
  WHERE o.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND o.course_number != 'ALL'
    AND o.is_curterm = 1
    AND ISNULL(o.EXCLUDEFROMGPA, 0) = 0

  UNION ALL

  SELECT CONVERT(INT,s.student_number) AS student_number
        ,sg.schoolid
        ,sg.academic_year
        ,'Y1' AS term      
        ,sg.course_number
        ,sg.course_name      
        ,sg.EARNEDCRHRS AS credit_hours
      
        /* final grades */      
        ,sg.[PERCENT] AS y1_grade_percent
        ,sg.GRADE AS y1_grade_letter

        ,sg.schoolname
        ,1 AS is_stored
  FROM KIPP_NJ..GRADES$STOREDGRADES#static sg
  JOIN KIPP_NJ..PS$STUDENTS#static s 
    ON sg.studentid = s.id
  WHERE ISNULL(sg.EXCLUDEFROMGPA,0) = 0
    AND ISNULL(sg.EXCLUDEFROMTRANSCRIPTS,0) = 0
    AND sg.STORECODE = 'Y1'
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