USE gabby
GO

CREATE OR ALTER VIEW tableau.zendesk_tickets AS

WITH comments_count AS (
	 SELECT c.ticket_id
		      ,COUNT(c.ticket_id) as comments_count
	 FROM gabby.zendesk.ticket_comments c
	 GROUP BY c.ticket_id
 )

,solved AS (
  SELECT ticket_id
        ,timestamp
        ,ROW_NUMBER() OVER(
          PARTITION BY ticket_id
            ORDER BY timestamp DESC) AS rn
  FROM gabby.zendesk.ticket_history
  WHERE property = 'status'
    AND new_value = 'solved'
 )

SELECT t.id AS ticket_id
	     ,CONVERT(NVARCHAR,t.subject) AS ticket_subject	     
	     ,t.status AS ticket_status      
  	   ,t.location	     
	     ,t.created_at
	     ,t.updated_at
	     ,t.due_at      
      ,t.category
	     ,t.tech_tier
      ,t.group_id
      ,t.submitter_id
      ,t.assignee_id            

      ,s.name AS submitter_name

      ,a.name AS assignee_name

      ,g.name AS group_name

	     ,c.comments_count	       
      
      ,slv.timestamp AS solved_timestamp            
FROM gabby.zendesk.tickets t
JOIN gabby.zendesk.users s
  ON t.submitter_id = s.id
LEFT OUTER JOIN gabby.zendesk.users a
  ON t.assignee_id = a.id
LEFT OUTER JOIN gabby.zendesk.groups g
  ON t.group_id = g.id
JOIN comments_count c
  ON t.id = c.ticket_id
LEFT OUTER JOIN solved slv
  ON t.id = slv.ticket_id
 AND slv.rn = 1
WHERE t.status != 'deleted'