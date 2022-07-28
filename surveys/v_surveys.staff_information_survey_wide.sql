USE gabby
GO

CREATE OR ALTER VIEW surveys.staff_information_survey_wide AS

SELECT employee_number
      ,community_live
      ,community_work
      ,education_level
      ,kipp_alumni
      ,[language]
      ,preferred_gender
      ,race_ethnicity
      ,relay
      ,teacher_prep
      ,undergrad_university
      ,CONVERT(FLOAT, years_teaching_any_state) AS years_teaching_any_state
      ,CONVERT(FLOAT, years_teaching_nj_and_fl) AS years_teaching_nj_and_fl
      ,CONVERT(FLOAT, professional_experience_before_KIPP) AS professional_experience_before_KIPP
FROM
    (
     SELECT employee_number
           ,CASE
             WHEN question_shortname LIKE 'community_live%' THEN 'community_live'
             WHEN question_shortname LIKE 'community_work%' THEN 'community_work'
             WHEN question_shortname LIKE 'language%' THEN 'language'
             WHEN question_shortname LIKE 'race_ethnicity%' THEN 'race_ethnicity'
             WHEN question_shortname LIKE 'teacher_prep%' THEN 'teacher_prep'
             ELSE question_shortname
            END AS question_shortname
           ,gabby.dbo.GROUP_CONCAT(answer) AS answer
     FROM gabby.surveys.staff_information_survey_detail
     WHERE rn_cur = 1
     GROUP BY employee_number, question_shortname
    ) sub
PIVOT(
  MAX(answer)
  FOR question_shortname IN (community_live, community_work, education_level, kipp_alumni
                            ,[language], preferred_gender, professional_experience_before_KIPP
                            ,race_ethnicity, relay, teacher_prep, undergrad_university
                            ,years_teaching_any_state, years_teaching_nj_and_fl)
 ) p
