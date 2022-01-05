USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_identifiers AS

WITH response_pivot AS (
  SELECT p.survey_response_id
        ,p.survey_id
        ,p.date_started
        ,CONVERT(VARCHAR(25), p.respondent_adp_associate_id) AS respondent_associate_id
        ,CONVERT(VARCHAR(125), LOWER(COALESCE(p.respondent_userprincipalname, p.email))) AS respondent_userprincipalname
        ,CONVERT(INT, CASE
                       WHEN ISNUMERIC(p.respondent_df_employee_number) = 1 THEN p.respondent_df_employee_number
                       WHEN CHARINDEX('[', COALESCE(p.respondent_df_employee_number, p.employee_preferred_name)) = 0 THEN NULL
                       ELSE SUBSTRING(
                              COALESCE(p.respondent_df_employee_number, p.employee_preferred_name)
                             ,CHARINDEX('[', COALESCE(p.respondent_df_employee_number, p.employee_preferred_name)) + 1
                             ,CHARINDEX(']', COALESCE(p.respondent_df_employee_number, p.employee_preferred_name)) 
                                - CHARINDEX('[', COALESCE(p.respondent_df_employee_number, p.employee_preferred_name)) - 1
                            )
                      END) AS respondent_employee_number
        ,CONVERT(INT, CASE
                       WHEN CHARINDEX('[', COALESCE(p.subject_df_employee_number, p.employee_preferred_name)) = 0 THEN NULL
                       ELSE SUBSTRING(
                              COALESCE(p.subject_df_employee_number, p.employee_preferred_name)
                             ,CHARINDEX('[', COALESCE(p.subject_df_employee_number,p.employee_preferred_name)) + 1
                             ,CHARINDEX(']', COALESCE(p.subject_df_employee_number,p.employee_preferred_name)) 
                                - CHARINDEX('[', COALESCE(p.subject_df_employee_number,p.employee_preferred_name)) - 1
                            )
                      END) AS subject_employee_number
        ,CASE WHEN CHARINDEX('[', p.subject_df_employee_number) = 0 THEN p.subject_df_employee_number END AS subject_preferred_name
        ,CASE
          WHEN p.is_manager = 'Yes - I am their manager.' THEN 1
          WHEN p.is_manager = 'No - I am their peer.' THEN 0
          ELSE CONVERT(INT, p.is_manager)
         END AS is_manager
  FROM
      (
       SELECT sq.survey_id
             ,sq.shortname

             ,srd.survey_response_id
             ,srd.date_started
             ,srd.answer
       FROM gabby.surveygizmo.survey_question_clean sq
       JOIN gabby.surveygizmo.survey_response_data srd
         ON sq.survey_id = srd.survey_id
        AND sq.survey_question_id = srd.question_id
        AND srd.answer IS NOT NULL
       WHERE sq.is_identifier_question = 1
      ) sub
  PIVOT(
    MAX(answer)
    FOR shortname IN (respondent_df_employee_number
                     ,respondent_userprincipalname
                     ,respondent_adp_associate_id
                     ,subject_df_employee_number
                     ,is_manager
                     ,employee_number
                     ,email
                     ,employee_preferred_name)
   ) p
 )

,response_clean AS (
  SELECT rp.survey_response_id
        ,rp.survey_id
        ,rp.date_started
        ,rp.subject_preferred_name
        ,rp.is_manager

        ,ab.subject_preferred_name_duplicate

        ,COALESCE(rp.subject_employee_number, ab.subject_df_employee_number) AS subject_employee_number
        ,COALESCE(rp.respondent_employee_number
                 ,upn.df_employee_number
                 ,adp.df_employee_number
                 ,mail.df_employee_number
                 ,ab.df_employee_number) AS respondent_employee_number
  FROM response_pivot rp
  LEFT JOIN gabby.people.staff_crosswalk_static upn
    ON rp.respondent_userprincipalname = upn.userprincipalname
  LEFT JOIN gabby.people.staff_crosswalk_static adp
    ON rp.respondent_associate_id = adp.adp_associate_id_legacy
  LEFT JOIN gabby.people.staff_crosswalk_static mail
    ON rp.respondent_userprincipalname = mail.mail
  LEFT JOIN gabby.surveys.surveygizmo_abnormal_respondents ab
    ON rp.survey_id = ab.survey_id
   AND rp.survey_response_id = ab.survey_response_id
   AND ab._fivetran_deleted = 0
 )

