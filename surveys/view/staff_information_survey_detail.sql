CREATE OR ALTER VIEW
  surveys.staff_information_survey_detail AS
SELECT
  employee_number,
  survey_id,
  survey_response_id,
  campaign_academic_year,
  campaign_reporting_term,
  campaign_name,
  date_started,
  date_submitted,
  question_id,
  answer,
  CASE
    WHEN question_id IN (5, 8, 21, 30) THEN (
      question_shortname + CAST(rn_multiselect AS VARCHAR(2))
    )
    ELSE question_shortname
  END AS question_shortname,
  ROW_NUMBER() OVER (
    PARTITION BY
      employee_number,
      survey_id,
      campaign_name,
      question_shortname,
      rn_multiselect
    ORDER BY
      date_submitted DESC,
      survey_response_id DESC
  ) AS rn_campaign,
  ROW_NUMBER() OVER (
    PARTITION BY
      employee_number,
      survey_id,
      question_shortname,
      rn_multiselect
    ORDER BY
      date_submitted DESC,
      survey_response_id DESC
  ) AS rn_cur
FROM
  (
    SELECT
      sri.subject_df_employee_number AS employee_number,
      sri.survey_id,
      sri.survey_response_id,
      sri.campaign_academic_year,
      sri.campaign_reporting_term,
      sri.campaign_name,
      sri.date_started,
      sri.date_submitted,
      sd.question_id,
      sd.question,
      sq.shortname,
      COALESCE(
        CASE
          WHEN qo.question_id = 5 THEN 'race_ethnicity_'
          WHEN qo.question_id = 8 THEN 'community_live_'
          WHEN qo.question_id = 21 THEN 'community_work_'
          WHEN qo.question_id = 30 THEN 'teacher_prep_'
        END,
        sq.shortname,
        LOWER(REPLACE(sd.question, ' ', '_'))
      ) AS question_shortname,
      COALESCE(sd.answer, qo.option_value) AS answer,
      ROW_NUMBER() OVER (
        PARTITION BY
          sd.survey_id,
          sd.survey_response_id,
          sd.question_id
        ORDER BY
          qo.option_value
      ) AS rn_multiselect
    FROM
      gabby.surveygizmo.survey_response_identifiers_static AS sri
      INNER JOIN gabby.surveygizmo.survey_response_data AS sd ON (
        sri.survey_id = sd.survey_id
        AND sri.survey_response_id = sd.survey_response_id
      )
      INNER JOIN gabby.surveygizmo.survey_question_clean_static AS sq ON (
        sd.survey_id = sq.survey_id
        AND sd.question_id = sq.survey_question_id
        AND sq.base_type = 'Question'
      )
      LEFT JOIN gabby.surveygizmo.survey_question_options_static AS qo ON (
        sd.survey_id = qo.survey_id
        AND sd.question_id = qo.question_id
        AND qo.option_disabled = 0
        AND CHARINDEX(qo.option_id, sd.options) > 0
      )
    WHERE
      sri.survey_id = 6330385
      AND sri.[status] = 'Complete'
      AND sri.rn_respondent_subject = 1
  ) AS sub