CREATE OR ALTER VIEW
  tableau.lli_tracker AS
SELECT
  54 AS repository_id,
  r.repository_row_id,
  gabby.utilities.DATE_TO_SY (
    CAST(
      r.field_date_administered AS DATE
    )
  ) AS academic_year,
  CAST(
    r.field_date_administered AS DATE
  ) AS date_administered,
  r.field_level_tested AS level_tested,
  r.field_pass_fall AS test_status,
  r.field_fiction_nonfiction AS genre,
  r.field_administrator_1 AS test_administrator,
  r.field_within_the_text AS within_the_text,
  r.field_beyond_the_text AS beyond_the_text,
  r.field_about_the_text AS about_the_text,
  r.field_accuracy_1 AS accuracy,
  r.field_fluency_1 AS fluency,
  r.field_reading_rate_wpm AS wpm,
  r.field_text_familiarity AS text_familiarity,
  s.local_student_id AS student_number,
  co.lastfirst,
  co.reporting_schoolid,
  co.grade_level,
  co.iep_status,
  co.team,
  co.c_504_status,
  co.region
FROM
  gabby.illuminate_dna_repositories.repository_54 AS r
  INNER JOIN gabby.illuminate_public.students AS s ON (r.student_id = s.student_id)
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
    s.local_student_id = co.student_number
    AND gabby.utilities.DATE_TO_SY (
      CAST(
        r.field_date_administered AS DATE
      )
    ) = co.academic_year
    AND co.rn_year = 1
  )
WHERE
  CONCAT(54, '_', r.repository_row_id) IN (
    SELECT
      row_hash
    FROM
      gabby.illuminate_dna_repositories.repository_row_ids
  )
