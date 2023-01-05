CREATE OR ALTER VIEW
  tableau.lit_tracker AS
WITH
  lit_round AS (
    SELECT
      co.student_number,
      co.lastfirst,
      co.enroll_status,
      co.academic_year,
      co.region,
      co.school_level,
      co.school_name,
      co.school_abbreviation,
      co.grade_level,
      co.team,
      co.iep_status,
      co.lep_status,
      co.is_pathways,
      co.c_504_status,
      co.is_pathways AS is_self_contained,
      term.lit AS lit_term,
      CASE
        WHEN co.academic_year >= 2015 THEN REPLACE(term.ar, 'AR', 'Q')
        ELSE REPLACE(term.ar, 'AR', 'Hex ')
      END AS ar_term,
      achv.is_curterm,
      achv.read_lvl,
      achv.lvl_num,
      achv.gleq,
      achv.dna_lvl,
      achv.dna_lvl_num,
      achv.moved_levels,
      achv.achv_unique_id,
      achv.dna_unique_id,
      achv.n_levels_moved_y1,
      achv.gleq_growth_y1,
      achv.goal_lvl,
      achv.goal_num,
      achv.met_goal,
      achv.hard_lvl,
      achv.goal_status,
      achv.lvl_num - achv.goal_num AS distance_from_goal,
      achv.lvl_num - LAG(achv.lvl_num, 1) OVER (
        PARTITION BY
          achv.academic_year,
          achv.student_number
        ORDER BY
          achv.[start_date] ASC
      ) AS n_lvl_moved_round,
      atid.is_fp,
      atid.genre,
      atid.test_administered_by,
      (
        SELECT
          MAX(v)
        FROM
          (
            VALUES
              (atid.test_date),
              (dtid.test_date),
              (htid.test_date)
          ) AS val (v)
      ) AS test_date,
      /* AR */
      ar.words,
      ar.mastery,
      ar.pct_fiction,
      ar.n_passed,
      ar.n_total,
      CASE
        WHEN ar.words_goal < 0 THEN NULL
        ELSE ar.words_goal
      END AS words_goal
    FROM
      powerschool.cohort_identifiers_static AS co
      INNER JOIN reporting.reporting_term_map AS term ON (
        co.school_level = term.school_level
        AND (
          co.academic_year BETWEEN term.min_year AND term.max_year
        )
      )
      INNER JOIN lit.achieved_by_round_static AS achv ON (
        co.student_number = achv.student_number
        AND co.academic_year = achv.academic_year
        AND term.lit = achv.test_round
        AND achv.[start_date] <= CURRENT_TIMESTAMP
      )
      LEFT JOIN lit.all_test_events_static AS atid ON (
        achv.achv_unique_id = atid.unique_id
      )
      LEFT JOIN lit.all_test_events_static AS dtid ON (
        achv.dna_unique_id = dtid.unique_id
      )
      LEFT JOIN lit.all_test_events_static AS htid ON (
        achv.hard_unique_id = htid.unique_id
      )
      LEFT JOIN renaissance.ar_progress_to_goals AS ar ON (
        co.student_number = ar.student_number
        AND co.academic_year = ar.academic_year
        AND term.ar = ar.reporting_term
        AND ar.[start_date] <= CURRENT_TIMESTAMP
        AND ar.n_total > 0
      )
    WHERE
      co.rn_year = 1
      AND co.academic_year >= (
        utilities.GLOBAL_ACADEMIC_YEAR () - 3
      )
      AND co.grade_level != 99
      AND co.school_level != 'OD'
  )
SELECT
  lr.student_number,
  lr.lastfirst AS student_name,
  lr.enroll_status,
  lr.academic_year,
  lr.region,
  lr.school_level,
  lr.school_name,
  lr.school_abbreviation,
  lr.grade_level,
  lr.team,
  lr.iep_status,
  lr.lep_status,
  lr.is_pathways,
  lr.c_504_status,
  lr.is_self_contained,
  lr.lit_term,
  lr.ar_term,
  lr.is_curterm,
  lr.read_lvl,
  lr.lvl_num,
  lr.gleq,
  lr.dna_lvl,
  lr.dna_lvl_num,
  lr.moved_levels,
  lr.achv_unique_id AS unique_id,
  lr.dna_unique_id,
  lr.n_levels_moved_y1,
  lr.n_lvl_moved_round,
  lr.gleq_growth_y1,
  lr.goal_lvl,
  lr.goal_num,
  lr.met_goal,
  lr.hard_lvl,
  lr.goal_status,
  lr.distance_from_goal,
  lr.is_fp,
  lr.genre,
  lr.test_date,
  lr.test_administered_by,
  lr.words,
  lr.mastery,
  lr.pct_fiction,
  lr.n_passed,
  lr.n_total,
  lr.words_goal,
  ROW_NUMBER() OVER (
    PARTITION BY
      lr.student_number,
      lr.academic_year,
      lr.lit_term,
      lr.ar_term,
      lr.achv_unique_id
    ORDER BY
      lr.achv_unique_id
  ) AS rn_test,
  /* component data */
  long.domain AS component_domain,
  long.[label] AS component_strand,
  long.specific_label AS component_strand_specific,
  long.score AS component_score,
  long.benchmark AS component_benchmark,
  long.is_prof AS component_prof,
  long.margin AS component_margin,
  long.dna_filter
FROM
  lit_round AS lr
  LEFT JOIN lit.component_proficiency_long_static AS long ON (
    lr.dna_unique_id = long.unique_id
  )
