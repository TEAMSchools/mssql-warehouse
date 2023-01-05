CREATE OR ALTER VIEW
  naviance.sat_act_conversion AS
SELECT
  sub.student_number,
  sub.academic_year,
  sub.test_date,
  'Composite' AS act_subject,
  CASE
    WHEN sub.total_score < 560 THEN 11
    ELSE CAST(sac.act_composite_score AS INT)
  END AS scale_score /* concordance data does not exist for < 560 */
FROM
  (
    SELECT
      sat.student_number,
      utilities.DATE_TO_SY (sat.test_date) AS academic_year,
      sat.test_date,
      CAST(
        COALESCE(
          onc.new_sat_total_score,
          sat.all_tests_total
        ) AS INT
      ) AS total_score
    FROM
      naviance.sat_scores_clean AS sat
      LEFT JOIN collegeboard.sat_old_new_concordance AS onc ON (
        sat.sat_scale = onc.old_sat_scale
        AND sat.all_tests_total = onc.old_sat_total_score
        AND sat.is_old_sat = 1
      )
  ) AS sub
  LEFT JOIN collegeboard.sat_act_concordance AS sac ON (
    sub.total_score = sac.sat_total_score
  )
