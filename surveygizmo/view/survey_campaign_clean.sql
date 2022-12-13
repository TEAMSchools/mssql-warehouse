USE gabby GO
CREATE OR ALTER VIEW
  surveygizmo.survey_campaign_clean AS
SELECT
  id AS survey_campaign_id,
  survey_id,
  [name],
  [type],
  CAST(
    CASE
      WHEN link_open_date = '0000-00-00 00:00:00' THEN NULL
      ELSE link_open_date
    END AS DATETIME2
  ) AS link_open_date,
  CAST(
    CASE
      WHEN link_close_date = '0000-00-00 00:00:00' THEN NULL
      ELSE link_close_date
    END AS DATETIME2
  ) AS link_close_date,
  [status],
  close_message,
  CAST(date_created AS DATETIME2) AS date_created,
  CAST(date_modified AS DATETIME2) AS date_modified,
  invite_id,
  [language],
  link_type,
  subtype,
  uri,
  [ssl],
  limit_responses,
  token_variables,
  LTRIM(RTRIM(RIGHT([name], CHARINDEX(' ', REVERSE([name]))))) AS reporting_term_code,
  gabby.utilities.DATE_TO_SY (
    CAST(
      CASE
        WHEN link_open_date = '0000-00-00 00:00:00' THEN NULL
        ELSE link_open_date
      END AS DATETIME2
    )
  ) AS academic_year
FROM
  gabby.surveygizmo.survey_campaign
