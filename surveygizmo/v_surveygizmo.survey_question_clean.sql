USE gabby GO
CREATE OR ALTER VIEW
  surveygizmo.survey_question_clean AS
SELECT
  id AS survey_question_id,
  survey_id,
  CAST(base_type AS NVARCHAR(16)) AS base_type,
  CAST([type] AS NVARCHAR(32)) AS [type],
  comment,
  has_showhide_deps,
  CAST(
    CASE
      WHEN shortname <> '' THEN shortname
    END AS NVARCHAR(128)
  ) AS shortname,
  CASE
    WHEN [type] = 'ESSAY' THEN N'Y'
    WHEN [type] = 'TEXTBOX' THEN N'Y'
    ELSE N'N'
  END AS is_open_ended,
  CASE
    WHEN shortname IN (
      'respondent_df_employee_number',
      'respondent_userprincipalname',
      'respondent_adp_associate_id',
      'subject_df_employee_number',
      'is_manager',
      'employee_number',
      'email',
      'employee_preferred_name',
      'salesforce_id'
    ) THEN 1
    ELSE 0
  END AS is_identifier_question,
  CAST(
    JSON_VALUE(title, '$.English') AS NVARCHAR(2048)
  ) AS title_english,
  CAST(
    JSON_VALUE(properties, '$.url') AS NVARCHAR(128)
  ) AS [url],
  CAST(
    JSON_VALUE(properties, '$.orientation') AS NVARCHAR(16)
  ) AS orientation,
  CAST(
    JSON_VALUE(
      properties,
      '$.question_description_above'
    ) AS BIT
  ) AS question_description_above,
  CAST(
    JSON_VALUE(properties, '$."soft-required"') AS BIT
  ) AS soft_required,
  CAST(
    JSON_VALUE(properties, '$.disabled') AS BIT
  ) AS [disabled],
  CAST(
    JSON_VALUE(
      properties,
      '$.hide_after_response'
    ) AS BIT
  ) AS hide_after_response,
  CAST(
    JSON_VALUE(properties, '$.break_after') AS BIT
  ) AS break_after,
  CAST(
    gabby.utilities.STRIP_HTML (JSON_VALUE(title, '$.English')) AS VARCHAR(2048)
  ) AS title_clean,
  JSON_QUERY(properties, '$.custom_css') AS custom_css,
  JSON_QUERY(properties, '$.messages') AS messages_json,
  JSON_QUERY(properties, '$.show_rules') AS show_rules_json,
  varname AS varname_json,
  [description] AS description_json
FROM
  gabby.surveygizmo.survey_question
