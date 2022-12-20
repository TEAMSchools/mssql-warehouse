CREATE OR ALTER VIEW
  tableau.kipp_forward_survey_score_weights AS
WITH
  weight_denominator AS (
    SELECT
      survey_id,
      SUM(
        CAST(answer_value AS FLOAT)
      ) AS answer_total
    FROM
      gabby.surveygizmo.survey_detail
    WHERE
      survey_id = 6734664
      AND question_shortname IN (
        'imp_1',
        'imp_2',
        'imp_3',
        'imp_4',
        'imp_5',
        'imp_6',
        'imp_7',
        'imp_8',
        'imp_9',
        'imp_10'
      )
    GROUP BY
      survey_id
  ),
  score_weights AS (
    SELECT
      s.question_shortname,
      s.question_title,
      (
        SUM(
          CAST(
            s.answer_value AS FLOAT
          )
        ) / a.answer_total
      ) * 10.0 AS item_weight
    FROM
      weight_denominator AS a
      LEFT JOIN surveygizmo.survey_detail AS s ON a.survey_id = s.survey_id
      AND s.survey_id = 6734664
      AND s.question_shortname IN (
        'imp_1',
        'imp_2',
        'imp_3',
        'imp_4',
        'imp_5',
        'imp_6',
        'imp_7',
        'imp_8',
        'imp_9',
        'imp_10'
      )
    GROUP BY
      s.question_shortname,
      s.question_title,
      a.answer_total
  ),
  avg_scores AS (
    SELECT
      question_shortname,
      avg_weighted_scores
    FROM
      (
        SELECT
          AVG(level_pay_quality) AS imp_1,
          AVG(stable_pay_quality) AS imp_2,
          AVG(stable_hours_quality) AS imp_3,
          AVG(
            control_hours_location_quality
          ) AS imp_4,
          AVG(job_security_quality) AS imp_5,
          AVG(benefits_quality) AS imp_6,
          AVG(advancement_quality) AS imp_7,
          AVG(enjoyment_quality) AS imp_8,
          AVG(purpose_quality) AS imp_9,
          AVG(power_quality) AS imp_10
        FROM
          gabby.tableau.kipp_forward_survey
      ) AS sub UNPIVOT (
        avg_weighted_scores FOR question_shortname IN (
          imp_1,
          imp_2,
          imp_3,
          imp_4,
          imp_5,
          imp_6,
          imp_7,
          imp_8,
          imp_9,
          imp_10
        )
      ) AS u
  )
SELECT
  s.question_shortname,
  s.avg_weighted_scores,
  w.item_weight / 10.0 AS percent_weight,
  w.question_title
FROM
  avg_scores AS s
  INNER JOIN score_weights AS w ON s.question_shortname = w.question_shortname
