USE gabby;
GO

CREATE OR ALTER VIEW surveys.cmo_survey_final AS

WITH cmo_survey AS (
  SELECT sur.df_id AS df_employee_number
        ,sur.your_email_address_for_tracking_purposes_ AS email
        ,sur.date_submitted AS date_submitted
        ,sur.time_started AS time_started
        ,sur.job_position AS primary_job
        ,sur.location AS primary_site        
        ,CASE WHEN MONTH(CAST(sur.date_submitted AS DATE)) < 6 THEN 'spring' ELSE 'fall' END AS term_name
        ,gabby.utilities.DATE_TO_SY(sur.date_submitted) AS academic_year

        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_accounts_payable_team_could_improve_) AS accounts_payable_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_accounts_payable_team_is_effective) AS accounts_payable_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_accounts_payable_team_does_that_s_effective_) AS accounts_payable_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_accounts_payable_team_) AS accounts_payable_expect
        ,CONVERT(VARCHAR(MAX), sur.have_you_identified_any_gaps_that_could_be_filled_with_cmo_support_or_oversight_) AS cmo_gaps_oe
        ,CONVERT(VARCHAR(MAX), sur.the_cmo_is_headed_in_the_right_direction_) AS cmo_right_direction
        ,CONVERT(VARCHAR(MAX), sur.i_always_feel_like_cmo_departments_and_my_school_region_are_on_the_same_team_or_working_toward_the_same_big_goals_) AS cmo_team_goals
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_compliance_team_could_improve_) AS compliance_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_compliance_team_is_effective) AS compliance_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_compliance_team_does_that_s_effective_) AS compliance_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_compliance_team_) AS compliance_expect
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_data_team_is_effective) AS data_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_data_team_does_that_s_effective_) AS data_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_data_team_) AS data_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_data_team_could_improve_) AS data_improve_oe        
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_employee_relations_team_is_effective) AS employee_relations_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_employee_relations_team_does_that_s_effective_) AS employee_relations_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_employee_relations_team_) AS employee_relations_expect
        ,CONVERT(VARCHAR(MAX), sur.i_know_who_my_hr_manager_is_and_how_to_access_her_regarding_employment_issues_) AS employee_relations_hrmanager
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_employee_relations_team_could_improve_) AS employee_relations_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_regional_enrollment_team_is_effective) AS enrollment_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_regional_enrollment_team_does_that_s_effective_) AS enrollment_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_our_regional_enrollment_team_) AS enrollment_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_regional_enrollment_team_could_improve_) AS enrollment_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_facilities_team_is_effective) AS facilities_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_facilities_team_does_that_s_effective_) AS facilities_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_facilities_team_) AS facilities_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_facilities_team_could_improve_) AS facilities_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_finance_team_is_effective) AS finance_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_finance_team_does_that_s_effective_) AS finance_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_finance_team_) AS finance_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_finance_team_could_improve_) AS finance_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_human_resources_team_is_effective) AS human_resources_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_human_resources_team_does_that_s_effective_) AS human_resources_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_human_resources_team_) AS human_resources_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_human_resources_team_could_improve_) AS human_resources_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_marketing_team_is_effective) AS marketing_communication
        ,CONVERT(VARCHAR(MAX), sur.i_receive_the_support_guidance_needed_for_communications_in_times_of_crisis_) AS marketing_crisis
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_marketing_team_does_that_s_effective_) AS marketing_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_marketing_team_) AS marketing_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_marketing_team_could_improve_) AS marketing_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.i_know_what_support_to_expect_from_the_aramark_team_at_my_school_) AS nutrition_aramark
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_nutrition_team_is_effective) AS nutrition_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_nutrition_team_does_that_s_effective_) AS nutrition_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_nutrition_team_) AS nutrition_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_nutrition_team_could_improve_) AS nutrition_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.please_provide_details_for_any_survey_responses_that_would_benefit_from_additional_context_) AS overall_details_oe
        ,CONVERT(VARCHAR(MAX), sur.what_else_if_anything_do_you_wish_we_had_asked_you_in_this_survey_about_the_support_you_receive_from_cmo_teams_) AS overall_questions_oe        
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_purchasing_team_is_effective) AS purchasing_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_purchasing_team_does_that_s_effective_) AS purchasing_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_purchasing_team_) AS purchasing_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_purchasing_team_could_improve_) AS purchasing_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_real_estate_team_is_effective) AS real_estate_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_real_estate_team_does_that_s_effective_) AS real_estate_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_real_estate_team_) AS real_estate_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_real_estate_team_could_improve_) AS real_estate_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_recruitment_team_is_effective) AS recruitment_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_recruitment_team_does_that_s_effective_) AS recruitment_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_recruitment_team_) AS recruitment_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_recruitment_team_could_improve_) AS recruitment_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_special_education_team_is_effective) AS special_education_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_special_education_team_does_that_s_effective_) AS special_education_effective_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_special_education_team_) AS special_education_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_special_education_team_could_improve_) AS special_education_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.assessments_provided_by_the_teaching_learning_team_are_accurate_error_free_and_provide_valuable_data) AS teaching_learning_assessments
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_teaching_learning_team_is_effective) AS teaching_learning_communication
        ,CONVERT(VARCHAR(MAX), sur.curriculum_provided_by_the_teaching_learning_team_is_rigorous_and_aligned_to_standards_) AS teaching_learning_curriculum
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_teaching_learning_team_does_that_s_effective_) AS teaching_learning_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_teaching_learning_team_) AS teaching_learning_expect
        ,CONVERT(VARCHAR(MAX), sur.the_teaching_learning_team_has_helped_my_school_improve_our_results_and_our_students_experience_) AS teaching_learning_help
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_teaching_learning_team_could_improve_) AS teaching_learning_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.i_am_familiar_with_and_invested_in_the_instructional_vision_of_kipp_new_jersey_kipp_miami_) AS teaching_learning_vision
        ,CONVERT(VARCHAR(MAX), sur.communication_from_the_technology_team_is_effective) AS technology_communication
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_technology_team_does_that_s_effective_) AS technology_effective_oe
        ,CONVERT(VARCHAR(MAX), sur.i_receive_what_i_expect_from_the_technology_team_) AS technology_expect
        ,CONVERT(VARCHAR(MAX), sur.what_is_one_thing_the_technology_team_could_improve_) AS technology_improve_oe
        ,CONVERT(VARCHAR(MAX), sur.i_can_rely_on_my_region_s_network_internet_access_cmo_sla_available_at_least_99_overall_) AS technology_internetaccess
  FROM surveys.cmo_survey sur
 )

