USE gabby
GO

CREATE OR ALTER VIEW tableau.zendesk_tickets AS

WITH comments_count AS (
	 SELECT c.ticket_id
		      ,COUNT(c.ticket_id) - 1 AS comments_count
	 FROM gabby.zendesk.ticket_comment c  
	 GROUP BY c.ticket_id
 )

,solved AS (
  SELECT ticket_id
        ,MAX(updated) AS updated
  FROM gabby.zendesk.ticket_field_history
  WHERE field_name = 'status'
    AND value = 'solved'
  GROUP BY ticket_id
 )

SELECT t.id AS ticket_id
	     ,CONVERT(VARCHAR(500),t.subject) AS ticket_subject
	     ,t.status AS ticket_status      
  	   ,t.custom_location AS location	     
	     ,t.created_at
	     ,t.updated_at
	     ,t.due_at      
      ,t.custom_category AS category
	     ,t.custom_tech_tier AS tech_tier
      ,t.group_id
      ,t.submitter_id
      ,t.assignee_id            

      ,s.name AS submitter_name

      ,a.name AS assignee_name
      ,a.custom_user_group AS assignee_user_group      

      ,g.name AS group_name

	     ,c.comments_count	       
      
      ,slv.updated AS solved_timestamp            
FROM gabby.zendesk.ticket t
LEFT JOIN gabby.zendesk.[user] s
  ON t.submitter_id = s.id
LEFT JOIN gabby.zendesk.[user] a
  ON t.assignee_id = a.id
LEFT JOIN gabby.zendesk.[group] g
  ON t.group_id = g.id
LEFT JOIN comments_count c
  ON t.id = c.ticket_id
LEFT JOIN solved slv
  ON t.id = slv.ticket_id
WHERE t.status != 'deleted'