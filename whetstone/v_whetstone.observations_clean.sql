USE gabby
GO

CREATE OR ALTER VIEW whetstone.observations_clean AS

SELECT wo._id AS observation_id
      ,wo.signed      
      ,wo.is_published
      ,wo.observee_role
      ,wo.viewed_by_teacher
      ,wo.last_published
      ,wo.first_published
      ,wo.observed_at
      ,wo.created
      ,wo.quick_hits      
      ,wo.score
      ,wo.score_averaged_by_strand
      ,wo.percentage
      ,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(wo.list_two_column_a,'[',''),']',''),'"',' '))) AS list_two_column_a /* list_glows */
      ,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(wo.list_two_column_b,'[',''),']',''),'"',' '))) AS list_two_column_b /* list_grows */
      
      ,JSON_VALUE(wo.observer,'$.name') AS observer_name
      ,JSON_VALUE(wo.observer,'$.canvasId') AS observer_canvasId
      ,JSON_VALUE(wo.observer,'$.powerSchoolId') AS observer_powerSchoolId
      ,JSON_VALUE(wo.observer,'$.accountingId') AS observer_accountingId
      ,JSON_VALUE(wo.observer,'$.internalId') AS observer_internalId
      ,JSON_VALUE(wo.observer,'$.email') AS observer_email
      
      ,JSON_VALUE(wo.teacher,'$.name') AS teacher_name
      ,JSON_VALUE(wo.teacher,'$.canvasId') AS teacher_canvasId
      ,JSON_VALUE(wo.teacher,'$.powerSchoolId') AS teacher_powerSchoolId
      ,JSON_VALUE(wo.teacher,'$.accountingId') AS teacher_accountingId
      ,JSON_VALUE(wo.teacher,'$.internalId') AS teacher_internalId
      ,JSON_VALUE(wo.teacher,'$.email') AS teacher_email      
      
      ,JSON_VALUE(wo.teaching_assignment, '$.period') AS teaching_assignment_period
      ,JSON_VALUE(wo.teaching_assignment, '$.course') AS teaching_assignment_course
      ,JSON_VALUE(wo.teaching_assignment, '$.gradeLevel._id') AS teaching_assignment_gradeLevel_id
      ,JSON_VALUE(wo.teaching_assignment, '$.gradeLevel.name') AS teaching_assignment_gradeLevel_name
      ,JSON_VALUE(wo.teaching_assignment, '$.school._id') AS teaching_assignment_school_id
      ,JSON_VALUE(wo.teaching_assignment, '$.school.name') AS teaching_assignment_school_name

      ,JSON_VALUE(wo.rubric,'$._id') AS rubric_id
      ,JSON_VALUE(wo.rubric,'$.name') AS rubric_name      
      
      ,JSON_VALUE(wo.observation_type,'$._id') AS observation_type_id
      ,JSON_VALUE(wo.observation_type,'$.name') AS observation_type_name
FROM gabby.whetstone.observations wo