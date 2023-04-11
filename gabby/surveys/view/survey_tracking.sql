CREATE OR ALTER VIEW
  surveys.survey_tracking AS
WITH
  surveys AS (
    SELECT
      c.survey_id,
      c.[name] AS survey_round_code,
      c.academic_year,
      c.reporting_term_code,
      c.link_open_date AS survey_round_open,
      c.link_close_date AS survey_round_close,
      DATEADD(DAY, -15, c.link_open_date) AS survey_round_open_minus_fifteen,
      ROW_NUMBER() OVER (
        PARTITION BY
          c.survey_id
        ORDER BY
          c.link_open_date DESC
      ) AS rn_survey_recent,
      s.default_link AS survey_default_link,
      s.[title]
    FROM
      surveygizmo.survey_campaign_clean_static AS c
      INNER JOIN surveygizmo.survey_clean AS s ON (c.survey_id = s.survey_id)
    WHERE
      c.link_type = 'email'
      AND c.survey_id IN (
        4561325,
        4561288,
        5300913,
        6330385,
        6580731
      )
  ),
  survey_term_staff_scaffold AS (
    SELECT
      s.survey_id,
      s.survey_round_code,
      s.academic_year,
      s.reporting_term_code,
      s.survey_round_open,
      s.survey_round_close,
      s.survey_round_open_minus_fifteen,
      s.survey_default_link,
      s.title,
      r.df_employee_number AS respondent_employee_number,
      r.preferred_name AS respondent_name,
      r.legal_entity_name AS respondent_legal_entity_name,
      r.primary_on_site_department AS respondent_department,
      r.primary_job AS respondent_primary_job,
      r.primary_site AS respondent_location,
      r.[status] AS respondent_position_status,
      r.gender AS respondent_gender,
      r.primary_race_ethnicity_reporting AS respondent_race_ethnicity,
      r.is_manager AS respondent_is_manager,
      r.payclass AS respondent_worker_category,
      r.manager_df_employee_number AS respondent_manager_employee_number,
      r.manager_name AS respondent_manager_name,
      r.manager_business_unit AS respondent_manager_legal_entity_name,
      r.userprincipalname AS respondent_userprincipalname,
      LOWER(r.samaccountname) AS respondent_samaccountname,
      wcf.[Attended Relay] AS attended_relay,
      wcf.[KIPP Alumni Status] AS kipp_alumni_status,
      (
        wcf.[Life Experience in Communities We Serve]
      ) AS life_experience_in_communities_we_serve,
      (
        wcf.[Professional Experience in Communities We Serve]
      ) AS professional_experience_in_communities_we_serve,
      (
        wcf.[Years of Professional Experience before joining]
      ) AS years_of_professional_experience_before_joining,
      wcf.[Years Teaching - In any State] AS years_teaching_in_any_state,
      wcf.[Years Teaching - In NJ or FL] AS years_teaching_in_nj_or_fl,
      wcf.[Teacher Prep Program] AS teacher_prep_program
    FROM
      surveys AS s
      INNER JOIN people.staff_crosswalk_static AS r ON (
        r.[status] NOT IN ('Terminated', 'Prestart')
      )
      LEFT JOIN adp.workers_custom_field_group_wide_static AS wcf ON (
        r.adp_associate_id = wcf.worker_id
      )
    WHERE
      s.rn_survey_recent = 1
  ),
  clean_responses AS (
    SELECT
      c.survey_id,
      c.academic_year,
      CASE
        WHEN c.survey_id = 4561325 THEN 'Self & Others'
        WHEN c.survey_id = 4561288 THEN 'Manager'
        WHEN c.survey_id = 5300913 THEN 'R9/Engagement'
        WHEN c.survey_id = 6330385 THEN 'Staff Update'
        WHEN c.survey_id = 6580731 THEN 'Intent to Return'
      END AS survey_type,
      SUBSTRING(
        c.[name],
        CHARINDEX(' ', c.[name]) + 1,
        LEN(c.[name])
      ) AS reporting_term,
      i.date_submitted,
      i.respondent_df_employee_number AS respondent_employee_number,
      i.respondent_preferred_name AS respondent_name,
      i.respondent_legal_entity_name,
      i.respondent_primary_site AS respondent_location,
      i.respondent_department_name AS respondent_department,
      i.respondent_primary_job,
      i.is_manager AS respondent_is_manager,
      i.respondent_position_status,
      i.respondent_samaccountname,
      i.subject_df_employee_number AS subject_employee_number,
      i.subject_preferred_name AS subject_name
    FROM
      surveygizmo.survey_campaign_clean_static AS c
      INNER JOIN surveygizmo.survey_response_identifiers_static AS i ON (
        c.survey_id = i.survey_id
        AND (
          i.date_started BETWEEN c.link_open_date AND c.link_close_date
        )
        AND i.rn_respondent_subject = 1
      )
    WHERE
      (
        c.survey_id = 6330385
        OR (
          c.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
          AND c.survey_id IN (
            4561325,
            4561288,
            5300913,
            6580731
          )
        )
      )
  )
