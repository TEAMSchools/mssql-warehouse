CREATE OR ALTER VIEW
  surveygizmo.survey_response_clean_current AS
SELECT
  sub.id AS survey_response_id,
  sub.survey_id,
  sub.contact_id,
  sub.[status],
  sub.is_test_data,
  sub.datetime_started,
  sub.datetime_submitted,
  sub.date_started,
  sub.date_submitted,
  sub.response_time,
  sub.city,
  sub.postal,
  sub.region,
  sub.country,
  sub.latitude,
  sub.longitude,
  sub.dma,
  sub.[language],
  sub.ip_address,
  sub.link_id,
  sub.referer,
  sub.session_id,
  sub.user_agent,
  sub.url_privatedomain,
  sub.url_contact,
  sub.url_messageid,
  sub.url_sguid,
  sub.url_pathdata,
  sub.data_quality_json,
  sub.survey_data_json
FROM
  (
    SELECT
      sr.id,
      sr.survey_id,
      sr.contact_id,
      sr.is_test_data,
      sr.response_time,
      sr.latitude,
      sr.longitude,
      sr.dma,
      sr.link_id,
      CAST(sr.city AS NVARCHAR(64)) AS city,
      CAST(sr.postal AS NVARCHAR(32)) AS postal,
      CAST(sr.region AS NVARCHAR(8)) AS region,
      CAST(sr.country AS NVARCHAR(64)) AS country,
      CAST(sr.[language] AS NVARCHAR(16)) AS [language],
      CAST(sr.ip_address AS NVARCHAR(32)) AS ip_address,
      CAST(sr.session_id AS NVARCHAR(128)) AS session_id,
      CAST(sr.user_agent AS NVARCHAR(512)) AS user_agent,
      CAST(sr.referer AS NVARCHAR(1024)) AS referer,
      CAST(sr.data_quality AS NVARCHAR(MAX)) AS data_quality_json,
      CAST(
        JSON_VALUE(
          sr.url_variables,
          '$._privatedomain'
        ) AS NVARCHAR(1)
      ) AS url_privatedomain,
      CAST(
        JSON_VALUE(sr.url_variables, '$.__contact') AS NVARCHAR(32)
      ) AS url_contact,
      CAST(
        JSON_VALUE(
          sr.url_variables,
          '$.__messageid'
        ) AS NVARCHAR(32)
      ) AS url_messageid,
      CAST(
        JSON_VALUE(sr.url_variables, '$.sguid') AS NVARCHAR(32)
      ) AS url_sguid,
      CAST(
        JSON_VALUE(sr.url_variables, '$.__pathdata') AS NVARCHAR(256)
      ) AS url_pathdata,
      CAST(
        COALESCE(
          sr.survey_data_list,
          sr.survey_data
        ) AS NVARCHAR(MAX)
      ) AS survey_data_json,
      CAST(
        LEFT(sr.date_started, 19) AS DATETIME2
      ) AS datetime_started,
      CAST(
        CONVERT(
          DATETIME2,
          LEFT(sr.date_started, 19)
        ) AS DATE
      ) AS date_started,
      CONVERT(
        DATETIME2,
        CASE
          WHEN ISDATE(LEFT(sr.date_submitted, 19)) = 1 THEN LEFT(sr.date_submitted, 19)
        END
      ) AS datetime_submitted,
      CONVERT(
        DATE,
        CONVERT(
          DATETIME2,
          CASE
            WHEN (
              ISDATE(LEFT(sr.date_submitted, 19)) = 1
            ) THEN LEFT(sr.date_submitted, 19)
          END
        )
      ) AS date_submitted,
      CAST(
        COALESCE(dq.[status], sr.[status]) AS NVARCHAR(32)
      ) AS [status],
      ROW_NUMBER() OVER (
        PARTITION BY
          sr.id,
          sr.survey_id
        ORDER BY
          CASE
            WHEN sr.[status] = 'Complete' THEN 1
            ELSE 0
          END DESC,
          sr._modified DESC
      ) AS rn
    FROM
      surveygizmo.survey_response AS sr
      LEFT JOIN surveygizmo.survey_response_disqualified AS dq ON (
        sr.id = dq.id
        AND sr.survey_id = dq.survey_id
      )
    WHERE
      CAST(
        LEFT(sr.date_started, 19) AS DATETIME2
      ) >= DATEFROMPARTS(
        utilities.GLOBAL_ACADEMIC_YEAR (),
        7,
        1
      )
  ) AS sub
WHERE
  sub.rn = 1
