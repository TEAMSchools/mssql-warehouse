WITH
  grades AS (
    SELECT
      s.student_number,
      s.lastfirst,
      sg.grade_level,
      CASE
        WHEN sg.credit_type LIKE 'ENG%' THEN 'English'
        WHEN sg.credit_type LIKE 'MATH%' THEN 'Math'
        WHEN sg.credit_type LIKE 'SCI%' THEN 'Science'
        WHEN sg.credit_type LIKE 'SOC%' THEN 'History'
        WHEN sg.credit_type LIKE 'PHYSED%' THEN 'Phys Ed'
        WHEN sg.credit_type LIKE 'ART%' THEN 'VPA'
        WHEN sg.credit_type LIKE 'WLANG%' THEN 'World Lang'
      END AS [subject],
      sg.credit_type,
      sg.course_number,
      sg.potentialcrhrs,
      sg.earnedcrhrs,
      sg.[percent],
      sg.grade,
      sg.gpa_points,
      sg.gradescale_name,
      'Stored' AS [source]
    FROM
      gabby.powerschool.storedgrades AS sg
      LEFT JOIN gabby.powerschool.students AS s ON sg.studentid = s.id
      AND sg.[db_name] = s.[db_name]
    WHERE
      sg.schoolid = 73253
      AND sg.storecode = 'Y1'
      AND s.grade_level = 12
      AND s.enroll_status = 0
    UNION ALL
    SELECT
      s.student_number,
      s.lastfirst,
      s.grade_level,
      CASE
        WHEN c.credittype LIKE 'ENG%' THEN 'English'
        WHEN c.credittype LIKE 'MATH%' THEN 'Math'
        WHEN c.credittype LIKE 'SCI%' THEN 'Science'
        WHEN c.credittype LIKE 'SOC%' THEN 'History'
        WHEN c.credittype LIKE 'PHYSED%' THEN 'Phys Ed'
        WHEN c.credittype LIKE 'ART%' THEN 'VPA'
        WHEN c.credittype LIKE 'WLANG%' THEN 'World Lang'
      END AS [subject],
      c.credittype AS credit_type,
      fgs.course_number,
      fgs.potential_credit_hours AS potentialcrhrs,
      CASE
        WHEN fgs.y1_grade_letter LIKE 'F%' THEN 0
        ELSE fgs.potential_credit_hours
      END AS earnedcrhrs,
      fgs.y1_grade_percent_adj AS [percent],
      fgs.y1_grade_letter AS grade,
      fgs.y1_grade_pts AS gpa_points,
      STR(fgs.gradescaleid) AS gradescale_name,
      'Current' AS [source]
    FROM
      gabby.powerschool.final_grades_static AS fgs
      LEFT JOIN gabby.powerschool.courses AS c ON fgs.course_number = c.course_number
      AND fgs.[db_name] = c.[db_name]
      LEFT JOIN gabby.powerschool.students AS s ON fgs.studentid = s.id
      AND fgs.[db_name] = s.[db_name]
    WHERE
      s.enroll_status = 0
      AND s.grade_level = 12
      AND fgs.storecode = 'Q4'
      AND fgs.potential_credit_hours != 0
      AND s.schoolid = 73253
      AND fgs.yearid = RIGHT(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
        2
      ) + 10
  )
SELECT
  student_number,
  lastfirst,
  [Math],
  [English],
  [Science],
  [History],
  [Phys Ed],
  [VPA],
  [World Lang]
FROM
  (
    SELECT
      g.student_number,
      g.lastfirst,
      g.[subject],
      ROUND(
        SUM(g.gpa_points * g.earnedcrhrs) / SUM(g.potentialcrhrs),
        2
      ) AS y1_gpa
    FROM
      grades AS g
    GROUP BY
      g.student_number,
      g.lastfirst,
      g.[subject]
  ) AS sub PIVOT (
    MAX(y1_gpa) FOR [subject] IN (
      [Math],
      [English],
      [Science],
      [History],
      [Phys Ed],
      [VPA],
      [World Lang]
    )
  ) AS p
