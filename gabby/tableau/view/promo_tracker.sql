CREATE OR ALTER VIEW
  tableau.promo_tracker AS
WITH
  roster AS (
    SELECT
      co.studentid,
      co.student_number,
      co.lastfirst,
      co.academic_year,
      co.region,
      co.school_level,
      co.schoolid,
      co.reporting_schoolid,
      co.grade_level,
      co.cohort,
      co.team,
      co.advisor_name,
      co.iep_status,
      co.enroll_status,
      co.[db_name],
      CAST(dt.alt_name AS VARCHAR) AS term_name,
      CAST(dt.time_per_name AS VARCHAR) AS reporting_term,
      dt.[start_date] AS term_start_date,
      dt.end_date AS term_end_date
    FROM
      powerschool.cohort_identifiers_static co
      INNER JOIN reporting.reporting_terms dt ON (
        co.academic_year = dt.academic_year
        AND co.schoolid = dt.schoolid
        AND dt.identifier = 'RT'
        AND dt._fivetran_deleted = 0
        AND dt.alt_name <> 'Summer School'
      )
    WHERE
      co.academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
      AND co.rn_year = 1
      AND co.is_enrolled_recent = 1
      AND co.reporting_schoolid <> 5173
    UNION ALL
    SELECT
      co.studentid,
      co.student_number,
      co.lastfirst,
      co.academic_year,
      co.region,
      co.school_level,
      co.schoolid,
      co.reporting_schoolid,
      co.grade_level,
      co.cohort,
      co.team,
      co.advisor_name,
      co.iep_status,
      co.enroll_status,
      co.[db_name],
      'Y1' AS term,
      CAST(dt.time_per_name AS VARCHAR) AS reporting_term,
      dt.[start_date] AS term_start_date,
      dt.end_date AS term_end_date
    FROM
      powerschool.cohort_identifiers_static co
      INNER JOIN reporting.reporting_terms dt ON (
        co.academic_year = dt.academic_year
        AND dt.schoolid = 0
        AND dt.identifier = 'SY'
        AND dt._fivetran_deleted = 0
      )
    WHERE
      co.academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
      AND co.rn_year = 1
      AND co.is_enrolled_recent = 1
      AND co.reporting_schoolid <> 5173
  ),
  contact AS (
    SELECT
      student_number,
      person_name AS person,
      contact_type AS [type],
      contact AS [value]
    FROM
      powerschool.student_contacts_static
  ),
  grades AS (
    -- /* term grades */
    -- SELECT
    --   student_number,
    --   academic_year,
    --   reporting_term,
    --   credittype,
    --   course_name,
    --   term_grade_percent_adjusted,
    --   'TERM' AS subdomain,
    --   'Term' AS finalgradename
    -- FROM
    --   powerschool.final_grades_static
    -- WHERE
    --   yearid >= (
    --     utilities.GLOBAL_ACADEMIC_YEAR () - 1990
    --   ) - 1
    --   AND excludefromgpa = 0
    -- UNION ALL
    -- SELECT
    --   student_number,
    --   academic_year,
    --   'SY1' AS reporting_term,
    --   credittype,
    --   course_name,
    --   y1_grade_percent_adjusted AS term_grade_percent_adjusted,
    --   'TERM' AS subdomain,
    --   'Y1' AS finalgradename
    -- FROM
    --   powerschool.final_grades_static
    -- WHERE
    --   academic_year IN (
    --     utilities.GLOBAL_ACADEMIC_YEAR (),
    --     utilities.GLOBAL_ACADEMIC_YEAR () - 1
    --   )
    --   AND is_curterm = 1
    --   AND excludefromgpa = 0
    -- UNION ALL
    /* previous year grades */
    SELECT
      s.student_number,
      gr.academic_year,
      CASE
        WHEN (gr.storecode = 'Y1') THEN 'SY1'
        ELSE REPLACE(gr.storecode, 'Q', 'RT')
      END AS reporting_term,
      gr.credit_type AS credittype,
      gr.course_name,
      gr.[percent] AS term_grade_percent_adjusted,
      'TERM' AS subdomain,
      CASE
        WHEN (gr.storecode = 'Y1') THEN 'Y1'
        ELSE 'Term'
      END AS finalgradename
    FROM
      powerschool.storedgrades gr
      INNER JOIN powerschool.students s ON (
        gr.studentid = s.id
        AND gr.[db_name] = s.[db_name]
      )
    WHERE
      gr.academic_year = utilities.GLOBAL_ACADEMIC_YEAR () - 1
      AND gr.excludefromgpa = 0
      -- UNION ALL
      -- /* category grades */
      -- SELECT
      --   student_number,
      --   academic_year,
      --   'SY1' AS reporting_term,
      --   credittype,
      --   course_name,
      --   ROUND(AVG(grade_category_pct), 0) AS term_grade_percent_adjusted,
      --   'CATEGORY' AS subdomain,
      --   grade_category AS finalgradename
      -- FROM
      --   powerschool.category_grades_static
      -- WHERE
      --   academic_year IN (
      --     utilities.GLOBAL_ACADEMIC_YEAR (),
      --     utilities.GLOBAL_ACADEMIC_YEAR () - 1
      --   )
      --   AND grade_category <> 'Q'
      -- GROUP BY
      --   student_number,
      --   academic_year,
      --   grade_category,
      --   credittype,
      --   course_name
  ),
  attendance AS (
    SELECT
      studentid,
      [db_name],
      academic_year,
      reporting_term,
      UPPER(
        LEFT(field, CHARINDEX('_', field) - 1)
      ) AS att_code,
      [value] AS att_counts,
      CASE
        WHEN (field = 'presentpct_term') THEN 'ABSENT'
        WHEN (field = 'ontimepct_term') THEN 'TARDY'
        WHEN (
          field IN ('attpts_term', 'attptspct_term')
        ) THEN 'PROMO'
        WHEN (field LIKE 'A%') THEN 'ABSENT'
        WHEN (field LIKE 'T%') THEN 'TARDY'
        WHEN (field LIKE '%SS%') THEN 'SUSPENSION'
      END AS subdomain
    FROM
      (
        SELECT
          studentid,
          [db_name],
          academic_year,
          reporting_term,
          a_count_term,
          ad_count_term,
          ae_count_term,
          iss_count_term,
          oss_count_term,
          t_count_term,
          t10_count_term,
          abs_unexcused_count_term,
          tdy_all_count_term,
          (
            abs_unexcused_count_term + ROUND((TDY_all_count_term / 3), 1, 1)
          ) AS attpts_term,
          ROUND(
            (
              (
                mem_count_term - abs_unexcused_count_term
              ) / CASE
                WHEN (mem_count_term = 0) THEN NULL
                ELSE mem_count_term
              END
            ) * 100,
            0
          ) AS presentpct_term,
          ROUND(
            (
              (
                mem_count_term - abs_unexcused_count_term - TDY_all_count_term
              ) / CASE
                WHEN (
                  (
                    mem_count_term - abs_unexcused_count_term
                  ) = 0
                ) THEN NULL
                ELSE (
                  mem_count_term - abs_unexcused_count_term
                )
              END
            ) * 100,
            0
          ) AS ontimepct_term,
          ROUND(
            (
              (
                mem_count_term - (
                  abs_unexcused_count_term + ROUND((TDY_all_count_term / 3), 1, 1)
                )
              ) / CASE
                WHEN (mem_count_term = 0) THEN NULL
                ELSE mem_count_term
              END
            ) * 100,
            0
          ) AS attptspct_term
        FROM
          powerschool.attendance_counts_static
        WHERE
          academic_year IN (
            utilities.GLOBAL_ACADEMIC_YEAR (),
            utilities.GLOBAL_ACADEMIC_YEAR () - 1
          )
          AND mem_count_term > 0
          AND mem_count_term <> abs_unexcused_count_term
        UNION ALL
        SELECT
          studentid,
          [db_name],
          academic_year,
          'SY1' AS reporting_term,
          a_count_y1,
          ad_count_y1,
          ae_count_y1,
          iss_count_y1,
          oss_count_y1,
          t_count_y1,
          t10_count_y1,
          abs_unexcused_count_y1,
          tdy_all_count_y1,
          abs_unexcused_count_y1 + ROUND((TDY_all_count_y1 / 3), 1, 1) AS attpts_y1,
          ROUND(
            (
              (
                MEM_count_y1 - (
                  abs_unexcused_count_y1 + ROUND((TDY_all_count_y1 / 3), 1, 1)
                )
              ) / CASE
                WHEN (MEM_count_y1 = 0) THEN NULL
                ELSE MEM_count_y1
              END
            ) * 100,
            0
          ) AS attptspct_y1,
          ROUND(
            (
              (
                MEM_count_y1 - abs_unexcused_count_y1
              ) / CASE
                WHEN (MEM_count_y1 = 0) THEN NULL
                ELSE MEM_count_y1
              END
            ) * 100,
            0
          ) AS presentpct_y1,
          ROUND(
            (
              (
                MEM_count_y1 - abs_unexcused_count_y1 - TDY_all_count_y1
              ) / CASE
                WHEN (
                  (
                    MEM_count_y1 - abs_unexcused_count_y1
                  ) = 0
                ) THEN NULL
                ELSE (
                  mem_count_y1 - abs_unexcused_count_y1
                )
              END
            ) * 100,
            0
          ) AS ontimepct_y1
        FROM
          powerschool.attendance_counts_static
        WHERE
          academic_year IN (
            utilities.GLOBAL_ACADEMIC_YEAR (),
            utilities.GLOBAL_ACADEMIC_YEAR () - 1
          )
          AND mem_count_y1 > 0
          AND mem_count_y1 <> abs_unexcused_count_y1
          AND is_curterm = 1
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          a_count_term,
          ad_count_term,
          ae_count_term,
          abs_unexcused_count_term,
          t_count_term,
          t10_count_term,
          tdy_all_count_term,
          iss_count_term,
          oss_count_term,
          presentpct_term,
          ontimepct_term,
          attpts_term,
          attptspct_term
        )
      ) AS u
  ),
  modules AS (
    SELECT
      subject_area,
      module_number,
      academic_year,
      local_student_id AS student_number,
      assessment_id,
      module_type,
      date_taken AS measure_date,
      CONVERT(
        VARCHAR(250),
        CASE
          WHEN (subject_area = 'Writing') THEN standard_description
          ELSE standard_code
        END
      ) AS standards,
      CASE
        WHEN (subject_area = 'Writing') THEN points
        ELSE percent_correct
      END AS percent_correct,
      CASE
        WHEN (performance_band_number = 5) THEN 'Above'
        WHEN (performance_band_number = 4) THEN 'Target'
        WHEN (performance_band_number = 3) THEN 'Near'
        WHEN (performance_band_number = 2) THEN 'Below'
        WHEN (performance_band_number = 1) THEN 'Far Below'
      END AS proficiency_label,
      CASE
        WHEN (subject_area = 'Writing') THEN 'WRITING RUBRIC'
        WHEN (response_type = 'O') THEN 'OVERALL'
        WHEN (response_type = 'S') THEN 'STANDARDS'
      END AS subdomain
    FROM
      illuminate_dna_assessments.agg_student_responses_all
    WHERE
      module_type IS NOT NULL
      AND response_type IN ('O', 'S')
      AND academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
  ),
  gpa AS (
    SELECT
      student_number,
      academic_year,
      reporting_term,
      schoolid,
      gpa_y1 AS gpa,
      'GPA Y1 - TERM' AS subdomain
    FROM
      powerschool.gpa_detail
    WHERE
      academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
    UNION ALL
    SELECT
      student_number,
      academic_year,
      'SY1' AS reporting_term,
      schoolid,
      gpa_y1 AS GPA,
      'GPA Y1' AS subdomain
    FROM
      powerschool.gpa_detail
    WHERE
      academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
      AND is_curterm = 1
    UNION ALL
    SELECT
      CAST(s.student_number AS INT) AS student_number,
      utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
      'SY1' AS reporting_Term,
      gpa.schoolid,
      gpa.cumulative_Y1_gpa AS gpa,
      'GPA CUMULATIVE' AS subdomain
    FROM
      powerschool.gpa_cumulative gpa
      INNER JOIN powerschool.students s ON (
        gpa.studentid = s.id
        AND gpa.[db_name] = s.[db_name]
      )
    UNION ALL
    SELECT
      CAST(s.student_number AS INT) AS student_number,
      utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
      'SY1' AS reporting_Term,
      gpa.schoolid,
      gpa.earned_credits_cum AS gpa,
      'CREDITS EARNED' AS subdomain
    FROM
      powerschool.gpa_cumulative gpa
      INNER JOIN powerschool.students s ON (
        gpa.studentid = s.id
        AND gpa.[db_name] = s.[db_name]
      )
  ),
  lit AS (
    /* STEP/F&P */
    SELECT
      student_number,
      academic_year,
      test_round,
      read_lvl,
      lvl_num,
      'ACHIEVED' AS subdomain
    FROM
      lit.achieved_by_round_static
    WHERE
      read_lvl IS NOT NULL
      AND [start_date] <= CAST(CURRENT_TIMESTAMP AS DATE)
    UNION ALL
    SELECT
      student_number,
      academic_year,
      test_round,
      goal_lvl,
      goal_num,
      'GOAL' AS subdomain
    FROM
      lit.achieved_by_round_static
    WHERE
      goal_lvl IS NOT NULL
      AND [start_date] <= CAST(CURRENT_TIMESTAMP AS DATE)
    UNION ALL
    /* Lexile */
    SELECT
      student_id,
      academic_year,
      term AS test_round,
      CONCAT(ritto_reading_score, 'L') AS read_lvl,
      CASE
        WHEN (ritto_reading_score = 0) THEN -1
        WHEN (
          ritto_reading_score BETWEEN 0 AND 100
        ) THEN 1
        WHEN (
          ritto_reading_score BETWEEN 100 AND 200
        ) THEN 5
        WHEN (
          ritto_reading_score BETWEEN 200 AND 300
        ) THEN 10
        WHEN (
          ritto_reading_score BETWEEN 300 AND 400
        ) THEN 14
        WHEN (
          ritto_reading_score BETWEEN 400 AND 500
        ) THEN 17
        WHEN (
          ritto_reading_score BETWEEN 500 AND 600
        ) THEN 20
        WHEN (
          ritto_reading_score BETWEEN 600 AND 700
        ) THEN 22
        WHEN (
          ritto_reading_score BETWEEN 700 AND 800
        ) THEN 25
        WHEN (
          ritto_reading_score BETWEEN 800 AND 900
        ) THEN 27
        WHEN (
          ritto_reading_score BETWEEN 900 AND 1000
        ) THEN 28
        WHEN (
          ritto_reading_score BETWEEN 1000 AND 1100
        ) THEN 29
        WHEN (
          ritto_reading_score BETWEEN 1100 AND 1200
        ) THEN 30
        WHEN (ritto_reading_score >= 1200) THEN 31
      END AS lvl_num,
      'ACHIEVED' AS subdomain
    FROM
      nwea.assessment_result_identifiers
    WHERE
      measurement_scale = 'Reading'
      AND school_name = 'Newark Collegiate Academy'
      AND rn_term_subj = 1
    UNION ALL
    SELECT
      map.student_id,
      map.academic_year,
      map.term AS test_round,
      CASE
        WHEN (s.grade_level = 9) THEN '900L'
        WHEN (s.grade_level = 10) THEN '1000L'
        WHEN (s.grade_level = 11) THEN '1100L'
        WHEN (s.grade_level = 12) THEN '1200L'
      END AS goal_lvl,
      CASE
        WHEN (s.grade_level = 9) THEN 28
        WHEN (s.grade_level = 10) THEN 29
        WHEN (s.grade_level = 11) THEN 30
        WHEN (s.grade_level = 12) THEN 31
      END AS goal_num,
      'GOAL' AS subdomain
    FROM
      nwea.assessment_result_identifiers map
      INNER JOIN powerschool.students s ON (
        map.student_id = s.student_number
      )
    WHERE
      map.measurement_scale = 'Reading'
      AND map.school_name = 'Newark Collegiate Academy'
      AND map.rn_term_subj = 1
  ),
  map AS (
    SELECT
      student_id AS student_number,
      academic_year,
      test_year,
      term,
      measurement_scale,
      test_ritscore,
      percentile_2015_norms AS testpercentile,
      NULL AS subdomain
    FROM
      nwea.assessment_result_identifiers
    WHERE
      rn_term_subj = 1
  ),
  standardized_tests AS (
    /* PARCC */
    SELECT
      local_student_identifier AS student_number,
      academic_year,
      NULL AS test_date,
      'PARCC' AS test_name,
      [subject],
      test_scale_score,
      test_performance_level,
      CASE
        WHEN (test_performance_level = 5) THEN 'Exceeded'
        WHEN (test_performance_level = 4) THEN 'Met'
        WHEN (test_performance_level = 3) THEN 'Approached'
        WHEN (test_performance_level = 2) THEN 'Partially Met'
        WHEN (test_performance_level = 1) THEN 'Did Not Meet'
      END AS performance_level_label
    FROM
      parcc.summative_record_file_clean
    UNION ALL
    /* NJASK & HSPA */
    SELECT
      local_student_id AS student_number,
      academic_year,
      NULL AS test_date,
      test_type,
      [subject],
      scaled_score,
      CASE
        WHEN (
          performance_level = 'Advanced Proficient'
        ) THEN 5
        WHEN (performance_level = 'Proficient') THEN 4
        WHEN (
          performance_level = 'Partially Proficient'
        ) THEN 1
      END AS performance_level,
      performance_level AS performance_level_label
    FROM
      njsmart.all_state_assessments
    UNION ALL
    /* ACT */
    SELECT
      student_number,
      academic_year,
      test_date,
      test_name,
      CAST([subject] AS VARCHAR(25)) AS [subject],
      scale_score,
      NULL AS performance_level,
      NULL AS performance_level_label
    FROM
      (
        SELECT
          student_number,
          academic_year,
          test_date,
          test_type AS test_name,
          CAST(composite AS INT) AS composite,
          CAST(english AS INT) AS english,
          CAST(math AS INT) AS math,
          CAST(reading AS INT) AS reading,
          CAST(science AS INT) AS science
        FROM
          naviance.act_scores_clean
      ) AS sub UNPIVOT (
        scale_score FOR [subject] IN (
          composite,
          english,
          math,
          reading,
          science
        )
      ) AS u
    UNION ALL
    /* ACT Prep */
    SELECT
      student_number,
      academic_year,
      administered_at AS test_date,
      'ACT Prep' AS test_name,
      CASE
        WHEN (subject_area = 'Mathematics') THEN 'Math'
        ELSE subject_area
      END AS [subject],
      scale_score,
      overall_performance_band AS performance_level,
      NULL AS performance_level_label
    FROM
      act.test_prep_scores
    WHERE
      academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
      AND rn_dupe = 1
    UNION ALL
    /* SAT */
    SELECT
      student_number,
      academic_year,
      test_date,
      'SAT' AS test_name,
      CAST([subject] AS VARCHAR(25)) AS [subject],
      scale_score,
      NULL AS performance_level,
      NULL AS performance_level_label
    FROM
      naviance.sat_scores_clean UNPIVOT (
        scale_score FOR [subject] IN (
          all_tests_total,
          math,
          verbal,
          writing
        )
      ) AS u
    UNION ALL
    /* SAT II */
    SELECT
      student_number,
      academic_year,
      test_date,
      'SAT II' test_name,
      test_name AS [subject],
      score AS scale_score,
      NULL AS performance_level,
      NULL AS performance_level_label
    FROM
      naviance.sat_2_scores_clean
    UNION ALL
    /* AP */
    SELECT
      CAST(hs_student_id AS INT) AS student_number,
      utilities.DATE_TO_SY (
        CONVERT(
          DATE,
          CASE
            WHEN (test_date = '0000-00-00') THEN NULL
            ELSE REPLACE(test_date, '-00', '-01')
          END
        )
      ) AS academic_year,
      CONVERT(
        DATE,
        CASE
          WHEN (test_date = '0000-00-00') THEN NULL
          ELSE REPLACE(test_date, '-00', '-01')
        END
      ) AS test_date,
      'AP' AS test_name,
      CAST(test_name AS VARCHAR(125)) AS [subject],
      CAST(score AS INT) AS scale_score,
      NULL AS performance_level,
      NULL AS performance_level_label
    FROM
      naviance.ap_scores
    UNION ALL
    /* EXPLORE */
    SELECT
      CAST(hs_student_id AS INT) AS hs_student_id,
      utilities.DATE_TO_SY (
        CONVERT(
          DATE,
          CASE
            WHEN (test_date = '0000-00-00') THEN NULL
            ELSE REPLACE(test_date, '-00', '-01')
          END
        )
      ) AS academic_year,
      CONVERT(
        DATE,
        CASE
          WHEN (test_date = '0000-00-00') THEN NULL
          ELSE REPLACE(test_date, '-00', '-01')
        END
      ) AS test_date,
      'EXPLORE' AS test_name,
      CAST([subject] AS VARCHAR(25)) AS [subject],
      CAST(scale_score AS INT) AS scale_score,
      NULL AS performance_level,
      NULL AS performance_level_label
    FROM
      naviance.explore_scores UNPIVOT (
        scale_score FOR [subject] IN (
          english,
          math,
          reading,
          science,
          composite
        )
      ) AS u
    UNION ALL
    SELECT
      CAST(hs_student_id AS INT) AS student_number,
      utilities.DATE_TO_SY (
        CONVERT(
          DATE,
          CASE
            WHEN (test_date = '0000-00-00') THEN NULL
            ELSE REPLACE(test_date, '-00', '-01')
          END
        )
      ) AS academic_year,
      CONVERT(
        DATE,
        CASE
          WHEN (test_date = '0000-00-00') THEN NULL
          ELSE REPLACE(test_date, '-00', '-01')
        END
      ) AS test_date,
      'PSAT' AS test_name,
      CAST([subject] AS VARCHAR(25)) AS [subject],
      CAST(scale_score AS INT) AS scale_score,
      NULL AS performance_level,
      NULL AS performance_level_label
    FROM
      naviance.psat_scores UNPIVOT (
        scale_score FOR [subject] IN (
          critical_reading,
          math,
          writing,
          total
        )
      ) AS u
  ),
  collegeapps AS (
    SELECT
      student_number,
      collegename,
      [level],
      result_code,
      [value],
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number
        ORDER BY
          competitiveness_ranking_int DESC
      ) AS competitiveness_ranking
    FROM
      (
        SELECT
          CAST(app.hs_student_id AS INT) AS student_number,
          CAST(app.collegename AS VARCHAR(125)) AS collegename,
          CAST(app.[level] AS VARCHAR(25)) AS [level],
          CONVERT(
            VARCHAR(125),
            CASE
              WHEN (
                app.result_code IN ('unknown')
                OR app.result_code IS NULL
              ) THEN app.stage
              ELSE app.result_code
            END
          ) AS result_code,
          CONVERT(
            VARCHAR(250),
            CONCAT(
              'Type:',
              CHAR(9),
              REPLACE(app.inst_control, 'p', 'P'),
              CHAR(10),
              'Attending:',
              CHAR(9),
              app.attending,
              CHAR(10),
              app.comments
            )
          ) AS [value],
          CASE
            WHEN (
              a.competitiveness_ranking_c = 'Most Competitive+'
            ) THEN 7
            WHEN (
              a.competitiveness_ranking_c = 'Most Competitive'
            ) THEN 6
            WHEN (
              a.competitiveness_ranking_c = 'Highly Competitive'
            ) THEN 5
            WHEN (
              a.competitiveness_ranking_c = 'Very Competitive'
            ) THEN 4
            WHEN (
              a.competitiveness_ranking_c = 'Noncompetitive'
            ) THEN 1
            WHEN (
              a.competitiveness_ranking_c = 'Competitive'
            ) THEN 3
            WHEN (
              a.competitiveness_ranking_c = 'Less Competitive'
            ) THEN 2
          END competitiveness_ranking_int
        FROM
          naviance.college_applications app
          LEFT JOIN alumni.account a ON (
            app.ceeb_code = CAST(a.ceeb_code_c AS VARCHAR)
            AND a.record_type_id = '01280000000BQEkAAO'
            AND a.competitiveness_ranking_c IS NOT NULL
          )
      ) AS sub
  ),
  promo_status AS (
    SELECT
      student_number,
      academic_year,
      reporting_term_name,
      CAST(field AS VARCHAR) AS subdomain,
      CASE
        WHEN (field LIKE '%status%') THEN [value]
      END AS text_value,
      CASE
        WHEN (field LIKE '%status%') THEN NULL
        ELSE CAST([value] AS FLOAT)
      END AS numeric_value
    FROM
      (
        SELECT
          student_number,
          academic_year,
          reporting_term_name,
          CAST(promo_status_overall AS VARCHAR) AS promo_status_overall,
          CAST(
            promo_status_attendance AS VARCHAR
          ) AS promo_status_att,
          CAST(promo_status_lit AS VARCHAR) AS promo_status_lit,
          CAST(promo_status_grades AS VARCHAR) AS promo_status_grades,
          CAST(promo_status_qa_math AS VARCHAR) AS promo_status_qa_math
        FROM
          reporting.promotional_status
        WHERE
          academic_year IN (
            utilities.GLOBAL_ACADEMIC_YEAR (),
            utilities.GLOBAL_ACADEMIC_YEAR () - 1
          )
          AND is_curterm = 1
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          promo_status_overall,
          promo_status_att,
          promo_status_lit,
          promo_status_grades,
          promo_status_qa_math
        )
      ) AS u
  ),
  instructional_tech AS (
    SELECT
      student_number,
      academic_year,
      words AS progress,
      words_goal AS goal,
      stu_status_words AS goal_status,
      CASE
        WHEN (reporting_term = 'ARY') THEN 'Y1'
        ELSE REPLACE(reporting_term, 'AR', 'Q')
      END AS term_name,
      'AR' AS subdomain
    FROM
      renaissance.ar_progress_to_goals
    WHERE
      academic_year IN (
        utilities.GLOBAL_ACADEMIC_YEAR (),
        utilities.GLOBAL_ACADEMIC_YEAR () - 1
      )
  )
  --/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'GRADES' AS DOMAIN,
  gr.subdomain,
  gr.credittype AS [subject],
  gr.course_name,
  gr.finalgradename AS measure_name,
  gr.term_grade_percent_adjusted AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster r
  LEFT JOIN grades gr ON (
    r.student_number = gr.student_number
    AND r.academic_year = gr.academic_year
    AND r.reporting_term = gr.reporting_term
  )
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'ATTENDANCE' AS DOMAIN,
  att.subdomain,
  NULL AS [subject],
  NULL AS course_name,
  att.att_code AS measure_name,
  att.att_counts AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster r
  LEFT JOIN attendance att ON (
    r.studentid = att.studentid
    AND r.[db_name] = att.[db_name]
    AND r.academic_year = att.academic_year
    AND r.reporting_term = att.reporting_term
  )
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  cma.module_number AS term,
  r.reporting_term,
  'MODULES' AS DOMAIN,
  cma.subdomain,
  cma.subject_area AS [subject],
  cma.module_type AS course_name,
  cma.standards AS measure_name,
  cma.percent_correct AS measure_value,
  cma.measure_date,
  cma.assessment_id AS performance_level,
  cma.proficiency_label AS performance_level_label
