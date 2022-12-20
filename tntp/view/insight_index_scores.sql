CREATE OR ALTER VIEW
  tntp.insight_index_scores AS
SELECT
  sub.administration_year,
  sub.administration_academic_year,
  sub.administration_round,
  sub.reporting_schoolid,
  sub.school,
  SUM(sub.pct_agree) AS sum_pct_agree,
  ROUND(
    (
      SUM(sub.pct_agree) * 3
    ) + 1,
    1
  ) AS instructional_culture_index
FROM
  (
    SELECT
      administration_year,
      administration_academic_year,
      administration_round,
      reporting_schoolid,
      school,
      variable,
      AVG(is_agree) AS pct_agree
    FROM
      gabby.tntp.insight_survey_detail
    WHERE
      survey_type = 'Teacher'
      AND is_ici = 1
    GROUP BY
      administration_year,
      administration_academic_year,
      administration_round,
      reporting_schoolid,
      school,
      variable
  ) AS sub
GROUP BY
  sub.administration_year,
  sub.administration_academic_year,
  sub.administration_round,
  sub.reporting_schoolid,
  sub.school
