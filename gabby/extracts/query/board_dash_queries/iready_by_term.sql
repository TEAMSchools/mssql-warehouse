SELECT
    *
FROM
    (
        SELECT
            LEFT(dr.academic_year, 4) AS academic_year,
            dr.student_id,
            CASE
                WHEN co.region IN ('TEAM', 'KCNA') THEN 'NJ'
                WHEN co.region = 'KMS' THEN 'Miami'
            END AS region,
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
            CASE
                WHEN rt.alt_name IS NULL THEN 'Outside Round'
                ELSE rt.alt_name
            END AS test_round,
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
            JOIN gabby.powerschool.cohort_identifiers_static AS co ON co.academic_year = LEFT(dr.academic_year, 4)
            AND co.student_number = dr.student_id
            AND co.rn_year = 1
    ) AS sub
WHERE
    sub.rn_round = 1
ORDER BY
    sub.student_id ASC,
    sub.[subject] ASC,
    sub.academic_year ASC,
    sub.round_number ASC
    