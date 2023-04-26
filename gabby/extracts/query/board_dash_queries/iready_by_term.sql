SELECT
    sub.academic_year,
    sub.student_id,
    sub.region,
    sub.entity,
    sub.ethnicity,
    sub.gender,
    sub.lep_status,
    sub.iep_status,
    sub.school_abbreviation,
    sub.grade_level,
    sub.grade_band,
    sub.cohort,
    sub.[subject],
    sub.start_date,
    sub.completion_date,
    sub.round_number,
    sub.test_round,
    sub.test_round_date,
    sub.baseline_diagnostic_y_n_,
    sub.most_recent_diagnostic_y_n_,
    sub.overall_scale_score,
    sub.[percentile],
    sub.overall_relative_placement,
    sub.orp_short,
    sub.placement_3_level,
    sub.percent_progress_to_annual_typical_growth_,
    sub.percent_progress_to_annual_stretch_growth_,
    sub.diagnostic_gain,
    sub.annual_typical_growth_measure,
    sub.annual_stretch_growth_measure,
    'i-Ready' AS source,
    sub.rn_round
FROM
    (
        SELECT
            LEFT(dr.academic_year, 4) AS academic_year,
            dr.student_id,
            CASE
                WHEN co.region IN ('TEAM', 'KCNA') THEN 'NJ'
                WHEN co.region = 'KMS' THEN 'Miami'
            END AS region,
            co.region AS entity,
            co.ethnicity,
            co.gender,
            CASE
                WHEN co.lep_status = 1 THEN 'LEP'
                ELSE 'Not LEP'
            END AS lep_status,
            CASE
                WHEN co.iep_status LIKE 'SPED%' THEN 'Has IEP'
                ELSE 'No IEP'
            END AS iep_status,
            co.school_abbreviation,
            co.grade_level,
            CASE
                WHEN co.grade_level BETWEEN 0
                AND 4 THEN 'K-4'
                WHEN co.grade_level BETWEEN 5
                AND 8 THEN '5-8'
            END AS grade_band,
            co.cohort,
            CASE
                WHEN dr._file LIKE '%ela%' THEN 'ELA'
                WHEN dr._file LIKE '%math%' THEN 'Math'
            END AS [subject],
            dr.start_date,
            dr.completion_date,
            RIGHT(rt.time_per_name, 1) AS round_number,
            COALESCE(rt.alt_name, 'Outside Round') AS test_round,
            CASE
                WHEN rt.alt_name = 'BOY' THEN 'September ' + LEFT(dr.academic_year, 4)
                WHEN rt.alt_name = 'MOY' THEN 'January ' + RIGHT(dr.academic_year, 4)
                WHEN rt.alt_name = 'EOY' THEN 'May ' + RIGHT(dr.academic_year, 4)
            END AS test_round_date,
            dr.baseline_diagnostic_y_n_,
            dr.most_recent_diagnostic_y_n_,
            dr.overall_scale_score,
            dr.[percentile],
            dr.overall_relative_placement,
            CASE
                WHEN dr.overall_relative_placement = '3 or More Grade Levels Below' THEN 'Lvl 1'
                WHEN dr.overall_relative_placement = '2 Grade Levels Below' THEN 'Lvl 2'
                WHEN dr.overall_relative_placement = '1 Grade Level Below' THEN 'Lvl 3'
                WHEN dr.overall_relative_placement = 'Early On Grade Level' THEN 'Lvl 4'
                WHEN dr.overall_relative_placement = 'Mid or Above Grade Level' THEN 'Lvl 5'
            END AS orp_short,
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
            dr.percent_progress_to_annual_typical_growth_,
            dr.percent_progress_to_annual_stretch_growth_,
            dr.diagnostic_gain,
            dr.annual_typical_growth_measure,
            dr.annual_stretch_growth_measure,
            COUNT(*) OVER(
                PARTITION BY rt.alt_name,
                dr.student_id,
                dr.academic_year,
                dr._file
                ORDER BY
                    dr.completion_date DESC
            ) AS rn_round
        FROM
            gabby.iready.diagnostic_results AS dr
            LEFT JOIN gabby.people.school_crosswalk AS sc ON (dr.school = sc.site_name)
            LEFT JOIN gabby.reporting.reporting_terms AS rt ON (
                (
                    dr.completion_date BETWEEN rt.start_date
                    AND rt.end_date
                )
                AND rt.identifier = 'IR'
                AND sc.region = rt.region
            )
            INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
                co.academic_year = LEFT(dr.academic_year, 4)
                AND co.student_number = dr.student_id
                AND co.rn_year = 1
            )
        WHERE
            co.academic_year >= 2021
    ) AS sub
WHERE
    sub.rn_round = 1
UNION
ALL
SELECT
    abr.academic_year,
    abr.student_number AS student_id,
    CASE
        WHEN sc.[db_name] = 'kippmiami' THEN 'Miami'
        WHEN sc.[db_name] IN ('kippnewark', 'kippcamden') THEN 'NJ'
    END AS region,
    co.region AS entity,
    co.ethnicity,
    co.gender,
    CASE
        WHEN co.lep_status = 1 THEN 'LEP'
        ELSE 'Not LEP'
    END AS lep_status,
    CASE
        WHEN co.iep_status LIKE 'SPED%' THEN 'Has IEP'
        ELSE 'No IEP'
    END AS iep_status,
    NULL AS school_abbreviation,
    abr.grade_level,
    'K-4' AS grade_band,
    NULL AS cohort,
    'ELA' AS [subject],
    NULL AS [start_date],
    NULL AS completion_date,
    NULL AS round_number,
    CASE
        WHEN abr.test_round = 'DR' THEN 'BOY'
        WHEN abr.test_round = 'Q2' THEN 'MOY'
        WHEN abr.test_round = 'Q4' THEN 'EOY'
        ELSE 'Outside Round'
    END AS test_round,
    NULL AS test_round_date,
    NULL AS baseline_diagnostic_y_n_,
    NULL AS most_recent_diagnostic_y_n_,
    NULL AS overall_scale_score,
    NULL AS [percentile],
    NULL AS overall_relative_placement,
    CASE
        WHEN abr.goal_status = 'Far Below' THEN 'Lvl 1'
        WHEN abr.goal_status = 'Below' THEN 'Lvl 2'
        WHEN abr.goal_status = 'Approaching' THEN 'Lvl 3'
        WHEN abr.goal_status = 'Target' THEN 'Lvl 4'
        WHEN abr.goal_status = 'Above Target' THEN 'Lvl 5'
    END AS orp_short,
    CASE
        WHEN abr.goal_status IN ('Below', 'Far Below') THEN 'Two or More Grade Levels Below'
        WHEN abr.goal_status = 'Approaching' THEN '1 Grade Level Below'
        WHEN abr.goal_status IN ('Target', 'Above Target') THEN 'On or Above Grade Level'
        ELSE NULL
    END AS placement_3_level,
    NULL AS percent_progress_to_annual_typical_growth_,
    NULL AS percent_progress_to_annual_stretch_growth_,
    NULL AS diagnostic_gain,
    NULL AS annual_typical_growth_measure,
    NULL AS annual_stretch_growth_measure,
    'F&P' AS source,
    NULL AS rn_round
FROM
    gabby.lit.achieved_by_round_static abr
    LEFT JOIN gabby.powerschool.schools sc ON (abr.schoolid = sc.school_number)
    INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
        co.academic_year = abr.academic_year
        AND co.student_number = abr.student_number
        AND co.rn_year = 1
    )
WHERE
    abr.grade_level < 5
    AND sc.[db_name] <> 'kippmiami'
    AND abr.academic_year >= 2021