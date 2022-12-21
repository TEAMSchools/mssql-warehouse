CREATE OR ALTER VIEW
  tableau.oer_dbq_dashboard AS
WITH
  enrollments AS (
    SELECT
      enr.student_number,
      enr.academic_year,
      REPLACE(
        enr.COURSE_NUMBER,
        'ENG11',
        'ENG10'
      ) AS course_number,
      enr.course_name,
      enr.expression AS course_period,
      enr.teacher_name,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number,
          academic_year,
          course_number
        ORDER BY
          section_enroll_status DESC,
          dateenrolled DESC
      ) AS rn
    FROM
      gabby.powerschool.course_enrollments_static AS enr
    WHERE
      enr.academic_year >= 2015
      AND enr.credittype = 'ENG'
      AND enr.schoolid = 73253
    UNION ALL
    SELECT
      enr.student_number,
      enr.academic_year,
      'ENG' AS course_number,
      enr.course_name,
      enr.expression AS course_period,
      enr.teacher_name,
      1 AS rn
    FROM
      gabby.powerschool.course_enrollments_static AS enr
    WHERE
      enr.academic_year <= 2014
      AND enr.credittype = 'ENG'
      AND enr.section_enroll_status = 0
      AND enr.schoolid = 73253
      AND enr.rn_subject = 1
  ),
  oer_repos AS (
    SELECT
      repository_id,
      date_administered,
      title,
      student_number,
      academic_year,
      term,
      unit_number,
      series,
      course_number,
      repository_row_id,
      field_label,
      field_value,
      SUBSTRING(
        field_label,
        CHARINDEX('_', field_label) + 1,
        1
      ) AS prompt_number,
      SUBSTRING(
        field_label,
        CHARINDEX('_', field_label) + 3,
        LEN(field_label)
      ) AS strand
    FROM
      (
        SELECT
          r.repository_id,
          r.date_administered,
          r.title,
          s.local_student_id AS student_number,
          LEFT(ur.[year], 4) AS academic_year,
          CASE
            WHEN gabby.utilities.DATE_TO_SY (r.date_administered) <= 2014 THEN REPLACE(ur.[quarter], 'QE', 'Q')
            ELSE rt.alt_name
          END AS term,
          CASE
            WHEN gabby.utilities.DATE_TO_SY (r.date_administered) <= 2014 THEN ur.[quarter]
            ELSE CONCAT('Unit ', RIGHT(r.title, 1))
          END AS unit_number,
          CASE
            WHEN gabby.utilities.DATE_TO_SY (r.date_administered) <= 2014 THEN RIGHT(ur.[quarter], 1)
            ELSE RIGHT(r.title, 1)
          END AS series,
          CASE
            WHEN RIGHT(ur.[course], 1) = 'H' THEN CONCAT('ENG', LEFT(ur.[course], 1), 5)
            ELSE CONCAT('ENG', LEFT(ur.[course], 2))
          END AS course_number,
          ur.repository_row_id,
          ur.prompt_1_analysis_of_evidence,
          ur.prompt_1_choice_of_evidence,
          ur.prompt_1_context_of_evidence,
          ur.prompt_1_justification,
          ur.prompt_1_overall,
          ur.prompt_1_quality_of_ideas,
          ur.prompt_2_analysis_of_evidence,
          ur.prompt_2_choice_of_evidence,
          ur.prompt_2_context_of_evidence,
          ur.prompt_2_justification,
          ur.prompt_2_overall,
          ur.prompt_2_quality_of_ideas,
          ur.prompt_3_analysis_of_evidence,
          ur.prompt_3_choice_of_evidence,
          ur.prompt_3_context_of_evidence,
          ur.prompt_3_justification,
          ur.prompt_3_overall,
          ur.prompt_3_quality_of_ideas,
          ur.prompt_4_analysis_of_evidence,
          ur.prompt_4_choice_of_evidence,
          ur.prompt_4_context_of_evidence,
          ur.prompt_4_justification,
          ur.prompt_4_overall,
          ur.prompt_4_quality_of_ideas
        FROM
          gabby.illuminate_dna_repositories.oer_repositories AS ur
          INNER JOIN gabby.illuminate_public.students AS s ON ur.student_id = s.student_id
          INNER JOIN gabby.illuminate_dna_repositories.repositories AS r ON ur.repository_id = r.repository_id
          LEFT JOIN gabby.reporting.reporting_terms AS rt ON (
            r.date_administered BETWEEN rt.start_date AND rt.end_date
          )
          AND rt.schoolid = 73253
          AND rt.identifier = 'RT'
          AND rt._fivetran_deleted = 0
      ) AS sub UNPIVOT (
        field_value FOR field_label IN (
          prompt_1_analysis_of_evidence,
          prompt_1_choice_of_evidence,
          prompt_1_context_of_evidence,
          prompt_1_justification,
          prompt_1_overall,
          prompt_1_quality_of_ideas,
          prompt_2_analysis_of_evidence,
          prompt_2_choice_of_evidence,
          prompt_2_context_of_evidence,
          prompt_2_justification,
          prompt_2_overall,
          prompt_2_quality_of_ideas,
          prompt_3_analysis_of_evidence,
          prompt_3_choice_of_evidence,
          prompt_3_context_of_evidence,
          prompt_3_justification,
          prompt_3_overall,
          prompt_3_quality_of_ideas,
          prompt_4_analysis_of_evidence,
          prompt_4_choice_of_evidence,
          prompt_4_context_of_evidence,
          prompt_4_justification,
          prompt_4_overall,
          prompt_4_quality_of_ideas
        )
      ) AS u
  )
