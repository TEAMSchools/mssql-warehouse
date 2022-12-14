USE gabby
GO

CREATE OR ALTER VIEW act.test_prep_scores AS

WITH long_data AS (
  SELECT ais.assessment_id,
        gabby.illuminate_dna_assessments.assessments_identifiers_static.academic_year_clean AS academic_year,
        gabby.illuminate_dna_assessments.assessments_identifiers_static.administered_at,
        gabby.illuminate_dna_assessments.agg_student_responses.student_id AS illuminate_student_id,
        gabby.illuminate_dna_assessments.agg_student_responses.performance_band_level AS overall_performance_band,

        gabby.illuminate_dna_assessments.agg_student_responses.percent_correct AS overall_percent_correct,
        gabby.illuminate_dna_assessments.agg_student_responses.number_of_questions,
        gabby.powerschool.cohort_identifiers_static.grade_level,
        gabby.powerschool.cohort_identifiers_static.schoolid,
        CAST(
            gabby.illuminate_dna_assessments.assessments_identifiers_static.title AS NVARCHAR(
                128
            )
        ) AS assessment_title,

        CAST(
            gabby.illuminate_dna_assessments.assessments_identifiers_static.subject_area AS NVARCHAR(
                128
            )
        ) AS subject_area,

        ROUND(
            (
                (
                    gabby.illuminate_dna_assessments.agg_student_responses.percent_correct / 100
                ) * gabby.illuminate_dna_assessments.agg_student_responses.number_of_questions
            ),
            0
        ) AS overall_number_correct,
        CAST(
            gabby.illuminate_public.students.local_student_id AS INT
        ) AS student_number,

        CAST(gabby.reporting.reporting_terms.time_per_name AS VARCHAR) AS time_per_name,
        CAST(
            gabby.reporting.reporting_terms.alt_name AS VARCHAR
        ) AS administration_round
  FROM gabby.illuminate_dna_assessments.assessments_identifiers_static ais
  INNER JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
    ON
        gabby.illuminate_dna_assessments.assessments_identifiers_static.assessment_id = gabby.illuminate_dna_assessments.agg_student_responses.assessment_id
  INNER JOIN gabby.illuminate_public.students s
    ON
        gabby.illuminate_dna_assessments.agg_student_responses.student_id = gabby.illuminate_public.students.student_id
  INNER JOIN gabby.reporting.reporting_terms rt
    ON
        gabby.illuminate_dna_assessments.assessments_identifiers_static.administered_at BETWEEN gabby.reporting.reporting_terms.start_date AND gabby.reporting.reporting_terms.end_date
   AND gabby.reporting.reporting_terms.identifier = 'ACT'
   AND gabby.reporting.reporting_terms._fivetran_deleted = 0
  INNER JOIN gabby.powerschool.cohort_identifiers_static co
    ON
        gabby.illuminate_public.students.local_student_id = gabby.powerschool.cohort_identifiers_static.student_number
   AND gabby.illuminate_dna_assessments.assessments_identifiers_static.academic_year_clean = gabby.powerschool.cohort_identifiers_static.academic_year
   AND gabby.powerschool.cohort_identifiers_static.rn_year = 1
  WHERE
      gabby.illuminate_dna_assessments.assessments_identifiers_static.scope = 'ACT Prep'
),

scaled AS (
  SELECT long_data.student_number,
        long_data.illuminate_student_id,
        long_data.academic_year,
        long_data.assessment_id,
        long_data.assessment_title,
        long_data.administration_round,
        long_data.time_per_name,
        long_data.administered_at,
        long_data.subject_area,
        long_data.number_of_questions,
        long_data.overall_number_correct,
        long_data.overall_percent_correct,
        long_data.overall_performance_band,
        long_data.grade_level,
        long_data.schoolid,

        CAST(gabby.act.scale_score_key.scale_score AS INT) AS scale_score,

        ROW_NUMBER() OVER(
           PARTITION BY long_data.student_number,
           long_data.academic_year,
           long_data.subject_area,
           long_data.time_per_name
             ORDER BY long_data.overall_number_correct DESC) AS rn_highscore
  FROM long_data
  LEFT JOIN gabby.act.scale_score_key
    ON long_data.academic_year = gabby.act.scale_score_key.academic_year
   AND long_data.grade_level = gabby.act.scale_score_key.grade_level
   AND long_data.time_per_name = gabby.act.scale_score_key.administration_round
   AND long_data.subject_area = gabby.act.scale_score_key.subject
   AND long_data.overall_number_correct = gabby.act.scale_score_key.raw_score
   AND gabby.act.scale_score_key._fivetran_deleted = 0
),

