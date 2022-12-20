CREATE OR ALTER VIEW
  deanslist.incidents_clean AS
SELECT
  incident_id,
  reporting_incident_id,
  student_id,
  student_school_id,
  infraction_type_id,
  school_id,
  location_id,
  category_id,
  status_id,
  is_referral,
  is_active,
  send_alert,
  hearing_flag,
  CAST(
    addl_reqs AS NVARCHAR(2048)
  ) AS addl_reqs,
  CAST(
    admin_summary AS NVARCHAR(MAX)
  ) AS admin_summary,
  CAST(
    category AS NVARCHAR(256)
  ) AS category,
  CAST(
    context AS NVARCHAR(MAX)
  ) AS context,
  CAST(
    family_meeting_notes AS NVARCHAR(MAX)
  ) AS family_meeting_notes,
  CAST(gender AS NVARCHAR(2)) AS gender,
  CAST(
    grade_level_short AS NVARCHAR(8)
  ) AS grade_level_short,
  CAST(
    homeroom_name AS NVARCHAR(64)
  ) AS homeroom_name,
  CAST(
    infraction AS NVARCHAR(256)
  ) AS infraction,
  CAST(
    [location] AS NVARCHAR(128)
  ) AS [location],
  CAST(
    reported_details AS NVARCHAR(MAX)
  ) AS reported_details,
  CAST(
    return_period AS NVARCHAR(8)
  ) AS return_period,
  CAST(
    [status] AS NVARCHAR(64)
  ) AS [status],
  CAST(
    student_first AS NVARCHAR(64)
  ) AS student_first,
  CAST(
    student_last AS NVARCHAR(64)
  ) AS student_last,
  CAST(
    student_middle AS NVARCHAR(64)
  ) AS student_middle,
  CAST(
    create_by AS NVARCHAR(16)
  ) AS create_by,
  CAST(
    create_first AS NVARCHAR(64)
  ) AS create_first,
  CAST(
    create_last AS NVARCHAR(64)
  ) AS create_last,
  CAST(
    create_middle AS NVARCHAR(64)
  ) AS create_middle,
  CAST(
    create_title AS NVARCHAR(16)
  ) AS create_title,
  CAST(
    update_by AS NVARCHAR(16)
  ) AS update_by,
  CAST(
    update_first AS NVARCHAR(32)
  ) AS update_first,
  CAST(
    update_last AS NVARCHAR(64)
  ) AS update_last,
  CAST(
    update_middle AS NVARCHAR(16)
  ) AS update_middle,
  CAST(
    update_title AS NVARCHAR(16)
  ) AS update_title,
  CAST(
    JSON_VALUE(return_date, '$.date') AS DATE
  ) AS return_date,
  CAST(
    JSON_VALUE(issue_ts, '$.date') AS DATETIME2
  ) AS issue_ts,
  CAST(
    JSON_VALUE(update_ts, '$.date') AS DATETIME2
  ) AS update_ts,
  CAST(
    JSON_VALUE(close_ts, '$.date') AS DATETIME2
  ) AS close_ts,
  CAST(
    JSON_VALUE(review_ts, '$.date') AS DATETIME2
  ) AS review_ts,
  CAST(
    JSON_VALUE(create_ts, '$.date') AS DATETIME2
  ) AS create_ts,
  CAST(
    JSON_VALUE(
      dl_lastupdate,
      '$.date'
    ) AS DATETIME2
  ) AS dl_lastupdate,
  gabby.utilities.DATE_TO_SY (
    CAST(
      JSON_VALUE(create_ts, '$.date') AS DATETIME2
    )
  ) AS create_academic_year
FROM
  deanslist.incidents
