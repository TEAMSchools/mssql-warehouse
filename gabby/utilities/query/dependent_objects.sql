WITH
  cte_dependentobjects AS (
    SELECT DISTINCT
      SCHEMA_NAME(b.schema_id) AS [schema_name],
      SCHEMA_NAME(b.schema_id) + '.' + b.name AS schema_object_name,
      b.type AS object_type,
      SCHEMA_NAME(c.schema_id) AS dependent_schema_name,
      SCHEMA_NAME(c.schema_id) + '.' + c.name AS dependent_schema_object_name,
      c.type AS dependent_object_type
    FROM
      sys.sysdepends AS a
      INNER JOIN sys.objects AS b ON a.id = b.object_id
      AND b.type IN ('V')
      INNER JOIN sys.objects AS c ON a.depid = c.object_id
      AND c.type IN ('U', 'V')
  ),
  cte_dependentobjects2 AS (
    SELECT
      a.schema_object_name,
      a.object_type,
      a.dependent_schema_object_name,
      a.dependent_object_type,
      1 AS [level]
    FROM
      cte_dependentobjects AS a
    WHERE
      a.schema_object_name LIKE 'tableau.marketing%'
      -- a.schema_object_name IN (
      -- 'adp.workers_clean',
      -- 'adp.workers_custom_field_group_wide',
      -- 'adsi.user_attributes',
      -- 'deanslist.incidents_penalties',
      -- 'deanslist.terms_clean',
      -- 'illuminate_dna_assessments.assessment_responses_long',
      -- 'illuminate_dna_assessments.assessment_responses_rollup_current',
      -- 'illuminate_dna_assessments.assessments_identifiers',
      -- 'illuminate_dna_assessments.course_enrollment_scaffold_current',
      -- 'illuminate_dna_assessments.performance_band_lookup',
      -- 'illuminate_dna_assessments.student_assessment_scaffold_current',
      -- 'illuminate_dna_repositories.sight_words_data_current',
      -- 'illuminate_public.student_session_aff_clean',
      -- 'illuminate_standards.standards_domain',
      -- 'lit.achieved_by_round',
      -- 'lit.all_test_events',
      -- 'lit.component_proficiency_long',
      -- 'njdoe.certification_certificate_history',
      -- 'people.employment_history',
      -- 'people.manager_history',
      -- 'people.salary_history',
      -- 'people.staff_crosswalk',
      -- 'people.status_history',
      -- 'people.work_assignment_history',
      -- 'pm.teacher_goal_scaffold',
      -- 'pm.teacher_goals_exemption_clean',
      -- 'pm.teacher_goals_overall_scores',
      -- 'pm.teacher_goals_roster',
      -- 'powerschool.advisory',
      -- 'powerschool.attendance_clean_current',
      -- 'powerschool.attendance_counts',
      -- 'powerschool.calendar_rollup',
      -- 'powerschool.category_grades_wide',
      -- 'powerschool.category_grades',
      -- 'powerschool.cohort_identifiers_scaffold_current',
      -- 'powerschool.cohort_identifiers',
      -- 'powerschool.cohort',
      -- 'powerschool.course_enrollments_current',
      -- 'powerschool.enrollment_identifiers',
      -- 'powerschool.final_grades_wide',
      -- 'powerschool.final_grades',
      -- 'powerschool.gradebook_assignments_current',
      -- 'powerschool.gradebook_assignments_scores_current',
      -- 'powerschool.gradebook_setup',
      -- 'powerschool.gradescaleitem_lookup',
      -- 'powerschool.ps_adaadm_daily_ctod_current',
      -- 'powerschool.ps_attendance_daily_current',
      -- 'powerschool.ps_enrollment_all'
      -- 'powerschool.ps_membership_reg_current',
      -- 'powerschool.spenrollments_gen',
      -- 'powerschool.student_access_accounts',
      -- 'powerschool.student_contacts_wide',
      -- 'powerschool.student_contacts',
      -- 'powerschool.teachers',
      -- 'powerschool.team_roster',
      -- 'powerschool.u_clg_et_stu_alt_clean',
      -- 'powerschool.u_clg_et_stu_clean',
      -- 'recruiting.leading_indicators'
      -- 'renaissance.ar_goals_current',
      -- 'renaissance.ar_individualized_goals_long',
      -- 'renaissance.ar_most_recent_quiz',
      -- 'renaissance.ar_studentpractice_identifiers',
      -- 'renaissance.ar_studentpractice_rollup',
      -- 'steptool.component_scores',
      -- 'surveygizmo.survey_campaign_clean',
      -- 'surveygizmo.survey_question_clean',
      -- 'surveygizmo.survey_question_options',
      -- 'surveygizmo.survey_response_clean_current',
      -- 'surveygizmo.survey_response_data_current',
      -- 'surveygizmo.survey_response_data_options_current',
      -- 'surveygizmo.survey_response_identifiers',
      -- 'surveys.self_and_others_survey_rollup',
      -- 'surveys.staff_information_survey_wide',
      -- 'tableau.ar_time_series_current',
      -- 'tableau.attendance_dashboard_current',
      -- 'whetstone.observations_scores_checkboxes',
      -- 'whetstone.observations_scores_text_boxes',
      -- 'whetstone.observations_scores',
      -- )
      -- OR a.schema_name = 'extracts'
      -- OR a.schema_name = 'tableau'
    UNION ALL
    SELECT
      a.schema_object_name,
      a.object_type,
      a.dependent_schema_object_name,
      a.dependent_object_type,
      (b.level + 1) AS [level]
    FROM
      cte_dependentobjects AS a
      INNER JOIN cte_dependentobjects2 AS b ON (
        a.schema_object_name = b.dependent_schema_object_name
      )
  ),
  objects_union AS (
    SELECT
      schema_object_name,
      object_type,
      dependent_schema_object_name,
      [level]
    FROM
      cte_dependentobjects2
    UNION ALL
    SELECT
      dependent_schema_object_name,
      dependent_object_type,
      NULL AS dependent_schema_object_name,
      [level]
    FROM
      cte_dependentobjects2
  ),
  objects_grouped AS (
    SELECT
      schema_object_name AS [Name],
      object_type AS [Object Type],
      gabby.dbo.GROUP_CONCAT_DS (
        DISTINCT dependent_schema_object_name,
        ',',
        1
      ) AS [Dependents],
      MIN([level]) AS [level]
    FROM
      objects_union
    GROUP BY
      schema_object_name,
      object_type
  )
SELECT
  [Name],
  CASE
    WHEN [Object Type] = 'U' THEN 'Table'
    WHEN [Object Type] = 'V' THEN 'View'
    WHEN [Object Type] = 'FN' THEN 'Function'
    WHEN [Object Type] = 'P' THEN 'Procedure'
  END AS [Object Type],
  [Dependents]
FROM
  objects_grouped
ORDER BY
  CASE
    WHEN [Dependents] IS NOT NULL THEN 1
    ELSE 0
  END ASC,
  [level] DESC
