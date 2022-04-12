USE gabby
GO

CREATE OR ALTER VIEW extracts.mdcps_aces_survey AS

SELECT s.primary_job
      ,s.primary_site
      ,s.[status]
      ,s.first_name
      ,s.last_name
      ,s.position_id
      ,s.legal_entity_name
      ,s.df_employee_number
      ,s.original_hire_date
      ,s.flsa_status AS payclass
      ,s.[address]
      ,s.city
      ,s.[state]
      ,s.postal_code
      ,s.annual_salary
      ,s.userprincipalname
      ,s.termination_date

      ,cf.[Miami - ACES Number] AS miami_aces

      ,si.answer AS highest_education_level

      ,'2x Month' AS pay_frequency
      ,'' AS duty_days
      ,'N/A' AS teacher_eval
      ,'N/A' AS Contribution504B
      ,'B' AS BasicLifePlan
      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR()

FROM gabby.people.staff_crosswalk_static s
LEFT JOIN gabby.adp.workers_custom_field_group_wide_static cf
  ON s.adp_associate_id = cf.worker_id
LEFT JOIN gabby.surveys.staff_information_survey_detail si
  ON s.df_employee_number = si.employee_number
WHERE s.legal_entity_name = 'KIPP Miami'
  AND si.question_shortname = 'education_level'
  AND si.rn_cur = 1
  AND (YEAR(s.termination_date) IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(),gabby.utilities.GLOBAL_ACADEMIC_YEAR()+ 1) OR termination_date IS NULL)
ORDER BY s.[primary_site],s.last_name
