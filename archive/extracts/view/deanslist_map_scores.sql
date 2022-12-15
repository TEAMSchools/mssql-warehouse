USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_map_scores AS
SELECT
  student_number,
  term,
  test_year,
  [subject],
  map_percentile,
  map_ritscore,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number,
      [subject]
    ORDER BY
      test_year,
      term_numeric
  ) AS map_index
FROM
  (
    SELECT
      co.student_number,
      terms.[value] AS term,
      CASE
        WHEN terms.[value] = 'Fall' THEN co.academic_year
        ELSE (co.academic_year + 1)
      END AS test_year,
      CASE
        WHEN terms.[value] = 'Winter' THEN 1
        WHEN terms.[value] = 'Spring' THEN 2
        WHEN terms.[value] = 'Fall' THEN 3
      END AS term_numeric,
      subjects.[value] AS [subject],
      map.percentile_2015_norms AS map_percentile,
      map.test_ritscore AS map_ritscore
    FROM
      gabby.powerschool.cohort_identifiers_static AS co
      CROSS JOIN STRING_SPLIT ('Fall,Winter,Spring', ',') terms
      CROSS JOIN STRING_SPLIT (
        'Mathematics,Reading,Science - General Science,Language Usage',
        ','
      ) subjects
      LEFT JOIN gabby.nwea.assessment_result_identifiers AS map ON co.student_number = map.student_id
      AND co.academic_year = map.academic_year
      AND terms.[value] = map.term
      AND subjects.[value] = map.measurement_scale
      AND map.rn_term_subj = 1
    WHERE
      co.grade_level <= 8
      AND co.enroll_status = 0
      AND co.rn_year = 1
  ) sub