SELECT
  COALESCE(
    st.respondent_employee_number,
    c.respondent_employee_number
  ) AS survey_taker_id,
  COALESCE(
    st.respondent_name,
    c.respondent_name
  ) AS survey_taker_name,
  COALESCE(
    st.respondent_legal_entity_name,
    c.respondent_legal_entity_name
  ) AS survey_taker_legal_entity_name,
  COALESCE(
    st.respondent_location,
    c.respondent_location
  ) AS survey_taker_location,
  COALESCE(
    st.respondent_department,
    c.respondent_department
  ) AS survey_taker_department,
  COALESCE(
    st.respondent_primary_job,
    c.respondent_primary_job
  ) AS survey_taker_primary_job,
  COALESCE(
    st.respondent_is_manager,
    c.respondent_is_manager
  ) AS is_manager,
  COALESCE(
    st.respondent_position_status,
    c.respondent_position_status
  ) AS survey_taker_adp_status,
  COALESCE(
    st.respondent_samaccountname,
    c.respondent_samaccountname
  ) AS survey_taker_samaccount,
  COALESCE(
    st.academic_year,
    c.academic_year
  ) AS academic_year,
  COALESCE(
    st.reporting_term_code,
    c.reporting_term
  ) AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  sa.survey_round_status,
  COALESCE(sa.assignment, c.subject_name) AS assignment,
  COALESCE(
    sa.assignment_employee_id,
    CASE
      WHEN CHARINDEX('[', c.subject_name) = 0 THEN NULL
      ELSE SUBSTRING(
        c.subject_name,
        CHARINDEX('[', c.subject_name) + 1,
        6
      )
    END
  ) AS assignment_employee_id,
  COALESCE(
    sa.assignment_preferred_name,
    c.subject_name
  ) AS assignment_preferred_name,
  sa.assignment_location,
  sa.assignment_adp_status,
  sa.assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  INNER JOIN surveys.so_assignments_long AS sa ON (
    st.respondent_employee_number = sa.survey_taker_id
    AND sa.survey_round_status = 'Yes'
  )
  LEFT JOIN clean_responses AS c ON (
    sa.assignment_employee_id = c.subject_employee_number
    AND sa.survey_taker_id = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
WHERE
  st.survey_id = 4561325 /* S&O Survey Code */
  AND (
    c.subject_employee_number != COALESCE(
      st.respondent_employee_number,
      c.respondent_employee_number
    )
    OR c.subject_employee_number IS NULL
  )
UNION ALL
SELECT
  COALESCE(
    st.respondent_employee_number,
    c.respondent_employee_number
  ) AS survey_taker_id,
  COALESCE(
    st.respondent_name,
    c.respondent_name
  ) AS survey_taker_name,
  COALESCE(
    st.respondent_legal_entity_name,
    c.respondent_legal_entity_name
  ) AS survey_taker_legal_entity_name,
  COALESCE(
    st.respondent_location,
    c.respondent_location
  ) AS survey_taker_location,
  COALESCE(
    st.respondent_department,
    c.respondent_department
  ) AS survey_taker_department,
  COALESCE(
    st.respondent_primary_job,
    c.respondent_primary_job
  ) AS survey_taker_primary_job,
  COALESCE(
    st.respondent_is_manager,
    c.respondent_is_manager
  ) AS is_manager,
  COALESCE(
    st.respondent_position_status,
    c.respondent_position_status
  ) AS survey_taker_adp_status,
  COALESCE(
    st.respondent_samaccountname,
    c.respondent_samaccountname
  ) AS survey_taker_samaccount,
  COALESCE(
    st.academic_year,
    c.academic_year
  ) AS academic_year,
  COALESCE(
    st.reporting_term_code,
    c.reporting_term
  ) AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  c.subject_name AS assignment,
  CASE
    WHEN CHARINDEX('[', c.subject_name) = 0 THEN NULL
    ELSE SUBSTRING(
      c.subject_name,
      CHARINDEX('[', c.subject_name) + 1,
      6
    )
  END AS assignment_employee_id,
  c.subject_name AS assignment_preferred_name,
  c.respondent_location AS assignment_location,
  s.assignment_adp_status,
  CASE
    WHEN st.respondent_is_manager = 1 THEN 'Self & Others - Manager Feedback'
    ELSE 'Self & Others - Peer Feedback'
  END AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  clean_responses AS c
  INNER JOIN survey_term_staff_scaffold AS st ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
  LEFT JOIN surveys.so_assignments_long AS s ON (
    c.subject_employee_number = s.assignment_employee_id
    AND c.respondent_employee_number = s.survey_taker_id
  )
WHERE
  c.survey_id = 4561325 /* S&O Survey Code */
  AND s.assignment IS NULL
  AND (
    (
      c.subject_employee_number != COALESCE(
        st.respondent_employee_number,
        c.respondent_employee_number
      )
    )
    OR (
      c.subject_employee_number IS NULL
    )
  )
UNION ALL
SELECT
  COALESCE(
    st.respondent_employee_number,
    c.respondent_employee_number
  ) AS survey_taker_id,
  COALESCE(
    st.respondent_name,
    c.respondent_name
  ) AS survey_taker_name,
  COALESCE(
    st.respondent_legal_entity_name,
    c.respondent_legal_entity_name
  ) AS survey_taker_legal_entity_name,
  COALESCE(
    st.respondent_location,
    c.respondent_location
  ) AS survey_taker_location,
  COALESCE(
    st.respondent_department,
    c.respondent_department
  ) AS survey_taker_department,
  COALESCE(
    st.respondent_primary_job,
    c.respondent_primary_job
  ) AS survey_taker_primary_job,
  COALESCE(
    st.respondent_is_manager,
    c.respondent_is_manager
  ) AS is_manager,
  COALESCE(
    st.respondent_position_status,
    c.respondent_position_status
  ) AS survey_taker_adp_status,
  COALESCE(
    st.respondent_samaccountname,
    c.respondent_samaccountname
  ) AS survey_taker_samaccount,
  COALESCE(
    st.academic_year,
    c.academic_year
  ) AS academic_year,
  COALESCE(
    st.reporting_term_code,
    c.reporting_term
  ) AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  pm.survey_round_status AS survey_round_status,
  'Your Manager' AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'Manager Survey' AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  INNER JOIN pm.assignments AS pm ON (
    st.respondent_employee_number = pm.df_employee_number
    AND pm.survey_round_status IN (
      'Yes',
      'Yes - Manager Survey Only'
    )
  )
  LEFT JOIN clean_responses AS c ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
WHERE
  st.survey_id = 4561288 /* MGR Survey Code */
  AND (
    (
      c.subject_employee_number != COALESCE(
        st.respondent_employee_number,
        c.respondent_employee_number
      )
    )
    OR (
      c.subject_employee_number IS NULL
    )
  )
UNION
SELECT
  COALESCE(
    st.respondent_employee_number,
    c.respondent_employee_number
  ) AS survey_taker_id,
  COALESCE(
    st.respondent_name,
    c.respondent_name
  ) AS survey_taker_name,
  COALESCE(
    st.respondent_legal_entity_name,
    c.respondent_legal_entity_name
  ) AS survey_taker_legal_entity_name,
  COALESCE(
    st.respondent_location,
    c.respondent_location
  ) AS survey_taker_location,
  COALESCE(
    st.respondent_department,
    c.respondent_department
  ) AS survey_taker_department,
  COALESCE(
    st.respondent_primary_job,
    c.respondent_primary_job
  ) AS survey_taker_primary_job,
  COALESCE(
    st.respondent_is_manager,
    c.respondent_is_manager
  ) AS is_manager,
  COALESCE(
    st.respondent_position_status,
    c.respondent_position_status
  ) AS survey_taker_adp_status,
  COALESCE(
    st.respondent_samaccountname,
    c.respondent_samaccountname
  ) AS survey_taker_samaccount,
  COALESCE(
    st.academic_year,
    c.academic_year
  ) AS academic_year,
  COALESCE(
    st.reporting_term_code,
    c.reporting_term
  ) AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  'Your Manager' AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'Manager Survey' AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  clean_responses AS c
  LEFT JOIN survey_term_staff_scaffold AS st ON (
    c.respondent_employee_number = st.respondent_employee_number
    AND c.academic_year = st.academic_year
    AND c.reporting_term = st.reporting_term_code
    AND c.survey_id = st.survey_id
  )
WHERE
  st.survey_id = 4561288 /* MGR Survey Code */
  AND (
    (
      c.subject_employee_number != COALESCE(
        st.respondent_employee_number,
        c.respondent_employee_number
      )
    )
    OR (
      c.subject_employee_number IS NULL
    )
  )
UNION ALL
SELECT
  st.respondent_employee_number AS survey_taker_id,
  st.respondent_name AS survey_taker_name,
  st.respondent_legal_entity_name AS survey_taker_legal_entity_name,
  st.respondent_location AS survey_taker_location,
  st.respondent_department AS survey_taker_department,
  st.respondent_primary_job AS survey_taker_primary_job,
  st.respondent_is_manager AS is_manager,
  st.respondent_position_status AS survey_taker_adp_status,
  st.respondent_samaccountname AS survey_taker_samaccount,
  st.academic_year,
  st.reporting_term_code AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  pr.engagement_survey_assignment AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'Regional & Staff Engagement Survey' AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  LEFT JOIN clean_responses AS c ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
  LEFT JOIN pm.assignments AS pm ON (
    st.respondent_employee_number = pm.df_employee_number
  )
  LEFT JOIN extracts.gsheets_pm_assignment_roster AS pr ON (
    st.respondent_employee_number = pr.df_employee_number
  )
WHERE
  st.survey_id = 5300913 /* R9S Survey Code */
  AND pm.survey_round_status IN (
    'Yes',
    'Yes - Manager Survey Only'
  )
UNION ALL
SELECT
  st.respondent_employee_number AS survey_taker_id,
  st.respondent_name AS survey_taker_name,
  st.respondent_legal_entity_name AS survey_taker_legal_entity_name,
  st.respondent_location AS survey_taker_location,
  st.respondent_department AS survey_taker_department,
  st.respondent_primary_job AS survey_taker_primary_job,
  st.respondent_is_manager AS is_manager,
  st.respondent_position_status AS survey_taker_adp_status,
  st.respondent_samaccountname AS survey_taker_samaccount,
  st.academic_year,
  st.reporting_term_code AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  'Update Your Staff Info' AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'Staff Update' AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  LEFT JOIN clean_responses AS c ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.survey_id = c.survey_id
  )
