USE gabby GO
CREATE OR ALTER VIEW
  ekg.walkthrough_scores_detail AS
WITH
  archive_unpivot AS (
    SELECT
      academic_year,
      term_name AS reporting_term,
      CAST(rubric_strand_field AS VARCHAR(250)) AS rubric_strand_field,
      pct_of_classrooms_proficient,
      LTRIM(RTRIM(school)) AS school
    FROM
      gabby.ekg.walkthrough_scores_archive UNPIVOT (
        pct_of_classrooms_proficient FOR rubric_strand_field IN (
          culture_arrival_dismissal,
          culture_bathrooms,
          culture_celebrations,
          culture_cell_phones,
          culture_character,
          culture_common_spaces,
          culture_dress_code,
          culture_engaged,
          culture_food_gum_candy,
          culture_hallways,
          culture_j_factor,
          culture_main_office,
          culture_mission_vision,
          culture_quiet_for_adults,
          culture_respect,
          culture_student_work,
          culture_transition_time,
          student_effective_redirections,
          student_on_task,
          student_one_hundred_percent,
          student_peer_interactions,
          student_quiet_for_adults,
          student_small_group_blended,
          student_speed_urgency,
          student_students_engaged,
          teacher_awareness,
          teacher_classroom_systems,
          teacher_cold_calls,
          teacher_criteria_for_success,
          teacher_daily_mastery,
          teacher_directions_expectations,
          teacher_discourse,
          teacher_effective_redirections,
          teacher_environment,
          teacher_evidence,
          teacher_flow_pacing,
          teacher_follow_up_and_response,
          teacher_formative_cfu,
          teacher_goal_objective,
          teacher_goals_connected,
          teacher_grade_level_expectations,
          teacher_individual,
          teacher_j_factor,
          teacher_key_message,
          teacher_mastery_awareness,
          teacher_objective_aim_agenda,
          teacher_question_quality,
          teacher_ratio,
          teacher_school_grade_systems,
          teacher_transitions,
          teacher_warm_demanding,
          teacher_whole_class_feedback
        )
      ) u
  ),
  current_unpivot AS (
    SELECT
      school
    COLLATE Latin1_General_BIN AS school,
    academic_year,
    reporting_term
    COLLATE Latin1_General_BIN AS reporting_term,
    am_pm,
    CAST(rubric_strand_field AS VARCHAR(250)) AS rubric_strand_field,
    pct_of_classrooms_proficient
    FROM
      gabby.ekg.walkthrough_scores UNPIVOT (
        pct_of_classrooms_proficient FOR rubric_strand_field IN (
          overallaverage,
          threecsaverage,
          rtwksadaverage,
          studentobservableaverage,
          teacherobservableaverage,
          schooloperationsaverage,
          schoolwidecultureaverage,
          accountabletalkduringdiscourseso,
          activelisteningengagementso,
          breakfastorlunchroutines,
          builddiscourse,
          celebrations,
          CHARACTER,
          clarityofcfsobjectives,
          clarityofcontentdelivery,
          cleanlinessbathrooms,
          cleanlinessclassrooms,
          cleanlinesshallwaypublicspaces,
          cleanlinessoffice,
          coldcall,
          directions,
          engagementjoyfromteacher,
          expectations,
          feedbacktokids,
          flexibility,
          flowpacing,
          individualrelationships,
          keymessages,
          kidsknowwhattodoso,
          lessonlaunchframing,
          missionvision,
          monitoringofbehavior,
          movementso,
          onehundredpctnooptout,
          ontaskso,
          persistthroughstruggleso,
          questioninglevel,
          realtimefeedbackandsupport,
          respectadultsso,
          respectfulsupportiveinteractionsso,
          respectpeersso,
          respectwithkids,
          responsivecorrections,
          rightisright,
          routinesprocedures,
          showcall,
          studentevaluationsso,
          studentworkdisplay,
          transitionprocedures,
          turntalks,
          uninterruptedlearning,
          upholdexpectations,
          urgency,
          urgentlymonitor,
          volumeso,
          warmdemanding,
          wholegrouprelationships,
          worthwhiletaskpractice
        )
      ) u
  ),
  scores_union AS (
    SELECT
      school,
      academic_year,
      reporting_term,
      rubric_strand_field,
      pct_of_classrooms_proficient
    FROM
      archive_unpivot
    UNION ALL
    SELECT
      school,
      academic_year,
      reporting_term,
      rubric_strand_field,
      pct_of_classrooms_proficient
    FROM
      current_unpivot
  )
