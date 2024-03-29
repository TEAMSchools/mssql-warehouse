CREATE OR ALTER VIEW
  surveys.survey_completion AS
WITH
  webhook_feed AS (
    SELECT
      s._created AS date_created,
      s.survey_timestamp,
      s.subject_name,
      CONVERT(
        INT,
        CASE
          WHEN CHARINDEX('[', s.subject_name) = 0 THEN NULL
          ELSE SUBSTRING(
            s.subject_name,
            CHARINDEX('[', s.subject_name) + 1,
            CHARINDEX(']', s.subject_name) - CHARINDEX('[', s.subject_name) - 1
          )
        END
      ) AS subject_df_employee_number,
      LOWER(s.email) AS email,
      utilities.DATE_TO_SY (s._created) AS academic_year,
      CASE
        WHEN c.[name] LIKE '%SO1%' THEN 'SO1'
        WHEN c.[name] LIKE '%SO2%' THEN 'SO2'
        WHEN c.[name] LIKE '%SO3%' THEN 'SO3'
        WHEN c.[name] LIKE '%SO4%' THEN 'SO4'
      END AS reporting_term,
      s.is_manager,
      'Self & Others' AS survey_type,
      c.survey_id AS survey_id
    FROM
      surveys.self_and_others_survey AS s
      INNER JOIN surveygizmo.survey_campaign_clean_static AS c ON (
        c.survey_id = 4561325
        AND (
          CAST(s._created AS DATETIME2) BETWEEN c.link_open_date AND c.link_close_date
        )
      )
    WHERE
      utilities.DATE_TO_SY (s._created) = utilities.GLOBAL_ACADEMIC_YEAR ()
      AND s.subject_name IS NOT NULL
    UNION ALL
    SELECT
      m._created AS date_created,
      m.survey_timestamp,
      m.subject_name,
      CONVERT(
        INT,
        CASE
          WHEN CHARINDEX('[', m.subject_name) = 0 THEN NULL
          ELSE SUBSTRING(
            m.subject_name,
            CHARINDEX('[', m.subject_name) + 1,
            CHARINDEX(']', m.subject_name) - CHARINDEX('[', m.subject_name) - 1
          )
        END
      ) AS subject_df_employee_number,
      LOWER(m.responder_name) AS email,
      utilities.DATE_TO_SY (m._created) AS academic_year,
      CASE
        WHEN c.[name] LIKE '%MGR1%' THEN 'MGR1'
        WHEN c.[name] LIKE '%MGR2%' THEN 'MGR2'
        WHEN c.[name] LIKE '%MGR3%' THEN 'MGR3'
        WHEN c.[name] LIKE '%MGR4%' THEN 'MGR4'
      END AS reporting_term,
      NULL AS is_manager,
      'Manager' AS survey_type,
      c.survey_id AS survey_id
    FROM
      surveys.manager_survey AS m
      INNER JOIN surveygizmo.survey_campaign_clean_static AS c ON (
        c.survey_id = 4561288
        AND (
          CAST(m._created AS DATETIME2) BETWEEN c.link_open_date AND c.link_close_date
        )
      )
    WHERE
      utilities.DATE_TO_SY (m._created) = utilities.GLOBAL_ACADEMIC_YEAR ()
      AND m.subject_name IS NOT NULL
      AND m.q_1 IS NOT NULL
    UNION ALL
    SELECT
      e._created AS date_created,
      e._created AS survey_timestamp,
      'R9/Engagement' AS subject_name,
      999999 AS subject_df_employee_number,
      LOWER(e.email) AS email,
      utilities.DATE_TO_SY (e._created) AS academic_year,
      CASE
        WHEN c.[name] LIKE '%R9S1%' THEN 'R9S1'
        WHEN c.[name] LIKE '%R9S2%' THEN 'R9S2'
        WHEN c.[name] LIKE '%R9S3%' THEN 'R9S3'
        WHEN c.[name] LIKE '%R9S4%' THEN 'R9S4'
      END AS reporting_term,
      NULL AS is_manager,
      'R9/Engagement' AS survey_type,
      c.survey_id AS survey_id
    FROM
      surveys.r_9_engagement_survey AS e
      INNER JOIN surveygizmo.survey_campaign_clean_static AS c ON (
        c.survey_id = 5300913
        AND (
          CAST(e._created AS DATETIME2) BETWEEN c.link_open_date AND c.link_close_date
        )
      )
    WHERE
      utilities.DATE_TO_SY (e._created) = utilities.GLOBAL_ACADEMIC_YEAR ()
  ),
  response_identifiers AS (
    SELECT
      date_submitted AS date_created,
      date_submitted AS survey_timestamp,
      CASE
        WHEN survey_id = 5300913 THEN 'R9/Engagement'
        ELSE CONCAT(
          subject_preferred_name,
          ' - ',
          subject_primary_site,
          ' [',
          subject_df_employee_number,
          ']'
        )
      END AS subject_name,
      CASE
        WHEN survey_id = 5300913 THEN 999999
        ELSE subject_df_employee_number
      END AS subject_df_employee_number,
      LOWER(respondent_mail) AS email,
      campaign_academic_year AS academic_year,
      campaign_reporting_term AS reporting_term,
      is_manager AS is_manager,
      CASE
        WHEN survey_id = 4561325 THEN 'Self & Others'
        WHEN survey_id = 4561288 THEN 'Manager'
        WHEN survey_id = 5300913 THEN 'R9/Engagement'
      END AS survey_type,
      survey_id AS survey_id
    FROM
      surveygizmo.survey_response_identifiers_static
    WHERE
      campaign_academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  ),
  survey_feed AS (
    SELECT
      COALESCE(r.date_created, w.date_created) AS date_created,
      COALESCE(
        r.survey_timestamp,
        w.survey_timestamp
      ) AS date_submitted,
      COALESCE(r.subject_name, w.subject_name) AS subject_name,
      COALESCE(
        r.subject_df_employee_number,
        w.subject_df_employee_number
      ) AS subject_df_employee_number,
      COALESCE(r.email, w.email) AS responder_email,
      COALESCE(r.academic_year, w.academic_year) AS academic_year,
      COALESCE(
        r.reporting_term,
        w.reporting_term
      ) AS reporting_term,
      COALESCE(r.is_manager, w.is_manager) AS is_manager,
      COALESCE(r.survey_type, w.survey_type) AS survey_type,
      COALESCE(r.survey_id, w.survey_id) AS survey_id
    FROM
      response_identifiers AS r
      FULL JOIN webhook_feed AS w ON (
        r.survey_id = w.survey_id
        AND r.email = w.email
        AND r.subject_df_employee_number = w.subject_df_employee_number
        AND r.reporting_term = w.reporting_term
      )
  ),
  teacher_scaffold AS (
    SELECT
      sr.df_employee_number,
      sr.preferred_first_name AS preferred_first,
      sr.preferred_last_name AS preferred_last,
      sr.preferred_name,
      sr.primary_site AS location_custom,
      sr.primary_job AS job_title_description,
      CASE
        WHEN sr.[status] IN ('INACTIVE', 'ADMIN_LEAVE') THEN 'LEAVE'
        ELSE sr.[status]
      END AS position_status,
      LOWER(sr.userprincipalname) AS email1,
      CASE
        WHEN LOWER(
          REPLACE(sr.userprincipalname, '-', '')
        ) = LOWER(sr.userprincipalname) THEN NULL
        ELSE LOWER(
          REPLACE(sr.userprincipalname, '-', '')
        )
      END AS email2,
      CASE
        WHEN LOWER(sr.mail) = LOWER(sr.userprincipalname) THEN NULL
        ELSE LOWER(sr.mail)
      END AS email3,
      'Self & Others' AS survey_type,
      ss.[value] AS reporting_term,
      utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year
    FROM
      people.staff_crosswalk_static AS sr
      CROSS JOIN STRING_SPLIT ('SO1,SO2,SO3', ',') AS ss
    WHERE
      sr.[status] NOT IN ('TERMINATED', 'PRESTART')
    UNION ALL
    SELECT
      sr.df_employee_number,
      sr.preferred_first_name AS preferred_first,
      sr.preferred_last_name AS preferred_last,
      sr.preferred_name,
      sr.primary_site AS location_custom,
      sr.primary_job AS job_title_description,
      CASE
        WHEN sr.[status] IN ('INACTIVE', 'ADMIN_LEAVE') THEN 'LEAVE'
        ELSE sr.[status]
      END AS position_status,
      LOWER(sr.userprincipalname) AS email1,
      CASE
        WHEN LOWER(
          REPLACE(sr.userprincipalname, '-', '')
        ) = LOWER(sr.userprincipalname) THEN NULL
        ELSE LOWER(
          REPLACE(sr.userprincipalname, '-', '')
        )
      END AS email2,
      CASE
        WHEN LOWER(sr.mail) = LOWER(sr.userprincipalname) THEN NULL
        ELSE LOWER(sr.mail)
      END AS email3,
      'R9/Engagement' AS survey_type,
      ss.[value] AS reporting_term,
      utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year
    FROM
      people.staff_crosswalk_static AS sr
      CROSS JOIN STRING_SPLIT ('R9S1,R9S2,R9S3,R9S4', ',') AS ss
    WHERE
      sr.[status] NOT IN ('TERMINATED', 'PRESTART')
    UNION ALL
    SELECT
      sr.df_employee_number,
      sr.preferred_first_name AS preferred_first,
      sr.preferred_last_name AS preferred_last,
      sr.preferred_name,
      sr.primary_site AS location_custom,
      sr.primary_job AS job_title_description,
      CASE
        WHEN sr.[status] IN ('INACTIVE', 'ADMIN_LEAVE') THEN 'LEAVE'
        ELSE sr.[status]
      END AS position_status,
      LOWER(sr.userprincipalname) AS email1,
      CASE
        WHEN LOWER(
          REPLACE(sr.userprincipalname, '-', '')
        ) = LOWER(sr.userprincipalname) THEN NULL
        ELSE LOWER(
          REPLACE(sr.userprincipalname, '-', '')
        )
      END AS email2,
      CASE
        WHEN LOWER(sr.mail) = LOWER(sr.userprincipalname) THEN NULL
        ELSE LOWER(sr.mail)
      END AS email3,
      'Manager' AS survey_type,
      ss.[value] AS reporting_term,
      utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year
    FROM
      people.staff_crosswalk_static AS sr
      CROSS JOIN STRING_SPLIT ('MGR1,MGR2,MGR3,MGR4', ',') AS ss
    WHERE
      sr.[status] NOT IN ('TERMINATED', 'PRESTART')
  )