FROM
  roster r
  LEFT JOIN modules cma ON (
    r.student_number = cma.student_number
    AND r.academic_year = cma.academic_year
  )
WHERE
  r.term_name = 'Y1'
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  gpa.academic_year AS YEAR,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'GPA',
  gpa.subdomain,
  NULL AS [subject],
  NULL AS course_name,
  NULL AS measure_name,
  gpa.GPA AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster r
  INNER JOIN gpa ON (
    r.student_number = gpa.student_number
    AND r.schoolid = gpa.schoolid
    AND r.academic_year >= gpa.academic_year
    AND r.reporting_term = gpa.reporting_term
    AND r.term_start_date <= CAST(CURRENT_TIMESTAMP AS DATE)
  )
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  lit.academic_year AS YEAR,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  lit.test_round AS term,
  r.reporting_term,
  'LIT',
  lit.subdomain,
  NULL AS [subject],
  NULL AS course_name,
  lit.read_lvl AS measure_name,
  lit.lvl_num AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster r
  LEFT JOIN lit ON (
    r.student_number = lit.student_number
    AND r.academic_year >= lit.academic_year
  )
WHERE
  r.term_name = 'Y1'
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  map.academic_year AS [year],
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  map.term,
  r.reporting_term,
  'MAP' AS DOMAIN,
  map.subdomain,
  map.measurement_scale AS [subject],
  NULL AS course_name,
  CAST(map.test_ritscore AS VARCHAR) AS measure_name,
  map.testpercentile AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster r
  LEFT JOIN map ON (
    r.student_number = map.student_number
  )