WHERE
  st.survey_id = 6330385 /* UP Survey Code */
UNION ALL
SELECT
  st.respondent_employee_number AS survey_taker_id,
  st.respondent_name AS survey_taker_name,
  st.respondent_legal_entity_name AS survey_taker_legal_entity_name,
  st.respondent_location AS survey_taker_location,
  st.respondent_department AS survey_taker_department,
  st.respondent_primary_job AS survey_taker_primary_job,
  0 AS is_manager,
  st.respondent_position_status AS survey_taker_adp_status,
  st.respondent_samaccountname AS survey_taker_samaccount,
  st.academic_year,
  st.reporting_term_code AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  'One Off Staff Survey' AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'One Off Staff Survey' AS assignment_type,
  'Cannot be tracked' AS completed_survey_subject_name,
  NULL AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  LEFT JOIN clean_responses AS c ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
WHERE
  st.survey_id = 6330385 /* UP Survey Code */
UNION ALL
SELECT
  st.respondent_employee_number AS survey_taker_id,
  st.respondent_name AS survey_taker_name,
  st.respondent_legal_entity_name AS survey_taker_legal_entity_name,
  st.respondent_location AS survey_taker_location,
  st.respondent_department AS survey_taker_department,
  st.respondent_primary_job AS survey_taker_primary_job,
  st.respondent_is_manager AS is_manager,
  st.respondent_position_status AS survey_taker_adp_status,
  st.respondent_samaccountname AS survey_taker_samaccount,
  st.academic_year,
  st.reporting_term_code AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  'Intent to Return' AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'Intent to Return' AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  LEFT JOIN clean_responses AS c ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
