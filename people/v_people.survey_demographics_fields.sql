USE gabby
GO

CREATE OR ALTER VIEW people.survey_demographics_fields AS

WITH survey_multiselect AS (
  SELECT subject_adp_associate_id
        ,preferred_race_ethnicity
        ,community_grow_up
        ,community_professional_experience
        ,teacher_path
  FROM (
  SELECT sub.subject_adp_associate_id
        ,qc.shortname
        ,gabby.dbo.GROUP_CONCAT(qo.option_value) AS answer
  FROM
      (
       SELECT sri.subject_adp_associate_id
             ,sri.survey_id
             ,sri.survey_response_id
             ,ROW_NUMBER() OVER(PARTITION BY sri.subject_adp_associate_id ORDER BY sri.date_submitted DESC) AS rn
       FROM gabby.surveygizmo.survey_response_identifiers_static sri
       WHERE sri.[status] = 'Complete'
         AND sri.survey_id = 6330385
      ) sub
  INNER JOIN gabby.surveygizmo.survey_response_data sd
    ON sub.survey_id = sd.survey_id
   AND sub.survey_response_id = sd.survey_response_id
  LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
    ON sub.survey_id = qo.survey_id
   AND sd.question_id = qo.question_id
   AND qo.option_disabled = 0
   AND CHARINDEX(qo.option_id, sd.options) > 0
  JOIN gabby.surveygizmo.survey_question_clean_static qc
       ON sd.survey_id = qc.survey_id
       AND sd.question_id = qc.survey_question_id
       AND qc.shortname IN ('preferred_race_ethnicity'
                           ,'community_grow_up'
                           ,'community_professional_experience'
                           ,'teacher_path')
  WHERE sub.rn = 1
  GROUP BY sub.subject_adp_associate_id, qc.shortname
  ) s
  PIVOT(MAX(answer) FOR shortname in (preferred_race_ethnicity
                                     ,community_grow_up
                                     ,community_professional_experience
                                     ,teacher_path)
        ) p
 )

,other_survey_responses AS (
    SELECT subject_adp_associate_id
          ,preferred_gender
          ,education_level
          ,undergrad_university
          ,professional_experience_before_KIPP
          ,years_teaching_nj_and_fl
          ,years_teaching_any_state
          ,kipp_alumni
          ,relay
    FROM (
          SELECT sub.subject_adp_associate_id
                ,shortname
                ,answer
          FROM
              (
               SELECT sri.subject_adp_associate_id
                     ,sri.survey_id
                     ,sri.survey_response_id
                     ,ROW_NUMBER() OVER(PARTITION BY sri.subject_adp_associate_id ORDER BY sri.date_submitted DESC) AS rn
               FROM gabby.surveygizmo.survey_response_identifiers_static sri
               WHERE sri.[status] = 'Complete'
                 AND sri.survey_id = 6330385
              ) sub
          INNER JOIN gabby.surveygizmo.survey_response_data sd
            ON sub.survey_id = sd.survey_id
           AND sub.survey_response_id = sd.survey_response_id
          LEFT JOIN gabby.surveygizmo.survey_question_clean_static qc
            ON sd.survey_id = qc.survey_id
           AND sd.question_id = qc.survey_question_id
          LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
            ON sub.survey_id = qo.survey_id
           AND sd.question_id = qo.question_id
           AND qo.option_disabled = 0
           AND CHARINDEX(qo.option_id, sd.options) > 0
          WHERE sub.rn = 1
             ) s
             PIVOT(MAX(answer) FOR shortname IN (preferred_gender
                                                ,education_level
                                                ,undergrad_university
                                                ,professional_experience_before_KIPP
                                                ,years_teaching_nj_and_fl
                                                ,years_teaching_any_state
                                                ,kipp_alumni
                                                ,relay) 
                   ) p
 )

SELECT cw.adp_associate_id
      ,cw.df_employee_number AS employee_number

      ,m.preferred_race_ethnicity
      ,m.community_grow_up
      ,m.community_professional_experience
      ,m.teacher_path

      ,o.preferred_gender
      ,o.education_level
      ,o.undergrad_university
      ,o.professional_experience_before_KIPP
      ,o.years_teaching_nj_and_fl
      ,o.years_teaching_any_state
      ,o.kipp_alumni
      ,o.relay

FROM gabby.people.staff_crosswalk_static cw
LEFT JOIN survey_multiselect m
  ON cw.adp_associate_id = m.subject_adp_associate_id
LEFT JOIN other_survey_responses o
  ON cw.adp_associate_id = o.subject_adp_associate_id