WHERE
  r.term_name = 'Y1'
  AND r.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  std.academic_year AS YEAR,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'STANDARDIZED TESTS' AS DOMAIN,
  std.test_name AS subdomain,
  std.[subject],
  NULL AS course_name,
  CAST(NEWID() AS VARCHAR(250)) AS measure_name,
  std.test_scale_score AS measure_value,
  std.test_date AS measure_date,
  std.test_performance_level AS performance_level,
  std.performance_level_label
FROM
  roster r
  LEFT JOIN standardized_tests std ON (
    r.student_number = std.student_number
  )
WHERE
  r.term_name = 'Y1'
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'COLLEGE APPS' AS DOMAIN,
  apps.[level] AS subdomain,
  apps.result_code AS [subject],
  apps.collegename AS course_name,
  NULL AS measure_name,
  NULL AS measure_value,
  NULL AS measure_date,
  apps.competitiveness_ranking AS performance_level,
  apps.[value] AS performance_level_label
FROM
  roster r
  LEFT JOIN collegeapps apps ON (
    r.student_number = apps.student_number
  )
WHERE
  r.term_name = 'Y1'
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  'Q' + RIGHT(promo.reporting_term_name, 1) AS reporting_term,
  'PROMO STATUS' AS DOMAIN,
  promo.subdomain,
  NULL AS [subject],
  NULL AS course_name,
  NULL AS measure_name,
  NULL AS measure_value,
  NULL AS measure_date,
  promo.numeric_value AS performance_level,
  promo.text_value AS performance_level_label
