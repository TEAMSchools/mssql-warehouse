USE gabby
GO

CREATE OR ALTER VIEW extracts.mdcps_aces_survey AS

SELECT job_title 
      ,[location]
      ,position_status
      ,first_name
      ,last_name
      ,NULL AS SSN
      ,position_id
      ,business_unit
      ,employee_number
      ,original_hire_date
      ,NULL AS miami_aces
      ,flsa AS payclass
      ,NULL AS pay_frequency
      ,NULL AS highest_education_level
      ,NULL AS duty_days
      ,NULL AS teacher_eval
      ,address_street
      ,address_city
      ,address_state
      ,address_zip
      ,NULL AS MonthlyCarrierCost
      ,NULL AS MedicalCoverage
      ,NULL AS Contribution504B
      ,NULL AS BasicLifePlan
      ,annual_salary
FROM gabby.people.staff_roster
WHERE business_unit = 'KIPP Miami'
  AND position_status <> 'Terminated'
  
