CREATE OR ALTER VIEW
  zendesk.ticket_metrics_clean AS
SELECT
  id,
  ticket_id,
  [url],
  group_stations,
  assignee_stations,
  reopens,
  replies,
  assignee_updated_at,
  requester_updated_at,
  status_updated_at,
  initially_assigned_at,
  assigned_at,
  solved_at,
  latest_comment_added_at,
  created_at,
  updated_at,
  CAST(
    JSON_VALUE(
      first_resolution_time_in_minutes,
      '$.calendar'
    ) AS INT
  ) AS first_resolution_time_in_minutes_calendar,
  CAST(
    JSON_VALUE(
      first_resolution_time_in_minutes,
      '$.business'
    ) AS INT
  ) AS first_resolution_time_in_minutes_business,
  CAST(
    JSON_VALUE(
      reply_time_in_minutes,
      '$.calendar'
    ) AS INT
  ) AS reply_time_in_minutes_calendar,
  CAST(
    JSON_VALUE(
      reply_time_in_minutes,
      '$.business'
    ) AS INT
  ) AS reply_time_in_minutes_business,
  CAST(
    JSON_VALUE(
      full_resolution_time_in_minutes,
      '$.calendar'
    ) AS INT
  ) AS full_resolution_time_in_minutes_calendar,
  CAST(
    JSON_VALUE(
      full_resolution_time_in_minutes,
      '$.business'
    ) AS INT
  ) AS full_resolution_time_in_minutes_business,
  CAST(
    JSON_VALUE(
      agent_wait_time_in_minutes,
      '$.calendar'
    ) AS INT
  ) AS agent_wait_time_in_minutes_calendar,
  CAST(
    JSON_VALUE(
      agent_wait_time_in_minutes,
      '$.business'
    ) AS INT
  ) AS agent_wait_time_in_minutes_business,
  CAST(
    JSON_VALUE(
      requester_wait_time_in_minutes,
      '$.calendar'
    ) AS INT
  ) AS requester_wait_time_in_minutes_calendar,
  CAST(
    JSON_VALUE(
      requester_wait_time_in_minutes,
      '$.business'
    ) AS INT
  ) AS requester_wait_time_in_minutes_business
FROM
  gabby.zendesk.ticket_metrics
