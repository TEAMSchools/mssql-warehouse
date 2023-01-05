CREATE OR ALTER VIEW
  pm.teacher_grade_levels AS
WITH
  ps_section_teacher AS (
    SELECT
      sec.id AS sectionid,
      sec.section_number,
      sec.section_type,
      sec.course_number,
      sec.[db_name],
      t.teachernumber
    FROM
      gabby.powerschool.sections AS sec
      INNER JOIN gabby.powerschool.sectionteacher AS st ON (
        sec.id = st.sectionid
        AND sec.[db_name] = st.[db_name]
      )
      INNER JOIN gabby.powerschool.roledef AS rd ON (
        st.roleid = rd.id
        AND st.[db_name] = rd.[db_name]
        AND rd.[name] IN ('Lead Teacher', 'Co-teacher')
      )
      INNER JOIN gabby.powerschool.teachers_static AS t ON (
        st.teacherid = t.id
        AND st.[db_name] = t.[db_name]
      )
    WHERE
      (
        sec.section_type != 'SC'
        OR sec.section_type IS NULL
      )
  ),
  gl_students AS (
    SELECT
      st.teachernumber,
      enr.academic_year,
      co.grade_level AS student_grade_level,
      COUNT(DISTINCT enr.sectionid) AS n_sections_gl,
      COUNT(enr.student_number) AS n_students_gl
    FROM
      ps_section_teacher AS st
      INNER JOIN gabby.powerschool.course_enrollments AS enr ON (
        st.sectionid = enr.abs_sectionid
        AND st.[db_name] = enr.[db_name]
      )
      INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
        enr.student_number = co.student_number
        AND (
          enr.dateenrolled BETWEEN co.entrydate AND co.exitdate
        )
      )
    GROUP BY
      st.teachernumber,
      enr.academic_year,
      co.grade_level
  ),
  percentages AS (
    SELECT
      teachernumber,
      academic_year,
      student_grade_level,
      n_sections_gl,
      n_students_gl,
      n_students_total,
      CAST(n_students_gl AS FLOAT) / n_students_total AS pct_students_gl
    FROM
      (
        SELECT
          teachernumber,
          academic_year,
          student_grade_level,
          n_sections_gl,
          n_students_gl,
          SUM(n_students_gl) OVER (
            PARTITION BY
              teachernumber,
              academic_year
          ) AS n_students_total
        FROM
          gl_students
      ) AS sub
  )
SELECT
  p.teachernumber,
  p.academic_year,
  p.student_grade_level,
  p.n_sections_gl,
  p.n_students_gl,
  p.n_students_total,
  p.pct_students_gl,
  ROW_NUMBER() OVER (
    PARTITION BY
      p.teachernumber,
      p.academic_year
    ORDER BY
      p.pct_students_gl DESC
  ) AS is_primary_gl,
  COALESCE(
    idps.df_employee_number,
    CASE
      WHEN ISNUMERIC(p.teachernumber) = 1 THEN p.teachernumber
    END
  ) AS employee_number
FROM
  percentages AS p
  LEFT JOIN gabby.people.id_crosswalk_powerschool AS idps ON (
    p.teachernumber = idps.ps_teachernumber
    AND idps.is_master = 1
  )
