CREATE OR ALTER VIEW
  pm.teacher_goals_overall_scores AS
SELECT
  sub.df_employee_number,
  sub.preferred_name,
  sub.business_unit AS legal_entity_name,
  sub.hire_date,
  sub.primary_job,
  sub.primary_site,
  sub.academic_year,
  sub.pm_term,
  sub.etr_score,
  sub.so_score,
  sub.overall_score,
  CASE
    WHEN sub.etr_score >= 3.495 THEN 4
    WHEN sub.etr_score >= 2.745 THEN 3
    WHEN sub.etr_score >= 1.745 THEN 2
    WHEN sub.etr_score < 1.745 THEN 1
  END AS etr_tier,
  CASE
    WHEN sub.so_score >= 3.495 THEN 4
    WHEN sub.so_score >= 2.995 THEN 3
    WHEN sub.so_score >= 1.995 THEN 2
    WHEN sub.so_score < 1.995 THEN 1
  END AS so_tier,
  CASE
    WHEN sub.overall_score >= 3.495 THEN 4
    WHEN sub.overall_score >= 2.745 THEN 3
    WHEN sub.overall_score >= 1.745 THEN 2
    WHEN sub.overall_score < 1.745 THEN 1
  END AS overall_tier
FROM
  (
    SELECT
      p.df_employee_number,
      p.preferred_name,
      p.business_unit,
      p.hire_date,
      p.primary_job,
      p.primary_site,
      p.academic_year,
      p.pm_term,
      p.[Excellent Teaching Rubric] AS etr_score,
      p.[Self & Others] AS so_score,
      COALESCE(
        (
          p.[Excellent Teaching Rubric] * 0.8
        ) + (p.[Self & Others] * 0.2),
        p.[Self & Others],
        p.[Excellent Teaching Rubric]
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
          LEFT JOIN gabby.people.staff_roster AS r ON tg.df_employee_number = r.employee_number
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