overall_scores AS (
  SELECT student_number,
        illuminate_student_id,
        academic_year,
        schoolid,
        grade_level,
        time_per_name,
        subject_area,
        assessment_id,
        assessment_title,
        administration_round,
        administered_at,
        number_of_questions,
        overall_number_correct,
        overall_percent_correct,
        overall_performance_band,
        scale_score
  FROM scaled
  WHERE rn_highscore = 1

  UNION ALL

  SELECT student_number,
        illuminate_student_id,
        academic_year,
        schoolid,
        grade_level,
        time_per_name,
        'Composite' AS subject_area,
        NULL AS assessment_id,
        NULL AS assessment_title,
        administration_round,
        MIN(administered_at) AS administered_at,
        SUM(number_of_questions) AS number_of_questions,
        SUM(overall_number_correct) AS overall_number_correct,
        ROUND(
            (SUM(overall_number_correct) / SUM(number_of_questions)) * 100, 0
        ) AS overall_percent_correct,
        NULL AS overall_performance_band,
        CASE
            WHEN COUNT(scale_score) = 4 THEN ROUND(AVG(scale_score), 0)
        END AS scale_score
  FROM scaled
  GROUP BY student_number,
          illuminate_student_id,
          academic_year,
          schoolid,
          grade_level,
          administration_round,
          time_per_name
)

SELECT sub.student_number,
      sub.academic_year,
      sub.schoolid,
      sub.grade_level,
      sub.assessment_id,
      sub.assessment_title,
      sub.time_per_name,
      sub.administration_round,
      sub.administered_at,
      sub.subject_area,
      sub.number_of_questions,
      sub.overall_number_correct,
      sub.overall_percent_correct,
      sub.overall_performance_band,
      sub.scale_score,
      sub.prev_scale_score,
      sub.pretest_scale_score,
      sub.growth_from_pretest,

      std.percent_correct AS standard_percent_correct,
      std.mastered AS standard_mastered,

      CAST(s.custom_code AS NVARCHAR(128)) AS standard_code,
      CAST(s.description AS NVARCHAR(2048)) AS standard_description,

      CAST(COALESCE(ps2.state_num, ps.state_num) AS NVARCHAR(128)) AS standard_strand,

      ROW_NUMBER() OVER(
         PARTITION BY sub.student_number,
         sub.academic_year,
         sub.administration_round,
         sub.subject_area
           ORDER BY sub.student_number) AS rn_dupe,
      ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.subject_area
           ORDER BY sub.time_per_name DESC) AS rn_curr
FROM
    (
     SELECT student_number,
           illuminate_student_id,
           academic_year,
           schoolid,
           grade_level,
           assessment_id,
           assessment_title,
           time_per_name,
           administration_round,
           administered_at,
           subject_area,
           number_of_questions,
           overall_number_correct,
           overall_percent_correct,
           overall_performance_band,
           scale_score,

           LAG(scale_score, 1) OVER(
              PARTITION BY student_number, academic_year, subject_area
              ORDER BY administered_at
            ) AS prev_scale_score,
           MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(
              PARTITION BY student_number, academic_year, subject_area
            ) AS pretest_scale_score,
           CASE WHEN administration_round = 'Pre-Test' THEN NULL ELSE scale_score END
              - MAX(
                  CASE WHEN administration_round = 'Pre-Test' THEN scale_score END
              ) OVER(
                  PARTITION BY student_number, academic_year, subject_area
                )
              AS growth_from_pretest
     FROM overall_scores
    ) AS sub
LEFT JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard AS std
  ON sub.assessment_id = std.assessment_id
 AND sub.illuminate_student_id = std.student_id
LEFT JOIN gabby.illuminate_standards.standards AS s
  ON std.standard_id = s.standard_id
LEFT JOIN gabby.illuminate_standards.standards AS ps
  ON s.parent_standard_id = ps.standard_id
LEFT JOIN gabby.illuminate_standards.standards AS ps2
  ON ps.parent_standard_id = ps2.standard_id
