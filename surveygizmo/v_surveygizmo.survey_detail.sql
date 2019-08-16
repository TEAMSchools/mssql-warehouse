USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_detail AS

SELECT s.survey_id
      ,s.title AS survey_title

      ,sr.survey_response_id
      ,sr.contact_id
      ,sr.date_started
      ,sr.date_submitted
      ,sr.response_time

      ,sc.[name] AS campaign_name
      ,sc.academic_year

      ,sq.shortname
      ,sq.title_english

      ,srd.answer

      ,qo.value AS answer_value
FROM gabby.surveygizmo.survey_clean s
JOIN gabby.surveygizmo.survey_response_clean sr
  ON s.survey_id = sr.survey_id
 AND sr.[status] = 'Complete'
LEFT JOIN gabby.surveygizmo.survey_campaign_clean sc
  ON sr.survey_id = sc.survey_id
 AND sr.date_started BETWEEN sc.link_open_date AND sc.link_close_date
JOIN gabby.surveygizmo.survey_question_clean sq
  ON s.survey_id = sq.survey_id
 AND sq.base_type = 'Question'
LEFT JOIN gabby.surveygizmo.survey_response_data srd
  ON sr.survey_id = srd.survey_id
 AND sr.survey_response_id = srd.survey_response_id
 AND sq.survey_question_id = srd.question_id
LEFT JOIN gabby.surveygizmo.survey_question_options qo
  ON sq.survey_id = qo.survey_id
 AND sq.survey_question_id = qo.question_id
 AND srd.answer_id = qo.option_id