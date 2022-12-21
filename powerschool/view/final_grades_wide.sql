CREATE OR ALTER VIEW
  powerschool.final_grades_wide AS
WITH
  grades_unpivot AS (
    SELECT
      studentid,
      yearid,
      storecode,
      CAST(reporting_term AS NVARCHAR(4)) AS reporting_term,
      course_number,
      sectionid,
      y1_grade_letter,
      y1_grade_percent_adj,
      need_90,
      need_80,
      need_70,
      need_60,
      CONCAT(
        LOWER(reporting_term),
        '_',
        field
      ) AS pivot_field,
      CASE
        WHEN [value] = '' THEN NULL
        ELSE [value]
      END AS [value]
    FROM
      (
        SELECT
          studentid,
          yearid,
          course_number,
          sectionid,
          storecode,
          y1_grade_percent_adj,
          y1_grade_letter,
          need_90,
          need_80,
          need_70,
          need_60,
          REPLACE(storecode, 'Q', 'RT') AS reporting_term,
          /* empty strings preserve storecode structure when there aren't any grades */
          ISNULL(
            CAST(
              term_grade_letter AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_letter,
          ISNULL(
            CAST(
              term_grade_percent AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_percent,
          ISNULL(
            CAST(
              term_grade_letter_adj AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_letter_adj,
          ISNULL(
            CAST(
              term_grade_percent_adj AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_percent_adj
        FROM
          powerschool.final_grades_static
        UNION ALL
        SELECT
          fg.studentid,
          fg.yearid,
          fg.course_number,
          fg.sectionid,
          fg.storecode,
          fg.y1_grade_percent_adj,
          fg.y1_grade_letter,
          fg.need_90,
          fg.need_80,
          fg.need_70,
          fg.need_60,
          'CUR' AS reporting_term,
          /* empty strings preserve storecode structure when there aren't any grades */
          ISNULL(
            CAST(
              fg.term_grade_letter AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_letter,
          ISNULL(
            CAST(
              fg.term_grade_percent AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_percent,
          ISNULL(
            CAST(
              fg.term_grade_letter_adj AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_letter_adj,
          ISNULL(
            CAST(
              fg.term_grade_percent_adj AS NVARCHAR(16)
            ),
            ''
          ) AS term_grade_percent_adj
        FROM
          powerschool.final_grades_static AS fg
          INNER JOIN gabby.reporting.reporting_terms AS rt ON (
            (
              fg.storecode = rt.alt_name
              COLLATE LATIN1_GENERAL_BIN
            )
            AND fg.yearid = rt.yearid
            AND rt.identifier = 'RT'
            AND rt.is_curterm = 1
            AND rt.schoolid = 0
          )
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          term_grade_letter,
          term_grade_percent,
          term_grade_letter_adj,
          term_grade_percent_adj
        )
      ) AS u
  )
SELECT
  studentid,
  yearid,
  course_number,
  sectionid,
  storecode,
  reporting_term,
  y1_grade_letter,
  y1_grade_percent_adj,
  need_90,
  need_80,
  need_70,
  need_60,
  MAX(rt1_term_grade_letter) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt1_term_grade_letter,
  MAX(rt1_term_grade_letter_adj) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt1_term_grade_letter_adjusted,
  MAX(
    CAST(
      rt1_term_grade_percent AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt1_term_grade_percent,
  MAX(
    CAST(
      rt1_term_grade_percent_adj AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt1_term_grade_percent_adjusted,
  MAX(rt2_term_grade_letter) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt2_term_grade_letter,
  MAX(rt2_term_grade_letter_adj) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt2_term_grade_letter_adjusted,
  MAX(
    CAST(
      rt2_term_grade_percent AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt2_term_grade_percent,
  MAX(
    CAST(
      rt2_term_grade_percent_adj AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt2_term_grade_percent_adjusted,
  MAX(rt3_term_grade_letter) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt3_term_grade_letter,
  MAX(rt3_term_grade_letter_adj) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt3_term_grade_letter_adjusted,
  MAX(
    CAST(
      rt3_term_grade_percent AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt3_term_grade_percent,
  MAX(
    CAST(
      rt3_term_grade_percent_adj AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt3_term_grade_percent_adjusted,
  MAX(rt4_term_grade_letter) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt4_term_grade_letter,
  MAX(rt4_term_grade_letter_adj) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt4_term_grade_letter_adjusted,
  MAX(
    CAST(
      rt4_term_grade_percent AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt4_term_grade_percent,
  MAX(
    CAST(
      rt4_term_grade_percent_adj AS DECIMAL(4, 0)
    )
  ) OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number
    ORDER BY
      storecode ASC
  ) AS rt4_term_grade_percent_adjusted,
  [cur_term_grade_letter],
  [cur_term_grade_letter_adj] AS [cur_term_grade_letter_adjusted],
  CAST(
    [cur_term_grade_percent] AS DECIMAL(4, 0)
  ) AS [cur_term_grade_percent],
  CAST(
    cur_term_grade_percent_adj AS DECIMAL(4, 0)
  ) AS [cur_term_grade_percent_adjusted],
  NULL AS rn_credittype
FROM
  grades_unpivot PIVOT (
    MAX([value]) FOR pivot_field IN (
      [rt1_term_grade_letter],
      [rt1_term_grade_letter_adj],
      [rt1_term_grade_percent],
      [rt1_term_grade_percent_adj],
      [rt2_term_grade_letter],
      [rt2_term_grade_letter_adj],
      [rt2_term_grade_percent],
      [rt2_term_grade_percent_adj],
      [rt3_term_grade_letter],
      [rt3_term_grade_letter_adj],
      [rt3_term_grade_percent],
      [rt3_term_grade_percent_adj],
      [rt4_term_grade_letter],
      [rt4_term_grade_letter_adj],
      [rt4_term_grade_percent],
      [rt4_term_grade_percent_adj],
      [cur_term_grade_letter],
      [cur_term_grade_letter_adj],
      [cur_term_grade_percent],
      [cur_term_grade_percent_adj]
    )
  ) AS p