SELECT
  school,
  reporting_schoolid,
  region,
  school_level,
  academic_year,
  reporting_term,
  rubric_strand_field,
  rubric_domain,
  rubric_strand_label,
  rubric_strand_description,
  AVG(pct_of_classrooms_proficient) AS pct_of_classrooms_proficient,
  ROW_NUMBER() OVER (
    PARTITION BY
      reporting_schoolid,
      academic_year,
      rubric_strand_field
    ORDER BY
      reporting_term DESC
  ) AS rn_most_recent_yr
FROM
  (
    SELECT
      su.school,
      su.academic_year,
      su.reporting_term,
      su.rubric_strand_field,
      su.pct_of_classrooms_proficient,
      CASE
        WHEN su.school IN ('TEAM', 'TEAM Academy') THEN 133570965
        WHEN su.school IN ('Rise', 'Rise Academy') THEN 73252
        WHEN su.school IN ('NCA', 'Newark Collegiate Academy') THEN 73253
        WHEN su.school IN ('SPARK', 'SPARK Academy') THEN 73254
        WHEN su.school IN ('THRIVE', 'THRIVE Academy') THEN 73255
        WHEN su.school IN ('Seek', 'Seek Academy') THEN 73256
        WHEN su.school IN ('Life', 'Life Academy') THEN 73257
        WHEN su.school IN ('BOLD', 'BOLD Academy') THEN 73258
        WHEN su.school IN ('LSP', 'KSLP', 'Lanning Square Primary') THEN 179901
        WHEN su.school IN ('LSM', 'KLSM', 'Lanning Square Middle') THEN 179902
        WHEN su.school IN ('KWM', 'KIPP Whittier Middle') THEN 179903
        WHEN su.school IN ('WEK') THEN 1799015075
        WHEN su.school = 'KIPP NJ' THEN 0
        WHEN su.school IN ('Pathways', 'Pathways ES') THEN 732574573
        WHEN su.school = 'Pathways MS' THEN 732585074
      END AS reporting_schoolid,
      CASE
        WHEN su.school IN (
          'TEAM',
          'TEAM Academy',
          'Rise',
          'Rise Academy',
          'NCA',
          'Newark Collegiate Academy',
          'SPARK',
          'SPARK Academy',
          'THRIVE',
          'THRIVE Academy',
          'Seek',
          'Seek Academy',
          'Life',
          'Life Academy',
          'BOLD',
          'BOLD Academy',
          'Pathways ES',
          'Pathways MS'
        ) THEN 'TEAM'
        WHEN su.school IN (
          'LSP',
          'KSLP',
          'Lanning Square Primary',
          'LSM',
          'KLSM',
          'Lanning Square Middle',
          'KWM',
          'KIPP Whittier Middle',
          'WEK'
        ) THEN 'KCNA'
        WHEN su.school = 'KIPP NJ' THEN 'All'
      END AS region,
      CASE
        WHEN su.school IN (
          'SPARK',
          'SPARK Academy',
          'THRIVE',
          'THRIVE Academy',
          'Seek',
          'Seek Academy',
          'Life',
          'Life Academy',
          'LSP',
          'KSLP',
          'Lanning Square Primary',
          'WEK',
          'Pathways ES'
        ) THEN 'ES'
        WHEN su.school IN (
          'TEAM',
          'TEAM Academy',
          'Rise',
          'Rise Academy',
          'Pathways MS',
          'BOLD',
          'BOLD Academy',
          'LSM',
          'KLSM',
          'Lanning Square Middle',
          'KWM',
          'KIPP Whittier Middle'
        ) THEN 'MS'
        WHEN su.school IN ('NCA', 'Newark Collegiate Academy') THEN 'HS'
        WHEN su.school = 'KIPP NJ' THEN 'All'
      END AS school_level,
      map.rubric_domain,
      map.rubric_strand_label,
      map.rubric_strand_description
    FROM
      scores_union su
      LEFT JOIN gabby.ekg.walkthrough_domain_map map ON su.rubric_strand_field = map.rubric_strand_field
    COLLATE Latin1_General_BIN
  ) sub
GROUP BY
  school,
  reporting_schoolid,
  region,
  school_level,
  academic_year,
  reporting_term,
  rubric_strand_field,
  rubric_domain,
  rubric_strand_label,
  rubric_strand_description
