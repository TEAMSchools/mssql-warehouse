CREATE OR ALTER VIEW
  tableau.qa_report_card_comment_audit AS
WITH
  repo_fields AS (
    SELECT
      r.repository_id,
      r.title,
      CASE
        WHEN r.repository_id = 216 THEN 'Q1'
        WHEN r.repository_id = 207 THEN 'Q2'
        WHEN r.repository_id = 208 THEN 'Q3'
        WHEN r.repository_id = 209 THEN 'Q4'
      END AS term_name,
      CAST(f.[label] AS VARCHAR(250)) AS field_label,
      CASE
        WHEN f.[name] = 'field_character_comment_1_1' THEN 'field_character_comment_1'
        WHEN f.[name] = 'field_character_comment_2_1' THEN 'field_character_comment_2'
        ELSE f.[name]
      END AS field_name
    FROM
      illuminate_dna_repositories.repositories AS r
      INNER JOIN illuminate_dna_repositories.fields AS f ON (
        r.repository_id = f.repository_id
        AND f.deleted_at IS NULL
        AND f.[name] != 'field_term'
      )
    WHERE
      r.repository_id IN (216, 207, 208, 209)
  )
SELECT
  co.student_number,
  co.lastfirst,
  co.region,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.enroll_status,
  co.school_level,
  rf.term_name,
  rf.repository_id,
  rf.field_name,
  rf.field_label,
  rdu.comment_code,
  rdu.comment_subject AS [subject],
  rdu.subcategory,
  rdu.comment
FROM
  powerschool.cohort_identifiers_static AS co
  CROSS JOIN repo_fields AS rf
  LEFT JOIN reporting.illuminate_report_card_comments AS rdu ON (
    co.student_number = rdu.student_number
    AND co.academic_year = rdu.academic_year
    AND rf.repository_id = rdu.repository_id
    AND rf.field_name = rdu.comment_field
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND co.grade_level <= 4
