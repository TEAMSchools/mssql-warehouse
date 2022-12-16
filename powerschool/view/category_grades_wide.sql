CREATE OR ALTER VIEW
  powerschool.category_grades_wide AS
WITH
  grades_long AS (
    SELECT
      cat.studentid,
      cat.schoolid,
      cat.yearid,
      cat.course_number,
      cat.reporting_term,
      cat.reporting_term AS rt,
      cat.storecode_type,
      cat.category_pct,
      cat.citizenship,
      CASE
        WHEN CAST(CURRENT_TIMESTAMP AS DATE) (
          BETWEEN cat.termbin_start_date AND cat.termbin_end_date
        ) THEN 1
        ELSE 0
      END AS is_curterm,
      si.credittype
    FROM
      powerschool.category_grades_static AS cat
      INNER JOIN powerschool.sections_identifiers AS si ON cat.sectionid = si.sectionid
    WHERE
      cat.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
    UNION ALL
    SELECT
      cat.studentid,
      cat.schoolid,
      cat.yearid,
      'ALL' AS course_number,
      cat.reporting_term,
      cat.reporting_term AS rt,
      cat.storecode_type,
      CAST(
        ROUND(AVG(cat.category_pct), 0) AS DECIMAL(4, 0)
      ) AS category_pct,
      NULL AS citizenship,
      CASE
        WHEN CAST(CURRENT_TIMESTAMP AS DATE) (
          BETWEEN cat.termbin_start_date AND cat.termbin_end_date
        ) THEN 1
        ELSE 0
      END AS is_curterm,
      'ALL' AS credittype
    FROM
      powerschool.category_grades_static AS cat
    WHERE
      cat.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
    GROUP BY
      cat.studentid,
      cat.schoolid,
      cat.yearid,
      cat.reporting_term,
      cat.storecode_type,
      cat.termbin_start_date,
      cat.termbin_end_date
    UNION ALL
    SELECT
      cat.studentid,
      cat.schoolid,
      cat.yearid,
      cat.course_number,
      cat.reporting_term,
      'CUR' AS rt,
      cat.storecode_type,
      cat.category_pct,
      cat.citizenship,
      1 AS is_curterm,
      si.credittype
    FROM
      powerschool.category_grades_static AS cat
      INNER JOIN powerschool.sections_identifiers AS si ON cat.sectionid = si.sectionid
    WHERE
      cat.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
      AND CAST(CURRENT_TIMESTAMP AS DATE) (
        BETWEEN cat.termbin_start_date AND cat.termbin_end_date
      )
    UNION ALL
    SELECT
      cat.studentid,
      cat.schoolid,
      cat.yearid,
      'ALL' AS course_number,
      cat.reporting_term,
      'CUR' AS rt,
      cat.storecode_type,
      CAST(
        ROUND(AVG(cat.category_pct), 0) AS DECIMAL(4, 0)
      ) AS category_pct,
      NULL AS citizenship,
      1 AS is_curterm,
      'ALL' AS credittype
    FROM
      powerschool.category_grades_static AS cat
    WHERE
      cat.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
      AND CAST(CURRENT_TIMESTAMP AS DATE) (
        BETWEEN cat.termbin_start_date AND cat.termbin_end_date
      )
    GROUP BY
      cat.studentid,
      cat.schoolid,
      cat.yearid,
      cat.reporting_term,
      cat.storecode_type
  ),
  grades_unpivot AS (
    SELECT
      studentid,
      schoolid,
      yearid,
      credittype,
      course_number,
      reporting_term,
      rt,
      is_curterm,
      storecode_type,
      field,
      [value]
    FROM
      (
        SELECT
          studentid,
          schoolid,
          yearid,
          credittype,
          course_number,
          reporting_term,
          rt,
          is_curterm,
          storecode_type,
          CAST(category_pct AS NVARCHAR(4)) AS category_pct,
          CAST(citizenship AS NVARCHAR(4)) AS citizenship
        FROM
          grades_long
      ) AS sub UNPIVOT (
        [value] FOR field IN (category_pct, citizenship)
      ) AS u
  ),
  grades_repivot AS (
    SELECT
      studentid,
      yearid,
      credittype,
      course_number,
      reporting_term,
      is_curterm,
      schoolid,
      CAST(F_CUR AS DECIMAL(4, 0)) AS F_CUR,
      CAST(F_RT1 AS DECIMAL(4, 0)) AS F_RT1,
      CAST(F_RT2 AS DECIMAL(4, 0)) AS F_RT2,
      CAST(F_RT3 AS DECIMAL(4, 0)) AS F_RT3,
      CAST(F_RT4 AS DECIMAL(4, 0)) AS F_RT4,
      CAST(S_CUR AS DECIMAL(4, 0)) AS S_CUR,
      CAST(S_RT1 AS DECIMAL(4, 0)) AS S_RT1,
      CAST(S_RT2 AS DECIMAL(4, 0)) AS S_RT2,
      CAST(S_RT3 AS DECIMAL(4, 0)) AS S_RT3,
      CAST(S_RT4 AS DECIMAL(4, 0)) AS S_RT4,
      CAST(W_CUR AS DECIMAL(4, 0)) AS W_CUR,
      CAST(W_RT1 AS DECIMAL(4, 0)) AS W_RT1,
      CAST(W_RT2 AS DECIMAL(4, 0)) AS W_RT2,
      CAST(W_RT3 AS DECIMAL(4, 0)) AS W_RT3,
      CAST(W_RT4 AS DECIMAL(4, 0)) AS W_RT4,
      CAST(E_CUR AS DECIMAL(4, 0)) AS E_CUR,
      CAST(E_RT1 AS DECIMAL(4, 0)) AS E_RT1,
      CAST(E_RT2 AS DECIMAL(4, 0)) AS E_RT2,
      CAST(E_RT3 AS DECIMAL(4, 0)) AS E_RT3,
      CAST(E_RT4 AS DECIMAL(4, 0)) AS E_RT4,
      CTZ_CUR,
      CTZ_RT1,
      CTZ_RT2,
      CTZ_RT3,
      CTZ_RT4
    FROM
      (
        SELECT
          gr.studentid,
          gr.yearid,
          gr.credittype,
          gr.course_number,
          gr.reporting_term,
          gr.is_curterm,
          gr.[value],
          CONCAT(gr.storecode_type, '_', gr.rt) AS pivot_field,
          MAX(gr.schoolid) OVER (
            PARTITION BY
              gr.studentid,
              gr.yearid,
              gr.course_number,
              gr.reporting_term
            ORDER BY
              gr.reporting_term ASC
          ) AS schoolid
        FROM
          grades_unpivot AS gr
        WHERE
          gr.field = 'category_pct'
        UNION ALL
        SELECT
          gr.studentid,
          gr.yearid,
          gr.credittype,
          gr.course_number,
          gr.reporting_term,
          gr.is_curterm,
          gr.[value],
          CONCAT('CTZ_', gr.rt) AS pivot_field,
          MAX(gr.schoolid) OVER (
            PARTITION BY
              gr.studentid,
              gr.yearid,
              gr.course_number,
              gr.reporting_term
            ORDER BY
              gr.reporting_term ASC
          ) AS schoolid
        FROM
          grades_unpivot AS gr
        WHERE
          gr.field = 'citizenship'
          AND gr.storecode_type = 'Q'
      ) AS sub PIVOT (
        MAX([value]) FOR pivot_field IN (
          [F_CUR],
          [F_RT1],
          [F_RT2],
          [F_RT3],
          [F_RT4],
          [S_CUR],
          [S_RT1],
          [S_RT2],
          [S_RT3],
          [S_RT4],
          [W_CUR],
          [W_RT1],
          [W_RT2],
          [W_RT3],
          [W_RT4],
          [E_CUR],
          [E_RT1],
          [E_RT2],
          [E_RT3],
          [E_RT4],
          [CTZ_CUR],
          [CTZ_RT1],
          [CTZ_RT2],
          [CTZ_RT3],
          [CTZ_RT4]
        )
      ) AS p
  )
