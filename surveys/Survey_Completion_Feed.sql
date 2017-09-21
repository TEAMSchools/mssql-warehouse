CREATE VIEW AS Survey_Completion_feed

SELECT _created AS Date_completed
	,email AS Responder
	,subject_name AS Feedback_recipient
	,'Self & Others' AS Survey
FROM surveys.self_and_others_survey
	UNION
SELECT _created AS Date_completed
	,responder_name AS Responder
	,subject_name AS Feedback_recipient
	,'Manager' AS Survey	
FROM surveys.manager_survey

--Please post this view to a gdoc :)