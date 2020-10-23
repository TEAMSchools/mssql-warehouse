USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_clean AS

SELECT sub.observation_id
      ,sub.observation_type_id
      ,sub.score
      ,sub.district_id
      ,sub.observed_at
      ,sub.created
      ,sub.last_modified
      ,sub.first_published
      ,sub.last_published
      ,sub.archived_at
      ,sub.signed_at
      ,sub.is_private
      ,sub.is_published
      ,sub.locked
      ,sub.require_signature
      ,sub.assign_action_step_widget_text
      ,sub.quick_hits
      ,sub.private_notes_4
      ,sub.list_two_column_a
      ,sub.list_two_column_b
      ,sub.observer_id
      ,sub.observer_name
      ,sub.teacher_id
      ,sub.teacher_name
      ,sub.rubric_id
      ,sub.rubric_name
      ,sub.teaching_assignment_id
      ,sub.teaching_assignment_school_id
      ,sub.teaching_assignment_grade_id
      ,sub.teaching_assignment_gradeLevel_id
      ,sub.teaching_assignment_course_id
      ,sub.teaching_assignment_period_id
      
      ,t.internal_id AS teacher_internal_id
      ,t.user_email AS teacher_email
      
      ,o.internal_id AS observer_internal_id
      ,o.user_email AS observer_email
FROM
    (
    SELECT wo._id AS observation_id
          ,wo.[observation_type] AS observation_type_id
          ,wo.[score]
          ,wo.[district] AS district_id
          ,wo.[observed_at]
          ,wo.[created]
          ,wo.[last_modified]
          ,wo.[first_published]
          ,wo.[last_published]
          ,wo.[archived_at]
          ,wo.[signed_at]
          ,wo.[is_private]
          ,wo.[is_published]
          ,wo.[locked]
          ,wo.[require_signature]
          ,wo.[assign_action_step_widget_text]
          ,wo.[quick_hits]
          ,wo.[private_notes_4]

          ,JSON_VALUE(wo.[list_two_column_a], '$[0]') AS list_two_column_a /* list_glows */
          ,JSON_VALUE(wo.[list_two_column_b], '$[0]') AS list_two_column_b /* list_grows */
          ,JSON_VALUE(wo.observer,'$._id') AS observer_id
          ,JSON_VALUE(wo.observer,'$.name') AS observer_name
          ,JSON_VALUE(wo.teacher,'$._id') AS teacher_id
          ,JSON_VALUE(wo.teacher,'$.name') AS teacher_name
          ,JSON_VALUE(wo.rubric,'$._id') AS rubric_id
          ,JSON_VALUE(wo.rubric,'$.name') AS rubric_name
          ,JSON_VALUE(wo.teaching_assignment, '$._id') AS teaching_assignment_id
          ,JSON_VALUE(wo.teaching_assignment, '$.school') AS teaching_assignment_school_id
          ,JSON_VALUE(wo.teaching_assignment, '$.grade') AS teaching_assignment_grade_id
          ,JSON_VALUE(wo.teaching_assignment, '$.gradeLevel') AS teaching_assignment_gradeLevel_id
          ,JSON_VALUE(wo.teaching_assignment, '$.course') AS teaching_assignment_course_id
          ,JSON_VALUE(wo.teaching_assignment, '$.period') AS teaching_assignment_period_id
    FROM gabby.whetstone.observations wo
    WHERE wo.[archived_at] IS NULL
   ) sub
LEFT JOIN gabby.whetstone.users_clean t
  ON sub.teacher_id = t.[user_id]
LEFT JOIN gabby.whetstone.users_clean o
  ON sub.observer_id = o.[user_id]