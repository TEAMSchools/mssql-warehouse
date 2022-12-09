USE gabby GO
CREATE OR ALTER VIEW
  zendesk.ticket_metrics AS
WITH
  date_metrics AS (
    SELECT
      ticket_id,
      assignee_id_updated_max AS assigned_at,
      assignee_id_updated_min AS initially_assigned_at,
      requester_id_updated_max AS requester_updated_at,
      status_updated_max AS status_updated_at,
      solved_updated_max AS solved_at,
      all_updated_max AS updated_at,
      comment_created_max AS latest_comment_added_at,
      comment_created_min AS initial_comment_added_at
    FROM
      (
        SELECT
          ticket_id,
          field_name + '_' + metric_name
        COLLATE SQL_Latin1_General_CP1_CI_AS AS pivot_field,
        field_value
        FROM
          (
            SELECT
              ticket_id,
              field_name AS field_name,
              MIN(updated) AS updated_min,
              MAX(updated) AS updated_max,
              NULL AS created_max,
              NULL AS created_min
            FROM
              gabby.zendesk.ticket_field_history
            WHERE
              field_name IN ('group_id', 'assignee_id', 'requester_id', 'status')
            GROUP BY
              ticket_id,
              field_name
            UNION ALL
            SELECT
              ticket_id,
              'solved' AS field_name,
              MIN(updated) AS updated_min,
              MAX(updated) AS updated_max,
              NULL AS created_max,
              NULL AS created_min
            FROM
              gabby.zendesk.ticket_field_history
            WHERE
              VALUE = 'solved'
            GROUP BY
              ticket_id
            UNION ALL
            SELECT
              ticket_id,
              'all' AS field_name,
              MIN(updated) AS updated_min,
              MAX(updated) AS updated_max,
              NULL AS created_max,
              NULL AS created_min
            FROM
              gabby.zendesk.ticket_field_history
            GROUP BY
              ticket_id
            UNION ALL
            SELECT
              ticket_id,
              'comment' AS field_name,
              NULL AS updated_min,
              NULL AS updated_max,
              MAX(created) AS created_max,
              MIN(
                CASE
                  WHEN [public] = 1 THEN created
                END
              ) AS created_min
            FROM
              gabby.zendesk.ticket_comment
            GROUP BY
              ticket_id
          ) sub UNPIVOT (field_value FOR metric_name IN (updated_min, updated_max, created_max, created_min)) u
      ) sub PIVOT (
        MAX(field_value) FOR pivot_field IN (
          assignee_id_updated_max,
          assignee_id_updated_min,
          requester_id_updated_max,
          status_updated_max,
          solved_updated_max,
          all_updated_max,
          comment_created_max,
          comment_created_min
        )
      ) p
  ),
  count_metrics AS (
    SELECT
      ticket_id,
      group_id_value_count_distinct AS group_stations,
      assignee_id_value_count_distinct AS assignee_stations
    FROM
      (
        SELECT
          ticket_id,
          field_name + '_value_count_distinct' AS field_name,
          COUNT(DISTINCT VALUE) AS value_count
        FROM
          gabby.zendesk.ticket_field_history
        WHERE
          field_name IN ('group_id', 'assignee_id')
        GROUP BY
          ticket_id,
          field_name
      ) sub PIVOT (
        MAX(value_count) FOR field_name IN (group_id_value_count_distinct, assignee_id_value_count_distinct)
      ) p
  ),
  reopens AS (
    SELECT
      ticket_id,
      COUNT(ticket_id) AS reopens
    FROM
      (
        SELECT
          ticket_id,
          VALUE AS current_status,
          LAG(VALUE, 1, 'new') OVER (
            PARTITION BY
              ticket_id
            ORDER BY
              ticket_id,
              updated
          ) AS prev_status
        FROM
          gabby.zendesk.ticket_field_history
        WHERE
          field_name = 'status'
      ) sub
    WHERE
      current_status = 'open'
      AND prev_status = 'solved'
    GROUP BY
      ticket_id
  )
SELECT
  t.id AS ticket_id,
  t.created_at,
  dm.assigned_at
  --ASSIGNEE_UPDATED_AT is incorrect
,
  dm.initially_assigned_at,
  dm.requester_updated_at,
  dm.status_updated_at,
  dm.solved_at,
  dm.updated_at,
  dm.latest_comment_added_at,
  dm.initial_comment_added_at,
  cm.assignee_stations,
  cm.group_stations,
  r.reopens
FROM
  gabby.zendesk.ticket t
  LEFT JOIN date_metrics dm ON t.id = dm.ticket_id
  LEFT JOIN count_metrics cm ON t.id = cm.ticket_id
  LEFT JOIN reopens r ON t.id = r.ticket_id
