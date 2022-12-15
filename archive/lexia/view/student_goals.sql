USE gabby GO
CREATE OR ALTER VIEW
  lexia.student_goals AS
WITH
  grade_level_goals AS (
    SELECT
      CASE
        WHEN grade_level_material = 'PreK' THEN -1
        ELSE CAST(grade_level_material AS INT)
      END AS grade_level,
      CAST(SUM(units) AS INT) AS units_goal
    FROM
      gabby.lexia.goals_by_level
    GROUP BY
      grade_level_material
  ),
  min_level AS (
    SELECT
      username,
      grade_level,
      min_level_number,
      CASE
        WHEN grade_level >= max_lexia_grade_level THEN grade_level
        WHEN grade_level < max_lexia_grade_level THEN max_lexia_grade_level
      END AS highest_grade_level
    FROM
      (
        SELECT
          username,
          grade_level,
          MIN(level_number) AS min_level_number,
          MAX(lexia_grade_level) AS max_lexia_grade_level
        FROM
          (
            SELECT DISTINCT
              CAST(username AS VARCHAR(25)) AS username,
              gabby.utilities.DATE_TO_SY (CAST(activity_start_time AS DATE)) AS academic_year,
              CASE
                WHEN LEFT(grade_label, 1) = 'K' THEN 0
                ELSE CAST(LEFT(grade_label, 1) AS INT)
              END AS grade_level,
              CASE
                WHEN grade_level_material IN ('Pre K') THEN -1
                WHEN LEFT(
                  REVERSE(
                    LEFT(
                      REVERSE(grade_level_material),
                      CHARINDEX(' ', REVERSE(grade_level_material)) - 1
                    )
                  ),
                  1
                ) = 'K' THEN 0
                ELSE CAST(
                  LEFT(
                    REVERSE(
                      LEFT(
                        REVERSE(grade_level_material),
                        CHARINDEX(' ', REVERSE(grade_level_material)) - 1
                      )
                    ),
                    1
                  ) AS INT
                )
              END AS lexia_grade_level,
              CAST(REPLACE(levelname, 'Level ', '') AS INT) AS level_number
            FROM
              gabby.lexia.student_progress
          ) sub
        GROUP BY
          username,
          grade_level
      ) sub
  ),
  other_goals AS (
    SELECT
      sub.username,
      goals.level,
      CASE
        WHEN goals.grade_level_material = 'PreK' THEN -1
        ELSE CAST(goals.grade_level_material AS INT)
      END AS lexia_grade_level,
      SUM(goals.units) AS units_goal
    FROM
      min_level sub
      LEFT OUTER JOIN gabby.lexia.goals_by_level goals ON sub.min_level_number <= goals.level
      AND sub.highest_grade_level >= CASE
        WHEN goals.grade_level_material = 'PreK' THEN -1
        ELSE CAST(goals.grade_level_material AS INT)
      END
    GROUP BY
      sub.username,
      goals.level,
      goals.grade_level_material
  )
SELECT
  student_number,
  academic_year,
  SUM(units_goal) AS target_units,
  SUM(
    CASE
      WHEN grade_level = lexia_grade_level THEN units_goal
    END
  ) AS grade_level_target,
  SUM(
    CASE
      WHEN grade_level <> lexia_grade_level THEN units_goal
      ELSE 0
    END
  ) AS other_level_target
FROM
  (
    SELECT
      co.student_number,
      co.academic_year,
      co.grade_level,
      co.grade_level AS lexia_grade_level,
      g.units_goal
    FROM
      gabby.powerschool.cohort_identifiers_static co
      INNER JOIN grade_level_goals g ON co.grade_level = g.grade_level
    WHERE
      co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND co.rn_year = 1
    UNION ALL
    SELECT
      co.student_number,
      co.academic_year,
      co.grade_level,
      og.lexia_grade_level,
      og.units_goal
    FROM
      gabby.powerschool.cohort_identifiers_static co
      INNER JOIN gabby.powerschool.students s ON co.student_number = s.student_number
      AND co.db_name = s.db_name
      INNER JOIN other_goals og ON s.student_web_id = og.username
    COLLATE Latin1_General_BIN
    AND co.grade_level <> og.lexia_grade_level
    WHERE
      co.rn_year = 1
      AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  ) sub
GROUP BY
  student_number,
  academic_year
