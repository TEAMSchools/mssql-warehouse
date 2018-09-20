USE gabby
GO

CREATE OR ALTER VIEW tableau.pm_etr_dashboard AS

SELECT wo._id AS observation_id
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
      ,wo.personal_notes
      ,wo.list_two_column_b
      ,wo.list_two_column_a
      ,wo.classroom_visits      
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

      ,wos.score_id
      ,wos.score_measurement_id
      ,wos.score_percentage
      ,wos.score_value
            
      ,wm.name AS measurement_name
      ,wm.description  AS measurement_description
      ,wm.scale_min AS measurement_scale_min
      ,wm.scale_max AS measurement_scale_max      
      ,wm.measurement_groups

      ,tb.text_box_id
      ,tb.text_box_label
      ,tb.text_box_text
FROM gabby.whetstone.observations_clean wo
LEFT JOIN gabby.whetstone.observations_scores wos
  ON wo._id = wos.observation_id
LEFT JOIN gabby.whetstone.measurements wm
  ON wos.score_measurement_id = wm._id
LEFT JOIN gabby.whetstone.observations_scores_text_boxes tb
  ON wos.score_id = tb.score_id