USE gabby
GO

CREATE OR ALTER VIEW pm.teacher_grade_levels AS

WITH ps_section_teacher AS (
  SELECT sec.id AS sectionid
        ,sec.section_number
        ,sec.section_type
        ,sec.course_number_clean AS course_number        
        ,sec.db_name
                
        ,t.teachernumber
  FROM gabby.powerschool.sections sec  
  JOIN gabby.powerschool.sectionteacher st
    ON sec.id = st.sectionid
   AND sec.db_name = st.db_name
   AND st.roleid IN (25, 26, 41, 42)
  JOIN gabby.powerschool.teachers_static t
    ON st.teacherid = t.id
   AND st.db_name = t.db_name
  WHERE (sec.section_type != 'SC' OR sec.section_type IS NULL)
 )

,gl_students AS (

  SELECT sr.df_employee_number
        ,enr.academic_year
        ,co.grade_level AS student_grade_level
        ,COUNT(DISTINCT enr.student_number) AS n_gl_students
  FROM gabby.people.staff_crosswalk_static sr 
  JOIN ps_section_teacher st
    ON sr.ps_teachernumber = st.teachernumber COLLATE Latin1_General_BIN
   AND sr.db_name = st.db_name
  JOIN gabby.powerschool.course_enrollments_static enr
    ON st.sectionid = enr.abs_sectionid
   AND st.db_name = enr.db_name
  JOIN gabby.powerschool.cohort_identifiers_static co
    ON enr.student_number = co.student_number
  GROUP BY sr.df_employee_number, enr.academic_year, co.grade_level

)

, total_students AS (
  SELECT sr.df_employee_number
        ,enr.academic_year
        ,COUNT(DISTINCT enr.student_number) AS n_total_students
  FROM gabby.people.staff_crosswalk_static sr 
  JOIN ps_section_teacher st
    ON sr.ps_teachernumber = st.teachernumber COLLATE Latin1_General_BIN
   AND sr.db_name = st.db_name
  JOIN gabby.powerschool.course_enrollments_static enr
    ON st.sectionid = enr.abs_sectionid
   AND st.db_name = enr.db_name

  GROUP BY sr.df_employee_number, enr.academic_year
)

,percentages AS (

SELECT t.df_employee_number
      ,t.academic_year
      ,t.n_total_students
      ,g.student_grade_level
      ,g.n_gl_students
      ,CONVERT(FLOAT,g.n_gl_students) / (CASE WHEN t.n_total_students = 0 THEN 1 ELSE CONVERT(FLOAT,t.n_total_students) END) AS percent_gl
      ,MAX(CONVERT(FLOAT,g.n_gl_students) / (CASE WHEN t.n_total_students = 0 THEN 1 ELSE CONVERT(FLOAT,t.n_total_students) END)) AS max_percentage
FROM gl_students g LEFT JOIN total_students t
  ON g.df_employee_number = t.df_employee_number
 AND g.academic_year = t.academic_year
WHERE n_total_students > 0
GROUP BY t.df_employee_number, t.academic_year, t.n_total_students, g.student_grade_level, g.n_gl_students

)

SELECT df_employee_number
      ,academic_year
      ,student_grade_level AS primary_grade_level
FROM percentages 
WHERE percent_gl = max_percentage