SELECT
  *
FROM
  (
    SELECT
      s.student_number,
      s.grade_level,
      s.schoolid,
      CASE
        WHEN g.[name] = 'KIPP NJ 2019 (5-12) Weighted'
        AND fg.y1_grade_percent_adj = 59 THEN 1.67
        WHEN g.[name] = 'KIPP NJ 2019 (5-12) Unweighted'
        AND fg.y1_grade_percent_adj = 59 THEN 0.67
        WHEN g.[name] = 'Florida - 6-12'
        AND fg.y1_grade_percent_adj = 59 THEN 1.00
        ELSE fg.y1_grade_pts
      END AS gpa_points,
      CASE
        WHEN fg.y1_grade_percent_adj > 100 THEN 100
        WHEN fg.y1_grade_percent_adj = 59 THEN 60
        ELSE fg.y1_grade_percent_adj
      END AS [percent],
      CASE
        WHEN g.[name] = 'Florida - 6-12'
        AND fg.y1_grade_percent_adj = 59 THEN 'D'
        WHEN g.[name] IN (
          'KIPP NJ 2019 (5-12) Unweighted',
          'KIPP NJ 2019 (5-12) Weighted'
        )
        AND fg.y1_grade_percent_adj = 59 THEN 'D-'
        ELSE fg.y1_grade_letter
      END AS grade,
      'Y1' AS storecode,
      sec.credittype AS credit_type,
      sec.course_number,
      sec.course_name,
      sec.teacher_lastfirst AS teacher_name,
      sec.sectionid,
      sec.credit_hours AS [PotentialCrHrs],
      CASE
        WHEN fg.y1_grade_percent_adj >= 59 THEN sec.credit_hours
        ELSE 0
      END AS [EarnedCrHrs],
      g.[name] AS gradescale_name,
      sch.[name] AS schoolname,
      sec.termid,
      ROW_NUMBER() OVER (
        PARTITION BY
          fg.[db_name],
          fg.studentid,
          fg.yearid,
          fg.course_number
        ORDER BY
          fg.termbin_end_date DESC
      ) AS rn,
      fg.storecode AS original_storecode
    FROM
      powerschool.final_grades_static AS fg
      INNER JOIN powerschool.gradescaleitem AS g ON (
        fg.gradescaleid = g.id
        AND fg.db_name = g.db_name
      )
      INNER JOIN powerschool.sections_identifiers AS sec ON (
        fg.sectionid = sec.sectionid
        AND fg.db_name = sec.db_name
      )
      INNER JOIN powerschool.schools AS sch ON (sec.schoolid = sch.school_number)
      INNER JOIN powerschool.students AS s ON (
        s.id = fg.studentid
        AND s.[db_name] = fg.[db_name]
      )
    WHERE
      fg.y1_grade_letter IS NOT NULL
      AND fg.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
  ) AS sub
WHERE
  rn = 1
