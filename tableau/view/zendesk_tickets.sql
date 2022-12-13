USE gabby GO
CREATE OR ALTER VIEW
  tableau.zendesk_tickets AS
WITH
  field_crosswalk AS (
    SELECT
      g.id,
      g.[name] AS field_value,
      'group_id' AS field_name
    FROM
      gabby.zendesk.[group] g
    UNION ALL
    SELECT
      u.id,
      u.email AS field_value,
      'assignee_id' AS field_name
    FROM
      gabby.zendesk.[user] u
  ),
  original_value AS (
    SELECT
      fh.ticket_id,
      fh.field_name,
      fc.field_value,
      ROW_NUMBER() OVER (
        PARTITION BY
          fh.ticket_id,
          fh.field_name
        ORDER BY
          fh.updated ASC
      ) AS field_rn
    FROM
      gabby.zendesk.ticket_field_history fh
      LEFT JOIN field_crosswalk fc ON fh.field_name = fc.field_name
      AND fh.[value] = fc.id
    WHERE
      fh.field_name IN ('group_id', 'assignee_id')
  ),
  group_updated AS (
    SELECT
      fh.ticket_id,
      MAX(fh.updated) AS group_updated
    FROM
      gabby.zendesk.ticket_field_history fh
    WHERE
      fh.field_name = 'group_id'
    GROUP BY
      fh.ticket_id
  )
SELECT
  t.id AS ticket_id,
  t.created_at,
  t.[status] AS ticket_status,
  t.custom_category AS category,
  t.custom_tech_tier AS tech_tier,
  t.custom_location AS [location],
  CAST(t.[subject] AS NVARCHAR(512)) AS ticket_subject,
  CONCAT('https://teamschools.zendesk.com/agent/tickets/', t.id) AS ticket_url,
  DATEDIFF(WEEKDAY, t.created_at, gu.group_updated) AS weekdays_created_to_last_group,
  DATEDIFF(WEEKDAY, t.created_at, tm.solved_at) AS weekdays_created_to_solved,
  s.[name] AS submitter_name,
  a.[name] AS assignee,
  tm.assignee_updated_at,
  tm.initially_assigned_at,
  tm.solved_at,
  tm.replies AS comments_count,
  tm.full_resolution_time_in_minutes_business AS total_bh_minutes,
  tm.reply_time_in_minutes_business,
  tm.assignee_stations,
  tm.group_stations,
  DATEDIFF(WEEKDAY, t.created_at, tm.initially_assigned_at) AS weekdays_created_to_first_assigned,
  DATEDIFF(WEEKDAY, t.created_at, tm.assignee_updated_at) AS weekdays_created_to_last_assigned,
  og.field_value AS original_group,
  gu.group_updated AS group_updated,
  g.[name] AS last_group,
  c.primary_job AS assignee_primary_job,
  c.primary_site AS assignee_primary_site,
  c.legal_entity_name AS assignee_legal_entity,
  sx.primary_on_site_department AS submitter_dept,
  sx.primary_job AS submitter_job,
  sx.primary_site AS submitter_site,
  sx.legal_entity_name AS submitter_entity,
  oad.preferred_name AS original_assignee,
  oad.primary_job AS orig_assignee_job,
  oad.primary_on_site_department AS orig_assignee_dept
FROM
  gabby.zendesk.ticket t
  LEFT JOIN gabby.zendesk.[user] s ON t.submitter_id = s.id
  LEFT JOIN gabby.zendesk.[user] a ON t.assignee_id = a.id
  LEFT JOIN gabby.zendesk.ticket_metrics_clean tm ON t.id = tm.ticket_id
  LEFT JOIN original_value og ON t.id = og.ticket_id
  AND og.field_name = 'group_id'
  AND og.field_rn = 1
  LEFT JOIN group_updated gu ON t.id = gu.ticket_id
  LEFT JOIN gabby.zendesk.[group] g ON t.group_id = g.id
  LEFT JOIN gabby.people.staff_crosswalk_static c ON a.email = c.userprincipalname
  LEFT JOIN gabby.people.staff_crosswalk_static sx ON s.email = sx.userprincipalname
  LEFT JOIN original_value oa ON t.id = oa.ticket_id
  AND oa.field_name = 'assignee_id'
  AND oa.field_rn = 1
  LEFT JOIN gabby.people.staff_crosswalk_static oad ON oa.field_value = oad.userprincipalname
WHERE
  t.[status] <> 'deleted'
