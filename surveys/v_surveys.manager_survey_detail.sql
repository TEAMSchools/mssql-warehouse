USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_detail AS

SELECT sub.survey_type
      ,sub.response_id
      ,sub.academic_year
      ,sub.reporting_term
      ,sub.term_name
      ,sub.time_started
      ,sub.date_submitted
      ,sub.status
      ,sub.respondent_associate_id
      ,sub.respondent_salesforce_id
      ,sub.respondent_email_address
      ,sub.respondent_name
      ,sub.subject_associate_id
      ,sub.question_code
      ,sub.response
      ,sub.subject_name
      ,sub.subject_location
      ,sub.subject_manager_id
      ,sub.reporting_schoolid
      ,sub.school_level
      ,sub.region
      ,sub.subject_username
      ,sub.subject_manager_name
      ,sub.subject_manager_username
      ,sub.question_text
      ,sub.open_ended
      ,sub.response_value

      ,ROUND(AVG(response_value) OVER(PARTITION BY academic_year, reporting_term, question_code, subject_location), 1) AS avg_response_value_location
FROM
    (
     SELECT mgr.survey_type
           ,mgr.response_id
           ,mgr.academic_year
           ,mgr.reporting_term
           ,mgr.term_name
           ,mgr.time_started
           ,mgr.date_submitted
           ,mgr.status
           ,mgr.respondent_associate_id
           ,mgr.respondent_salesforce_id
           ,mgr.respondent_email_address
           ,mgr.respondent_name      
           ,mgr.subject_associate_id
           ,mgr.question_code
           ,mgr.response
           ,mgr.question_text
           ,mgr.open_ended
           ,mgr.response_value
      
           ,COALESCE(CONCAT(dfdf.preferred_first_name, ' ', dfdf.preferred_last_name)
                    ,CONCAT(dfadp.preferred_first_name, ' ', dfadp.preferred_last_name)) AS subject_name
           ,COALESCE(dfdf.primary_site, dfadp.primary_site) AS subject_location
           ,COALESCE(dfdf.primary_site_reporting_schoolid, dfadp.primary_site_reporting_schoolid) AS reporting_schoolid
           ,COALESCE(dfdf.primary_site_school_level, dfadp.primary_site_school_level) AS school_level
           ,COALESCE(dfdf.legal_entity_name, dfadp.legal_entity_name) AS region
           ,COALESCE(dfdf.manager_adp_associate_id, dfadp.manager_adp_associate_id) AS subject_manager_id

           ,COALESCE(addf.samaccountname, adadp.samaccountname) AS subject_username

           ,COALESCE(admgrdf.displayname, admgradp.displayname) AS subject_manager_name
           ,COALESCE(admgrdf.samaccountname, admgradp.samaccountname) AS subject_manager_username
     FROM gabby.surveys.manager_survey_long_static mgr     
     LEFT JOIN gabby.dayforce.staff_roster dfadp
       ON mgr.subject_associate_id = dfadp.adp_associate_id
     LEFT JOIN gabby.adsi.user_attributes_static adadp
       ON dfadp.adp_associate_id = adadp.idautopersonalternateid
     LEFT JOIN gabby.adsi.user_attributes_static admgradp
       ON dfadp.manager_adp_associate_id = admgradp.idautopersonalternateid
     LEFT JOIN gabby.dayforce.staff_roster dfdf
       ON mgr.subject_associate_id = CONVERT(VARCHAR,dfdf.df_employee_number)
     LEFT JOIN gabby.adsi.user_attributes_static addf
       ON CONVERT(VARCHAR,dfdf.df_employee_number) = addf.employeenumber     
     LEFT JOIN gabby.adsi.user_attributes_static admgrdf
       ON CONVERT(VARCHAR,dfdf.manager_df_employee_number) = admgrdf.employeenumber
    ) sub