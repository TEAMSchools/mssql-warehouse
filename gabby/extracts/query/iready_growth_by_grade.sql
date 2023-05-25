SELECT
    co.region,
    co.school_abbreviation,
    co.grade_level,
    gm.[subject],
    ROUND(
        AVG(
            CAST(
                CASE
                    WHEN gm.progress_typical >= 100 THEN 1
                    ELSE 0
                END AS FLOAT
            )
        ),
        2
    ) AS pct_achieve_typical,
    CASE
        WHEN ROUND(
            AVG(
                CAST(
                    CASE
                        WHEN gm.progress_typical >= 100 THEN 1
                        ELSE 0
                    END AS FLOAT
                )
            ),
            2
        ) >=.6 THEN 'Goal Met'
        ELSE 'Goal Not Met'
    END AS goal_status_typical,
    ROUND(
        AVG(
            CAST(
                CASE
                    WHEN gm.progress_stretch >= 100 THEN 1
                    ELSE 0
                END AS FLOAT
            )
        ),
        2
    ) AS pct_achieve_stretch,
    CASE
        WHEN ROUND(
            AVG(
                CAST(
                    CASE
                        WHEN gm.progress_stretch >= 100 THEN 1
                        ELSE 0
                    END AS FLOAT
                )
            ),
            2
        ) >=.3 THEN 'Goal Met'
        ELSE 'Goal Not Met'
    END AS goal_status_stretch
FROM
    gabby.iready.growth_metrics AS gm
    INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON (
        gm.student_number = co.student_number
        AND gm.academic_year = co.academic_year
        AND co.rn_year = 1
        AND co.enroll_status = 0
    )
WHERE
    gm.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND (
        co.region = 'KMS'
        OR (
            co.region IN ('KCNA', 'TEAM')
            AND co.grade_level > 4
        )
        OR (
            co.region IN ('TEAM', 'KCNA')
            AND gm.[subject] = 'Math'
        )
    )
GROUP BY
    co.region,
    co.school_abbreviation,
    co.grade_level,
    gm.[subject]
ORDER BY
    co.region ASC,
    co.school_abbreviation ASC,
    gm.[subject] ASC,
    co.grade_level ASC