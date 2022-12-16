USE gabby GO
CREATE OR ALTER VIEW
  tableau.state_assessment_dashboard AS
WITH
  promo AS (
    SELECT
      student_number,
      CASE
        WHEN [ES] IS NOT NULL THEN 1
        ELSE 0
      END AS attended_es,
      CASE
        WHEN [MS] IS NOT NULL THEN 1
        ELSE 0
      END AS attended_ms
    FROM
      (
        SELECT
          student_number,
          school_level,
          grade_level
        FROM
          gabby.powerschool.cohort_identifiers_static
        WHERE
          rn_school = 1
      ) AS sub PIVOT (
        MAX(grade_level) FOR school_level IN ([ES], [MS])
      ) p
  ),
  external_prof AS (
    SELECT
      academic_year,
      test_code,
      [NJ],
      [NPS],
      [CPS]
    FROM
      (
        SELECT
          academic_year,
          test_code,
          entity,
          (SUM(proficient_count) / SUM(valid_scores)) * 100 AS pct_proficient
        FROM
          (
            SELECT
              academic_year,
              test_code,
              valid_scores,
              proficient_count,
              CASE
                WHEN district_name IS NULL THEN 'NJ'
                WHEN district_name = 'CAMDEN CITY' THEN 'CPS'
                WHEN district_name = 'NEWARK CITY' THEN 'NPS'
              END AS entity
            FROM
              gabby.njdoe.parcc_clean
            WHERE
              subgroup = 'TOTAL'
              AND school_code IS NULL
              AND (
                district_name IN ('NEWARK CITY', 'CAMDEN CITY')
                OR (
                  district_name IS NULL
                  AND dfg IS NULL
                )
              )
          ) AS sub
        GROUP BY
          academic_year,
          test_code,
          entity
      ) AS sub PIVOT (
        MAX(pct_proficient) FOR entity IN ([NJ], [NPS], [CPS])
      ) p
  ),
  ms_grad AS (
    SELECT
      student_number,
      ms_attended
    FROM
      (
        SELECT
          student_number,
          school_name AS ms_attended,
          ROW_NUMBER() OVER (
            PARTITION BY
              student_number
            ORDER BY
              exitdate DESC
          ) AS rn
        FROM
          gabby.powerschool.cohort_identifiers_static
        WHERE
          school_level = 'MS'
      ) AS sub
    WHERE
      rn = 1
  ),
  ps_users AS (
    SELECT DISTINCT
      u.sif_stateprid,
      u.lastfirst
    FROM
      gabby.powerschool.users AS u
      INNER JOIN gabby.powerschool.schools AS sch ON u.homeschoolid = sch.school_number
      AND u.[db_name] = sch.[db_name]
    WHERE
      u.sif_stateprid != ''
  )
SELECT
  co.student_number,
  co.lastfirst,
  co.academic_year,
  co.region,
  co.school_level,
  co.reporting_schoolid AS schoolid,
  co.school_abbreviation,
  co.grade_level,
  co.cohort,
  co.entry_schoolid,
  co.entry_grade_level,
  co.enroll_status,
  co.lep_status,
  co.lunchstatus,
  co.ethnicity,
  co.gender,
  'PARCC' AS test_type,
  parcc.test_code
COLLATE SQL_Latin1_General_CP1_CI_AS AS test_code,
parcc.[subject]
COLLATE SQL_Latin1_General_CP1_CI_AS AS [subject],
parcc.test_scale_score,
parcc.test_performance_level,
parcc.test_reading_csem AS test_standard_error,
parcc.staff_member_identifier,
CASE
  WHEN parcc.[subject] = 'Science'
  AND parcc.test_performance_level >= 3 THEN 1
  WHEN parcc.[subject] = 'Science'
  AND parcc.test_performance_level < 3 THEN 0
  WHEN parcc.test_performance_level >= 4 THEN 1
  WHEN parcc.test_performance_level < 4 THEN 0
END AS is_proficient,
CASE
  WHEN parcc.student_with_disabilities IN ('IEP', 'Y', 'B') THEN 'SPED'
  ELSE 'No IEP'
END AS iep_status,
ext.nj AS pct_prof_nj,
ext.nps AS pct_prof_nps,
ext.cps AS pct_prof_cps,
NULL AS pct_prof_parcc,
promo.attended_es,
promo.attended_ms,
ms.ms_attended,
pu.lastfirst AS teacher_lastfirst
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.parcc.summative_record_file_clean AS parcc ON co.student_number = parcc.local_student_identifier
  AND co.academic_year = parcc.academic_year
  LEFT JOIN external_prof AS ext ON co.academic_year = ext.academic_year
  AND parcc.test_code = ext.test_code
COLLATE Latin1_General_BIN
LEFT JOIN promo ON co.student_number = promo.student_number
LEFT JOIN ms_grad AS ms ON co.student_number = ms.student_number
LEFT JOIN ps_users AS pu ON parcc.staff_member_identifier = pu.sif_stateprid
WHERE
  co.rn_year = 1
UNION ALL
SELECT
  co.student_number,
  co.lastfirst,
  co.academic_year,
  co.region,
  co.school_level,
  co.reporting_schoolid AS schoolid,
  co.school_abbreviation,
  co.grade_level,
  co.cohort,
  co.entry_schoolid,
  co.entry_grade_level,
  co.enroll_status,
  co.lep_status,
  co.lunchstatus,
  co.ethnicity,
  co.gender,
  asa.test_type,
  CONCAT(
    LEFT(asa.[subject], 3),
    RIGHT(CONCAT('0', co.grade_level), 2)
  ) AS test_code,
  asa.[subject],
  asa.scaled_score,
  CASE
    WHEN asa.performance_level = 'Advanced Proficient' THEN 5
    WHEN asa.performance_level = 'Proficient' THEN 4
    WHEN asa.performance_level = 'Partially Proficient' THEN 1
  END AS performance_level,
  NULL AS test_standard_error,
  NULL staff_member_identifier,
  CASE
    WHEN asa.scaled_score = 0 THEN NULL
    WHEN asa.scaled_score >= 200 THEN 1
    WHEN asa.scaled_score < 200 THEN 0
  END AS is_proficient,
  co.iep_status,
  NULL AS pct_prof_nj,
  NULL AS pct_prof_nps,
  NULL AS pct_prof_cps,
  NULL AS pct_prof_parcc,
  promo.attended_es,
  promo.attended_ms,
  ms.ms_attended,
  NULL AS teacher_lastfirst
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.njsmart.all_state_assessments AS asa ON co.student_number = asa.local_student_id
  AND co.academic_year = asa.academic_year
  LEFT JOIN promo ON co.student_number = promo.student_number
  LEFT JOIN ms_grad AS ms ON co.student_number = ms.student_number
WHERE
  co.rn_year = 1