SELECT
  studentid,
  schoolid,
  yearid,
  credittype,
  course_number,
  reporting_term,
  is_curterm,
  [F_CUR] /* mastery */,
  [S_CUR] /* participation */,
  [W_CUR] /* work habits */,
  [E_CUR] /* homework quality for MS, exams for HS */,
  CAST(
    ROUND(
      AVG([F_CUR]) OVER (
        PARTITION BY
          studentid,
          yearid,
          course_number
        ORDER BY
          reporting_term ASC
      ),
      0
    ) AS DECIMAL(4, 0)
  ) AS F_Y1,
  CAST(
    ROUND(
      AVG([S_CUR]) OVER (
        PARTITION BY
          studentid,
          yearid,
          course_number
        ORDER BY
          reporting_term ASC
      ),
      0
    ) AS DECIMAL(4, 0)
  ) AS S_Y1,
  CAST(
    ROUND(
      AVG([W_CUR]) OVER (
        PARTITION BY
          studentid,
          yearid,
          course_number
        ORDER BY
          reporting_term ASC
      ),
      0
    ) AS DECIMAL(4, 0)
  ) AS W_Y1,
  CAST(
    ROUND(
      AVG([E_CUR]) OVER (
        PARTITION BY
          studentid,
          yearid,
          course_number
        ORDER BY
          reporting_term ASC
      ),
      0
    ) AS DECIMAL(4, 0)
  ) AS E_Y1,
  CAST(
    MAX([F_RT1]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [F_RT1],
  CAST(
    MAX([F_RT2]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [F_RT2],
  CAST(
    MAX([F_RT3]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [F_RT3],
  CAST(
    MAX([F_RT4]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [F_RT4],
  CAST(
    MAX([S_RT1]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [S_RT1],
  CAST(
    MAX([S_RT2]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [S_RT2],
  CAST(
    MAX([S_RT3]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [S_RT3],
  CAST(
    MAX([S_RT4]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [S_RT4],
  CAST(
    MAX([W_RT1]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [W_RT1],
  CAST(
    MAX([W_RT2]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [W_RT2],
  CAST(
    MAX([W_RT3]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [W_RT3],
  CAST(
    MAX([W_RT4]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [W_RT4],
  CAST(
    MAX([E_RT1]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [E_RT1],
  CAST(
    MAX([E_RT2]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [E_RT2],
  CAST(
    MAX([E_RT3]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [E_RT3],
  CAST(
    MAX([E_RT4]) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        reporting_term ASC
    ) AS DECIMAL(4, 0)
  ) AS [E_RT4],
  CTZ_CUR,
  CTZ_RT1,
  CTZ_RT2,
  CTZ_RT3,
  CTZ_RT4,
  ROW_NUMBER() OVER (
    PARTITION BY
      studentid,
      yearid,
      reporting_term,
      credittype
    ORDER BY
      course_number
  ) AS rn_credittype
FROM
  grades_repivot
