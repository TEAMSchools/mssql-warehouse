USE gabby GO
CREATE OR ALTER VIEW
  surveygizmo.survey_response_data_options_current AS
SELECT
  srd.survey_id,
  srd.survey_response_id,
  srd.question_id,
  ol.id AS option_id,
  ol.[option] AS option_name,
  ol.answer
FROM
  gabby.surveygizmo.survey_response_data_current_static AS srd
  CROSS APPLY OPENJSON (srd.options_list, '$')
WITH
  (
    id NVARCHAR(16),
    [option] NVARCHAR(128),
    answer NVARCHAR(128)
  ) AS ol
WHERE
  srd.options_list IS NOT NULL
