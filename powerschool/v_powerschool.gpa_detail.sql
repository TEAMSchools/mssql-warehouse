USE gabby
GO

CREATE OR ALTER VIEW powerschool.gpa_detail AS

SELECT student_number
      ,schoolid
      ,grade_level
      ,academic_year
      ,term_name
      ,semester
      ,reporting_term
      ,is_curterm      
      ,total_credit_hours      
      ,grade_avg_term
      ,gpa_points_total_term
      ,weighted_gpa_points_term
      ,gpa_term      
      ,grade_avg_y1
      ,gpa_points_total_y1
      ,weighted_gpa_points_y1
      ,gpa_y1
      ,gpa_y1_unweighted      
      ,n_failing_y1

      /* GPA semester */
      ,AVG(grade_avg_term) OVER(PARTITION BY student_number, academic_year, semester) AS grade_avg_semester
      ,SUM(GPA_points_total_term) OVER(PARTITION BY student_number, academic_year, semester) AS gpa_points_total_semester
      ,SUM(weighted_GPA_points_term) OVER(PARTITION BY student_number, academic_year, semester) AS weighted_gpa_points_semester
      ,SUM(total_credit_hours) OVER(PARTITION BY student_number, academic_year, semester) AS total_credit_hours_semester
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM(weighted_GPA_points_term) OVER(PARTITION BY student_number, academic_year, semester)
         / SUM(credit_hours_term) OVER(PARTITION BY student_number, academic_year, semester)),2)) AS gpa_semester
FROM
    (
     SELECT student_number
           ,schoolid
           ,grade_level      
           ,academic_year      
           ,term_name                       
           ,reporting_term 
           ,is_curterm
           ,CASE 
             WHEN term_name IN ('Q1','Q2') THEN 'S1'
             WHEN term_name IN ('Q3','Q4') THEN 'S2'
            END AS semester

           /* GPA term */
           ,ROUND(AVG(term_grade_percent),0) AS grade_avg_term
           ,SUM(term_gpa_points) AS gpa_points_total_term
           ,SUM((credit_hours * term_gpa_points)) AS weighted_gpa_points_term      
           ,SUM(CASE WHEN term_grade_percent IS NULL THEN NULL ELSE credit_hours END) AS credit_hours_term
           /* when no term_name pct, then exclude credit hours */
           ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * term_gpa_points)) / SUM(CASE WHEN term_grade_percent IS NULL THEN NULL ELSE credit_hours END)),2)) AS gpa_term
           
           /* GPA Y1 */
           ,ROUND(AVG(y1_grade_percent_adjusted),0) AS grade_avg_y1      
           ,SUM(y1_gpa_points) AS gpa_points_total_y1
           ,SUM((credit_hours * y1_gpa_points)) AS weighted_gpa_points_y1
           /* when no y1 pct, then exclude credit hours */
           ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * y1_gpa_points)) / SUM(CASE WHEN y1_grade_percent_adjusted IS NULL THEN NULL ELSE credit_hours END)),2)) AS gpa_y1
           ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * y1_gpa_points_unweighted)) / SUM(CASE WHEN y1_grade_percent_adjusted IS NULL THEN NULL ELSE credit_hours END)),2)) AS gpa_y1_unweighted
           
           /* other */
           ,SUM(CASE WHEN y1_grade_percent_adjusted IS NULL THEN NULL ELSE credit_hours END) AS total_credit_hours
           ,SUM(CASE WHEN y1_grade_letter LIKE 'F%' THEN 1 ELSE 0 END) AS n_failing_y1
     FROM gabby.powerschool.final_grades_static
     WHERE excludefromgpa = 0
     GROUP BY student_number
             ,academic_year      
             ,term_name
             ,reporting_term 
             ,is_curterm
             ,schoolid
             ,grade_level
     HAVING SUM(credit_hours) > 0
    ) sub