SELECT rc.survey_response_id
      ,rc.survey_id
      ,CONVERT(DATE, rc.date_started) AS date_started
      ,rc.subject_employee_number AS subject_df_employee_number
      ,rc.respondent_employee_number AS respondent_df_employee_number
      ,COALESCE(rc.is_manager
               ,CASE 
                 WHEN rc.respondent_employee_number = seh.reports_to_employee_number THEN 1 
                 ELSE 0 
                END) AS is_manager

      ,sr.[status]
      ,sr.contact_id
      ,sr.date_submitted
      ,sr.response_time

      ,sc.academic_year AS campaign_academic_year
      ,sc.[name] AS campaign_name
      ,sc.reporting_term_code AS campaign_reporting_term

      ,resp.preferred_name AS respondent_preferred_name
      ,resp.adp_associate_id AS respondent_adp_associate_id
      ,resp.userprincipalname AS respondent_userprincipalname
      ,resp.mail AS respondent_mail
      ,resp.samaccountname AS respondent_samaccountname

      ,reh.business_unit AS respondent_legal_entity_name
      ,reh.[location] AS respondent_primary_site
      ,reh.home_department AS respondent_department_name
      ,reh.job_title AS respondent_primary_job

      ,rsch.ps_school_id AS respondent_primary_site_schoolid
      ,rsch.school_level AS respondent_primary_site_school_level

      ,reh.reports_to_employee_number AS respondent_manager_df_employee_number

      ,rmgr.preferred_name AS respondent_manager_name
      ,rmgr.mail AS respondent_manager_mail
      ,rmgr.userprincipalname AS respondent_manager_userprincipalname
      ,rmgr.samaccountname AS respondent_manager_samaccountname

      ,subj.preferred_name AS subject_preferred_name
      ,subj.adp_associate_id AS subject_adp_associate_id
      ,subj.userprincipalname AS subject_userprincipalname
      ,subj.mail AS subject_mail
      ,subj.samaccountname AS subject_samaccountname

      ,seh.business_unit AS subject_legal_entity_name
      ,seh.[location] AS subject_primary_site
      ,seh.home_department AS subject_department_name
      ,seh.job_title AS subject_primary_job

      ,ssch.ps_school_id AS subject_primary_site_schoolid
      ,ssch.school_level AS subject_primary_site_school_level

      ,seh.reports_to_employee_number AS subject_manager_df_employee_number

      ,smgr.preferred_name AS subject_manager_name
      ,smgr.mail AS subject_manager_mail
      ,smgr.userprincipalname AS subject_manager_userprincipalname
      ,smgr.samaccountname AS subject_manager_samaccountname

      ,ROW_NUMBER() OVER(
         PARTITION BY rc.survey_id, sc.academic_year, sc.[name], rc.respondent_employee_number, rc.subject_employee_number
           ORDER BY sr.datetime_submitted DESC) AS rn_respondent_subject
FROM response_clean rc
JOIN gabby.surveygizmo.survey_response_clean sr
  ON rc.survey_id = sr.survey_id
 AND rc.survey_response_id = sr.survey_response_id
 AND sr.[status] = 'Complete'
LEFT JOIN gabby.surveygizmo.survey_campaign_clean_static sc
  ON rc.survey_id = sc.survey_id
 AND rc.date_started BETWEEN sc.link_open_date AND sc.link_close_date
LEFT JOIN gabby.people.staff_crosswalk_static resp
  ON rc.respondent_employee_number = resp.df_employee_number
LEFT JOIN gabby.people.employment_history reh
  ON resp.position_id = reh.position_id
 AND CONVERT(DATE, sc.link_close_date) BETWEEN reh.effective_start_date AND reh.effective_end_date
LEFT JOIN gabby.people.staff_crosswalk_static rmgr
  ON reh.reports_to_employee_number = rmgr.df_employee_number
LEFT JOIN gabby.people.school_crosswalk rsch
  ON reh.[location] = rsch.site_name
LEFT JOIN gabby.people.staff_crosswalk_static subj
  ON rc.subject_employee_number = subj.df_employee_number
LEFT JOIN gabby.people.employment_history seh
  ON subj.position_id = seh.position_id
 AND CONVERT(DATE, sc.link_close_date) BETWEEN seh.effective_start_date AND seh.effective_end_date
LEFT JOIN gabby.people.staff_crosswalk_static smgr
  ON seh.reports_to_employee_number = smgr.df_employee_number
LEFT JOIN gabby.people.school_crosswalk ssch
  ON seh.[location] = ssch.site_name
