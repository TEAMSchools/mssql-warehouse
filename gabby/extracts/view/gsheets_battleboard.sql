CREATE OR ALTER VIEW
  extracts.gsheets_battleboard AS
WITH
  elementary_grade AS (
    SELECT
      employee_number,
      MAX(student_grade_level) AS student_grade_level
    FROM
      pm.teacher_grade_levels
    GROUP BY
      employee_number
  ),
  etr_pivot AS (
    SELECT
      df_employee_number,
      academic_year,
      [PM1],
      [PM2],
      [PM3],
      [PM4]
    FROM
      (
        SELECT
          df_employee_number,
          academic_year,
          pm_term,
          overall_score
        FROM
          pm.teacher_goals_overall_scores_static
        WHERE
          academic_year >= utilities.GLOBAL_ACADEMIC_YEAR () - 1
      ) AS sub PIVOT (
        AVG(overall_score) FOR pm_term IN ([PM1], [PM2], [PM3], [PM4])
      ) AS p
  ),
  itr_pivot AS (
    SELECT
      respondent_df_employee_number,
      campaign_academic_year,
      [intent_to_return],
      [reason_for_leaving_primary],
      [reason_for_leaving_secondary],
      [transfer_1],
      [transfer_oe],
      [stay_oe],
      [anything_else_oe]
    FROM
      (
        SELECT
          respondent_df_employee_number,
          campaign_academic_year,
          question_shortname,
          answer
        FROM
          surveys.intent_to_return_survey_detail
      ) AS sub PIVOT (
        MAX(answer) FOR question_shortname IN (
          [intent_to_return],
          [reason_for_leaving_primary],
          [reason_for_leaving_secondary],
          [transfer_1],
          [transfer_oe],
          [stay_oe],
          [anything_else_oe]
        )
      ) AS p
  )
SELECT
  c.df_employee_number,
  c.[status],
  c.preferred_name,
  c.primary_site,
  c.primary_job,
  c.primary_on_site_department,
  c.mail,
  c.google_email,
  c.original_hire_date,
  ROUND(e.[PM1], 2) AS [PM1],
  ROUND(e.[PM2], 2) AS [PM2],
  ROUND(e.[PM3], 2) AS [PM3],
  ROUND(p.[PM4], 2) AS [Last Year Final],
  i.intent_to_return,
  i.reason_for_leaving_primary,
  i.reason_for_leaving_secondary,
  i.transfer_1,
  i.transfer_oe,
  i.stay_oe,
  i.anything_else_oe,
  CASE
    WHEN (
      c.primary_on_site_department = 'Elementary'
      AND g.student_grade_level IS NOT NULL
    ) THEN CONCAT(
      c.primary_on_site_department,
      ', Grade ',
      g.student_grade_level
    )
    ELSE c.primary_on_site_department
  END AS department_grade
FROM
  people.staff_crosswalk_static AS c
  LEFT JOIN etr_pivot AS e ON (
    c.df_employee_number = e.df_employee_number
    AND e.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  )
  LEFT JOIN etr_pivot AS p ON (
    c.df_employee_number = p.df_employee_number
    AND p.academic_year = utilities.GLOBAL_ACADEMIC_YEAR () - 1
  )
  LEFT JOIN elementary_grade AS g ON (
    c.df_employee_number = g.employee_number
  )
  LEFT JOIN itr_pivot AS i ON (
    c.df_employee_number = i.respondent_df_employee_number
    AND i.campaign_academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  )
WHERE
  c.[status] NOT IN ('TERMINATED')
