USE gabby
GO

CREATE OR ALTER VIEW surveys.survey_completion AS

WITH survey_feed AS (
  SELECT _created AS date_created
        ,CONVERT(DATETIME2,survey_timestamp) AS date_submitted
        ,subject_name
        ,LOWER(email) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) IN (8, 9, 10) THEN 'SO1'
          WHEN MONTH(_created) IN (11, 12, 1, 2) THEN 'SO2'
          WHEN MONTH(_created) IN (3, 4, 5, 6, 7) THEN 'SO3'
         END AS reporting_term
        ,'Self & Others' AS survey_type
  FROM surveys.self_and_others_survey
  WHERE subject_name IS NOT NULL
    AND survey_timestamp IS NOT NULL

  UNION ALL

  SELECT _created AS date_created
        ,CONVERT(DATETIME2,survey_timestamp) AS date_submitted
        ,subject_name
        ,LOWER(responder_name) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) IN (8, 9, 10) THEN 'MGR1'
          WHEN MONTH(_created) IN (11, 12, 1, 2) THEN 'MGR2'
          WHEN MONTH(_created) IN (3, 4, 5, 6, 7) THEN 'MGR3'
         END AS reporting_term
        ,'Manager' AS survey_type
  FROM surveys.manager_survey
  WHERE subject_name IS NOT NULL
    AND survey_timestamp IS NOT NULL

  UNION ALL

  SELECT _created AS date_created
        ,CONVERT(DATETIME2,survey_timestamp) AS date_submitted
        ,NULL AS subject_name
        ,LOWER(email) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) >= 7 THEN 'R9S1'
          WHEN MONTH(_created) < 7 THEN 'R9S2'
         END AS reporting_term
        ,'R9/Engagement' AS survey
  FROM surveys.r_9_engagement_survey
 )

SELECT f.date_created
      ,f.date_submitted
      ,f.responder_email      
      ,f.subject_name
      ,f.academic_year
      ,f.reporting_term
      ,f.survey_type

      ,COALESCE(uupn.df_employee_number, um.df_employee_number) AS df_employee_number
      ,COALESCE(uupn.preferred_first, um.preferred_first) AS survey_taker_first
      ,COALESCE(uupn.preferred_last, um.preferred_last) AS survey_taker_last
      ,COALESCE(uupn.preferred_name, um.preferred_name) AS survey_taker_name
      ,COALESCE(uupn.location_custom, um.location_custom) AS location_custom
FROM survey_feed f
LEFT JOIN gabby.tableau.staff_roster uupn
  ON f.responder_email = uupn.userprincipalname
LEFT JOIN gabby.tableau.staff_roster um
  ON f.responder_email = um.mail