CREATE OR ALTER VIEW
  extracts.deanslist_transcript_grades AS
WITH
  all_grades AS (
    SELECT
      s.student_number,
      sg.schoolid,
      sg.academic_year,
      sg.course_number,
      sg.course_name,
      sg.earnedcrhrs AS credit_hours,
      sg.[percent] AS y1_grade_percent,
      sg.grade AS y1_grade_letter,
      sg.schoolname,
      sg.storecode,
      1 AS is_stored
    FROM
      gabby.powerschool.storedgrades AS sg
      INNER JOIN gabby.powerschool.students AS s ON sg.studentid = s.id
      AND sg.[db_name] = s.[db_name]
    WHERE
      ISNULL(sg.excludefromtranscripts, 0) = 0
      AND sg.storecode = 'Y1'
    UNION ALL
    SELECT
      s.student_number,
      s.schoolid,
      fg.yearid + 1990 AS academic_year,
      fg.course_number,
      c.course_name,
      fg.potential_credit_hours AS credit_hours,
      fg.y1_grade_percent_adj AS y1_grade_percent,
      fg.y1_grade_letter,
      sch.[name] AS schoolname,
      'Y1' AS storecode,
      0 AS is_stored
    FROM
      gabby.powerschool.students AS s
      INNER JOIN gabby.powerschool.final_grades_static AS fg ON fg.studentid = s.id
      AND fg.[db_name] = s.[db_name]
      AND fg.exclude_from_gpa = 0
      AND CAST(CURRENT_TIMESTAMP AS DATE) (
        BETWEEN fg.termbin_start_date AND fg.termbin_end_date
      )
      INNER JOIN gabby.powerschool.courses AS c ON fg.course_number = c.course_number
      AND fg.[db_name] = c.[db_name]
      INNER JOIN gabby.powerschool.schools AS sch ON s.schoolid = sch.school_number
      AND s.[db_name] = sch.[db_name]
    WHERE
      s.grade_level >= 5
  )
SELECT
  student_number,
  academic_year,
  schoolid,
  storecode AS term,
  course_number,
  course_name,
  credit_hours,
  y1_grade_letter,
  y1_grade_percent,
  schoolname,
  is_stored
FROM
  (
    SELECT
      student_number,
      academic_year,
      schoolid,
      storecode,
      course_number,
      course_name,
      credit_hours,
      y1_grade_letter,
      y1_grade_percent,
      schoolname,
      is_stored,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number,
          course_number,
          course_name,
          academic_year,
          schoolname
        ORDER BY
          is_stored DESC
      ) AS rn
    FROM
      all_grades
  ) AS sub
WHERE
  rn = 1
