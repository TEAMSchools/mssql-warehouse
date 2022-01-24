USE gabby
GO

--CREATE OR ALTER VIEW tableau.zendesk_tickets AS
WITH original_group AS
(SELECT 
       sub.ticket_id
      ,g.[name] AS group_name
  FROM
      (SELECT *,
              ROW_NUMBER() OVER(
              PARTITION BY ticket_id, field_name
              ORDER BY updated) AS group_rn
              FROM gabby.zendesk.ticket_field_history fh
              WHERE field_name = 'group_id')
              AS sub
JOIN zendesk.[group] g
ON sub.[value] = g.id
WHERE sub.group_rn = 1
)

,group_updated AS
(SELECT 
        ticket_id
       ,MAX(updated) AS group_updated
FROM gabby.zendesk.ticket_field_history fh
WHERE field_name = 'group_id'
GROUP BY ticket_id
)

,original_assignee AS
(SELECT 
       sub.ticket_id
      ,sub.assignee_rn
      ,sub.updated AS assignee_updated
<<<<<<< Updated upstream
      ,u.[name] AS assignee_name
=======
      ,u.name AS assignee_name
>>>>>>> Stashed changes
      ,scw.primary_on_site_department as orig_assignee_dept
      ,scw.primary_job AS orig_assignee_job
      ,scw.legal_entity_name
      
FROM (SELECT *,
           ROW_NUMBER() OVER(
           PARTITION BY ticket_id, field_name
<<<<<<< Updated upstream
           ORDER BY updated) AS assignee_rn
=======
           ORDER BY updated DESC) AS assignee_rn
>>>>>>> Stashed changes
      FROM gabby.zendesk.ticket_field_history fh
       WHERE field_name = 'assignee_id' )
       AS sub
JOIN zendesk.[user] u
ON sub.[value] = u.id
JOIN gabby.people.staff_crosswalk_static scw
ON u.email = scw.userprincipalname
WHERE sub.assignee_rn = 1
)
<<<<<<< Updated upstream

,submitter_crosswalk AS (
  SELECT
        a.id
       ,c.df_employee_number
       ,c.legal_entity_name
       ,c.primary_job
       ,c.primary_on_site_department
  FROM zendesk.[user] a
  LEFT JOIN gabby.people.staff_crosswalk c
  ON a.email = c.userprincipalname
  WHERE c.userprincipalname IS NOT NULL
  )

SELECT 
       t.id AS ticket_id
      ,CONVERT(VARCHAR(500), t.[subject]) AS ticket_subject
      ,CASE 
       WHEN tm.assignee_stations < tm.group_stations THEN g.[name]
       WHEN c.primary_on_site_department IS NULL THEN g.[name]
       ELSE c.primary_on_site_department END AS last_assigned_dept_group -- if fewer assignees than groups, then the Zendesk group, if ADP department is null then the Zendesk group, otherwise, the last assignee's ADP department
      ,a.[name] AS assignee
      ,c.primary_job AS assignee_primary_job
      ,c.primary_site AS assignee_primary_site
      ,c.legal_entity_name AS assignee_legal_entity

      --time differences--
      ,tm.assignee_updated_at
      ,tm.initially_assigned_at
      ,gu.group_updated AS group_updated
=======


,submitter_crosswalk AS (
  SELECT
        a.id
       ,c.df_employee_number
       ,c.legal_entity_name
       ,c.primary_job
       ,c.primary_on_site_department
  FROM zendesk.[user] a
  LEFT JOIN gabby.people.staff_crosswalk c
  ON a.email = c.userprincipalname
  WHERE c.userprincipalname IS NOT NULL
  )