WHERE
  st.survey_id = 6580731 /* ITR Survey Code */
  AND st.reporting_term_code = 'ITR1'
UNION ALL
SELECT
  st.respondent_employee_number AS survey_taker_id,
  st.respondent_name AS survey_taker_name,
  st.respondent_legal_entity_name AS survey_taker_legal_entity_name,
  st.respondent_location AS survey_taker_location,
  st.respondent_department AS survey_taker_department,
  st.respondent_primary_job AS survey_taker_primary_job,
  st.respondent_is_manager AS is_manager,
  st.respondent_position_status AS survey_taker_adp_status,
  st.respondent_samaccountname AS survey_taker_samaccount,
  st.academic_year,
  st.reporting_term_code AS reporting_term,
  st.respondent_manager_employee_number AS manager_df_employee_number,
  st.respondent_manager_name AS manager_name,
  st.respondent_manager_legal_entity_name AS manager_legal_entity_name,
  st.respondent_worker_category AS worker_category,
  st.attended_relay,
  st.kipp_alumni_status,
  st.life_experience_in_communities_we_serve,
  st.respondent_gender AS preferred_gender,
  st.respondent_race_ethnicity AS preferred_race_ethnicity,
  st.professional_experience_in_communities_we_serve,
  st.years_of_professional_experience_before_joining,
  st.years_teaching_in_any_state,
  st.years_teaching_in_nj_or_fl,
  st.teacher_prep_program,
  st.respondent_userprincipalname AS userprincipalname,
  st.survey_round_open_minus_fifteen,
  st.survey_round_open,
  st.survey_round_close,
  st.survey_default_link,
  st.survey_id,
  'Yes' AS survey_round_status,
  'Intent to Return' AS assignment,
  NULL AS assignment_employee_id,
  NULL AS assignment_preferred_name,
  NULL AS assignment_location,
  NULL AS assignment_adp_status,
  'Intent to Return' AS assignment_type,
  c.subject_name AS completed_survey_subject_name,
  c.date_submitted AS survey_completion_date
FROM
  survey_term_staff_scaffold AS st
  LEFT JOIN clean_responses AS c ON (
    st.respondent_employee_number = c.respondent_employee_number
    AND st.academic_year = c.academic_year
    AND st.reporting_term_code = c.reporting_term
    AND st.survey_id = c.survey_id
  )
WHERE
  st.survey_id = 6580731 /* ITR Survey Code */
  AND st.reporting_term_code = 'ITR2'
  AND st.respondent_legal_entity_name = 'KIPP Miami'
