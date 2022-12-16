CREATE OR ALTER VIEW
  renaissance.ar_goals_current AS
WITH
  roster AS (
    SELECT
      student_number,
      academic_year,
      schoolid,
      grade_level,
      enroll_status,
      reporting_term,
      term_name,
      MAX(is_enrolled) AS is_enrolled
    FROM
      (
        SELECT
          co.student_number,
          co.academic_year,
          co.schoolid,
          co.grade_level,
          co.enroll_status,
          CASE
            WHEN co.exitdate <= dts.[start_date] THEN 0
            WHEN co.entrydate <= dts.end_date THEN 1
            ELSE 0
          END AS is_enrolled,
          dts.time_per_name AS reporting_term,
          dts.alt_name AS term_name
        FROM
          gabby.powerschool.cohort_identifiers_static AS co
          INNER JOIN gabby.reporting.reporting_terms AS dts ON co.schoolid = dts.schoolid
          AND co.academic_year = dts.academic_year
          AND dts.identifier = 'AR'
          AND dts.time_per_name != 'ARY'
          AND dts._fivetran_deleted = 0
        WHERE
          co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
          AND (
            co.school_level = 'MS'
            OR (
              co.schoolid = 73256
              AND co.grade_level >= 3
            )
          )
      ) AS sub
    GROUP BY
      student_number,
      academic_year,
      schoolid,
      grade_level,
      enroll_status,
      reporting_term,
      term_name
  ),
  default_goals AS (
    SELECT
      school_id,
      grade_level,
      CAST(words_goal AS INT) AS words_goal,
      UPPER(REPLACE(term_name, '_', '')) AS term_name
    FROM
      gabby.renaissance.ar_default_goals UNPIVOT (
        words_goal FOR term_name IN (q_1, q_2, q_3, q_4, y_1)
      ) u
  )
  /*
  ,ms_goals AS (
  SELECT sub.student_number
  ,sub.term
  
  ,CAST(tiers.words_goal AS INT) AS words_goal
  FROM
  (
  SELECT achv.student_number
  ,COALESCE(s1.[value], s2.[value]) AS term
  ,COALESCE(COALESCE(achv.indep_lvl_num, achv.lvl_num)
  ,LAG(COALESCE(achv.indep_lvl_num, achv.lvl_num), 2) OVER(
  PARTITION BY achv.student_number, achv.academic_year 
  ORDER BY achv.[start_date])
  ) AS indep_lvl_num /* Q1 & Q2 are set by BOY, carry them forward for setting goals at beginning of year */
  FROM gabby.lit.achieved_by_round_static AS achv
  LEFT JOIN STRING_SPLIT('AR1,AR2', ',') s1
  ON achv.reporting_term = 'LIT1'
  LEFT JOIN STRING_SPLIT('AR3,AR4', ',') s2
  ON achv.reporting_term = 'LIT2'
  WHERE achv.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND achv.reporting_term IN ('LIT1','LIT2')
  ) AS sub
  LEFT JOIN gabby.renaissance.ar_goal_criteria AS goal
  ON sub.indep_lvl_num  BETWEEN goal.[min] AND goal.[max]
  AND goal.criteria_clean = 'lvl_num'
  LEFT JOIN gabby.renaissance.ar_tier_goals AS tiers
  ON goal.tier = tiers.tier
  )
   */
,
  term_goals AS (
    SELECT
      student_number,
      academic_year,
      reporting_term,
      words_goal,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number,
          academic_year,
          reporting_term
        ORDER BY
          words_goal DESC
      ) AS rn_dupe
    FROM
      (
        SELECT
          r.student_number,
          r.academic_year,
          r.reporting_term,
          CASE
            WHEN r.is_enrolled = 0 THEN NULL
            WHEN r.enroll_status != 0 THEN -1
            WHEN COALESCE(
              g.adjusted_goal,
              df2.words_goal,
              df.words_goal
            ) = 0 THEN -1
            ELSE COALESCE(
              g.adjusted_goal,
              df2.words_goal,
              df.words_goal
            )
          END AS words_goal
        FROM
          roster AS r
          LEFT JOIN default_goals AS df ON r.grade_level = df.grade_level
          AND r.term_name = df.term_name
          AND df.school_id = 0
          LEFT JOIN default_goals AS df2 ON r.schoolid = df2.school_id
          AND r.grade_level = df2.grade_level
          AND r.term_name = df2.term_name
          LEFT JOIN gabby.renaissance.ar_individualized_goals_long_static AS g ON r.student_number = g.student_number
          AND r.reporting_term = g.reporting_term
      ) AS sub
  )
SELECT
  student_number,
  academic_year,
  reporting_term,
  CASE
    WHEN words_goal < 0 THEN -1
    ELSE words_goal
  END AS words_goal,
  NULL AS points_goal
FROM
  (
    SELECT
      student_number,
      academic_year,
      reporting_term,
      words_goal
    FROM
      term_goals
    WHERE
      rn_dupe = 1
    UNION ALL
    SELECT
      student_number,
      academic_year,
      'ARY' AS reporting_term,
      SUM(words_goal) AS words_goal
    FROM
      term_goals
    WHERE
      rn_dupe = 1
    GROUP BY
      student_number,
      academic_year
  ) AS sub
