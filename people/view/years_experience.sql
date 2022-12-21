CREATE OR ALTER VIEW
  people.years_experience AS
WITH
  days_active AS (
    SELECT
      employee_number,
      ISNULL(active, 0) AS days_active,
      ISNULL(inactive, 0) AS days_inactive
    FROM
      (
        SELECT
          employee_number,
          CASE
            WHEN position_status = 'Active' THEN 'active'
            ELSE 'inactive'
          END AS status_clean,
          DATEDIFF(
            DAY,
            effective_start_date,
            CASE
              WHEN (
                effective_end_date > CAST(CURRENT_TIMESTAMP AS DATE)
              ) THEN CAST(CURRENT_TIMESTAMP AS DATE)
              ELSE effective_end_date
            END
          ) AS [days]
        FROM
          gabby.people.employment_history_static
        WHERE
          position_status NOT IN ('Terminated', 'Pre-Start')
          AND job_title != 'Intern'
      ) AS sub PIVOT (
        SUM([days]) FOR status_clean IN (active, inactive)
      ) AS p
  ),
  years_teaching_at_kipp AS (
    SELECT
      employee_number,
      SUM(
        DATEDIFF(
          DAY,
          effective_start_date,
          effective_end_date
        )
      ) AS days_as_teacher
    FROM
      gabby.people.employment_history_static
    WHERE
      position_status NOT IN ('Terminated', 'Pre-Start')
      AND job_title IN (
        'Teacher',
        'Learning Specialist',
        'Learning Specialist Coordinator',
        'Teacher in Residence',
        'Teacher, ESL',
        'Teacher ESL',
        'Co-Teacher'
      )
    GROUP BY
      employee_number
  )
SELECT
  d.employee_number,
  ROUND(d.days_active / 365.25, 2) AS years_active_at_kipp,
  ROUND(d.days_inactive / 365.25, 2) AS years_inactive_at_kipp,
  (
    ROUND(d.days_active / 365.25, 2) + ROUND(d.days_inactive / 365.25, 2)
  ) AS years_at_kipp_total,
  ISNULL((y.days_as_teacher / 365.25), 0) AS years_teaching_at_kipp,
  sdf.years_teaching_any_state AS years_teaching_prior_to_kipp,
  sdf.[professional_experience_before_KIPP] AS years_experience_prior_to_kipp,
  (
    ISNULL((y.days_as_teacher / 365.25), 0) + ISNULL(sdf.years_teaching_any_state, 0)
  ) AS years_teaching_total,
  ROUND(d.days_active / 365.25, 2) + ROUND(d.days_inactive / 365.25, 2) + ISNULL(
    sdf.[professional_experience_before_KIPP],
    0
  ) AS years_experience_total
FROM
  days_active AS d
  LEFT JOIN years_teaching_at_kipp AS y ON (
    d.employee_number = y.employee_number
  )
  LEFT JOIN gabby.surveys.staff_information_survey_wide_static AS sdf ON (
    d.employee_number = sdf.employee_number
  )