SELECT
  co.schoolid,
  co.grade_level,
  co.student_number,
  co.lastfirst,
  co.team,
  co.iep_status,
  'OER' AS test_type,
  w.title,
  w.academic_year,
  w.term,
  w.unit_number,
  w.course_number,
  w.strand,
  w.prompt_number,
  w.field_value AS score,
  enr.course_name,
  enr.course_period,
  enr.teacher_name
FROM
  oer_repos AS w
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON w.student_number = co.student_number
  AND w.academic_year = co.academic_year
  AND co.rn_year = 1
  LEFT JOIN enrollments AS enr
WITH
  (NOLOCK) ON co.student_number = enr.student_number
  AND co.academic_year = enr.academic_year
  AND w.course_number = enr.course_number
COLLATE SQL_Latin1_General_CP1_CI_AS
AND enr.rn = 1
UNION ALL
/* DBQs */
SELECT
  sub.schoolid,
  sub.grade_level,
  sub.student_number,
  sub.lastfirst,
  sub.team,
  sub.iep_status,
  'DBQ' AS test_type,
  sub.title,
  sub.academic_year,
  sub.term,
  CONCAT('DBQ', RIGHT(sub.unit_number, 1)) AS unit_number,
  sub.course_number,
  sub.strand,
  sub.prompt_number,
  sub.score,
  enr.course_name,
  enr.expression AS course_period,
  enr.teacher_name
FROM
  (
    SELECT
      co.student_number,
      co.lastfirst,
      co.academic_year,
      co.schoolid,
      co.grade_level,
      co.team,
      co.iep_status,
      co.db_name,
      dts.alt_name AS term,
      a.title,
      SUBSTRING(
        LTRIM(a.title),
        1,
        CHARINDEX(' ', LTRIM(a.title))
      ) AS course_number,
      CASE
        WHEN a.academic_year_clean <= 2015 THEN SUBSTRING(
          a.title,
          PATINDEX('%QE_%', a.title),
          3
        )
        WHEN PATINDEX('%DBQ [0-9]%', a.title) > 0 THEN SUBSTRING(
          a.title,
          PATINDEX('%DBQ [0-9]%', a.title),
          5
        )
        WHEN PATINDEX('%DBQ[0-9]%', a.title) > 0 THEN SUBSTRING(
          a.title,
          PATINDEX('%DBQ[0-9]%', a.title),
          4
        )
      END AS unit_number,
      std.description AS strand,
      CAST(r.percent_correct AS FLOAT) AS score,
      1 AS prompt_number
    FROM
      gabby.illuminate_dna_assessments.assessments AS a
      INNER JOIN gabby.illuminate_codes.dna_scopes AS dsc ON a.code_scope_id = dsc.code_id
      AND dsc.code_translation = 'DBQ'
      INNER JOIN gabby.illuminate_codes.dna_subject_areas AS dsu ON a.code_subject_area_id = dsu.code_id
      AND dsu.code_translation = 'History'
      INNER JOIN gabby.reporting.reporting_terms AS dts ON (
        a.administered_at BETWEEN dts.start_date AND dts.end_date
      )
      AND dts.schoolid = 73253
      AND dts.identifier = 'RT'
      AND dts._fivetran_deleted = 0
      INNER JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard AS r ON a.assessment_id = r.assessment_id
      INNER JOIN gabby.illuminate_public.students AS s ON r.student_id = s.student_id
      INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON s.local_student_id = co.student_number
      AND a.academic_year_clean = co.academic_year
      AND co.rn_year = 1
      INNER JOIN gabby.illuminate_standards.standards AS std ON r.standard_id = std.standard_id
    WHERE
      a.academic_year_clean >= 2016
  ) AS sub
  LEFT JOIN gabby.powerschool.course_enrollments_static AS enr ON sub.student_number = enr.student_number
  AND sub.academic_year = enr.academic_year
  AND sub.course_number = enr.course_number
COLLATE SQL_Latin1_General_CP1_CI_AS
AND sub.db_name = enr.db_name
AND enr.section_enroll_status = 0
