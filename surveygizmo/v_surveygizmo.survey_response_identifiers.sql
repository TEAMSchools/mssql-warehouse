USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_identifiers AS

WITH response_pivot AS (
  SELECT p.survey_response_id
        ,p.survey_id
        ,p.date_started
        ,CONVERT(VARCHAR(25), p.respondent_adp_associate_id) AS respondent_adp_associate_id
        ,CONVERT(VARCHAR(125),LOWER(p.respondent_userprincipalname)) AS respondent_userprincipalname
        ,CONVERT(INT, CASE
                       WHEN ISNUMERIC(p.respondent_df_employee_number) = 1 THEN p.respondent_df_employee_number
                       WHEN CHARINDEX('[', p.respondent_df_employee_number) = 0 THEN NULL
                       ELSE SUBSTRING(p.respondent_df_employee_number
                                     ,CHARINDEX('[', p.respondent_df_employee_number) + 1
                                     ,CHARINDEX(']', p.respondent_df_employee_number) - CHARINDEX('[', p.respondent_df_employee_number) - 1)
                      END) AS respondent_df_employee_number
        ,CONVERT(INT, CASE
                       WHEN CHARINDEX('[', p.subject_df_employee_number) = 0 THEN NULL
                       ELSE SUBSTRING(p.subject_df_employee_number
                                     ,CHARINDEX('[', p.subject_df_employee_number) + 1
                                     ,CHARINDEX(']', p.subject_df_employee_number) - CHARINDEX('[', p.subject_df_employee_number) - 1)
                      END) AS subject_df_employee_number
        ,CASE WHEN CHARINDEX('[', p.subject_df_employee_number) = 0 THEN p.subject_df_employee_number END AS subject_preferred_name
  FROM
      (
       SELECT srd.survey_response_id
             ,srd.survey_id
             ,srd.date_started
             ,srd.answer
             ,cw.field_mapping
       FROM gabby.surveygizmo.survey_response_data_static srd
       JOIN gabby.people.surveygizmo_crosswalk cw
         ON srd.survey_id = cw.survey_id
        AND srd.question_id = cw.question_id
        AND cw._fivetran_deleted = 0
       WHERE srd.answer IS NOT NULL
      ) sub
  PIVOT(
    MAX(answer)
    FOR field_mapping IN (respondent_df_employee_number
                         ,respondent_userprincipalname
                         ,respondent_adp_associate_id
                         ,subject_df_employee_number)
   ) p
 )

,response_clean AS (
  SELECT rp.survey_response_id
        ,rp.survey_id
        ,rp.date_started
        ,COALESCE(rp.subject_df_employee_number, subj.df_employee_number) AS subject_df_employee_number
        ,COALESCE(rp.respondent_df_employee_number
                 ,upn.df_employee_number
                 ,adp.df_employee_number
                 ,mail.df_employee_number
                 ,ab.df_employee_number) AS respondent_df_employee_number
  FROM response_pivot rp
  LEFT JOIN gabby.people.staff_crosswalk_static upn
    ON rp.respondent_userprincipalname = upn.userprincipalname
  LEFT JOIN gabby.people.staff_crosswalk_static adp
    ON rp.respondent_adp_associate_id = adp.adp_associate_id
  LEFT JOIN gabby.people.staff_crosswalk_static mail
    ON rp.respondent_userprincipalname = mail.mail
  LEFT JOIN gabby.surveys.surveygizmo_abnormal_respondents ab
    ON rp.survey_id = ab.survey_id
   AND rp.survey_response_id = ab.survey_response_id
   AND ab._fivetran_deleted = 0
  LEFT JOIN gabby.people.staff_crosswalk_static subj
    ON rp.subject_preferred_name = subj.preferred_name
 )

,work_assignment AS (
  SELECT ewa.employee_reference_code
        ,ewa.legal_entity_name
        ,ewa.physical_location_name AS primary_site
        ,ewa.department_name
        ,ewa.job_name AS primary_job
        ,CONVERT(DATE, ewa.work_assignment_effective_start) AS work_assignment_effective_start
        ,CONVERT(DATE, COALESCE(CASE WHEN ewa.work_assignment_effective_end != '' THEN ewa.work_assignment_effective_end END
                               ,GETDATE()
           )) AS work_assignment_effective_end
        ,ROW_NUMBER() OVER (PARTITION BY ewa.employee_reference_code, ewa.work_assignment_effective_start
           ORDER BY ewa.work_assignment_effective_end DESC) AS rn

        ,scw.ps_school_id AS primary_site_schoolid
        ,scw.school_level AS primary_site_school_level
  FROM gabby.dayforce.employee_work_assignment ewa
  LEFT JOIN gabby.people.school_crosswalk scw
    ON ewa.physical_location_name = scw.site_name
   AND scw._fivetran_deleted = 0
  WHERE ewa.primary_work_assignment = 1
)

