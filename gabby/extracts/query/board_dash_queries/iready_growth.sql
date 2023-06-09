WITH subjects AS (
    SELECT
        s.[value] AS [subject]
    FROM
        STRING_SPLIT ('ELA,Math', ',') AS s
),
iready AS (
    SELECT
        LEFT(dr.academic_year, 4) AS academic_year,
        dr.student_id AS student_number,
        CASE
            WHEN dr._file LIKE '%ela%' THEN 'ELA'
            WHEN dr._file LIKE '%math%' THEN 'Math'
        END AS [subject],
        COALESCE(rt.alt_name, 'Outside Round') AS test_round,
        dr.completion_date,
        dr.overall_relative_placement,
        CASE
            WHEN dr.overall_relative_placement IN (
                'Early On Grade Level',
                'Mid or Above Grade Level'
            ) THEN 1
            WHEN dr.overall_relative_placement IN (
                '1 Grade Level Below',
                '2 Grade Levels Below',
                '3 or More Grade Levels Below'
            ) THEN 0
        END AS is_proficient,
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
)
SELECT
    co.academic_year,
    co.student_number,
    'NJ' AS region,
    co.school_abbreviation,
    co.grade_level,
    'K-4' AS grade_band,
    'ELA' AS [subject],
    CASE
        WHEN abr.test_round = 'DR' THEN 'BOY'
        WHEN abr.test_round = 'Q2' THEN 'MOY'
        WHEN abr.test_round = 'Q4' THEN 'EOY'
    END AS test_round,
    CASE
        WHEN abr.goal_status IN ('Target', 'Above Target', 'Achieved Z') THEN 1
        WHEN abr.goal_status IN ('Approaching', 'Below', 'Far Below') THEN 0
    END AS is_proficient,
    CASE
        WHEN abr.goal_status IN ('Above Target', 'Achieved Z') THEN 'Mid or Above Grade Level'
        WHEN abr.goal_status = 'Target' THEN 'Early on Grade Level'
        WHEN abr.goal_status IN ('Above Target', 'Achieved Z') THEN 'Mid or Above Grade Level'
        WHEN abr.goal_status = 'Approaching' THEN '1 Grade Level Below'
        WHEN abr.goal_status = 'Below' THEN '2 Grade Levels Below'
        WHEN abr.goal_status = 'Far Below' THEN '3 or More Grade Levels Below'
    END AS overall_relative_placement,
    CASE
        WHEN abr.goal_status IN ('Above Target', 'Achieved Z') THEN 'Lvl 5'
        WHEN abr.goal_status = 'Target' THEN 'Lvl 4'
        WHEN abr.goal_status = 'Approaching' THEN 'Lvl 3'
        WHEN abr.goal_status = 'Below' THEN 'Lvl 2'
        WHEN abr.goal_status = 'Far Below' THEN 'Lvl 3'
    END AS orp_short,
    CASE
        WHEN abr.goal_status IN ('Above Target', 'Achieved Z', 'Target') THEN 'On or Above Grade Level'
        WHEN abr.goal_status = 'Approaching' THEN '1 Grade Level Below'
        WHEN abr.goal_status IN ('Below', 'Far Below') THEN 'Two or More Grade Levels Below'
    END AS placement_3_level
FROM
    gabby.powerschool.cohort_identifiers_static AS co
    LEFT JOIN gabby.lit.achieved_by_round_static AS abr ON (
        co.student_number = abr.student_number
        AND co.academic_year = abr.academic_year
        AND abr.test_round IN ('DR', 'Q2', 'Q4')
    )
WHERE
    co.academic_year IN (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR(),
        gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
    )
    AND co.grade_level < 5
    AND co.region != 'KMS'
    AND co.rn_year = 1
    AND co.is_enrolled_recent = 1
UNION
ALL
SELECT
    co.academic_year,
    co.student_number,
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
    subj.[subject],
    ir.test_round,
    ir.is_proficient,
    ir.overall_relative_placement,
    ir.orp_short,
    ir.placement_3_level
FROM
    gabby.powerschool.cohort_identifiers_static AS co
    CROSS JOIN subjects AS subj
    LEFT JOIN iready AS ir ON (
        co.student_number = ir.student_number
        AND co.academic_year = ir.academic_year
        AND subj.[subject] = ir.[subject]
        AND ir.rn_round = 1
    )
WHERE
    co.academic_year IN (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR(),
        gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
    )
    AND co.grade_level < 9
    AND co.rn_year = 1
    AND co.is_enrolled_recent = 1
    AND (
        co.region = 'KMS'
        OR (
            co.region IN ('KCNA', 'TEAM')
            AND co.grade_level > 4
        )
        OR (
            co.region IN ('TEAM', 'KCNA')
            AND subj.[subject] = 'Math'
        )
    )