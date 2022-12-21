CREATE OR ALTER VIEW
  powerschool.section_scaffold_current AS
SELECT
  studentid,
  course_number,
  yearid,
  abs_sectionid,
  gradescaleid,
  term_name,
  ROW_NUMBER() OVER (
    PARTITION BY
      studentid,
      yearid,
      course_number,
      term_name
    ORDER BY
      is_dropped,
      dateleft DESC,
      sectionid DESC
  ) AS rn_term
FROM
  (
    SELECT
      cc.studentid,
      cc.course_number,
      cc.sectionid,
      cc.dateleft,
      CAST(LEFT(ABS(cc.termid), 2) AS INT) AS yearid,
      ABS(cc.sectionid) AS abs_sectionid,
      CASE
        WHEN cc.sectionid < 0 THEN 1
        ELSE 0
      END AS is_dropped,
      sec.gradescaleid,
      (
        CASE
          WHEN terms.alt_name = 'Summer School' THEN 'Q1'
          ELSE terms.alt_name
        END
        COLLATE LATIN1_GENERAL_BIN
      ) AS term_name
    FROM
      powerschool.cc
      INNER JOIN powerschool.sections AS sec ON (ABS(cc.sectionid) = sec.id)
      INNER JOIN gabby.reporting.reporting_terms AS terms ON (
        cc.schoolid = terms.schoolid
        AND terms.identifier = 'RT'
        AND (
          cc.dateenrolled BETWEEN terms.[start_date] AND terms.end_date
        )
      )
    WHERE
      (
        cc.dateenrolled BETWEEN DATEFROMPARTS(
          gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
          7,
          1
        ) AND CAST(CURRENT_TIMESTAMP AS DATE)
      )
  ) AS sub
