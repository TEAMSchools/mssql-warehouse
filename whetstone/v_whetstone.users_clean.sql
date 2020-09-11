USE gabby
GO

CREATE OR ALTER VIEW whetstone.users_clean AS

SELECT u.[_id] AS [user_id]
      ,u.[internal_id]
      ,u.[name] AS [user_name]
      ,u.[first] AS first_name
      ,u.[last] AS last_name
      ,u.[email] AS user_email
      ,u.[coach] AS coach_id
      ,u.[inactive]
      ,u.[locked]
      ,u.[reset_password_flag]
      ,JSON_VALUE(u.[default_information],'$.course.name') AS default_course_name
      ,JSON_VALUE(u.[default_information],'$.gradeLevel.name') AS default_gradelevel_name
      ,JSON_VALUE(u.[default_information],'$.period') AS default_period
      ,JSON_VALUE(u.[default_information],'$.school.name') AS default_school_name
      ,u.[created]
      ,u.[last_modified]
      ,u.[last_activity]
      ,u.[archived_at]
      ,u.[districts] AS districts_json
      ,u.[default_information] AS default_information_json
      ,u.[additional_emails] AS additional_emails_json
      ,u.[measurement_focuses] AS measurement_focuses_json
      ,u.[preferences] AS preferences_json
      ,u.[regional_admin_schools] AS regional_admin_schools_json
      ,u.[teaching_assignments] AS teaching_assignments_json
      ,u.[checklist] AS checklist_json
      ,u.[messages] AS messages_json
      ,u.[external_integrations] AS external_integrations_json
      ,u.[usertype] AS usertype_json
FROM [gabby].[whetstone].[users] u
