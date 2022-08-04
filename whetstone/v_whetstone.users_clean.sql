USE gabby
GO

CREATE OR ALTER VIEW whetstone.users_clean AS

SELECT [user_id]
      ,internal_id
      ,[user_name]
      ,first_name
      ,last_name
      ,user_email
      ,coach_id
      ,inactive
      ,locked
      ,reset_password_flag
      ,created
      ,last_modified
      ,last_activity
      ,archived_at
      ,usertype
      ,preferences
      ,default_school_id
      ,default_grade_level_id
      ,default_course_id
      ,districts_json
      ,additional_emails_json
      ,measurement_focuses_json
      ,regional_admin_schools_json
      ,teaching_assignments_json
      ,checklist_json
      ,messages_json
      ,external_integrations_json
      ,roles_json
FROM
    (
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
           ,u.[created]
           ,u.[last_modified]
           ,u.[last_activity]
           ,u.[archived_at]

           /* unparsed JSON objects */
           ,u.[usertype]
           ,u.[preferences]
           ,JSON_VALUE(u.[default_information], '$.school') AS default_school_id
           ,JSON_VALUE(u.[default_information], '$.gradeLevel') AS default_grade_level_id
           ,JSON_VALUE(u.[default_information], '$.course') AS default_course_id

           /* nested JSON arrays */
           ,u.[districts] AS districts_json
           ,u.[additional_emails] AS additional_emails_json
           ,u.[measurement_focuses] AS measurement_focuses_json
           ,u.[regional_admin_schools] AS regional_admin_schools_json
           ,u.[teaching_assignments] AS teaching_assignments_json
           ,u.[checklist] AS checklist_json
           ,u.[messages] AS messages_json
           ,u.[external_integrations] AS external_integrations_json
           ,u.roles AS roles_json

           ,ROW_NUMBER() OVER(PARTITION BY u._id ORDER BY u._line DESC) AS rn
     FROM [gabby].[whetstone].[users] u
    ) sub
WHERE rn = 1
