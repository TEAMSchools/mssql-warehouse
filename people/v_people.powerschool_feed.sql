USE gabby
GO

CREATE OR ALTER VIEW gabby.people.powerschool_feed AS

SELECT sr.employee_number AS local_staff_identifier
      ,NULL AS staff_member_identifier
      ,NULL AS ssn
      ,NULL AS name_prefix
      ,sr.first_name
      ,sr.last_name
      ,NULL AS former_name
      ,sr.preferred_gender AS sex
      ,sr.birth_date AS date_of_birth
      ,sr.is_hispanic AS ethnicity
      ,sr.is_race_asian
      ,sr.is_race_black
      ,sr.is_race_nhpi
      ,sr.is_race_white
      ,NULL AS certification_status
      ,CASE WHEN sr.position_status = 'Terminated' THEN 'I' ELSE 'A' END AS [status]
      ,original_hire_date AS district_employment_entry_date
      ,NULL AS entry_code
      ,termination_date AS district_employment_exit_date
      ,NULL AS gifted_and_talented
      
      ,sr.annual_salary AS salary
      ,si.language AS languages_spoken
      ,NULL AS migrant_education_program_category
      ,NULL AS mep_session_type
      ,NULL AS title_1_program_category
      ,sr.education_level AS highest_level_of_eduction
      ,NULL AS national_board_award
      ,NULL AS sep_program_contract_category
      ,NULL AS ell_instructor_credit_type
      ,sr.years_of_professional_experience_before_joining
      ,sr.years_teaching_in_nj_or_fl
      ,sr.years_at_kipp_total
      ,NULL AS traditional_route_program
      ,NULL AS alternative_route_program
FROM gabby.people.staff_roster sr
JOIN gabby.surveys.staff_information_survey_wide_static si
  ON sr.employee_number = si.employee_number