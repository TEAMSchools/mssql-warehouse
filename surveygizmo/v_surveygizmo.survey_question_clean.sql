USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_question_clean AS

SELECT id AS survey_question_id
      ,survey_id
      ,base_type
      ,[type]
      ,comment
      ,has_showhide_deps
      ,CASE WHEN shortname != '' THEN shortname END AS shortname
      
      ,JSON_VALUE(title, '$.English') AS title_english
      ,JSON_VALUE(properties, '$.url') AS [url]
      ,JSON_VALUE(properties, '$.orientation') AS orientation
      ,JSON_QUERY(properties, '$.custom_css') AS custom_css
      ,CONVERT(BIT, JSON_VALUE(properties, '$.question_description_above')) AS question_description_above
      ,CONVERT(BIT, JSON_VALUE(properties, '$."soft-required"')) AS soft_required
      ,CONVERT(BIT, JSON_VALUE(properties, '$.disabled')) AS [disabled]
      ,CONVERT(BIT, JSON_VALUE(properties, '$.hide_after_response')) AS hide_after_response
      ,CONVERT(BIT, JSON_VALUE(properties, '$.break_after')) AS break_after
      ,gabby.utilities.STRIP_HTML(JSON_VALUE(title, '$.English')) AS title_clean

      ,JSON_QUERY(properties, '$.messages') AS messages_json
      ,JSON_QUERY(properties, '$.show_rules') AS show_rules_json
      ,varname AS varname_json
      ,[description] AS description_json
FROM gabby.surveygizmo.survey_question