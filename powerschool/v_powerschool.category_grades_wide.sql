CREATE OR ALTER VIEW powerschool.category_grades_wide AS

WITH grades_long AS (
  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,cat.credittype
        ,cat.course_number
        ,cat.reporting_term
        ,cat.reporting_term AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,cat.grade_category_pct
        ,cat.citizenship
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  UNION ALL
  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,'ALL' AS credittype
        ,'ALL' AS course_number
        ,cat.reporting_term
        ,cat.reporting_term AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,ROUND(AVG(cat.grade_category_pct), 0) AS grade_category_pct
        ,NULL AS citizenship
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
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
        ,cat.reporting_term
        ,'CUR' AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,cat.grade_category_pct
        ,cat.citizenship
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  UNION ALL
  SELECT cat.student_number
        ,cat.schoolid
        ,cat.academic_year
        ,'ALL' AS credittype
        ,'ALL' AS course_number
        ,cat.reporting_term
        ,'CUR' AS rt
        ,cat.is_curterm
        ,cat.grade_category
        ,ROUND(AVG(cat.grade_category_pct), 0) AS grade_category_pct
        ,NULL AS citizenship
  FROM powerschool.category_grades_static cat
  WHERE cat.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  GROUP BY cat.student_number
          ,cat.schoolid
          ,cat.academic_year
          ,cat.reporting_term
          ,cat.grade_category
          ,cat.is_curterm
 )


,grades_unpivot AS (
  SELECT student_number
        ,schoolid
        ,academic_year
        ,credittype
        ,course_number
        ,reporting_term
        ,rt
        ,is_curterm
        ,grade_category
        ,field
        ,[value]
  FROM
      (
       SELECT student_number
             ,schoolid
             ,academic_year
             ,credittype
             ,course_number
             ,reporting_term
             ,rt
             ,is_curterm
             ,grade_category
             ,CONVERT(NVARCHAR(8), grade_category_pct) AS grade_category_pct
             ,CONVERT(NVARCHAR(8), citizenship) AS citizenship
       FROM grades_long
      ) sub
  UNPIVOT(
    [value]
    FOR field IN (grade_category_pct, citizenship)
   ) u
 )

,grades_repivot AS (
  SELECT student_number
        ,academic_year
        ,credittype
        ,course_number
        ,reporting_term
        ,is_curterm
        ,schoolid
        ,CONVERT(FLOAT, M_CUR) AS M_CUR
        ,CONVERT(FLOAT, M_RT1) AS M_RT1
        ,CONVERT(FLOAT, M_RT2) AS M_RT2
        ,CONVERT(FLOAT, M_RT3) AS M_RT3
        ,CONVERT(FLOAT, M_RT4) AS M_RT4
        ,CONVERT(FLOAT, P_CUR) AS P_CUR
        ,CONVERT(FLOAT, P_RT1) AS P_RT1
        ,CONVERT(FLOAT, P_RT2) AS P_RT2
        ,CONVERT(FLOAT, P_RT3) AS P_RT3
        ,CONVERT(FLOAT, P_RT4) AS P_RT4
        ,CONVERT(FLOAT, W_CUR) AS W_CUR
        ,CONVERT(FLOAT, W_RT1) AS W_RT1
        ,CONVERT(FLOAT, W_RT2) AS W_RT2
        ,CONVERT(FLOAT, W_RT3) AS W_RT3
        ,CONVERT(FLOAT, W_RT4) AS W_RT4
        ,CONVERT(FLOAT, E_CUR) AS E_CUR
        ,CONVERT(FLOAT, E_RT1) AS E_RT1
        ,CONVERT(FLOAT, E_RT2) AS E_RT2
        ,CONVERT(FLOAT, E_RT3) AS E_RT3
        ,CONVERT(FLOAT, E_RT4) AS E_RT4
        ,CTZ_CUR
        ,CTZ_RT1
        ,CTZ_RT2
        ,CTZ_RT3
        ,CTZ_RT4
  FROM
      (
       SELECT gr.student_number
             ,gr.academic_year
             ,gr.credittype
             ,gr.course_number
             ,CONVERT(VARCHAR(5), gr.reporting_term) AS reporting_term
             ,gr.is_curterm
             ,CONCAT(gr.grade_category, '_', gr.rt) AS pivot_field
             ,gr.[value]
             ,MAX(gr.schoolid) OVER(
                PARTITION BY gr.student_number, gr.academic_year, gr.course_number, gr.reporting_term 
                  ORDER BY gr.reporting_term ASC) AS schoolid
       FROM grades_unpivot gr
       WHERE gr.field = 'grade_category_pct'

       UNION ALL

       SELECT gr.student_number
             ,gr.academic_year
             ,gr.credittype
             ,gr.course_number
             ,CONVERT(VARCHAR(5), gr.reporting_term) AS reporting_term
             ,gr.is_curterm
             ,CONCAT('CTZ_', gr.rt) AS pivot_field
             ,gr.[value]
             ,MAX(gr.schoolid) OVER(
                PARTITION BY gr.student_number, gr.academic_year, gr.course_number, gr.reporting_term 
                  ORDER BY gr.reporting_term ASC) AS schoolid
       FROM grades_unpivot gr
       WHERE gr.field = 'citizenship'
         AND gr.grade_category = 'Q'
      ) sub
  PIVOT(
    MAX([value])
    FOR pivot_field IN ([M_CUR],[M_RT1],[M_RT2],[M_RT3],[M_RT4]
                       ,[P_CUR],[P_RT1],[P_RT2],[P_RT3],[P_RT4]
                       ,[W_CUR],[W_RT1],[W_RT2],[W_RT3],[W_RT4]
                       ,[E_CUR],[E_RT1],[E_RT2],[E_RT3],[E_RT4]
                       ,[CTZ_CUR],[CTZ_RT1],[CTZ_RT2],[CTZ_RT3],[CTZ_RT4])
   ) p
 )

SELECT student_number
      ,schoolid
      ,academic_year
      ,credittype
      ,course_number
      ,reporting_term
      ,is_curterm

      ,[M_CUR] /* mastery */
      ,[P_CUR] /* participation */
      ,[W_CUR] /* work habits */
      ,[E_CUR] /* homework quality for MS, exams for HS */

      ,ROUND(AVG([M_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS M_Y1
      ,ROUND(AVG([P_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS P_Y1
      ,ROUND(AVG([W_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS W_Y1
      ,ROUND(AVG([E_CUR]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS E_Y1

      ,MAX([M_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [M_RT1]
      ,MAX([M_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [M_RT2]
      ,MAX([M_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [M_RT3]
      ,MAX([M_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [M_RT4]
      ,MAX([P_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT1]
      ,MAX([P_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT2]
      ,MAX([P_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT3]
      ,MAX([P_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [P_RT4]
      ,MAX([W_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [W_RT1]
      ,MAX([W_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [W_RT2]
      ,MAX([W_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [W_RT3]
      ,MAX([W_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [W_RT4]
      ,MAX([E_RT1]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT1]
      ,MAX([E_RT2]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT2]
      ,MAX([E_RT3]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT3]
      ,MAX([E_RT4]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC) AS [E_RT4]

      ,CTZ_CUR
      ,CTZ_RT1
      ,CTZ_RT2
      ,CTZ_RT3
      ,CTZ_RT4

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, reporting_term, credittype
           ORDER BY course_number) AS rn_credittype
FROM grades_repivot
