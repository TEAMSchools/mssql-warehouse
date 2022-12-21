CREATE OR ALTER VIEW
  powerschool.category_grades AS
WITH
  enr AS (
    SELECT
      studentid,
      schoolid,
      yearid,
      course_number,
      sectionid,
      is_dropped_section,
      storecode_type,
      storecode,
      reporting_term,
      termbin_start_date,
      termbin_end_date,
      AVG(is_dropped_section) OVER (
        PARTITION BY
          yearid,
          course_number,
          studentid
      ) AS is_dropped_course
    FROM
      (
        SELECT
          cc.studentid,
          cc.schoolid,
          cc.course_number,
          ABS(cc.sectionid) AS sectionid,
          CASE
            WHEN cc.sectionid < 0 THEN 1.0
            ELSE 0.0
          END AS is_dropped_section,
          tb.yearid,
          tb.storecode,
          tb.date_1 AS termbin_start_date,
          tb.date_2 AS termbin_end_date,
          LEFT(tb.storecode, 1) AS storecode_type,
          CAST(
            CONCAT('RT', RIGHT(tb.storecode, 1)) AS NVARCHAR(8)
          ) AS reporting_term
        FROM
          powerschool.cc
          INNER JOIN powerschool.termbins AS tb ON (
            cc.schoolid = tb.schoolid
            AND ABS(cc.termid) = tb.termid
          )
        WHERE
          cc.dateenrolled >= DATEFROMPARTS(
            gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
            7,
            1
          )
      ) AS sub
  )
SELECT
  studentid,
  schoolid,
  yearid,
  course_number,
  sectionid,
  is_dropped_section,
  storecode_type,
  storecode,
  reporting_term,
  termbin_start_date,
  termbin_end_date,
  is_dropped_course,
  category_pct,
  citizenship,
  rn_storecode_course,
  CAST(
    ROUND(
      AVG(category_pct) OVER (
        PARTITION BY
          studentid,
          yearid,
          course_number,
          storecode_type
        ORDER BY
          termbin_start_date
      ),
      0
    ) AS DECIMAL(4, 0)
  ) AS category_pct_y1
FROM
  (
    SELECT
      enr.studentid,
      enr.schoolid,
      enr.yearid,
      enr.course_number,
      enr.sectionid,
      enr.is_dropped_section,
      enr.storecode_type,
      enr.storecode,
      enr.reporting_term,
      enr.termbin_start_date,
      enr.termbin_end_date,
      enr.is_dropped_course,
      CASE
        WHEN pgf.grade = '--' THEN NULL
        ELSE CAST(pgf.[percent] AS DECIMAL(4, 0))
      END AS category_pct,
      CASE
        WHEN pgf.citizenship != '' THEN pgf.citizenship
      END AS citizenship,
      ROW_NUMBER() OVER (
        PARTITION BY
          enr.studentid,
          enr.yearid,
          enr.course_number,
          enr.storecode
        ORDER BY
          enr.is_dropped_section ASC,
          pgf.[percent] DESC
      ) AS rn_storecode_course
    FROM
      enr
      LEFT JOIN powerschool.pgfinalgrades AS pgf ON (
        enr.studentid = pgf.studentid
        AND enr.sectionid = pgf.sectionid
        AND enr.storecode = pgf.finalgradename
      )
    WHERE
      enr.is_dropped_course < 1.0
  ) AS sub
WHERE
  rn_storecode_course = 1
