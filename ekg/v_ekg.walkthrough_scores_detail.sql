USE gabby
GO

CREATE OR ALTER VIEW ekg.walkthrough_scores_detail AS

WITH scores_unpivot AS (
  SELECT academic_year
        ,term_name AS reporting_term
        ,CASE
          WHEN LTRIM(RTRIM(school)) = 'Rise' THEN 73252
          WHEN LTRIM(RTRIM(school)) = 'NCA' THEN 73253
          WHEN LTRIM(RTRIM(school)) = 'SPARK' THEN 73254
          WHEN LTRIM(RTRIM(school)) = 'THRIVE' THEN 73255
          WHEN LTRIM(RTRIM(school)) = 'Seek' THEN 73256
          WHEN LTRIM(RTRIM(school)) = 'Life' THEN 73257
          WHEN LTRIM(RTRIM(school)) = 'BOLD' THEN 73258
          WHEN LTRIM(RTRIM(school)) = 'LSP' THEN 179901
          WHEN LTRIM(RTRIM(school)) = 'KSLP' THEN 179901
          WHEN LTRIM(RTRIM(school)) = 'LSM' THEN 179902
          WHEN LTRIM(RTRIM(school)) = 'KLSM ' THEN 179902
          WHEN LTRIM(RTRIM(school)) = 'KWM' THEN 179903
          WHEN LTRIM(RTRIM(school)) = 'TEAM' THEN 133570965
          WHEN LTRIM(RTRIM(school)) = 'WEK' THEN 1799015075
         END AS reporting_schoolid
        ,field
        ,pct_of_classrooms_proficient
  FROM gabby.ekg.walkthrough_scores_archive
  UNPIVOT(
    pct_of_classrooms_proficient
    FOR field IN (culture_arrival_dismissal
                 ,culture_bathrooms
                 ,culture_celebrations
                 ,culture_cell_phones
                 ,culture_character
                 ,culture_common_spaces
                 ,culture_dress_code
                 ,culture_engaged
                 ,culture_food_gum_candy
                 ,culture_hallways
                 ,culture_j_factor
                 ,culture_main_office
                 ,culture_mission_vision
                 ,culture_quiet_for_adults
                 ,culture_respect
                 ,culture_student_work
                 ,culture_transition_time
                 ,student_effective_redirections
                 ,student_on_task
                 ,student_one_hundred_percent
                 ,student_peer_interactions
                 ,student_quiet_for_adults
                 ,student_small_group_blended
                 ,student_speed_urgency
                 ,student_students_engaged
                 ,teacher_awareness
                 ,teacher_classroom_systems
                 ,teacher_cold_calls
                 ,teacher_criteria_for_success
                 ,teacher_daily_mastery
                 ,teacher_directions_expectations
                 ,teacher_discourse
                 ,teacher_effective_redirections
                 ,teacher_environment
                 ,teacher_evidence
                 ,teacher_flow_pacing
                 ,teacher_follow_up_and_response
                 ,teacher_formative_cfu
                 ,teacher_goal_objective
                 ,teacher_goals_connected
                 ,teacher_grade_level_expectations
                 ,teacher_individual
                 ,teacher_j_factor
                 ,teacher_key_message
                 ,teacher_mastery_awareness
                 ,teacher_objective_aim_agenda
                 ,teacher_question_quality
                 ,teacher_ratio
                 ,teacher_school_grade_systems
                 ,teacher_transitions
                 ,teacher_warm_demanding
                 ,teacher_whole_class_feedback)
   ) u
 )

SELECT reporting_schoolid
      ,academic_year
      ,reporting_term
      ,NULL AS domain
      ,ISNULL(field, 'overall') AS field
      ,AVG(pct_of_classrooms_proficient) AS pct_of_classrooms_proficient
FROM scores_unpivot
GROUP BY reporting_schoolid
        ,academic_year
        ,reporting_term
        ,CUBE(field)