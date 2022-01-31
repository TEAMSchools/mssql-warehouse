USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_data AS

SELECT cur.survey_response_id
      ,cur.survey_id
      ,cur.date_started
      ,cur.question_id
      ,cur.section_id
      ,cur.[type]
      ,cur.question
      ,cur.answer_id
      ,cur.answer
      ,cur.options
      ,cur.options_list
      ,cur.shown
FROM gabby.surveygizmo.survey_response_data_current_static cur

UNION ALL

SELECT rcv.survey_response_id
      ,rcv.survey_id
      ,rcv.date_started
      ,rcv.question_id
      ,rcv.section_id
      ,rcv.[type]
      ,rcv.question
      ,rcv.answer_id
      ,rcv.answer
      ,rcv.options
      ,rcv.options_list
      ,rcv.shown
FROM gabby.surveygizmo.survey_response_data_archive rcv