,manager AS (
  SELECT em.employee_reference_code
        ,em.manager_employee_number
        ,CONVERT(DATE, em.manager_effective_start) AS manager_effective_start
        ,CONVERT(DATE, COALESCE(CASE WHEN em.manager_effective_end != '' THEN em.manager_effective_end END
                               ,GETDATE())) AS manager_effective_end

        ,mgr.manager_df_employee_number
        ,mgr.manager_name
        ,mgr.manager_mail
        ,mgr.manager_userprincipalname
        ,mgr.manager_samaccountname
  FROM gabby.dayforce.employee_manager em
  JOIN gabby.people.staff_crosswalk_static mgr
    ON em.employee_reference_code = mgr.df_employee_number
  WHERE em.manager_derived_method = 'Direct Report'
 )

SELECT rc.survey_response_id
      ,rc.survey_id
      ,rc.date_started
      ,rc.subject_df_employee_number
      ,rc.respondent_df_employee_number
      
      ,resp.preferred_name AS respondent_preferred_name
      ,resp.adp_associate_id AS respondent_adp_associate_id
      ,resp.userprincipalname AS respondent_userprincipalname
      ,resp.mail AS respondent_mail
      ,resp.samaccountname AS respondent_samaccountname

      ,rwa.legal_entity_name AS respondent_legal_entity_name
      ,rwa.primary_site AS respondent_primary_site
      ,rwa.department_name AS respondent_department_name
      ,rwa.primary_job AS respondent_primary_job
      ,rwa.primary_site_schoolid AS respondent_primary_site_schoolid
      ,rwa.primary_site_school_level AS respondent_primary_site_school_level

      ,rmgr.manager_df_employee_number AS respondent_manager_df_employee_number
      ,rmgr.manager_name AS respondent_manager_name
      ,rmgr.manager_mail AS respondent_manager_mail
      ,rmgr.manager_userprincipalname AS respondent_manager_userprincipalname
      ,rmgr.manager_samaccountname AS respondent_manager_samaccountname

      ,subj.preferred_name AS subject_preferred_name
      ,subj.adp_associate_id AS subject_adp_associate_id
      ,subj.userprincipalname AS subject_userprincipalname
      ,subj.mail AS subject_mail
      ,subj.samaccountname AS subject_samaccountname

      ,swa.legal_entity_name AS subject_legal_entity_name
      ,swa.primary_site AS subject_primary_site
      ,swa.department_name AS subject_department_name
      ,swa.primary_job AS subject_primary_job
      ,swa.primary_site_schoolid AS subject_primary_site_schoolid
      ,swa.primary_site_school_level AS subject_primary_site_school_level

      ,smgr.manager_df_employee_number AS subject_manager_df_employee_number
      ,smgr.manager_name AS subject_manager_name
      ,smgr.manager_mail AS subject_manager_mail
      ,smgr.manager_userprincipalname AS subject_manager_userprincipalname
      ,smgr.manager_samaccountname AS subject_manager_samaccountname
FROM response_clean rc
LEFT JOIN gabby.people.staff_crosswalk_static resp
  ON rc.respondent_df_employee_number = resp.df_employee_number
LEFT JOIN work_assignment rwa
  ON rc.respondent_df_employee_number = rwa.employee_reference_code
 AND rc.date_started BETWEEN rwa.work_assignment_effective_start AND rwa.work_assignment_effective_end
 AND rwa.rn = 1
LEFT JOIN manager rmgr
  ON rc.respondent_df_employee_number = rmgr.employee_reference_code
 AND rc.date_started BETWEEN rmgr.manager_effective_start AND rmgr.manager_effective_end
LEFT JOIN gabby.people.staff_crosswalk_static subj
  ON rc.subject_df_employee_number = subj.df_employee_number
LEFT JOIN work_assignment swa
  ON rc.subject_df_employee_number = swa.employee_reference_code
 AND rc.date_started BETWEEN swa.work_assignment_effective_start AND swa.work_assignment_effective_end
 AND swa.rn = 1
LEFT JOIN manager smgr
  ON rc.subject_df_employee_number = smgr.employee_reference_code
 AND rc.date_started BETWEEN smgr.manager_effective_start AND smgr.manager_effective_end