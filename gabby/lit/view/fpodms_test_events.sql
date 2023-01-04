CREATE OR ALTER VIEW
  lit.fpodms_test_events AS
WITH
  classes_dedupe AS (
    SELECT
      school_name,
      school_year,
      [name],
      teacher_first_name,
      teacher_last_name,
      ROW_NUMBER() OVER (
        PARTITION BY
          school_name,
          school_year,
          [name]
        ORDER BY
          student_count DESC
      ) AS rn
    FROM
      gabby.fpodms.bas_classes
  ),
  clean_data AS (
    SELECT
      sub.unique_id,
      sub.student_identifier,
      sub.year_of_assessment,
      sub.academic_year,
      sub.assessment_date,
      sub.genre,
      sub.data_type,
      sub.class_name,
      sub.benchmark_level,
      sub.title,
      sub.accuracy_percent,
      sub.comprehension_within,
      sub.comprehension_beyond,
      sub.comprehension_about,
      sub.comprehension_additional,
      sub.comprehension_total,
      sub.comprehension_maximum,
      sub.comprehension_label,
      sub.fluency,
      sub.wpm_rate,
      sub.writing,
      sub.self_corrections,
      sub.text_level,
      sub.[status],
      sub.is_achieved,
      sub.schoolid,
      sub.test_administered_by,
      sub.testid,
      sub.is_fp,
      CASE
        WHEN sub.benchmark_level = 'Instructional' THEN sub.text_level
      END AS dna_lvl,
      CASE
        WHEN sub.benchmark_level = 'Instructional' THEN sub.text_level
      END AS instruct_lvl,
      CASE
        WHEN sub.benchmark_level = 'Independent' THEN sub.text_level
      END AS indep_lvl
    FROM
      (
        SELECT
          CONCAT(
            'FPBAS',
            LEFT(fp.year_of_assessment, 4),
            fp._line
          ) AS unique_id,
          fp.student_identifier,
          fp.year_of_assessment,
          CAST(
            LEFT(fp.year_of_assessment, 4) AS INT
          ) AS academic_year,
          CAST(fp.assessment_date AS DATE) AS assessment_date,
          fp.genre,
          fp.data_type,
          fp.class_name,
          fp.benchmark_level,
          fp.title,
          fp.accuracy_ AS accuracy_percent,
          fp.comprehension_within,
          fp.comprehension_beyond,
          fp.comprehension_about,
          fp.comprehension_additional,
          fp.comprehension_total,
          fp.comprehension_maximum,
          fp.comprehension_label,
          fp.fluency,
          fp.wpm_rate,
          fp.writing,
          /* how should this be parsed? */
          fp.self_corrections,
          CAST(fp.text_level AS VARCHAR(5)) AS text_level,
          CASE
            WHEN fp.benchmark_level = 'Independent' THEN 'Achieved'
            WHEN fp.benchmark_level = 'Instructional' THEN 'Did Not Achieve'
            WHEN fp.benchmark_level = 'Hard' THEN 'DNA - Hard'
          END AS [status],
          CASE
            WHEN fp.benchmark_level = 'Independent' THEN 1
            ELSE 0
          END AS is_achieved,
          sch.school_number AS schoolid,
          c.teacher_first_name + ', ' + c.teacher_last_name AS test_administered_by,
          3273 AS testid,
          1 AS is_fp
        FROM
          gabby.fpodms.bas_assessments AS fp
          LEFT JOIN gabby.people.school_crosswalk AS sc ON fp.school_name = sc.site_name
          LEFT JOIN gabby.powerschool.schools AS sch ON (
            sc.ps_school_id = sch.school_number
          )
          LEFT JOIN classes_dedupe AS c ON (
            fp.school_name = c.school_name
            AND fp.year_of_assessment = c.school_year
            AND fp.class_name = c.[name]
            AND c.rn = 1
          )
      ) AS sub
  ),
  predna AS (
    SELECT
      unique_id,
      student_identifier,
      year_of_assessment,
      academic_year,
      assessment_date,
      genre,
      data_type,
      class_name,
      benchmark_level,
      title,
      accuracy_percent,
      comprehension_within,
      comprehension_beyond,
      comprehension_about,
      comprehension_additional,
      comprehension_total,
      comprehension_maximum,
      comprehension_label,
      fluency,
      wpm_rate,
      writing,
      self_corrections,
      text_level,
      [status],
      is_achieved,
      schoolid,
      test_administered_by,
      testid,
      is_fp,
      dna_lvl,
      instruct_lvl,
      indep_lvl
    FROM
      clean_data
    UNION ALL
    SELECT
      unique_id + 'DNA' AS unique_id,
      student_identifier,
      year_of_assessment,
      academic_year,
      assessment_date,
      genre,
      data_type,
      class_name,
      'Independent' AS benchmark_level,
      title,
      accuracy_percent,
      comprehension_within,
      comprehension_beyond,
      comprehension_about,
      comprehension_additional,
      comprehension_total,
      comprehension_maximum,
      comprehension_label,
      fluency,
      wpm_rate,
      writing,
      self_corrections,
      'Pre-A' AS text_level,
      'Achieved' AS [status],
      is_achieved,
      schoolid,
      test_administered_by,
      testid,
      is_fp,
      dna_lvl,
      instruct_lvl,
      'Pre-A' AS indep_lvl
    FROM
      clean_data
    WHERE
      text_level = 'A'
      AND [status] IN ('Did Not Achieve', 'DNA - Hard')
  )
SELECT
  cd.unique_id,
  cd.student_identifier,
  cd.year_of_assessment,
  cd.academic_year,
  cd.assessment_date,
  cd.genre,
  cd.data_type,
  cd.class_name,
  cd.benchmark_level,
  cd.title,
  cd.accuracy_percent,
  cd.comprehension_within,
  cd.comprehension_beyond,
  cd.comprehension_about,
  cd.comprehension_additional,
  cd.comprehension_total,
  cd.comprehension_maximum,
  cd.comprehension_label,
  cd.fluency,
  cd.wpm_rate,
  cd.writing,
  cd.self_corrections,
  cd.text_level,
  cd.[status],
  cd.is_achieved,
  cd.schoolid,
  cd.test_administered_by,
  cd.testid,
  cd.is_fp,
  cd.dna_lvl,
  cd.instruct_lvl,
  cd.indep_lvl,
  rt.alt_name AS test_round,
  rt.time_per_name AS reporting_term,
  CAST(
    RIGHT(rt.time_per_name, 1) AS INT
  ) AS round_num,
  gleq.fp_lvl_num AS lvl_num,
  gleq.gleq AS gleq,
  gleq.lvl_num AS gleq_lvl_num,
  CASE
    WHEN cd.benchmark_level = 'Instructional' THEN gleq.fp_lvl_num
  END AS dna_lvl_num,
  CASE
    WHEN cd.benchmark_level = 'Instructional' THEN gleq.fp_lvl_num
  END AS instruct_lvl_num,
  CASE
    WHEN cd.benchmark_level = 'Independent' THEN gleq.fp_lvl_num
  END AS indep_lvl_num
FROM
  predna AS cd
  LEFT JOIN gabby.reporting.reporting_terms AS rt ON (
    cd.schoolid = rt.schoolid
    AND (
      cd.assessment_date BETWEEN rt.[start_date] AND rt.end_date
    )
    AND rt.identifier = 'LIT'
    AND rt._fivetran_deleted = 0
  )
  LEFT JOIN gabby.lit.gleq ON (cd.text_level = gleq.read_lvl)
