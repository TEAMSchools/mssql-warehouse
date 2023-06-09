CREATE OR ALTER VIEW
  iready.tests_by_round AS
WITH
  iready AS (
    SELECT
      LEFT(dr.academic_year, 4) AS academic_year,
      dr.student_id,
      co.region,
      co.school_abbreviation,
      co.grade_level,
      CASE
        WHEN dr._file LIKE '%ela%' THEN 'Reading'
        WHEN dr._file LIKE '%math%' THEN 'Math'
      END AS [subject],
      dr.start_date,
      dr.completion_date,
      RIGHT(rt.time_per_name, 1) AS round_number,
      COALESCE(rt.alt_name, 'Outside Round') AS test_round,
      CASE
        WHEN rt.alt_name = 'BOY' THEN 'Fall ' + LEFT(dr.academic_year, 4)
        WHEN rt.alt_name = 'MOY' THEN 'Winter ' + RIGHT(dr.academic_year, 4)
        WHEN rt.alt_name = 'EOY' THEN 'Spring ' + RIGHT(dr.academic_year, 4)
      END AS test_round_date,
      dr.baseline_diagnostic_y_n_,
      dr.most_recent_diagnostic_y_n_,
      dr.overall_scale_score,
      dr.[percentile],
      dr.overall_relative_placement,
      CASE
        WHEN dr.overall_relative_placement = '3 or More Grade Levels Below' THEN 1
        WHEN dr.overall_relative_placement = '2 Grade Levels Below' THEN 2
        WHEN dr.overall_relative_placement = '1 Grade Level Below' THEN 3
        WHEN dr.overall_relative_placement = 'Early On Grade Level' THEN 4
        WHEN dr.overall_relative_placement = 'Mid or Above Grade Level' THEN 5
      END AS orp_numerical,
      CASE
        WHEN dr.overall_relative_placement IN (
          'Early On Grade Level',
          'Mid or Above Grade Level'
        ) THEN 'On or Above Grade Level'
        WHEN dr.overall_relative_placement = '1 Grade Level Below' THEN dr.overall_relative_placement
        WHEN dr.overall_relative_placement IN (
          '2 Grade Levels Below',
          '3 or More Grade Levels Below'
        ) THEN 'Two or More Grade Levels Below'
      END AS placement_3_level,
      dr.rush_flag,
      dr.mid_on_grade_level_scale_score,
      dr.percent_progress_to_annual_typical_growth_,
      dr.percent_progress_to_annual_stretch_growth_,
      dr.diagnostic_gain,
      dr.annual_typical_growth_measure,
      dr.annual_stretch_growth_measure,
      COUNT(*) OVER (
        PARTITION BY
          rt.alt_name,
          dr.student_id,
          dr.academic_year,
          dr._file
        ORDER BY
          dr.completion_date DESC
      ) AS rn_subj_round,
      COUNT(*) OVER (
        PARTITION BY
          dr.student_id,
          dr.academic_year,
          dr._file
        ORDER BY
          dr.completion_date DESC
      ) AS rn_subj_year
    FROM
      gabby.iready.diagnostic_results AS dr
      LEFT JOIN gabby.people.school_crosswalk AS sc ON (dr.school = sc.site_name)
      LEFT JOIN gabby.reporting.reporting_terms AS rt ON (
        (
          dr.completion_date BETWEEN rt.start_date AND rt.end_date
        )
        AND rt.identifier = 'IR'
        AND sc.region = rt.region
      )
      INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
        co.academic_year = LEFT(dr.academic_year, 4)
        AND co.student_number = dr.student_id
        AND co.rn_year = 1
      )
  )
SELECT
  ir.academic_year,
  ir.student_id,
  ir.region,
  ir.school_abbreviation,
  ir.grade_level,
  ir.[subject],
  ir.start_date,
  ir.completion_date,
  ir.round_number,
  ir.test_round,
  ir.test_round_date,
  ir.baseline_diagnostic_y_n_,
  ir.most_recent_diagnostic_y_n_,
  ir.overall_scale_score,
  ir.[percentile],
  ir.overall_relative_placement,
  ir.orp_numerical,
  ir.placement_3_level,
  ir.rush_flag,
  ir.mid_on_grade_level_scale_score,
  ir.percent_progress_to_annual_typical_growth_,
  ir.percent_progress_to_annual_stretch_growth_,
  ir.diagnostic_gain,
  ir.annual_typical_growth_measure,
  ir.annual_stretch_growth_measure,
  cwo.sublevel_name AS sa_proj_lvl,
  cwo.sublevel_number AS sa_proj_lvl_num,
  cwt.sublevel_name AS sa_proj_lvl_typ,
  cwt.sublevel_number AS sa_proj_lvl_typ_num,
  cwt.sublevel_name AS sa_proj_lvl_str,
  cwt.sublevel_number AS sa_proj_lvl_str_num,
  ir.rn_subj_round,
  ir.rn_subj_year
FROM
  iready AS ir
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk AS cwo ON (
    ir.overall_scale_score BETWEEN cwo.scale_low AND cwo.scale_high
    AND ir.[subject] = cwo.test_name
    AND ir.grade_level = cwo.grade_level
    AND cwo.source_system = 'i-Ready'
    AND CASE
      WHEN ir.region IN ('KCNA', 'TEAM') THEN 'NJSLA'
      WHEN ir.region = 'KMS' THEN 'FL'
    END = cwo.destination_system
  )
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk AS cwt ON (
    ir.overall_scale_score + ir.annual_typical_growth_measure BETWEEN cwt.scale_low AND cwt.scale_high
    AND ir.[subject] = cwt.test_name
    AND ir.grade_level = cwt.grade_level
    AND cwt.source_system = 'i-Ready'
    AND CASE
      WHEN ir.region IN ('KCNA', 'TEAM') THEN 'NJSLA'
      WHEN ir.region = 'KMS' THEN 'FL'
    END = cwt.destination_system
  )
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk AS cws ON (
    ir.overall_scale_score + ir.annual_stretch_growth_measure BETWEEN cws.scale_low AND cws.scale_high
    AND ir.[subject] = cws.test_name
    AND ir.grade_level = cws.grade_level
    AND cws.source_system = 'i-Ready'
    AND CASE
      WHEN ir.region IN ('KCNA', 'TEAM') THEN 'NJSLA'
      WHEN ir.region = 'KMS' THEN 'FL'
    END = cws.destination_system
  )
