USE gabby GO
WITH
  ticket_dates AS (
    SELECT
      t.id AS ticket_id,
      t.created_at,
      MIN(tc.created) AS solved_at
    FROM
      gabby.zendesk.ticket AS t
      INNER JOIN gabby.zendesk.ticket_comment AS tc ON t.id = tc.ticket_id
      AND t.submitter_id <> tc.user_id
    GROUP BY
      t.id,
      t.created_at
  ),
  business_hours AS (
    SELECT
      DATEPART(WEEKDAY, business_hours_start) AS dw_numeric,
      DATEPART(HOUR, business_hours_start) AS start_hour,
      DATEPART(HOUR, business_hours_end) AS end_hour
    FROM
      (
        SELECT
          DATEADD(
            MINUTE,
            start_time_utc,
            DATEADD(
              DAY,
              - (DATEPART(WEEKDAY, CURRENT_TIMESTAMP) - 1),
              CAST(CAST(CURRENT_TIMESTAMP AS DATE))
            ) AS DATETIME2
          ) AS business_hours_start,
          DATEADD(
            MINUTE,
            end_time_utc,
            DATEADD(
              DAY,
              - (DATEPART(WEEKDAY, CURRENT_TIMESTAMP) - 1),
              CAST(CAST(CURRENT_TIMESTAMP AS DATE))
            ) AS DATETIME2
          ) AS business_hours_end
        FROM
          gabby.zendesk.schedule
      ) sub
  )
SELECT
  ticket_id,
  SUM(bh_day_minutes) AS total_bh_minutes
FROM
  (
    SELECT
      ticket_id,
      sub.created_at,
      sub.solved_at,
      sub.date,
      DATEDIFF(
        MINUTE,
        bh_day_start_timestamp,
        bh_day_end_timestamp
      ) AS bh_day_minutes
    FROM
      (
        SELECT
          ticket_id,
          sub.created_at,
          sub.solved_at,
          sub.date,
          CASE
            WHEN solved_at < bh_start_timestamp THEN NULL
            WHEN created_at (
              BETWEEN bh_start_timestamp AND bh_end_timestamp
            ) THEN created_at
            WHEN created_at < bh_start_timestamp THEN bh_start_timestamp
          END AS bh_day_start_timestamp,
          CASE
            WHEN sub.created_at > bh_end_timestamp THEN NULL
            WHEN solved_at (
              BETWEEN bh_start_timestamp AND bh_end_timestamp
            ) THEN sub.solved_at
            WHEN solved_at > bh_end_timestamp THEN bh_end_timestamp
          END AS bh_day_end_timestamp
        FROM
          (
            SELECT
              td.ticket_id,
              td.created_at,
              td.solved_at,
              rd.date,
              DATETIME2FROMPARTS(
                rd.year_part,
                rd.month_part,
                rd.day_part,
                bh.start_hour,
                0,
                0,
                0,
                0
              ) AS bh_start_timestamp,
              DATETIME2FROMPARTS(
                rd.year_part,
                rd.month_part,
                rd.day_part,
                bh.end_hour,
                0,
                0,
                0,
                0
              ) AS bh_end_timestamp
            FROM
              ticket_dates AS td
              INNER JOIN gabby.utilities.reporting_days AS rd ON rd.date (
                BETWEEN CAST(td.created_at AS DATE) AND CAST(td.solved_at AS DATE)
              )
              LEFT JOIN business_hours AS bh ON rd.dw_numeric = bh.dw_numeric
            WHERE
              td.ticket_id = 159300
          ) sub
      ) sub
  ) sub
GROUP BY
  ticket_id
