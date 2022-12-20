CREATE OR ALTER VIEW
  surveygizmo.survey_clean AS
SELECT
  id AS survey_id,
  title,
  [type],
  [status],
  team,
  CAST(
    created_on AS DATETIME2
  ) AS created_on,
  CAST(
    modified_on AS DATETIME2
  ) AS modified_on,
  JSON_VALUE(links, '$.edit') AS edit_link,
  JSON_VALUE(links, '$.publish') AS publish_link,
  JSON_VALUE(links, '$.default') AS default_link,
  JSON_VALUE(
    [statistics],
    '$.Partial'
  ) AS [partial],
  JSON_VALUE(
    [statistics],
    '$.Deleted'
  ) AS deleted,
  JSON_VALUE(
    [statistics],
    '$.Complete'
  ) AS complete,
  JSON_VALUE(
    [statistics],
    '$.TestData'
  ) AS test_data
FROM
  gabby.surveygizmo.survey
