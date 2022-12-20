CREATE OR ALTER VIEW
  surveys.covid_survey_detail AS
WITH
  identifiers AS (
    SELECT
      survey_response_id,
      covid_living,
      gender
    FROM
      (
        SELECT
          d.survey_response_id,
          d.question_shortname,
          d.answer
        FROM
          gabby.surveygizmo.survey_detail AS d
        WHERE
          d.survey_id = 5560557
          AND d.rn_respondent_subject = 1
          AND d.campaign_academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1)
      ) AS sub PIVOT (
        MAX(answer) FOR question_shortname IN (covid_living, gender)
      ) AS p
  ),
  ethnicity AS (
    SELECT
      rd.survey_response_id,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11194"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_asian,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11195"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_black,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11196"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_caucasian,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11197"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_hispanic,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11198"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_nativeamerican,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11199"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_pacificislander,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11200"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_na,
      CASE
        WHEN JSON_QUERY(rd.options, '$."11202"') IS NOT NULL THEN 1
        ELSE 0
      END AS is_other
    FROM
      gabby.surveygizmo.survey_response_data AS rd
    WHERE
      rd.survey_id = 5560557
      AND rd.question_id = 325
  )
SELECT
  d.survey_id,
  d.survey_title,
  d.survey_response_id,
  d.campaign_academic_year,
  d.date_started,
  d.date_submitted,
  d.campaign_name,
  d.campaign_reporting_term,
  d.is_open_ended,
  d.question_shortname,
  d.question_title,
  d.answer,
  d.answer_value,
  d.respondent_df_employee_number,
  d.respondent_preferred_name,
  d.respondent_mail,
  d.is_manager,
  d.respondent_adp_associate_id,
  d.respondent_legal_entity_name,
  d.respondent_primary_site,
  d.respondent_primary_site_schoolid,
  d.respondent_primary_site_school_level,
  d.respondent_manager_df_employee_number,
  d.respondent_samaccountname,
  d.respondent_manager_name,
  d.respondent_manager_samaccountname,
  d.respondent_department_name,
  w.job_name,
  i.covid_living,
  i.gender,
  e.is_asian,
  e.is_black,
  e.is_caucasian,
  e.is_hispanic,
  e.is_nativeamerican,
  e.is_pacificislander,
  e.is_other,
  CASE
    WHEN e.is_asian + e.is_black + e.is_caucasian + e.is_hispanic + e.is_nativeamerican + e.is_pacificislander + e.is_other > 1 THEN 1
    ELSE 0
  END AS is_multiracial
FROM
  gabby.surveygizmo.survey_detail AS d
  LEFT JOIN gabby.dayforce.employee_work_assignment AS w ON d.respondent_df_employee_number = w.employee_reference_code
  AND (
    d.date_submitted BETWEEN w.work_assignment_effective_start AND COALESCE(
      w.work_assignment_effective_end,
      DATEFROMPARTS((d.campaign_academic_year + 1), 6, 30)
    )
  )
  AND w.primary_work_assignment = 1
  LEFT JOIN identifiers AS i ON d.survey_response_id = i.survey_response_id
  LEFT JOIN ethnicity AS e ON d.survey_response_id = e.survey_response_id
WHERE
  d.survey_id = 5560557
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1)
