USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_clean AS

SELECT wo._id
      ,wo.signed
      ,wo.archived_at
      ,wo.is_published
      ,wo.observee_role
      ,wo.viewed_by_teacher
      ,wo.last_published
      ,wo.first_published
      ,wo.observed_at
      ,wo.created
      ,wo.quick_hits
      ,wo._fivetran_synced
      ,wo._modified
      ,wo.personal_notes
      ,wo.list_two_column_b
      ,wo.list_two_column_a
      ,wo.classroom_visits
      ,wo.scores
      ,wo.rubric
      ,wo.list_three_column_b
      ,wo.list_three_column_a
      ,wo.teaching_assignment
      ,wo.list_three_column_c
      ,wo.tags
      ,wo.observation_type
      ,wo.magic_notes
      ,wo.observer
      ,wo.list_two_column_apaired
      ,wo.teacher
      ,wo.score_overrides
      ,wo.video_notes
      ,wo.files
      ,wo.meetings
      ,wo.event_log
      ,wo.list_two_column_bpaired
      ,wo.list_one_column_a
      ,wo.last_modified
      ,wo.score
      ,wo.score_averaged_by_strand
      ,wo.percentage
FROM gabby.whetstone.observations wo