SELECT
  s.df_employee_number AS df_employee_number,
  s.preferred_first AS survey_taker_first,
  s.preferred_last AS survey_taker_last,
  s.preferred_name AS survey_taker_name,
  s.location_custom AS location_custom,
  s.job_title_description,
  s.position_status,
  COALESCE(
    f1.date_created,
    f2.date_created,
    f3.date_created
  ) AS date_created,
  COALESCE(
    f1.date_submitted,
    f2.date_submitted,
    f3.date_submitted
  ) AS date_submitted,
  COALESCE(
    f1.responder_email,
    f2.responder_email,
    f3.responder_email,
    s.email1
  ) AS responder_email,
  COALESCE(
    f1.subject_name,
    f2.subject_name,
    f3.subject_name
  ) AS subject_name,
  COALESCE(
    s.academic_year,
    f1.academic_year,
    f2.academic_year,
    f3.academic_year
  ) AS academic_year,
  COALESCE(
    s.reporting_term,
    f1.reporting_term,
    f2.reporting_term,
    f3.reporting_term
  ) AS reporting_term,
  COALESCE(
    s.survey_type,
    f1.survey_type,
    f2.survey_type,
    f3.survey_type
  ) AS survey_type,
  COALESCE(
    f1.is_manager,
    f2.is_manager,
    f3.is_manager
  ) AS is_manager
FROM
  teacher_scaffold AS s
  LEFT JOIN survey_feed AS f1 ON (
    s.email1 = f1.responder_email
    AND s.survey_type = f1.survey_type
    AND s.academic_year = f1.academic_year
    AND s.reporting_term = f1.reporting_term
  )
  LEFT JOIN survey_feed AS f2 ON (
    s.email2 = f2.responder_email
    AND s.survey_type = f2.survey_type
    AND s.academic_year = f2.academic_year
    AND s.reporting_term = f2.reporting_term
  )
  LEFT JOIN survey_feed AS f3 ON (
    s.email3 = f3.responder_email
    AND s.survey_type = f3.survey_type
    AND s.academic_year = f3.academic_year
    AND s.reporting_term = f3.reporting_term
  )
