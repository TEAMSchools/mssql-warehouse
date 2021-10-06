USE gabby 
GO

CREATE OR ALTER VIEW surveys.staff_information_survey_detail AS 

WITH survey_identifier AS (
  SELECT survey_id
        ,survey_response_id
        ,employee_number
        ,employee_preferred_name
        ,CASE WHEN employee_number = CASE
                                       WHEN CHARINDEX('[', employee_preferred_name) = 0 THEN NULL
                                       ELSE SUBSTRING(
                                              employee_preferred_name
                                             ,CHARINDEX('[', employee_preferred_name) + 1
                                             ,CHARINDEX(']', employee_preferred_name) 
                                                - CHARINDEX('[', employee_preferred_name) - 1
                                            )
                                      END
               THEN 1
               ELSE 0 
              END AS valid_respondant
  FROM (SELECT s.survey_id
              ,s.survey_response_id
              ,CONVERT(VARCHAR(250),sq.shortname) AS shortname
              ,s.answer
        FROM gabby.surveygizmo.survey_response_data_static s
        JOIN gabby.surveygizmo.survey_question_clean_static sq
          ON s.survey_id = sq.survey_id
         AND s.question_id = sq.survey_question_id
         AND sq.base_type = 'Question'
        WHERE s.survey_id = 6330385
          AND sq.shortname IN ('employee_number', 'employee_preferred_name')
        ) sub
        PIVOT( MAX(answer) FOR shortname IN (employee_preferred_name
                                                     ,employee_number)
             ) p

  )

SELECT employee_number
      ,survey_id
      ,survey_response_id
      ,campaign_academic_year
      ,campaign_reporting_term
      ,campaign_name
      ,date_started
      ,date_submitted
      ,question_id
      ,CASE 
        WHEN question_id IN (5, 8, 21, 30) THEN question_shortname + CONVERT(VARCHAR(2),rn_multiselect)
        ELSE question_shortname
       END as question_shortname
      ,answer
      ,ROW_NUMBER() OVER( PARTITION BY employee_number, survey_id, campaign_name, question_shortname, rn_multiselect ORDER BY date_submitted DESC, survey_response_id DESC) AS rn_campaign
      ,ROW_NUMBER() OVER( PARTITION BY employee_number, survey_id,question_shortname, rn_multiselect ORDER BY date_submitted DESC, survey_response_id DESC) AS rn_cur
FROM (
      SELECT si.employee_number
            ,si.survey_id
            ,si.survey_response_id

            ,sri.campaign_academic_year
            ,sri.campaign_reporting_term
            ,sri.campaign_name
            ,sri.date_started
            ,sri.date_submitted

            ,sd.question_id
            ,COALESCE(CASE 
                           WHEN qo.question_id = 5 THEN 'race_ethnicity_'
                           WHEN qo.question_id = 8 THEN 'community_live_'
                           WHEN qo.question_id = 21 THEN 'community_work_'
                           WHEN qo.question_id = 30 THEN 'teacher_prep_'
                         ELSE NULL
                        END
                      ,sq.shortname
                      ,LOWER(REPLACE(question,' ','_'))) AS question_shortname
            ,COALESCE(sd.answer,qo.option_value) AS answer
            ,ROW_NUMBER() OVER( PARTITION BY sd.survey_id, sd.survey_response_id, sd.question_id ORDER BY qo.option_value) AS rn_multiselect
      FROM survey_identifier si
      JOIN gabby.surveygizmo.survey_response_data_static sd
        ON si.survey_id = sd.survey_id
       AND si.survey_response_id = sd.survey_response_id
       AND si.valid_respondant = 1
      JOIN gabby.surveygizmo.survey_response_identifiers_static sri
        ON si.survey_id = sri.survey_id
       AND si.survey_response_id = sri.survey_response_id
       AND sri.[status] = 'Complete'
      JOIN gabby.surveygizmo.survey_question_clean_static sq
        ON sd.survey_id = sq.survey_id
       AND sd.question_id = sq.survey_question_id
       AND sq.base_type = 'Question'
      LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
        ON sd.survey_id = qo.survey_id
       AND sd.question_id = qo.question_id
       AND qo.option_disabled = 0
       AND CHARINDEX(qo.option_id,sd.options) > 0
      WHERE sd.survey_id = 6330385
      ) sub