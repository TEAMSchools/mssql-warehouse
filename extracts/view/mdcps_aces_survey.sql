CREATE OR ALTER VIEW
  extracts.mdcps_aces_survey AS
SELECT
  s.primary_job,
  s.primary_site,
  s.[status],
  s.first_name,
  s.last_name,
  s.position_id,
  s.legal_entity_name,
  s.df_employee_number,
  s.original_hire_date,
  s.flsa_status AS payclass,
  s.address,
  s.city,
  s.state,
  s.postal_code,
  s.annual_salary,
  s.termination_date,
  e.education_level,
  cf.[Miami - ACES Number] AS miami_aces,
  '2x Month' AS pay_frequency,
  '' AS duty_days,
  'N/A' AS teacher_eval,
  'N/A' AS [Contribution504B],
  'B' AS [BasicLifePlan]
FROM
  gabby.people.staff_crosswalk_static AS s
  LEFT JOIN gabby.adp.workers_custom_field_group_wide_static AS cf ON s.adp_associate_id = cf.worker_id
  LEFT JOIN gabby.surveys.staff_information_survey_wide_static AS e ON s.df_employee_number = e.employee_number
WHERE
  s.legal_entity_name = 'KIPP Miami'
  AND (
    s.termination_date >= DATEFROMPARTS(
      gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
      07,
      01
    )
    OR s.termination_date IS NULL
  )
