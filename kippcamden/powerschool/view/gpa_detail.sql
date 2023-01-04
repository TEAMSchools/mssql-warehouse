CREATE OR ALTER VIEW
  powerschool.gpa_detail AS
WITH
  grade_detail AS (
    /* current year */
    SELECT
      co.student_number,
      co.schoolid,
      co.grade_level,
      co.academic_year,
      fg.storecode,
      fg.y1_grade_letter,
      CAST(
        fg.term_grade_percent AS DECIMAL(3, 0)
      ) AS term_grade_percent,
      CAST(
        fg.y1_grade_percent_adj AS DECIMAL(3, 0)
      ) AS y1_grade_percent_adj,
      CAST(
        fg.potential_credit_hours AS DECIMAL(5, 2)
      ) AS potential_credit_hours,
      CAST(
        fg.term_grade_pts AS DECIMAL(3, 2)
      ) AS term_grade_pts,
      CAST(fg.y1_grade_pts AS DECIMAL(3, 2)) AS y1_grade_pts,
      CAST(
        fg.y1_grade_pts_unweighted AS DECIMAL(3, 2)
      ) AS y1_grade_pts_unweighted,
      rt.time_per_name AS reporting_term,
      rt.is_curterm
    FROM
      powerschool.cohort_static AS co
      INNER JOIN powerschool.final_grades_static AS fg ON (
        co.studentid = fg.studentid
        AND co.yearid = fg.yearid
        AND fg.exclude_from_gpa = 0
        AND fg.potential_credit_hours > 0
      )
      INNER JOIN gabby.reporting.reporting_terms AS rt ON (
        co.schoolid = rt.schoolid
        AND co.academic_year = rt.academic_year
        AND (
          fg.storecode = rt.alt_name
          COLLATE LATIN1_GENERAL_BIN
        )
        AND rt.identifier = 'RT'
      )
    WHERE
      co.rn_year = 1
    UNION ALL
    /* previous years */
    SELECT
      s.student_number,
      sg.schoolid,
      sg.grade_level,
      sg.academic_year,
      sg.storecode,
      y1.grade AS y1_grade_letter,
      CAST(sg.[percent] AS DECIMAL(3, 0)) AS term_grade_percent,
      CAST(y1.[percent] AS DECIMAL(3, 0)) AS y1_grade_percent_adjusted,
      CAST(c.credit_hours AS DECIMAL(5, 2)) AS potential_credit_hours,
      CAST(sg.gpa_points AS DECIMAL(3, 2)) AS term_grade_pts,
      CAST(y1.gpa_points AS DECIMAL(3, 2)) AS y1_grade_pts,
      NULL AS y1_grade_pts_unweighted,
      NULL AS reporting_term,
      CASE
        WHEN sg.storecode IN ('Q4', 'T3') THEN 1
        ELSE 0
      END AS is_curterm
    FROM
      powerschool.storedgrades AS sg
      INNER JOIN powerschool.students AS s ON (sg.studentid = s.id)
      INNER JOIN powerschool.courses AS c ON (
        sg.course_number = c.course_number
        AND c.credit_hours > 0
      )
      LEFT JOIN powerschool.storedgrades AS y1 ON (
        sg.studentid = y1.studentid
        AND LEFT(sg.termid, 2) = LEFT(y1.termid, 2)
        AND sg.course_number = y1.course_number
        AND y1.storecode = 'Y1'
      )
    WHERE
      sg.storecode_type IN ('Q', 'T')
      AND sg.excludefromgpa = 0
      AND sg.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  )
SELECT
  student_number,
  schoolid,
  grade_level,
  academic_year,
  storecode AS term_name,
  semester,
  reporting_term,
  is_curterm,
  gpa_points_total_term,
  gpa_term,
  gpa_points_total_y1,
  gpa_y1,
  gpa_y1_unweighted,
  n_failing_y1,
  total_credit_hours,
  CAST(grade_avg_term AS DECIMAL(3, 0)) AS grade_avg_term,
  CAST(grade_avg_y1 AS DECIMAL(3, 0)) AS grade_avg_y1,
  CAST(
    ROUND(weighted_gpa_points_term, 2) AS DECIMAL(5, 2)
  ) AS weighted_gpa_points_term,
  CAST(
    ROUND(weighted_gpa_points_y1, 2) AS DECIMAL(5, 2)
  ) AS weighted_gpa_points_y1,
  /* gpa semester */
  SUM(gpa_points_total_term) OVER (
    PARTITION BY
      student_number,
      academic_year,
      semester
  ) AS gpa_points_total_semester,
  CAST(
    ROUND(
      AVG(grade_avg_term) OVER (
        PARTITION BY
          student_number,
          academic_year,
          semester
      ),
      0
    ) AS DECIMAL(3, 0)
  ) AS grade_avg_semester,
  CAST(
    ROUND(
      SUM(weighted_gpa_points_term) OVER (
        PARTITION BY
          student_number,
          academic_year,
          semester
      ),
      2
    ) AS DECIMAL(5, 2)
  ) AS weighted_gpa_points_semester,
  CAST(
    ROUND(
      SUM(total_credit_hours) OVER (
        PARTITION BY
          student_number,
          academic_year,
          semester
      ),
      2
    ) AS DECIMAL(5, 2)
  ) AS total_credit_hours_semester,
  CAST(
    ROUND(
      SUM(weighted_gpa_points_term) OVER (
        PARTITION BY
          student_number,
          academic_year,
          semester
      ) / SUM(credit_hours_term) OVER (
        PARTITION BY
          student_number,
          academic_year,
          semester
      ),
      2
    ) AS DECIMAL(4, 2)
  ) AS gpa_semester
