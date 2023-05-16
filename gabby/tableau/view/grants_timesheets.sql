CREATE OR ALTER VIEW
  tableau.grants_timesheets AS
SELECT
  survey_id,
  survey_response_id,
  survey_title,
  respondent_df_employee_number,
  respondent_preferred_name,
  respondent_userprincipalname,
  respondent_legal_entity_name,
  respondent_primary_site,
  respondent_primary_job,
  [20] AS teammate_signature,
  [94] AS approver_signature,
  [72] AS approver_email,
  CONCAT(
    default_link,
    '?snc=',
    session_id,
    '&sg_navigate=start'
  ) AS edit_link
FROM
  (
    SELECT
      d.survey_id,
      d.survey_title,
      d.survey_response_id,
      d.respondent_df_employee_number,
      d.respondent_userprincipalname,
      d.respondent_legal_entity_name,
      d.respondent_preferred_name,
      d.respondent_primary_site,
      d.respondent_primary_job,
      d.survey_question_id,
      d.answer,
      c.default_link,
      r.session_id
    FROM
      gabby.surveygizmo.survey_detail AS d
      LEFT JOIN gabby.surveygizmo.survey_clean AS c ON (d.survey_id = c.survey_id)
      LEFT JOIN gabby.surveygizmo.survey_response_clean AS r ON (
        d.survey_id = r.survey_id
        AND d.survey_response_id = r.survey_response_id
      )
    WHERE
      d.survey_id IN (7151740, 7196293)
      AND d.respondent_df_employee_number IS NOT NULL
  ) AS sub PIVOT (
    MAX(answer) FOR survey_question_id IN ([20], [94], [72])
  ) AS p
