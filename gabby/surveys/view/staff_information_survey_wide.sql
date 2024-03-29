CREATE OR ALTER VIEW
  surveys.staff_information_survey_wide AS
WITH
  multi_select_groupings AS (
    SELECT
      employee_number,
      CASE
        WHEN question_shortname LIKE 'community_live%' THEN 'community_live'
        WHEN question_shortname LIKE 'community_work%' THEN 'community_work'
        WHEN question_shortname LIKE 'language%' THEN 'language'
        WHEN question_shortname LIKE 'race_ethnicity%' THEN 'race_ethnicity'
        WHEN question_shortname LIKE 'teacher_prep%' THEN 'teacher_prep'
        ELSE question_shortname
      END AS question_shortname,
      answer
    FROM
      surveys.staff_information_survey_detail
    WHERE
      rn_cur = 1
      AND employee_number IS NOT NULL
      AND answer IS NOT NULL
  )
SELECT
  employee_number,
  community_live,
  community_work,
  education_level,
  kipp_alumni,
  [language],
  preferred_gender,
  race_ethnicity,
  relay,
  teacher_prep,
  undergrad_university,
  CAST(
    years_teaching_any_state AS FLOAT
  ) AS years_teaching_any_state,
  CAST(
    years_teaching_nj_and_fl AS FLOAT
  ) AS years_teaching_nj_and_fl,
  CAST(
    professional_experience_before_kipp AS FLOAT
  ) AS professional_experience_before_kipp
FROM
  (
    SELECT
      employee_number,
      question_shortname,
      gabby.dbo.GROUP_CONCAT (answer) AS answer
    FROM
      multi_select_groupings
    GROUP BY
      employee_number,
      question_shortname
  ) sub PIVOT (
    MAX(answer) FOR question_shortname IN (
      community_live,
      community_work,
      education_level,
      kipp_alumni,
      [language],
      preferred_gender,
      professional_experience_before_kipp,
      race_ethnicity,
      relay,
      teacher_prep,
      undergrad_university,
      years_teaching_any_state,
      years_teaching_nj_and_fl
    )
  ) p
