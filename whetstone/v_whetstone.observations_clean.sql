USE gabby
GO

--CREATE OR ALTER VIEW whetstone.observations_clean AS

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
      ,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(wo.list_two_column_b,'[',''),']',''),'"',' '))) AS list_grows
      ,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(wo.list_two_column_a,'[',''),']',''),'"',' '))) AS list_glows
      ,JSON_VALUE(wo.rubric,'$.name') AS observation_form
      ,JSON_VALUE(wo.observation_type,'$.name') AS observation_type
      ,wo.magic_notes --seemingly an infinite number of arrays (comments) within magic notes
      ,wo.score AS overall_average
      ,wo.score_averaged_by_strand
      ,wo.percentage AS percentage_averaged_by_strand
      
      ,os.score_percentage
      ,os.score_value
      
      ,mos.name AS score_name
            
      ,tb.text_box_text
      ,tb.text_box_label
      
--These won't pull until the view is merged into gabby      
      --,ta.course
      --,ta.gradeLevel
      --,ta.school

--These won't pull until the view is merged into gabby           
      --,o.observed_by_name
      --,o.observed_by_df_id
      --,o.observed_by_email
      
--These won't pull until the view is merged into gabby           
      --,t.teacher_name
      --,t.teacher_df_id
      --,t.teacher_email
      
FROM gabby.whetstone.observations wo LEFT OUTER JOIN gabby.whetstone.observations_scores os
     ON wo._id = os.observation_id
  
     LEFT OUTER JOIN gabby.whetstone.measurements mos
     ON os.score_measurement_id = mos._id
  
     LEFT OUTER JOIN gabby.whetstone.observations_scores_text_boxes tb
     ON os.score_id = tb.score_id



     --LEFT OUTER JOIN gabby.whetstone.observations_teaching_assignment ta  --This join won't work until the view is merged to gabby
     --ON wo._id = ta.observation_id
     
     --LEFT OUTER JOIN gabby.whetstone.observations_observer o  --This join won't work until the view is merged to gabby
     --ON wo._id = o.observation_id
     
     --LEFT OUTER JOIN gabby.whetstone.observations_teacher t --This join won't work until the view is merged to gabby
     --ON wo_id = t.observation_id