CREATE OR ALTER VIEW
  surveygizmo.survey_response_identifiers AS
WITH
  response_pivot AS (
    SELECT
      survey_response_id,
      survey_id,
      date_started,
      salesforce_id,
      CAST(
        respondent_adp_associate_id AS VARCHAR(25)
      ) AS respondent_associate_id,
      CAST(
        LOWER(
          COALESCE(
            respondent_userprincipalname,
            email,
            alumni_email
          )
        ) AS VARCHAR(125)
      ) AS respondent_userprincipalname,
      CONVERT(
        INT,
        CASE
          WHEN (
            ISNUMERIC(respondent_df_employee_number) = 1
          ) THEN respondent_df_employee_number
          WHEN CHARINDEX(
            '[',
            COALESCE(
              respondent_df_employee_number,
              employee_preferred_name
            )
          ) = 0 THEN NULL
          ELSE SUBSTRING(
            COALESCE(
              respondent_df_employee_number,
              employee_preferred_name
            ),
            CHARINDEX(
              '[',
              COALESCE(
                respondent_df_employee_number,
                employee_preferred_name
              )
            ) + 1,
            CHARINDEX(
              ']',
              COALESCE(
                respondent_df_employee_number,
                employee_preferred_name
              )
            ) - CHARINDEX(
              '[',
              COALESCE(
                respondent_df_employee_number,
                employee_preferred_name
              )
            ) - 1
          )
        END
      ) AS respondent_employee_number,
      CONVERT(
        INT,
        CASE
          WHEN CHARINDEX(
            '[',
            COALESCE(
              subject_df_employee_number,
              employee_preferred_name
            )
          ) = 0 THEN NULL
          ELSE SUBSTRING(
            COALESCE(
              subject_df_employee_number,
              employee_preferred_name
            ),
            CHARINDEX(
              '[',
              COALESCE(
                subject_df_employee_number,
                employee_preferred_name
              )
            ) + 1,
            CHARINDEX(
              ']',
              COALESCE(
                subject_df_employee_number,
                employee_preferred_name
              )
            ) - CHARINDEX(
              '[',
              COALESCE(
                subject_df_employee_number,
                employee_preferred_name
              )
            ) - 1
          )
        END
      ) AS subject_employee_number,
      CASE
        WHEN (
          CHARINDEX('[', subject_df_employee_number) = 0
        ) THEN subject_df_employee_number
      END AS subject_preferred_name,
      CASE
        WHEN is_manager = 'Yes - I am their manager.' THEN 1
        WHEN is_manager = 'No - I am their peer.' THEN 0
        ELSE CAST(is_manager AS INT)
      END AS is_manager
    FROM
      (
        SELECT
          sq.survey_id,
          sq.shortname,
          srd.survey_response_id,
          srd.date_started,
          srd.answer
        FROM
          surveygizmo.survey_question_clean_static AS sq
          INNER JOIN surveygizmo.survey_response_data AS srd ON (
            sq.survey_id = srd.survey_id
            AND sq.survey_question_id = srd.question_id
            AND srd.answer IS NOT NULL
          )
        WHERE
          sq.is_identifier_question = 1
      ) AS sub PIVOT (
        MAX(answer) FOR shortname IN (
          respondent_df_employee_number,
          respondent_userprincipalname,
          respondent_adp_associate_id,
          subject_df_employee_number,
          is_manager,
          employee_number,
          email,
          alumni_email,
          employee_preferred_name,
          salesforce_id
        )
      ) AS p
  ),
  response_clean AS (
    SELECT
      rp.survey_response_id,
      rp.survey_id,
      rp.date_started,
      rp.subject_preferred_name,
      rp.is_manager,
      rp.salesforce_id,
      ab.subject_preferred_name_duplicate,
      COALESCE(
        rp.subject_employee_number,
        ab.subject_df_employee_number
      ) AS subject_employee_number,
      COALESCE(
        rp.respondent_employee_number,
        upn.df_employee_number,
        adp.df_employee_number,
        mail.df_employee_number,
        ab.df_employee_number
      ) AS respondent_employee_number,
      rp.respondent_userprincipalname AS nonstaff_email
    FROM
      response_pivot AS rp
      LEFT JOIN people.staff_crosswalk_static AS upn ON (
        rp.respondent_userprincipalname = upn.userprincipalname
      )
      LEFT JOIN people.staff_crosswalk_static AS adp ON (
        rp.respondent_associate_id = adp.adp_associate_id_legacy
      )
      LEFT JOIN people.staff_crosswalk_static AS mail ON (
        rp.respondent_userprincipalname = mail.mail
      )
      LEFT JOIN surveys.surveygizmo_abnormal_respondents AS ab ON (
        rp.survey_id = ab.survey_id
        AND rp.survey_response_id = ab.survey_response_id
        AND ab._fivetran_deleted = 0
      )
  )
