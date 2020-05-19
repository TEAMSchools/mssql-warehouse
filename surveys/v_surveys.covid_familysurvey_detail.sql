USE gabby
GO

CREATE OR ALTER VIEW surveys.covid_familysurvey_detail AS

WITH response_ids AS (
  SELECT survey_id
        ,survey_response_id
        ,date_started
        ,grade_level
        ,location AS school_site
  FROM (
       SELECT sq.survey_id
             ,sq.shortname

             ,srd.survey_response_id
             ,srd.date_started
             ,srd.answer
       FROM gabby.surveygizmo.survey_question_clean_static sq
       JOIN gabby.surveygizmo.survey_response_data_static srd
         ON sq.survey_id = srd.survey_id
        AND sq.survey_question_id = srd.question_id
        AND srd.answer IS NOT NULL
       WHERE sq.survey_id = 5593585
      ) sub
  PIVOT(
    MAX(answer)
    FOR shortname IN (grade_level
                     ,[location])
       ) p
       ) 
SELECT s.survey_id
      ,s.title AS survey_title

      ,sq.shortname AS question_shortname
      ,sq.title_clean AS question_title
      ,sq.is_open_ended

      ,srd.survey_response_id
      ,srd.date_started

      ,r.grade_level
      ,r.school_site

      ,COALESCE(qo.option_title_english, srd.answer) AS answer

      ,CASE WHEN ISNUMERIC(qo.option_value) = 0 THEN NULL ELSE qo.option_value END AS answer_value

      ,sc.academic_year
      ,sc.reporting_term_code
      ,sc.name AS campaign_name

FROM surveygizmo.survey_clean s
JOIN gabby.surveygizmo.survey_question_clean_static sq
  ON s.survey_id = sq.survey_id
 AND sq.base_type = 'Question'
 AND sq.[type] IN ('RADIO', 'ESSAY', 'TEXTBOX')
JOIN gabby.surveygizmo.survey_response_data_static srd
  ON sq.survey_id = srd.survey_id
 AND sq.survey_question_id = srd.question_id
 AND srd.answer IS NOT NULL
JOIN gabby.surveygizmo.survey_response_clean_static sr
  ON sq.survey_id = sr.survey_id
 AND srd.survey_response_id = sr.survey_response_id
JOIN response_ids r
  ON s.survey_id = r.survey_id
 AND srd.survey_response_id = r.survey_response_id
LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
  ON r.survey_id = qo.survey_id
 AND sq.survey_question_id = qo.question_id
 AND srd.answer_id = qo.option_id
LEFT JOIN gabby.surveygizmo.survey_campaign_clean_static sc
  ON s.survey_id = sc.survey_id
 AND srd.date_started BETWEEN sc.link_open_date AND sc.link_close_date
WHERE sr.[status] = 'Complete'