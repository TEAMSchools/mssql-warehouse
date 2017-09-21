USE gabby
GO

--CREATE VIEW tableau.zendesk_ticket_comprehensive#TESTVIEW AS

WITH comments_count AS (

	SELECT c.ticket_id
		  ,COUNT(c.ticket_id) as comments_count
	FROM zendesk.ticket_comments c
	GROUP BY c.ticket_id
)

SELECT 
	   t.id
	  ,t.subject
	  ,t.description
	  ,t.request_status
  	  ,t.location
	  ,t.recipient
	  ,t.status
	  
	  ,t.created_at
	  ,t.updated_at
	  ,'Need to get calculation of timespent from created_at to t.updated_at' AS time_spent
	  ,t.due_at

	  ,comments_count.comments_count

	  ,t.group_id
	  ,g.name
  	  ,t.category
	  ,t.tech_tier

	  ,t.submitter_id
	  ,submitter.name
	  ,t.assignee_id
	  ,assignee.name
	  
--custom fields that we likely do not use
	  ,t.url
	  ,t.requester_id
	  ,t.organization_id
	  ,t.via_channel
	  ,t.type
	  ,t.priority
	  ,t.forum_topic_id
	  ,t.problem_id
	  ,t.has_incidents
	  ,t.ticket_form_id
	  ,t.assignee
	  ,t.assignee_to
	  ,t.my_date
	  ,t.my_cat
	  ,t.date_ordered
	  ,t.actual_received_date
	  ,t.order_date
	  ,t.delivery_date
	  ,t.request_status
	  ,t.po
	  ,t.vendor
	  ,t.check_cut_date
	  ,t.total_time_spent_sec_
	  ,t.time_spent_last_update_sec_
	  ,t.department
     
FROM zendesk.tickets t

JOIN comments_count 
  ON t.id = comments_count.ticket_id

JOIN zendesk.groups g
  ON t.group_id = g.id

JOIN zendesk.users submitter
  ON submitter.id = t.submitter_id

JOIN zendesk.users assignee
  ON assignee.id = t.assignee_id

WHERE t.status != 'deleted'
  AND g.id IN (20148286, 21474460, 20249168) --data, tech, ha
  AND t.created_at >= '2015-07-01'


