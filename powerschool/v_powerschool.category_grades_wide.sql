CREATE OR ALTER VIEW powerschool.category_grades_wide AS

WITH grades_long AS (
  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,cat.credittype
        ,cat.course_number
        ,cat.sectionid
        ,cat.teacher_name
        ,cat.reporting_term
        ,cat.reporting_term AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,cat.grade_category_pct        
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1))
  UNION ALL
  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,'ALL' AS credittype
        ,'ALL' AS course_number
        ,NULL AS sectionid
        ,NULL AS teacher_name
        ,cat.reporting_term      
        ,cat.reporting_term AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,ROUND(AVG(cat.grade_category_pct), 0) AS grade_category_pct   
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1))
  GROUP BY cat.student_number
          ,cat.schoolid
          ,cat.academic_year
          ,cat.reporting_term      
          ,cat.grade_category
          ,cat.is_curterm

  UNION ALL

  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,cat.credittype
        ,cat.course_number
        ,cat.sectionid
        ,cat.teacher_name
        ,cat.reporting_term
        ,'CUR' AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,cat.grade_category_pct        
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1))
  UNION ALL
  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,'ALL' AS credittype
        ,'ALL' AS course_number
        ,NULL AS sectionid
        ,NULL AS teacher_name
        ,cat.reporting_term
        ,'CUR' AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,ROUND(AVG(cat.grade_category_pct), 0) AS grade_category_pct
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1))
  GROUP BY cat.student_number
          ,cat.schoolid
          ,cat.academic_year
          ,cat.reporting_term      
          ,cat.grade_category
          ,cat.is_curterm
 )

SELECT student_number
      ,schoolid
      ,academic_year
      ,credittype
      ,course_number
      ,sectionid
      ,teacher_name
      ,reporting_term      
      ,is_curterm
    
      ,[A_CUR] /* assessments */
      ,[C_CUR] /* classwork */      
      ,[H_CUR] /* homework */
      ,[P_CUR] /* class performance */
      ,[S_CUR] /* summative assessments */
      ,[E_CUR] /* homework quality for MS, exams for HS */      
      
      ,ROUND(AVG([A_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS A_Y1 
      ,ROUND(AVG([C_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS C_Y1      
      ,ROUND(AVG([H_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS H_Y1      
      ,ROUND(AVG([P_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS P_Y1
      ,ROUND(AVG([S_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS S_Y1
      ,ROUND(AVG([E_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS E_Y1

      ,MAX([A_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT1]
      ,MAX([A_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT2]
      ,MAX([A_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT3]
      ,MAX([A_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [A_RT4]
      ,MAX([C_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT1]
      ,MAX([C_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT2]
      ,MAX([C_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT3]
      ,MAX([C_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [C_RT4]
      ,MAX([E_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT1]
      ,MAX([E_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT2]
      ,MAX([E_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT3]
      ,MAX([E_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT4]
      ,MAX([H_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT1]
      ,MAX([H_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT2]
      ,MAX([H_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT3]
      ,MAX([H_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [H_RT4]
      ,MAX([P_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT1]
      ,MAX([P_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT2]
      ,MAX([P_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT3]
      ,MAX([P_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT4]
      ,MAX([S_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT1]
      ,MAX([S_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT2]
      ,MAX([S_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT3]
      ,MAX([S_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [S_RT4]

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, reporting_term, credittype
           ORDER BY course_number) AS rn_credittype
FROM
    (
     SELECT gr.student_number
           ,gr.academic_year
           ,gr.credittype
           ,gr.course_number
           ,CONVERT(VARCHAR,gr.reporting_term) AS reporting_term
           ,gr.is_curterm
           ,gr.sectionid
           ,gr.teacher_name                      

           ,CONCAT(gr.grade_category, '_', gr.rt) AS pivot_field           
           ,CASE 
             WHEN gr.schoolid = 73253 AND gr.grade_category = 'E' THEN NULL 
             ELSE gr.grade_category_pct 
            END AS grade_category_pct 

           ,MAX(gr.schoolid) OVER(PARTITION BY gr.student_number, gr.academic_year, gr.course_number, gr.reporting_term ORDER BY CONVERT(VARCHAR,gr.reporting_term) ASC) AS schoolid                      
     FROM grades_long gr       
    ) sub
PIVOT(
  MAX(grade_category_pct)
  FOR pivot_field IN ([A_CUR]
                     ,[A_RT1]
                     ,[A_RT2]
                     ,[A_RT3]
                     ,[A_RT4]
                     ,[C_CUR]
                     ,[C_RT1]
                     ,[C_RT2]
                     ,[C_RT3]
                     ,[C_RT4]
                     ,[E_CUR]
                     ,[E_RT1]
                     ,[E_RT2]
                     ,[E_RT3]
                     ,[E_RT4]
                     ,[H_CUR]
                     ,[H_RT1]
                     ,[H_RT2]
                     ,[H_RT3]
                     ,[H_RT4]
                     ,[P_CUR]
                     ,[P_RT1]
                     ,[P_RT2]
                     ,[P_RT3]
                     ,[P_RT4]
                     ,[S_CUR]
                     ,[S_RT1]
                     ,[S_RT2]
                     ,[S_RT3]
                     ,[S_RT4])
 ) p