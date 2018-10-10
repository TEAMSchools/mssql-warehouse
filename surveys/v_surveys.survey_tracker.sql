USE gabby
GO

--CREATE OR ALTER VIEW surveys.survey_tracker_feed AS

SELECT _created AS start_date
      ,email AS user_email
      ,survey_timestamp AS submitted_date
      ,subject_name
      ,CASE WHEN MONTH(_created) < 7 THEN YEAR(_created) - 1 ELSE YEAR(_created) END AS academic_year
      ,CASE WHEN MONTH(_created) IN (8,9,10) THEN 'SO1'
            WHEN MONTH(_created) IN (11,12,1,2) THEN 'SO2'
            WHEN MONTH(_created) IN (3,4,5) THEN 'SO3'
            ELSE 'SO'
       END AS reporting_term
      ,'Self & Others' AS survey
FROM surveys.self_and_others_survey
WHERE subject_name IS NOT NULL
  AND survey_timestamp IS NOT NULL

UNION ALL

SELECT _created AS start_date
      ,responder_name AS user_email
      ,survey_timestamp AS submitted_date
      ,subject_name
      ,CASE WHEN MONTH(_created) < 7 THEN YEAR(_created) - 1 ELSE YEAR(_created) END AS academic_year
      ,CASE WHEN MONTH(_created) IN (8,9,10) THEN 'MGR1'
            WHEN MONTH(_created) IN (11,12,1,2) THEN 'MGR2'
            WHEN MONTH(_created) IN (3,4,5) THEN 'MGR3'
            ELSE 'MGR'
       END AS reporting_term
      ,'Manager' AS survey

FROM surveys.manager_survey
WHERE subject_name IS NOT NULL
  AND survey_timestamp IS NOT NULL

UNION ALL

SELECT _created AS start_date
      ,email AS user_email
      ,_created AS submitted_date
      ,null AS subject_name
      ,CASE WHEN MONTH(_created) < 7 THEN YEAR(_created) - 1 ELSE YEAR(_created) END AS academic_year
      ,CASE WHEN MONTH(_created) IN (11,12,1,2) THEN 'R9S1'
            WHEN MONTH(_created) IN (4,5,6) THEN 'R9S2'
            ELSE 'R9S'
       END AS reporting_term
      ,'R9/Engagement' AS survey

FROM surveys.r_9_engagement_survey
