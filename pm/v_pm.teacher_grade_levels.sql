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
        ,co.academic_year
        ,co.grade_level AS student_grade_level
        ,COUNT(enr.student_number) AS n_gl_students
  FROM gabby.people.staff_crosswalk_static sr 
  JOIN ps_section_teacher st
    ON sr.ps_teachernumber = st.teachernumber COLLATE Latin1_General_BIN
   AND sr.db_name = st.db_name
  JOIN gabby.powerschool.course_enrollments_static enr
    ON st.sectionid = enr.abs_sectionid
   AND st.db_name = enr.db_name
  JOIN gabby.powerschool.cohort_identifiers_static co
    ON enr.student_number = co.student_number
   AND enr.academic_year = co.academic_year
  GROUP BY sr.df_employee_number, co.academic_year, co.grade_level
)

,percentages AS (

  SELECT g.df_employee_number
        ,g.academic_year
        ,g.student_grade_level
        ,g.n_gl_students
        ,SUM(g.n_gl_students) OVER( PARTITION BY g.df_employee_number, g.academic_year) AS n_total_students
        ,CONVERT(FLOAT,n_gl_students)/CONVERT(FLOAT,SUM(g.n_gl_students) OVER( PARTITION BY g.df_employee_number, g.academic_year)) AS percent_gl
  FROM gl_students g

)

SELECT df_employee_number
      ,academic_year
      ,student_grade_level
      ,n_gl_students
      ,n_total_students
      ,percent_gl
      ,CASE WHEN MAX(percent_gl) OVER( PARTITION BY df_employee_number, academic_year) = percent_gl THEN 1 ELSE 0 END AS primary_gl
FROM percentages