SELECT  
       t.id AS ticket_id
      ,CONVERT(VARCHAR(500), t.[subject]) AS ticket_subject

      --last assignee info --
      ,a.[name] AS last_assignee_name
      ,t.assignee_id AS assignee_id
      ,c.primary_job AS assignee_primary_job
      ,c.primary_site AS assignee_primary_site
      ,c.primary_on_site_department AS assignee_on_site_department
      ,c.legal_entity_name AS last_assignee_legal_entity
      ,g.[name] AS last_group

       --first group info--
      ,og.group_name AS og_group

       --group switch time--
      ,gu.group_updated AS group_updated
      ,t.created_at

      --first assignee info--
      ,oa.assignee_name AS original_assignee
      ,oa.assignee_updated
      ,oa.orig_assignee_dept
      ,oa.orig_assignee_job

      ,t.[status] AS ticket_status
      ,t.custom_location AS [location]
>>>>>>> Stashed changes
      ,t.created_at
      ,tm.solved_at
      ,tm.replies AS comments_count --remove?
      ,tm.full_resolution_time_in_minutes_business AS total_bh_minutes
      ,tm.reply_time_in_minutes_business
      ,DATEDIFF(WEEKDAY,t.created_at, tm.initially_assigned_at) AS created_to_first_assigned
      ,DATEDIFF(WEEKDAY,t.created_at,tm.assignee_updated_at) AS created_to_last_assigned
      ,DATEDIFF(WEEKDAY,t.created_at,gu.group_updated) AS created_to_last_group
      ,DATEDIFF(WEEKDAY,t.created_at,tm.solved_at) AS created_to_solved
      --first assignee info--
      ,oa.assignee_name AS original_assignee
      ,CASE
       WHEN tm.assignee_stations < tm.group_stations THEN og.group_name
       WHEN oa.orig_assignee_dept IS NULL THEN og.group_name
       ELSE oa.orig_assignee_dept END AS og_group
       --if fewer assignees than groups, then the original Zendesk group, if original assignee's ADP department null then the Zendesk group, otherwise, the original assignee's ADP department
      ,oa.orig_assignee_job

      --ticket info--
      ,t.[status] AS ticket_status
      ,t.custom_category AS category
      ,t.custom_tech_tier AS tech_tier
<<<<<<< Updated upstream

      --submitter info--
      ,sx.primary_on_site_department AS submitter_dept
      ,s.[name] AS submitter_name
      ,sx.primary_job AS submitter_job
      ,sx.legal_entity_name AS submitter_entity
      ,t.custom_location AS [location]
      ,CONCAT('https://teamschools.zendesk.com/agent/tickets/',t.id) AS ticket_url

=======
      ,t.group_id 

      --submitter info--
      ,t.submitter_id
      ,s.[name] AS submitter_name
      ,sx.df_employee_number AS submitter_employee_number
      ,sx.legal_entity_name AS submitter_entity
      ,sx.primary_job AS submitter_job
      ,sx.primary_on_site_department AS submitter_dept


      --ticket metrics--
      ,tm.replies AS comments_count
      ,tm.solved_at AS solved_timestamp
      ,tm.full_resolution_time_in_minutes_business AS total_bh_minutes
      ,tm.reply_time_in_minutes_business


>>>>>>> Stashed changes
FROM gabby.zendesk.ticket t
LEFT JOIN gabby.zendesk.[user] s
  ON t.submitter_id = s.id
LEFT JOIN gabby.zendesk.[user] a
  ON t.assignee_id = a.id
LEFT JOIN gabby.zendesk.[group] g
  ON t.group_id = g.id
LEFT JOIN gabby.people.staff_crosswalk c
  ON a.email = c.userprincipalname
LEFT JOIN gabby.zendesk.ticket_metrics_clean tm
  ON t.id = tm.ticket_id
LEFT JOIN original_group og
  ON t.id = og.ticket_id
LEFT JOIN group_updated gu
  ON t.id = gu.ticket_id
LEFT JOIN original_assignee oa
  ON t.id = oa.ticket_id
LEFT JOIN submitter_crosswalk sx
  ON t.submitter_id = sx.id
WHERE t.[status] <> 'deleted'
<<<<<<< Updated upstream
=======
AND t.id = '248371'

>>>>>>> Stashed changes

