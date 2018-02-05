USE gabby
GO

CREATE OR ALTER VIEW surveys.exit_survey_detail AS

SELECT adp.associate_id
      ,adp.termination_date
      ,adp.termination_reason_description
      ,adp.job_title_description
      ,adp.birth_date
      ,adp.eeo_ethnic_description
      ,adp.subject_dept_custom
      ,adp.benefits_eligibility_class_description
      ,adp.is_management
      ,adp.gender
      ,adp.hire_date
      ,adp.position_status      
      ,adp.primary_address_city
      ,adp.primary_address_state_territory_code
      ,adp.primary_address_zip_postal_code
      ,COALESCE(adp.location_custom, adp.location_description) AS location
      ,COALESCE(adp.manager_name, adp.reports_to_name) AS manager
      ,MONTH(adp.hire_date) AS hire_month
      ,COALESCE(YEAR(adp.termination_date), YEAR(GETDATE())) - YEAR(adp.hire_date) + 1 AS years_at_kipp
      ,gabby.utilities.DATE_TO_SY(adp.termination_date) AS termination_academic_year
	
      ,es.timestamp AS exit_survey_date
      ,es.q_1 AS exit_survey_title
      ,es.q_2 AS exit_survey_location
      ,es.q_3 AS nps
      ,es.q_4 AS nps_explanation
      ,es.q_5	AS voluntary_termination
      ,es.q_6 AS exit_survey_reason_for_leaving
      ,es.q_7 AS next_role
      ,es.q_8 AS next_title
      ,es.q_9 AS expectation_alignment
      ,es.q_10 AS open_comment
      ,es.q_11 AS anonymous
      ,es.q_12 AS consider_kipp_in_future
      ,es.q_13 AS what_does_kipp_do_well
      ,es.q_14 AS how_can_kipp_improve
      ,es.q_15 AS rating_career_growth
      ,es.q_16 AS rating_schedule_flexibility
      ,es.q_17 AS rating_compensation_benefits
      ,es.q_18 AS rating_school_culture
      ,es.q_19 AS rating_immediate_principal_supervisor
      ,es.q_20 AS rating_kid_focus
      ,es.q_21 AS rating_impact
      ,es.q_22 AS rating_improvement
      ,es.q_23 AS rating_freedom
      ,es.q_24 AS rating_fun
      ,es.q_25 AS rating_teamwork	     
FROM gabby.adp.staff_roster adp 
JOIN gabby.surveys.exit_survey es
  ON adp.associate_id = es.associate_id
WHERE adp.rn_curr = 1