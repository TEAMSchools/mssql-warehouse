CREATE OR ALTER VIEW
  whetstone.observations_clean AS
WITH
  sub AS (
    SELECT
      _id AS observation_id,
      observation_type AS observation_type_id,
      score,
      district AS district_id,
      observed_at,
      created,
      last_modified,
      first_published,
      last_published,
      archived_at,
      signed_at,
      is_private,
      is_published,
      locked,
      require_signature,
      assign_action_step_widget_text,
      quick_hits,
      private_notes_4,
      JSON_VALUE(list_two_column_a, '$[0]') AS list_two_column_a /* list_glows */,
      JSON_VALUE(list_two_column_b, '$[0]') AS list_two_column_b /* list_grows */,
      JSON_VALUE(observer, '$._id') AS observer_id,
      JSON_VALUE(observer, '$.name') AS observer_name,
      JSON_VALUE(teacher, '$._id') AS teacher_id,
      JSON_VALUE(teacher, '$.name') AS teacher_name,
      JSON_VALUE(rubric, '$._id') AS rubric_id,
      JSON_VALUE(rubric, '$.name') AS rubric_name,
      JSON_VALUE(teaching_assignment, '$._id') AS teaching_assignment_id,
      JSON_VALUE(teaching_assignment, '$.school') AS teaching_assignment_school_id,
      JSON_VALUE(teaching_assignment, '$.grade') AS teaching_assignment_grade_id,
      JSON_VALUE(
        teaching_assignment,
        '$.gradeLevel'
      ) AS teaching_assignment_grade_level_id,
      JSON_VALUE(teaching_assignment, '$.course') AS teaching_assignment_course_id,
      JSON_VALUE(teaching_assignment, '$.period') AS teaching_assignment_period_id
    FROM
      gabby.whetstone.observations
    WHERE
      archived_at IS NULL
  )
SELECT
  sub.observation_id,
  sub.observation_type_id,
  sub.score,
  sub.district_id,
  sub.observed_at,
  sub.created,
  sub.last_modified,
  sub.first_published,
  sub.last_published,
  sub.archived_at,
  sub.signed_at,
  sub.is_private,
  sub.is_published,
  sub.locked,
  sub.require_signature,
  sub.assign_action_step_widget_text,
  sub.quick_hits,
  sub.private_notes_4,
  sub.list_two_column_a,
  sub.list_two_column_b,
  sub.observer_id,
  sub.observer_name,
  sub.teacher_id,
  sub.teacher_name,
  sub.rubric_id,
  sub.rubric_name,
  sub.teaching_assignment_id,
  sub.teaching_assignment_school_id,
  sub.teaching_assignment_grade_id,
  sub.teaching_assignment_grade_level_id,
  sub.teaching_assignment_course_id,
  sub.teaching_assignment_period_id,
  t.internal_id AS teacher_internal_id,
  t.user_email AS teacher_email,
  o.internal_id AS observer_internal_id,
  o.user_email AS observer_email
FROM
  sub
  LEFT JOIN gabby.whetstone.users_clean AS t ON (sub.teacher_id = t.user_id)
  LEFT JOIN gabby.whetstone.users_clean AS o ON (sub.observer_id = o.user_id)