FROM
  roster r
  LEFT JOIN promo_status promo ON (
    r.student_number = promo.student_number
    AND r.academic_year = promo.academic_year
  )
WHERE
  r.term_name = 'Y1'
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'CONTACT' AS DOMAIN,
  c.[type] AS subdomain,
  c.person AS [subject],
  NULL AS course_name,
  c.[value] AS measure_name,
  NULL AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster r
  LEFT JOIN contact c ON (
    r.student_number = c.student_number
  )
WHERE
  r.term_name = 'Y1'
UNION ALL
--*/
--/*
SELECT
  r.studentid,
  r.student_number,
  r.lastfirst,
  r.academic_year,
  r.region,
  r.school_level,
  r.reporting_schoolid AS schoolid,
  r.grade_level,
  r.cohort,
  r.team,
  r.advisor_name,
  r.iep_status,
  r.enroll_status,
  r.term_name,
  r.reporting_term,
  'BLENDED LEARNING' AS DOMAIN,
  b.subdomain,
  NULL AS [subject],
  NULL AS course_name,
  NULL AS measure_name,
  b.progress AS measure_value,
  NULL AS measure_date,
  b.goal AS performance_level,
  b.goal_status AS performance_level_label
FROM
  roster r
  INNER JOIN instructional_tech b ON (
    r.student_number = b.student_number
    AND r.academic_year = b.academic_year
    AND r.term_name = b.term_name
  )
UNION ALL
--*/
--/*
/* blank row for default */
SELECT DISTINCT
  NULL AS studentid,
  NULL AS student_number,
  ' Choose a student...' AS lastfirst,
  academic_year,
  region,
  school_level,
  reporting_schoolid AS schoolid,
  grade_level,
  NULL AS cohort,
  NULL AS team,
  advisor_name,
  'No IEP' AS spedlep,
  0 AS enroll_status,
  NULL AS term,
  NULL AS reporting_term,
  'CONTACT' AS DOMAIN,
  NULL AS subdomain,
  NULL AS [subject],
  NULL AS course_name,
  NULL AS measure_name,
  NULL AS measure_value,
  NULL AS measure_date,
  NULL AS performance_level,
  NULL AS performance_level_label
FROM
  roster
WHERE
  term_name = 'Y1'
  --*/
