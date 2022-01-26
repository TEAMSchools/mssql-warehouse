USE gabby
GO

--CREATE OR ALTER VIEW extracts.mdcps_aces_survey AS

SELECT sr.job_title 
      ,sr.[location]
      ,sr.position_status
      ,sr.first_name
      ,sr.last_name
      ,sr.position_id
      ,sr.business_unit
      ,sr.employee_number
      ,sr.original_hire_date
      ,cf.[Miami - ACES Number] AS miami_aces
      ,sr.flsa AS payclass
      ,'2x Month' AS pay_frequency
      ,NULL AS highest_education_level
      ,NULL AS duty_days
      ,'N/A' AS teacher_eval
      ,sr.address_street
      ,sr.address_city
      ,sr.address_state
      ,sr.address_zip
      ,NULL AS MonthlyCarrierCost
      ,NULL AS MedicalCoverage
      ,'N/A' AS Contribution504B
      ,'B' AS BasicLifePlan
      ,sr.annual_salary
      ,sr.position_effective_start_date
      ,sr.termination_date
FROM gabby.people.staff_roster sr
LEFT JOIN gabby.adp.workers_custom_field_group_wide_static cf
  ON sr.employee_number = cf.[Employee Number]
WHERE sr.business_unit = 'KIPP Miami'
