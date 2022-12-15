USE gabby GO
CREATE OR ALTER VIEW
  tableau.kipp_forward_survey AS
WITH
  alumni_data AS (
    SELECT
      e.student_c,
      e.[name],
      e.pursuing_degree_type_c,
      e.type_c,
      e.start_date_c,
      e.actual_end_date_c,
      e.major_c,
      e.status_c,
      ROW_NUMBER() OVER (
        PARTITION BY
          e.student_c
        ORDER BY
          e.actual_end_date_c DESC
      ) AS rn_latest,
      c.first_name,
      c.last_name,
      c.[email],
      c.secondary_email_c AS [email2],
      c.kipp_ms_graduate_c,
      c.kipp_hs_graduate_c,
      c.kipp_hs_class_c,
      c.college_match_display_gpa_c,
      c.kipp_region_name_c,
      c.[description],
      c.gender_c,
      c.ethnicity_c
    FROM
      gabby.alumni.enrollment_c AS e
      INNER JOIN gabby.alumni.contact AS c ON e.student_c = c.id
    WHERE
      e.status_c = 'Graduated'
      AND e.is_deleted = 0
  ),
  survey_pivot AS (
    SELECT
      respondent_salesforce_id,
      date_submitted,
      survey_response_id,
      survey_title,
      survey_id,
      [first_name],
      [last_name],
      [after_grad],
      [alumni_dob],
      [alumni_email],
      [alumni_phone],
      [cur_1],
      [cur_2],
      [cur_3],
      [cur_4],
      [cur_5],
      [cur_6],
      [cur_7],
      [cur_8],
      [cur_9],
      [cur_10],
      [job_sat],
      [ladder],
      [covid],
      [linkedin],
      [linkedin_link],
      [debt_binary],
      [debt_amount],
      [annual_income]
    FROM
      (
        SELECT
          respondent_salesforce_id,
          question_shortname,
          answer,
          survey_title,
          date_submitted,
          survey_response_id,
          survey_id
        FROM
          gabby.surveygizmo.survey_detail
        WHERE
          survey_id = 6734664
      ) sub PIVOT (
        MAX(answer) FOR question_shortname IN (
          [first_name],
          [last_name],
          [alumni_dob],
          [alumni_email],
          [alumni_phone],
          [after_grad],
          [cur_1],
          [cur_2],
          [cur_3],
          [cur_4],
          [cur_5],
          [cur_6],
          [cur_7],
          [cur_8],
          [cur_9],
          [cur_10],
          [job_sat],
          [ladder],
          [covid],
          [linkedin],
          [linkedin_link],
          [debt_binary],
          [debt_amount],
          [annual_income]
        )
      ) p
  ),
  weight_denominator AS (
    SELECT
      survey_id,
      SUM(CAST(answer_value AS FLOAT)) AS answer_total
    FROM
      gabby.surveygizmo.survey_detail
    WHERE
      survey_id = 6734664
      AND question_shortname IN (
        'imp_1',
        'imp_2',
        'imp_3',
        'imp_4',
        'imp_5',
        'imp_6',
        'imp_7',
        'imp_8',
        'imp_9',
        'imp_10'
      )
    GROUP BY
      survey_id
  ),
  weight_table AS (
    SELECT
      s.question_shortname,
      (
        SUM(CAST(s.answer_value AS FLOAT)) / a.answer_total
      ) * 10 AS item_weight
    FROM
      weight_denominator AS a
      LEFT JOIN surveygizmo.survey_detail AS s ON a.survey_id = s.survey_id
      AND s.survey_id = 6734664
      AND s.question_shortname IN (
        'imp_1',
        'imp_2',
        'imp_3',
        'imp_4',
        'imp_5',
        'imp_6',
        'imp_7',
        'imp_8',
        'imp_9',
        'imp_10'
      )
    GROUP BY
      s.question_shortname,
      a.answer_total
  ),
  weight_pivot AS (
    SELECT
      '6734664' AS survey_id,
      [imp_1],
      [imp_2],
      [imp_3],
      [imp_4],
      [imp_5],
      [imp_6],
      [imp_7],
      [imp_8],
      [imp_9],
      [imp_10]
    FROM
      weight_table PIVOT (
        MAX(item_weight) FOR question_shortname IN (
          [imp_1],
          [imp_2],
          [imp_3],
          [imp_4],
          [imp_5],
          [imp_6],
          [imp_7],
          [imp_8],
          [imp_9],
          [imp_10]
        )
      ) p
  )
SELECT
  s.survey_title,
  s.survey_response_id,
  s.date_submitted,
  s.respondent_salesforce_id,
  s.first_name,
  s.last_name,
  s.alumni_phone,
  s.alumni_email,
  s.after_grad,
  s.alumni_dob,
  s.job_sat,
  s.ladder,
  s.covid,
  s.linkedin,
  s.linkedin_link,
  s.debt_binary,
  CAST(s.debt_amount AS money) AS debt_amount,
  CAST(s.annual_income AS money) AS annual_income
  /*weighted satisfaction scores based on relative importance of each*/
,
  s.cur_1 * p.imp_1 AS level_pay_quality,
  s.cur_2 * p.imp_2 AS stable_pay_quality,
  s.cur_3 * p.imp_3 AS stable_hours_quality,
  s.cur_4 * p.imp_4 AS control_hours_location_quality,
  s.cur_5 * p.imp_5 AS job_security_quality,
  s.cur_6 * p.imp_6 AS benefits_quality,
  s.cur_7 * p.imp_7 AS advancement_quality,
  s.cur_8 * p.imp_8 AS enjoyment_quality,
  s.cur_9 * p.imp_9 AS purpose_quality,
  s.cur_10 * p.imp_10 AS power_quality,
  (
    s.cur_1 * p.imp_1 + s.cur_2 * p.imp_2 + s.cur_3 * p.imp_3 + s.cur_4 * p.imp_4 + s.cur_5 * p.imp_5 + s.cur_6 * p.imp_6 + s.cur_7 * p.imp_7 + s.cur_8 * p.imp_8 + s.cur_9 * p.imp_9 + s.cur_10 * p.imp_10
  ) / 10.0 AS overall_quality,
  a.[name],
  a.kipp_ms_graduate_c,
  a.kipp_hs_graduate_c,
  a.kipp_hs_class_c,
  a.college_match_display_gpa_c,
  a.kipp_region_name_c,
  a.[description],
  a.gender_c,
  a.ethnicity_c,
  a.pursuing_degree_type_c,
  a.type_c,
  a.start_date_c,
  a.actual_end_date_c,
  a.major_c,
  a.status_c
FROM
  survey_pivot AS s
  LEFT JOIN weight_pivot AS p ON s.survey_id = p.survey_id
  LEFT JOIN alumni_data AS a ON (
    s.alumni_email = a.email
    OR s.alumni_email = a.email2
  )
  AND a.rn_latest = 1
  LEFT JOIN surveygizmo.survey_response_disqualified AS dq ON s.survey_id = dq.survey_id
  AND s.survey_response_id = dq.id
WHERE
  dq.id IS NULL