SELECT
  rc.survey_response_id,
  rc.survey_id,
  CAST(rc.date_started AS DATE) AS date_started,
  rc.subject_employee_number AS subject_df_employee_number,
  rc.respondent_employee_number AS respondent_df_employee_number,
  rc.salesforce_id AS respondent_salesforce_id,
  COALESCE(
    rc.is_manager,
    CASE
      WHEN rc.respondent_employee_number = seh.reports_to_employee_number THEN 1
      ELSE 0
    END
  ) AS is_manager,
  sr.[status],
  sr.contact_id,
  sr.date_submitted,
  sr.response_time,
  sc.academic_year AS campaign_academic_year,
  sc.[name] AS campaign_name,
  sc.reporting_term_code AS campaign_reporting_term,
  resp.preferred_name AS respondent_preferred_name,
  resp.adp_associate_id AS respondent_adp_associate_id,
  COALESCE(
    resp.userprincipalname,
    rc.nonstaff_email
  ) AS respondent_userprincipalname,
  resp.mail AS respondent_mail,
  resp.samaccountname AS respondent_samaccountname,
  reh.business_unit AS respondent_legal_entity_name,
  reh.[location] AS respondent_primary_site,
  reh.home_department AS respondent_department_name,
  reh.job_title AS respondent_primary_job,
  reh.position_status AS respondent_position_status,
  rsch.ps_school_id AS respondent_primary_site_schoolid,
  rsch.school_level AS respondent_primary_site_school_level,
  reh.reports_to_employee_number AS respondent_manager_df_employee_number,
  rmgr.preferred_name AS respondent_manager_name,
  rmgr.mail AS respondent_manager_mail,
  rmgr.userprincipalname AS respondent_manager_userprincipalname,
  rmgr.samaccountname AS respondent_manager_samaccountname,
  subj.preferred_name AS subject_preferred_name,
  subj.adp_associate_id AS subject_adp_associate_id,
  subj.userprincipalname AS subject_userprincipalname,
  subj.mail AS subject_mail,
  subj.samaccountname AS subject_samaccountname,
  seh.business_unit AS subject_legal_entity_name,
  seh.[location] AS subject_primary_site,
  seh.home_department AS subject_department_name,
  seh.job_title AS subject_primary_job,
  ssch.ps_school_id AS subject_primary_site_schoolid,
  ssch.school_level AS subject_primary_site_school_level,
  seh.reports_to_employee_number AS subject_manager_df_employee_number,
  smgr.preferred_name AS subject_manager_name,
  smgr.mail AS subject_manager_mail,
  smgr.userprincipalname AS subject_manager_userprincipalname,
  smgr.samaccountname AS subject_manager_samaccountname,
  ROW_NUMBER() OVER (
    PARTITION BY
      rc.survey_id,
      sc.academic_year,
      sc.[name],
      rc.respondent_employee_number,
      rc.subject_employee_number
    ORDER BY
      sr.datetime_submitted DESC
  ) AS rn_respondent_subject
FROM
  response_clean AS rc
  INNER JOIN surveygizmo.survey_response_clean AS sr ON (
    rc.survey_id = sr.survey_id
    AND rc.survey_response_id = sr.survey_response_id
    AND sr.[status] = 'Complete'
  )
  LEFT JOIN surveygizmo.survey_campaign_clean_static AS sc ON (
    rc.survey_id = sc.survey_id
    AND (
      rc.date_started BETWEEN sc.link_open_date AND sc.link_close_date
    )
    AND sc.[status] != 'Deleted'
  )
  LEFT JOIN people.staff_crosswalk_static AS resp ON (
    rc.respondent_employee_number = resp.df_employee_number
  )
  LEFT JOIN people.employment_history_static AS reh ON (
    resp.position_id = reh.position_id
    AND (
      -- trunk-ignore(sqlfluff/LT05)
      CAST(sc.link_close_date AS DATE) BETWEEN reh.effective_start_date AND reh.effective_end_date
    )
  )
  LEFT JOIN people.staff_crosswalk_static AS rmgr ON (
    reh.reports_to_employee_number = rmgr.df_employee_number
  )
  LEFT JOIN people.school_crosswalk AS rsch ON (reh.[location] = rsch.site_name)
  LEFT JOIN people.staff_crosswalk_static AS subj ON (
    rc.subject_employee_number = subj.df_employee_number
  )
  LEFT JOIN people.employment_history_static AS seh ON (
    subj.position_id = seh.position_id
    AND (
      -- trunk-ignore(sqlfluff/LT05)
      CAST(sc.link_close_date AS DATE) BETWEEN seh.effective_start_date AND seh.effective_end_date
    )
  )
  LEFT JOIN people.staff_crosswalk_static AS smgr ON (
    seh.reports_to_employee_number = smgr.df_employee_number
  )
  LEFT JOIN people.school_crosswalk AS ssch ON (seh.[location] = ssch.site_name)
