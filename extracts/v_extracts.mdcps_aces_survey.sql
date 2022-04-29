USE gabby
GO

CREATE OR ALTER VIEW extracts.mdcps_aces_survey AS

SELECT s.job_title
      ,s.[location]
      ,s.position_status
      ,s.termination_date
      ,s.first_name
      ,s.last_name
      ,s.position_id
      ,s.business_unit
      ,s.employee_number
      ,s.original_hire_date
      ,s.flsa AS payclass
      ,s.address_street
      ,s.address_city
      ,s.address_state
      ,s.address_zip
      ,s.annual_salary
      ,s.education_level

      ,cf.[Miami - ACES Number] AS miami_aces

      ,'2x Month' AS pay_frequency
      ,'' AS duty_days
      ,'N/A' AS teacher_eval
      ,'N/A' AS Contribution504B
      ,'B' AS BasicLifePlan
FROM gabby.people.staff_roster s
INNER JOIN gabby.adp.workers_custom_field_group_wide_static cf
  ON s.associate_id = cf.worker_id
WHERE s.business_unit = 'KIPP Miami'
  AND (s.termination_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) OR s.termination_date IS NULL)