,cmo_long AS (
  SELECT df_employee_number
        ,email
        ,academic_year
        ,term_name
        ,primary_site
        ,primary_job
        ,question
        ,response
  FROM cmo_survey
  UNPIVOT (
    response
    FOR question IN (accounts_payable_improve_oe
                    ,accounts_payable_communication
                    ,accounts_payable_effective_oe
                    ,accounts_payable_expect
                    ,cmo_gaps_oe
                    ,cmo_right_direction
                    ,cmo_team_goals
                    ,compliance_improve_oe
                    ,compliance_communication
                    ,compliance_effective_oe
                    ,compliance_expect
                    ,data_communication
                    ,data_effective_oe
                    ,data_expect
                    ,data_improve_oe
                    ,employee_relations_communication
                    ,employee_relations_effective_oe
                    ,employee_relations_expect
                    ,employee_relations_hrmanager
                    ,employee_relations_improve_oe
                    ,enrollment_communication
                    ,enrollment_effective_oe
                    ,enrollment_expect
                    ,enrollment_improve_oe
                    ,facilities_communication
                    ,facilities_effective_oe
                    ,facilities_expect
                    ,facilities_improve_oe
                    ,finance_communication
                    ,finance_effective_oe
                    ,finance_expect
                    ,finance_improve_oe
                    ,human_resources_communication
                    ,human_resources_effective_oe
                    ,human_resources_expect
                    ,human_resources_improve_oe
                    ,marketing_communication
                    ,marketing_crisis
                    ,marketing_effective_oe
                    ,marketing_expect
                    ,marketing_improve_oe
                    ,nutrition_aramark
                    ,nutrition_communication
                    ,nutrition_effective_oe
                    ,nutrition_expect
                    ,nutrition_improve_oe
                    ,overall_details_oe
                    ,overall_questions_oe
                    ,purchasing_communication
                    ,purchasing_effective_oe
                    ,purchasing_expect
                    ,purchasing_improve_oe
                    ,real_estate_communication
                    ,real_estate_effective_oe
                    ,real_estate_expect
                    ,real_estate_improve_oe
                    ,recruitment_communication
                    ,recruitment_effective_oe
                    ,recruitment_expect
                    ,recruitment_improve_oe
                    ,special_education_communication
                    ,special_education_effective_effective_oe
                    ,special_education_expect
                    ,special_education_improve_oe
                    ,teaching_learning_assessments
                    ,teaching_learning_communication
                    ,teaching_learning_curriculum
                    ,teaching_learning_effective_oe
                    ,teaching_learning_expect
                    ,teaching_learning_help
                    ,teaching_learning_improve_oe
                    ,teaching_learning_vision
                    ,technology_communication
                    ,technology_effective_oe
                    ,technology_expect
                    ,technology_improve_oe
                    ,technology_internetaccess)
   ) u
 )

SELECT cmo_long.df_employee_number
      ,cmo_long.email
      ,cmo_long.academic_year
      ,cmo_long.term_name
      ,cmo_long.primary_site
      ,cmo_long.primary_job
      ,cmo_long.question
      ,cmo_long.response AS response_text

      ,CASE WHEN RIGHT(cmo_long.question, 2) = 'oe' THEN 1 ELSE 0 END AS is_oe
      ,CASE
        WHEN cmo_long.response = 'Strongly Agree' THEN 4
        WHEN cmo_long.response = 'Agree' THEN 3
        WHEN cmo_long.response = 'Disagree' THEN 2
        WHEN cmo_long.response = 'Strongly Disagree' THEN 1
       END AS response_value
FROM cmo_long
WHERE cmo_long.response <> ''