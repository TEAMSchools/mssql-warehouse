USE gabby 
GO

CREATE OR ALTER VIEW surveys.staff_information_survey_detail AS 

SELECT sub.employee_number
      ,sub.survey_id
      ,sub.survey_response_id
      ,sub.campaign_academic_year
      ,sub.campaign_reporting_term
      ,sub.campaign_name
      ,sub.date_started
      ,sub.date_submitted
      ,sub.question_id
      ,sub.answer
      ,CASE 
        WHEN sub.question_id IN (5, 8, 21, 30) THEN sub.question_shortname + CONVERT(VARCHAR(2), sub.rn_multiselect)
        ELSE sub.question_shortname
       END AS question_shortname
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.employee_number, sub.survey_id, sub.campaign_name, sub.question_shortname, sub.rn_multiselect
           ORDER BY sub.date_submitted DESC, sub.survey_response_id DESC) AS rn_campaign
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.employee_number, sub.survey_id, sub.question_shortname, sub.rn_multiselect 
           ORDER BY sub.date_submitted DESC, sub.survey_response_id DESC) AS rn_cur
FROM
    (
     SELECT sri.subject_df_employee_number AS employee_number
           ,sri.survey_id
           ,sri.survey_response_id
           ,sri.campaign_academic_year
           ,sri.campaign_reporting_term
           ,sri.campaign_name
           ,sri.date_started
           ,sri.date_submitted

           ,sd.question_id
           ,sd.question

           ,sq.shortname

           ,COALESCE(
              CASE
               WHEN qo.question_id = 5 THEN 'race_ethnicity_'
               WHEN qo.question_id = 8 THEN 'community_live_'
               WHEN qo.question_id = 21 THEN 'community_work_'
               WHEN qo.question_id = 30 THEN 'teacher_prep_'
              END
             ,sq.shortname
             ,LOWER(REPLACE(sd.question, ' ', '_'))
            ) AS question_shortname
           ,COALESCE(sd.answer, qo.option_value) AS answer
           ,ROW_NUMBER() OVER(
              PARTITION BY sd.survey_id, sd.survey_response_id, sd.question_id
                ORDER BY qo.option_value) AS rn_multiselect
     FROM gabby.surveygizmo.survey_response_identifiers_static sri
     INNER JOIN gabby.surveygizmo.survey_response_data sd
       ON sri.survey_id = sd.survey_id
      AND sri.survey_response_id = sd.survey_response_id
     INNER JOIN gabby.surveygizmo.survey_question_clean_static sq
       ON sd.survey_id = sq.survey_id
      AND sd.question_id = sq.survey_question_id
      AND sq.base_type = 'Question'
     LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
       ON sd.survey_id = qo.survey_id
      AND sd.question_id = qo.question_id
      AND qo.option_disabled = 0
      AND CHARINDEX(qo.option_id, sd.options) > 0
     WHERE sri.survey_id = 6330385
       AND sri.[status] = 'Complete'
    ) sub
