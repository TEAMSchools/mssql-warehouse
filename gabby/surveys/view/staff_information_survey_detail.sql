CREATE OR ALTER VIEW
  surveys.staff_information_survey_detail AS
WITH
  responses AS (
    SELECT
      sri.survey_id,
      sri.subject_df_employee_number AS employee_number,
      sri.survey_response_id,
      sri.campaign_academic_year,
      sri.campaign_reporting_term,
      sri.campaign_name,
      sri.date_started,
      sri.date_submitted,
      sd.question_id,
      sd.options,
      sd.question,
      sd.answer,
      ROW_NUMBER() OVER (
        PARTITION BY
          sri.respondent_df_employee_number,
          sri.survey_id,
          sd.question_id
        ORDER BY
          sri.date_submitted DESC,
          sri.survey_response_id DESC
      ) AS rn_cur
    FROM
      surveygizmo.survey_response_identifiers_static AS sri
      INNER JOIN surveygizmo.survey_response_data AS sd ON (
        sri.survey_id = sd.survey_id
        AND sri.survey_response_id = sd.survey_response_id
        AND (
          sd.answer IS NOT NULL
          OR sd.question_id IN (5, 8, 21, 30)
        )
        AND sri.survey_id = 6330385
        AND sri.[status] = 'Complete'
        AND sri.rn_respondent_subject = 1
      )
  )
SELECT
  sub.employee_number,
  sub.survey_id,
  sub.survey_response_id,
  sub.campaign_academic_year,
  sub.campaign_reporting_term,
  sub.campaign_name,
  sub.date_started,
  sub.date_submitted,
  sub.question_id,
  sub.answer,
  CASE
    WHEN sub.question_id IN (5, 8, 21, 30) THEN (
      sub.question_shortname + CAST(sub.rn_multiselect AS VARCHAR(2))
    )
    ELSE sub.question_shortname
  END AS question_shortname,
  ROW_NUMBER() OVER (
    PARTITION BY
      sub.employee_number,
      sub.survey_id,
      sub.campaign_name,
      sub.question_shortname,
      sub.rn_multiselect
    ORDER BY
      sub.date_submitted DESC,
      sub.survey_response_id DESC
  ) AS rn_campaign,
  sub.rn_cur
FROM
  (
    SELECT
      r.employee_number,
      r.survey_id,
      r.survey_response_id,
      r.campaign_academic_year,
      r.campaign_reporting_term,
      r.campaign_name,
      r.date_started,
      r.date_submitted,
      r.question_id,
      r.question,
      r.rn_cur,
      sq.shortname,
      qo.question_id AS q_id,
      COALESCE(
        CASE
          WHEN qo.question_id = 5 THEN 'race_ethnicity_'
          WHEN qo.question_id = 8 THEN 'community_live_'
          WHEN qo.question_id = 21 THEN 'community_work_'
          WHEN qo.question_id = 30 THEN 'teacher_prep_'
        END,
        sq.shortname,
        LOWER(REPLACE(r.question, ' ', '_'))
      ) AS question_shortname,
      COALESCE(r.answer, qo.option_value) AS answer,
      ROW_NUMBER() OVER (
        PARTITION BY
          r.survey_id,
          r.survey_response_id,
          r.question_id
        ORDER BY
          qo.option_value
      ) AS rn_multiselect
    FROM
      responses AS r
      INNER JOIN surveygizmo.survey_question_clean_static AS sq ON (
        r.survey_id = sq.survey_id
        AND r.question_id = sq.survey_question_id
        AND sq.base_type = 'Question'
      )
      LEFT JOIN surveygizmo.survey_question_options_static AS qo ON (
        r.survey_id = qo.survey_id
        AND r.question_id = qo.question_id
        AND qo.option_disabled = 0
        AND CHARINDEX(qo.option_id, r.options) > 0
      )
  ) AS sub
