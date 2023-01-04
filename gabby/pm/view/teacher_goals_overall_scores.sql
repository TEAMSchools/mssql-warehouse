CREATE OR ALTER VIEW
  pm.teacher_goals_overall_scores AS
SELECT
  df_employee_number,
  preferred_name,
  business_unit AS legal_entity_name,
  hire_date,
  primary_job,
  primary_site,
  academic_year,
  pm_term,
  etr_score,
  so_score,
  overall_score,
  CASE
    WHEN etr_score >= 3.495 THEN 4
    WHEN etr_score >= 2.745 THEN 3
    WHEN etr_score >= 1.745 THEN 2
    WHEN etr_score < 1.745 THEN 1
  END AS etr_tier,
  CASE
    WHEN so_score >= 3.495 THEN 4
    WHEN so_score >= 2.995 THEN 3
    WHEN so_score >= 1.995 THEN 2
    WHEN so_score < 1.995 THEN 1
  END AS so_tier,
  CASE
    WHEN overall_score >= 3.495 THEN 4
    WHEN overall_score >= 2.745 THEN 3
    WHEN overall_score >= 1.745 THEN 2
    WHEN overall_score < 1.745 THEN 1
  END AS overall_tier
FROM
  (
    SELECT
      df_employee_number,
      preferred_name,
      business_unit,
      hire_date,
      primary_job,
      primary_site,
      academic_year,
      pm_term,
      [Excellent Teaching Rubric] AS etr_score,
      [Self & Others] AS so_score,
      COALESCE(
        (
          [Excellent Teaching Rubric] * 0.8
        ) + ([Self & Others] * 0.2),
        [Self & Others],
        [Excellent Teaching Rubric]
      ) AS overall_score
    FROM
      (
        SELECT
          tg.df_employee_number,
          tg.preferred_name,
          tg.primary_job,
          tg.primary_site,
          tg.academic_year,
          tg.pm_term,
          tg.metric_label,
          tg.metric_value_stored,
          r.original_hire_date AS hire_date,
          r.business_unit
        FROM
          gabby.tableau.pm_teacher_goals AS tg
          LEFT JOIN gabby.people.staff_roster AS r ON (
            tg.df_employee_number = r.employee_number
          )
        WHERE
          tg.metric_label IN (
            'Excellent Teaching Rubric',
            'Self & Others'
          )
          AND tg.metric_value_stored IS NOT NULL
      ) AS sub PIVOT (
        MAX(metric_value_stored) FOR metric_label IN (
          [Excellent Teaching Rubric],
          [Self & Others]
        )
      ) AS p
  ) AS sub
