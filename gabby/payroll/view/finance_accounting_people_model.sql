CREATE OR ALTER VIEW
  payroll.finance_accounting_people_model AS
WITH
  years AS (
    SELECT
      n AS academic_year,
      CASE
        WHEN (
          n = utilities.GLOBAL_ACADEMIC_YEAR ()
        ) THEN CAST(CURRENT_TIMESTAMP AS DATE)
        ELSE DATEFROMPARTS((n + 1), 4, 30)
      END AS effective_date
    FROM
      utilities.row_generator_smallint
    WHERE
      (
        n BETWEEN 2015 AND (
          utilities.GLOBAL_ACADEMIC_YEAR ()
        )
      )
  ),
  additional_earnings AS (
    SELECT
      employee_number,
      academic_year,
      SUM(ay_additional_earnings_amount) AS additional_earnings_summed
    FROM
      payroll.additional_annual_earnings_report
    GROUP BY
      employee_number,
      academic_year
  ),
  teacher_goals AS (
    SELECT
      df_employee_number,
      academic_year,
      pm_term,
      overall_tier,
      CASE
        WHEN (
          academic_year != utilities.GLOBAL_ACADEMIC_YEAR ()
          AND pm_term = 'PM4'
        ) THEN 1
        WHEN (
          academic_year != utilities.GLOBAL_ACADEMIC_YEAR ()
          AND pm_term != 'PM4'
        ) THEN NULL
        ELSE ROW_NUMBER() OVER (
          PARTITION BY
            df_employee_number,
            academic_year
          ORDER BY
            pm_term DESC
        )
      END AS rn_year_score
    FROM
      pm.teacher_goals_overall_scores_static
  )
SELECT
  cw.df_employee_number AS employee_number,
  cw.adp_associate_id,
  cw.position_id,
  cw.payroll_company_code AS company_code,
  cw.file_number,
  cw.preferred_first_name,
  cw.preferred_last_name,
  cw.first_name AS legal_first_name,
  cw.last_name AS legal_last_name,
  cw.primary_race_ethnicity_reporting,
  cw.gender,
  cw.is_manager,
  cw.original_hire_date,
  cw.rehire_date,
  cw.[status] AS current_status,
  cw.termination_date,
  y.academic_year,
  eh.effective_start_date,
  eh.effective_end_date,
  eh.business_unit,
  eh.[location],
  eh.home_department,
  eh.job_title,
  eh.position_status,
  eh.annual_salary,
  ae.additional_earnings_summed,
  /* if year is over, displays PM4 score */
  tg.overall_tier AS most_recent_pm_score,
  ye.years_at_kipp_total AS years_at_kipp_total_current,
  ye.years_teaching_total AS years_teaching_total_current,
  ly.business_unit AS last_year_business_unit,
  ly.job_title AS last_year_job_title,
  ehs.annual_salary AS original_salary_upon_hire,
  ROW_NUMBER() OVER (
    PARTITION BY
      cw.df_employee_number
    ORDER BY
      y.academic_year DESC,
      eh.position_status ASC
  ) AS rn_curr,
  ce.is_certified AS is_currently_certified_nj_only
FROM
  people.employment_history_static AS eh
  INNER JOIN years AS y ON (
    (
      y.effective_date BETWEEN eh.effective_start_date AND eh.effective_end_date
    )
  )
  INNER JOIN people.staff_crosswalk_static AS cw ON (
    eh.employee_number = cw.df_employee_number
    AND DATEADD(
      YEAR,
      1,
      COALESCE(
        cw.termination_date,
        CAST(CURRENT_TIMESTAMP AS DATE)
      )
    ) > y.effective_date
  )
  INNER JOIN people.years_experience AS ye ON (
    cw.df_employee_number = ye.employee_number
  )
  LEFT JOIN additional_earnings AS ae ON (
    cw.df_employee_number = ae.employee_number
    AND y.academic_year = ae.academic_year
  )
  LEFT JOIN teacher_goals AS tg ON (
    eh.employee_number = tg.df_employee_number
    AND y.academic_year = tg.academic_year
    AND tg.rn_year_score = 1
  )
  LEFT JOIN people.employment_history_static AS ly ON (
    cw.df_employee_number = ly.employee_number
    AND (
      (
        DATEADD(YEAR, -1, y.effective_date)
      ) BETWEEN ly.effective_start_date AND ly.effective_end_date
    )
  )
  LEFT JOIN people.employment_history_static AS ehs ON (
    cw.df_employee_number = ehs.employee_number
    AND (
      cw.original_hire_date BETWEEN ehs.effective_start_date AND ehs.effective_end_date
    )
    AND ehs.position_status = 'Active'
  )
  LEFT JOIN njdoe.cert_export AS ce ON (
    cw.df_employee_number = ce.employee_id
  )
