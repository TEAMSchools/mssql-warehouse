USE gabby
GO

CREATE OR ALTER VIEW surveys.tech_ops_survey_final AS

WITH to_survey AS (
  SELECT sur.please_confirm_your_email_address_please_use_your_kippnj_org_address_for_tracking_purposes_only_ AS email
        ,sur.day_to_day_operations_at_my_school_run_smoothly_ AS ops_day_to_day_ops
        ,sur.procedures_at_my_school_maximize_the_time_students_spend_learning_ AS ops_procedures
        ,sur.when_i_need_something_at_my_school_i_know_who_to_ask_ AS ops_know_who_to_ask
        ,sur.my_school_s_systems_track_student_information_such_as_grading_attendance_testing_etc_in_a_way_that_is_useful_and_up_to_date_ AS ops_systems_track_student_info
        ,sur.my_school_building_is_clean_and_well_maintained_ AS ops_building_clean_maintained
        ,sur.non_academic_services_for_students_such_as_busses_and_school_meals_are_well_managed_ AS ops_nonacademic_services_well_managed
        ,sur.operations_at_my_school_are_managed_by_non_instructional_staff_so_i_can_focus_on_teaching_ AS ops_managed_by_non_instructional_staff
        ,sur.i_have_the_materials_and_equipment_to_do_my_work_right_ AS ops_materials
        ,sur.my_co_workers_are_committed_to_doing_quality_work_ AS ops_coworkers_do_quality_work
        ,sur.communication_from_the_tech_team_is_effective_expectations_are_clearly_set_information_is_helpful_and_the_team_is_customer_serv AS tech_communication
        ,sur.my_requests_for_tech_support_are_resolved_appropriately AS tech_requests
        ,sur.i_can_consistently_rely_on_the_following_technology_in_my_school_my_own_staff_computer AS tech_staff_computer
        ,sur.i_can_consistently_rely_on_the_following_technology_in_my_school_student_devices AS tech_student_devices
        ,sur.i_can_consistently_rely_on_the_following_technology_in_my_school_av_projectors_document_cameras_interactive_smart_boards AS tech_hardware
        ,sur.i_can_consistently_rely_on_the_following_technology_in_my_school_copiers AS tech_copiers
        ,sur.i_can_consistently_rely_on_the_following_technology_in_my_school_printers AS tech_printers
        ,sur.i_submit_a_ticket_for_my_technology_requests_ AS tech_submit_tickets
        ,sur.i_would_like_tech_training_on_ AS tech_training
        ,sur.is_there_anything_else_you_d_like_the_operations_or_technology_teams_to_know_ AS tech_oe
        ,sur._system_date_system_time_
        ,sur.url_redirect
        ,CASE 
          WHEN MONTH(CONVERT(DATE,sur.date_submitted)) < 6 THEN 'spring'
          ELSE 'fall'
         END AS term_name
        ,gabby.utilities.DATE_TO_SY(sur.date_submitted) AS academic_year
       
        ,adsi.idautopersonalternateid AS associate_id

        ,roster.location_custom AS location
  FROM gabby.surveys.tech_ops_survey sur
  LEFT JOIN gabby.adsi.user_attributes_static adsi
    ON sur.please_confirm_your_email_address_please_use_your_kippnj_org_address_for_tracking_purposes_only_ = adsi.mail
  LEFT JOIN gabby.adp.staff_roster roster
    ON adsi.idautopersonalternateid = roster.associate_id
 )

,to_long AS (
  SELECT term_name
        ,academic_year
        ,email
        ,associate_id
        ,location
        ,question
        ,response
  FROM to_survey
  UNPIVOT( 
    response
    FOR question in (ops_day_to_day_ops
                    ,ops_procedures
                    ,ops_know_who_to_ask
                    ,ops_systems_track_student_info
                    ,ops_building_clean_maintained
                    ,ops_nonacademic_services_well_managed
                    ,ops_managed_by_non_instructional_staff
                    ,ops_materials
                    ,ops_coworkers_do_quality_work
                    ,tech_communication
                    ,tech_requests
                    ,tech_staff_computer
                    ,tech_student_devices
                    ,tech_hardware
                    ,tech_copiers
                    ,tech_printers
                    ,tech_submit_tickets
                    ,tech_training
                    ,tech_oe)
  ) u
 )
 
SELECT term_name
      ,academic_year
      ,location
      ,question
      ,response AS response_text
      ,CASE         
        WHEN response IN ('Strongly Agree','Always') THEN 5
        WHEN response = 'Agree' THEN 4
        WHEN response IN ('Neutral','Sometimes') THEN 3
        WHEN response = 'Disagree' THEN 2
        WHEN response IN ('Strongly Disagree','Never') THEN 1
       END AS response_value     
      ,CASE
        WHEN question IN ('tech_training', 'tech_oe') THEN 'oe'
        WHEN question = 'tech_submit_tickets' THEN 'frequency'
        ELSE 'likert'
       END AS response_type
      ,associate_id
FROM to_long