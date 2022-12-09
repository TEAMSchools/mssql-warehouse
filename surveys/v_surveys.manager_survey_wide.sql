USE gabby GO
CREATE OR ALTER VIEW
  surveys.manager_survey_wide AS
WITH
  survey_unpivot AS (
    SELECT
      academic_year,
      term_name,
      subject_name,
      subject_location,
      subject_manager_name,
      respondent_names,
      value,
      CONCAT(question_code, '_', field) AS pivot_field
    FROM
      (
        SELECT
          academic_year,
          term_name,
          question_code,
          subject_name,
          subject_location,
          subject_manager_name,
          CAST(
            COUNT(
              CASE
                WHEN open_ended = 'N' THEN response_value
              END
            ) AS NVARCHAR(MAX)
          ) AS n_responses,
          CAST(ROUND(AVG(CAST(response_value AS FLOAT)), 1) AS NVARCHAR(MAX)) AS avg_response_value_subject,
          CAST(MAX(avg_response_value_location) AS NVARCHAR(MAX)) AS avg_response_value_location,
          CAST(gabby.dbo.GROUP_CONCAT_D (DISTINCT respondent_name, CHAR(10)) AS NVARCHAR(MAX)) AS respondent_names,
          CAST(
            gabby.dbo.GROUP_CONCAT_D (
              CASE
                WHEN open_ended = 'Y' THEN response
              END,
              CHAR(10)
            ) AS NVARCHAR(MAX)
          ) AS response_text
        FROM
          gabby.surveys.manager_survey_detail
        GROUP BY
          academic_year,
          term_name,
          question_code,
          subject_name,
          subject_location,
          subject_manager_name
      ) sub UNPIVOT (
        value FOR field IN (n_responses, avg_response_value_subject, avg_response_value_location, response_text)
      ) u
  )
SELECT
  academic_year,
  term_name,
  subject_name,
  subject_location,
  subject_manager_name,
  respondent_names,
  [q_1_avg_response_value_location],
  [q_1_avg_response_value_subject],
  [q_1_n_responses],
  [q_1_response_text],
  [q_2_avg_response_value_location],
  [q_2_avg_response_value_subject],
  [q_2_n_responses],
  [q_2_response_text],
  [q_3_avg_response_value_location],
  [q_3_avg_response_value_subject],
  [q_3_n_responses],
  [q_3_response_text],
  [q_4_avg_response_value_location],
  [q_4_avg_response_value_subject],
  [q_4_n_responses],
  [q_4_response_text],
  [q_5_avg_response_value_location],
  [q_5_avg_response_value_subject],
  [q_5_n_responses],
  [q_5_response_text],
  [q_6_avg_response_value_location],
  [q_6_avg_response_value_subject],
  [q_6_n_responses],
  [q_6_response_text],
  [q_7_avg_response_value_location],
  [q_7_avg_response_value_subject],
  [q_7_n_responses],
  [q_7_response_text],
  [q_8_avg_response_value_location],
  [q_8_avg_response_value_subject],
  [q_8_n_responses],
  [q_8_response_text],
  [q_9_avg_response_value_location],
  [q_9_avg_response_value_subject],
  [q_9_n_responses],
  [q_9_response_text],
  [q_10_avg_response_value_location],
  [q_10_avg_response_value_subject],
  [q_10_n_responses],
  [q_10_response_text],
  [q_11_avg_response_value_location],
  [q_11_avg_response_value_subject],
  [q_11_n_responses],
  [q_11_response_text],
  [q_12_avg_response_value_location],
  [q_12_avg_response_value_subject],
  [q_12_n_responses],
  [q_12_response_text],
  [q_13_avg_response_value_location],
  [q_13_avg_response_value_subject],
  [q_13_n_responses],
  [q_13_response_text],
  [q_14_n_responses],
  [q_14_response_text],
  [q_15_n_responses],
  [q_15_response_text],
  [q_16_n_responses],
  [q_16_response_text],
  [q_17_n_responses],
  [q_17_response_text],
  [q_18_n_responses],
  [q_18_response_text]
FROM
  survey_unpivot PIVOT (
    MAX(value) FOR pivot_field IN (
      [q_1_avg_response_value_location],
      [q_1_avg_response_value_subject],
      [q_1_n_responses],
      [q_1_response_text],
      [q_2_avg_response_value_location],
      [q_2_avg_response_value_subject],
      [q_2_n_responses],
      [q_2_response_text],
      [q_3_avg_response_value_location],
      [q_3_avg_response_value_subject],
      [q_3_n_responses],
      [q_3_response_text],
      [q_4_avg_response_value_location],
      [q_4_avg_response_value_subject],
      [q_4_n_responses],
      [q_4_response_text],
      [q_5_avg_response_value_location],
      [q_5_avg_response_value_subject],
      [q_5_n_responses],
      [q_5_response_text],
      [q_6_avg_response_value_location],
      [q_6_avg_response_value_subject],
      [q_6_n_responses],
      [q_6_response_text],
      [q_7_avg_response_value_location],
      [q_7_avg_response_value_subject],
      [q_7_n_responses],
      [q_7_response_text],
      [q_8_avg_response_value_location],
      [q_8_avg_response_value_subject],
      [q_8_n_responses],
      [q_8_response_text],
      [q_9_avg_response_value_location],
      [q_9_avg_response_value_subject],
      [q_9_n_responses],
      [q_9_response_text],
      [q_10_avg_response_value_location],
      [q_10_avg_response_value_subject],
      [q_10_n_responses],
      [q_10_response_text],
      [q_11_avg_response_value_location],
      [q_11_avg_response_value_subject],
      [q_11_n_responses],
      [q_11_response_text],
      [q_12_avg_response_value_location],
      [q_12_avg_response_value_subject],
      [q_12_n_responses],
      [q_12_response_text],
      [q_13_avg_response_value_location],
      [q_13_avg_response_value_subject],
      [q_13_n_responses],
      [q_13_response_text],
      [q_14_n_responses],
      [q_14_response_text],
      [q_15_n_responses],
      [q_15_response_text],
      [q_16_n_responses],
      [q_16_response_text],
      [q_17_n_responses],
      [q_17_response_text],
      [q_18_n_responses],
      [q_18_response_text]
    )
  ) p
