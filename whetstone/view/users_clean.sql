CREATE OR ALTER VIEW
  whetstone.users_clean AS
SELECT
  _id AS USER_ID,
  internal_id,
  [name] AS USER_NAME,
  [first] AS first_name,
  [last] AS last_name,
  email AS user_email,
  coach AS coach_id,
  inactive,
  locked,
  reset_password_flag,
  created,
  last_modified,
  last_activity,
  archived_at,
  /* unparsed JSON objects */
  usertype,
  preferences,
  JSON_VALUE(default_information, '$.school') AS default_school_id,
  JSON_VALUE(
    default_information,
    '$.gradeLevel'
  ) AS default_grade_level_id,
  JSON_VALUE(default_information, '$.course') AS default_course_id,
  /* nested JSON arrays */
  districts AS districts_json,
  additional_emails AS additional_emails_json,
  measurement_focuses AS measurement_focuses_json,
  regional_admin_schools AS regional_admin_schools_json,
  teaching_assignments AS teaching_assignments_json,
  checklist AS checklist_json,
  messages AS messages_json,
  external_integrations AS external_integrations_json,
  roles AS roles_json
FROM
  gabby.whetstone.users