FROM
  (
    SELECT
      student_number,
      schoolid,
      grade_level,
      academic_year,
      storecode,
      reporting_term,
      is_curterm,
      CASE
        WHEN storecode IN ('Q1', 'Q2') THEN 'S1'
        WHEN storecode IN ('Q3', 'Q4') THEN 'S2'
      END AS semester,
      /* gpa term */
      ROUND(AVG(term_grade_percent), 0) AS grade_avg_term,
      SUM(term_grade_pts) AS gpa_points_total_term,
      SUM(
        potential_credit_hours * term_grade_pts
      ) AS weighted_gpa_points_term,
      SUM(
        CASE
          WHEN term_grade_percent IS NULL THEN NULL
          ELSE potential_credit_hours
        END
      ) AS credit_hours_term,
      CAST(
        ROUND(
          SUM(
            potential_credit_hours * term_grade_pts
          ) / (
            /* when no term_name pct, then exclude credit hours */
            CASE
              WHEN SUM(
                CASE
                  WHEN term_grade_percent IS NULL THEN NULL
                  ELSE potential_credit_hours
                END
              ) = 0 THEN NULL
              ELSE SUM(
                CASE
                  WHEN term_grade_percent IS NULL THEN NULL
                  ELSE potential_credit_hours
                END
              )
            END
          ),
          2
        ) AS DECIMAL(3, 2)
      ) AS gpa_term,
      /* gpa Y1 */
      ROUND(AVG(y1_grade_percent_adj), 0) AS grade_avg_y1,
      SUM(y1_grade_pts) AS gpa_points_total_y1,
      SUM(
        potential_credit_hours * y1_grade_pts
      ) AS weighted_gpa_points_y1,
      CAST(
        ROUND(
          SUM(
            potential_credit_hours * y1_grade_pts
          ) / (
            /* when no y1 pct, then exclude credit hours */
            CASE
              WHEN SUM(
                CASE
                  WHEN y1_grade_percent_adj IS NULL THEN NULL
                  ELSE potential_credit_hours
                END
              ) = 0 THEN NULL
              ELSE SUM(
                CASE
                  WHEN y1_grade_percent_adj IS NULL THEN NULL
                  ELSE potential_credit_hours
                END
              )
            END
          ),
          2
        ) AS DECIMAL(3, 2)
      ) AS gpa_y1,
      CAST(
        ROUND(
          SUM(
            potential_credit_hours * y1_grade_pts_unweighted
          ) / (
            /* when no y1 pct, then exclude credit hours */
            CASE
              WHEN SUM(
                CASE
                  WHEN y1_grade_percent_adj IS NULL THEN NULL
                  ELSE potential_credit_hours
                END
              ) = 0 THEN NULL
              ELSE SUM(
                CASE
                  WHEN y1_grade_percent_adj IS NULL THEN NULL
                  ELSE potential_credit_hours
                END
              )
            END
          ),
          2
        ) AS DECIMAL(3, 2)
      ) AS gpa_y1_unweighted,
      /* other */
      SUM(
        CASE
          WHEN y1_grade_percent_adj IS NULL THEN NULL
          ELSE potential_credit_hours
        END
      ) AS total_credit_hours,
      SUM(
        CASE
          WHEN y1_grade_letter LIKE 'F%' THEN 1
          ELSE 0
        END
      ) AS n_failing_y1
    FROM
      grade_detail
    GROUP BY
      student_number,
      academic_year,
      storecode,
      reporting_term,
      is_curterm,
      schoolid,
      grade_level
  ) AS sub
