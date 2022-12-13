USE gabby GO
CREATE OR ALTER VIEW
  tableau.miami_teacher_evaluation AS
WITH
  job_last_year AS (
    SELECT
      employee_number,
      job_title AS last_year_job,
      work_assignment_start_date,
      ROW_NUMBER() OVER (
        PARTITION BY
          employee_number
        ORDER BY
          work_assignment_start_date DESC
      ) AS rn_latest
    FROM
      gabby.people.employment_history_static
    WHERE
      business_unit_code = 'KIPP_MIAMI'
      AND work_assignment_start_date <= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR (), 6, 30)
  )
SELECT
  c.df_employee_number,
  c.preferred_name,
  c.[status],
  c.primary_site,
  c.primary_job,
  c.original_hire_date,
  c.termination_date,
  w.[Miami - ACES Number],
  w.[Years Teaching - In any State],
  s.overall_tier,
  j.last_year_job,
  CASE
    WHEN s.overall_tier = 4 THEN 'C'
    WHEN s.overall_tier = 3 THEN 'D'
    WHEN s.overall_tier = 2
    AND w.[Years Teaching - In any State] >= 2 THEN 'E'
    WHEN s.overall_tier = 2
    AND w.[Years Teaching - In any State] <= 3 THEN 'F'
    WHEN s.overall_tier = 2
    AND c.original_hire_date <= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 2, 6, 30) THEN 'E'
    WHEN s.overall_tier = 2
    AND c.original_hire_date <= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 3, 6, 30) THEN 'F'
    WHEN s.overall_tier = 1 THEN 'G'
    WHEN c.primary_job NOT IN (
      'Teacher',
      'Teacher in Residence',
      'Learning Specialist',
      'Assistant School Leader',
      'School Leader',
      'Dean of Students'
    ) THEN 'Z'
    ELSE 'I'
  END AS personnel_evaluation,
  '2332' AS school_number
FROM
  gabby.people.staff_crosswalk_static c
  LEFT JOIN gabby.adp.workers_custom_field_group_wide_static w ON c.df_employee_number = w.[Employee Number]
  LEFT JOIN gabby.pm.teacher_goals_overall_scores_static s ON c.df_employee_number = s.df_employee_number
  AND s.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1
  AND s.pm_term = 'PM4'
  LEFT JOIN job_last_year j ON c.df_employee_number = j.employee_number
  AND j.rn_latest = 1
WHERE
  c.legal_entity_name = 'KIPP Miami'
  AND c.original_hire_date <= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR (), 6, 30)
