USE gabby
GO

--CREATE OR ALTER VIEW surveys.survey_completion AS

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
        ,'R9/Engagement' AS subject_name
        ,LOWER(email) AS responder_email
        ,gabby.utilities.DATE_TO_SY(_created) AS academic_year
        ,CASE
          WHEN MONTH(_created) >= 7 THEN 'R9S1'
          WHEN MONTH(_created) < 7 THEN 'R9S2'
         END AS reporting_term
        ,'R9/Engagement' AS survey
  FROM surveys.r_9_engagement_survey
 )

 , teacher_roster AS (

   SELECT df_employee_number
         ,preferred_first
         ,preferred_last
         ,preferred_name
         ,CASE WHEN position_status IN ('INACTIVE', 'ADMIN_LEAVE')
               THEN 'LEAVE'
               ELSE position_status
             END AS position_status

         ,subject_dept_custom
         ,grades_taught_custom
         ,job_title_description
         ,legal_entity_name
         ,location_custom
         ,home_department_description
         ,benefits_eligibility_class_description
         ,is_management
         ,manager_df_employee_number
         ,manager_name
         ,LOWER(userprincipalname) as email1
         ,CASE WHEN (LOWER(REPLACE(userprincipalname,'-','')) = LOWER(userprincipalname)) 
               THEN NULL
               ELSE LOWER(REPLACE(userprincipalname,'-','')) 
             END AS email2
         ,CASE WHEN (LOWER(mail) = LOWER(userprincipalname)) 
               THEN NULL
               ELSE LOWER(mail)
             END AS email3
         ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
  FROM tableau.staff_roster
  WHERE position_status NOT IN ('TERMINATED', 'PRESTART')
  
  )

, teacher_scaffold AS (

  SELECT *
        ,'Self & Others' AS survey_type
  FROM teacher_roster

  UNION ALL

  SELECT *
        ,'R9/Engagement' AS survey_type
  FROM teacher_roster

  UNION ALL

  SELECT *
        ,'Manager' AS survey_type
  FROM teacher_roster

  )

SELECT COALESCE(f1.date_created, f2.date_created, f3.date_created) AS date_created
      ,COALESCE(f1.date_submitted, f2.date_submitted, f3.date_submitted) AS date_submitted
      ,COALESCE(f1.responder_email, f2.responder_email, f3.responder_email, email1) AS responder_email   
      ,COALESCE(f1.subject_name, f2.subject_name, f3.subject_name) AS subject_name
      ,COALESCE(f1.academic_year, f2.academic_year, f3.academic_year, gabby.utilities.GLOBAL_ACADEMIC_YEAR()) AS academic_year
      ,COALESCE(f1.reporting_term, f2.reporting_term, f3.reporting_term) AS reporting_term
      ,COALESCE(f1.survey_type, f2.survey_type, f3.survey_type, s.survey_type) AS survey_type

      ,s.df_employee_number AS df_employee_number
      ,s.preferred_first AS survey_taker_first
      ,s.preferred_last AS survey_taker_last
      ,s.preferred_name AS survey_taker_name
      ,s.location_custom AS location_custom
      ,s.job_title_description
      ,s.position_status

FROM teacher_scaffold s
LEFT JOIN survey_feed f1
  ON s.email1 = f1.responder_email
 AND s.survey_type = f1.survey_type
 AND s.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
LEFT JOIN survey_feed f2
  ON s.email2 = f2.responder_email
 AND s.survey_type = f2.survey_type
 AND s.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
LEFT JOIN survey_feed f3
  ON s.email3 = f3.responder_email
 AND s.survey_type = f3.survey_type
 AND s.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()