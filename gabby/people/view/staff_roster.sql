CREATE OR ALTER VIEW
  people.staff_roster AS
WITH
  all_staff AS (
    /* current */
    SELECT
      eh.employee_number,
      eh.associate_id,
      eh.position_id,
      eh.file_number,
      eh.termination_reason,
      eh.job_title,
      eh.home_department,
      eh.reports_to_associate_id,
      eh.reports_to_employee_number,
      CASE
        WHEN eh.position_status = 'Deceased' THEN 'Terminated'
        ELSE eh.position_status
      END AS position_status,
      eh.business_unit_code,
      eh.business_unit,
      eh.[location],
      eh.position_effective_start_date,
      eh.position_effective_end_date,
      eh.annual_salary,
      eh.effective_start_date,
      eh.status_effective_start_date,
      eh.primary_position,
      COALESCE(
        eh.work_assignment_start_date,
        eh.position_effective_start_date
      ) AS work_assignment_start_date
    FROM
      people.employment_history_static AS eh
    WHERE
      (
        -- trunk-ignore(sqlfluff/LT05)
        CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN eh.effective_start_date AND eh.effective_end_date
      )
    UNION ALL
    /* prestart */
    SELECT
      ps.employee_number,
      ps.associate_id,
      ps.position_id,
      ps.file_number,
      ps.termination_reason,
      ps.job_title,
      ps.home_department,
      ps.reports_to_associate_id,
      ps.reports_to_employee_number,
      'Prestart' AS position_status,
      ps.business_unit_code,
      ps.business_unit,
      ps.[location],
      ps.position_effective_start_date,
      ps.position_effective_end_date,
      ps.annual_salary,
      ps.effective_start_date,
      ps.status_effective_start_date,
      ps.primary_position,
      COALESCE(
        ps.work_assignment_start_date,
        ps.position_effective_start_date
      ) AS work_assignment_start_date
    FROM
      people.employment_history_static AS ps
    WHERE
      ps.status_effective_start_date > CAST(CURRENT_TIMESTAMP AS DATE)
      AND ps.position_status = 'Active'
      AND (
        ps.position_status_cur IS NULL
        OR ps.position_status_cur = 'Terminated'
      )
  ),
  hire_dates AS (
    SELECT
      associate_id,
      MIN(
        CASE
          WHEN position_status = 'Active' THEN status_effective_date
        END
      ) AS original_hire_date,
      MAX(
        CASE
          WHEN position_status IN ('Terminated', 'Deceased') THEN status_effective_date
        END
      ) AS termination_date
    FROM
      people.status_history_static
    GROUP BY
      associate_id
  ),
  termination_dates AS (
    SELECT
      associate_id,
      MAX(status_effective_date) AS termination_date
    FROM
      (
        SELECT
          associate_id,
          position_status,
          status_effective_date,
          LAG(position_status) OVER (
            PARTITION BY
              associate_id
            ORDER BY
              status_effective_date
          ) AS position_status_prev
        FROM
          people.status_history_static
      ) AS sub
    WHERE
      position_status_prev != 'Terminated'
      AND position_status IN ('Terminated', 'Deceased')
    GROUP BY
      associate_id
  ),
  rehire_dates AS (
    SELECT
      associate_id,
      MAX(status_effective_date) AS rehire_date
    FROM
      (
        SELECT
          associate_id,
          position_status,
          status_effective_date,
          LAG(position_status) OVER (
            PARTITION BY
              position_id
            ORDER BY
              status_effective_date
          ) AS position_status_prev
        FROM
          people.status_history_static
      ) AS sub
    WHERE
      position_status_prev = 'Terminated'
      AND position_status != 'Terminated'
    GROUP BY
      associate_id
  ),
  clean_staff AS (
    SELECT
      employee_number,
      associate_id,
      associate_oid,
      position_id,
      file_number,
      first_name,
      last_name,
      position_status,
      business_unit_code,
      business_unit,
      [location],
      home_department,
      job_title,
      is_manager,
      reports_to_associate_id,
      annual_salary,
      primary_position,
      position_effective_start_date,
      position_effective_end_date,
      work_assignment_start_date,
      original_hire_date,
      rehire_date,
      termination_date,
      termination_reason,
      job_family,
      address_street,
      address_city,
      address_state,
      address_zip,
      birth_date,
      personal_email,
      personal_mobile,
      wfmgr_pay_rule,
      worker_category,
      flsa,
      associate_id_legacy,
      sex,
      preferred_gender,
      gender_reporting,
      years_teaching_in_any_state,
      years_teaching_in_nj_or_fl,
      kipp_alumni_status,
      years_of_professional_experience_before_joining,
      life_experience_in_communities_we_serve,
      teacher_prep_program,
      professional_experience_in_communities_we_serve,
      attended_relay,
      preferred_race_ethnicity,
      preferred_race_ethnicity AS race,
      COALESCE(preferred_first_name, first_name) AS preferred_first_name,
      COALESCE(preferred_last_name, last_name) AS preferred_last_name,
      CASE
        WHEN preferred_race_ethnicity LIKE '%Decline to state%' THEN 1
        ELSE 0
      END AS is_race_decline,
      CASE
        WHEN preferred_race_ethnicity LIKE (
          '%My racial/ethnic identity is not listed%'
        ) THEN 1
        ELSE 0
      END AS is_race_other,
      CASE
        WHEN preferred_race_ethnicity LIKE '%Black/African American%' THEN 1
        ELSE 0
      END AS is_race_black,
      CASE
        WHEN preferred_race_ethnicity LIKE '%Asian%' THEN 1
        ELSE 0
      END AS is_race_asian,
      CASE
        WHEN preferred_race_ethnicity LIKE (
          '%Native Hawaiian or Other Pacific Islander%'
        ) THEN 1
        ELSE 0
      END AS is_race_nhpi,
      CASE
        WHEN preferred_race_ethnicity LIKE '%Middle Eastern%' THEN 1
        ELSE 0
      END AS is_race_mideast,
      CASE
        WHEN preferred_race_ethnicity LIKE '%White%' THEN 1
        ELSE 0
      END AS is_race_white,
      CASE
        WHEN preferred_race_ethnicity LIKE '%Native American/First Nation%' THEN 1
        ELSE 0
      END AS is_race_nafirstnation,
      CASE
        WHEN preferred_race_ethnicity LIKE '%Bi/Multiracial%' THEN 1
        WHEN preferred_race_ethnicity LIKE '%,%' THEN 1
        ELSE 0
      END AS is_race_multi,
      CASE
        WHEN preferred_race_ethnicity IS NULL THEN NULL
        WHEN preferred_race_ethnicity LIKE '%Decline to state%' THEN NULL
        WHEN (
          preferred_race_ethnicity LIKE '%Latinx/Hispanic/Chicana(o)%'
        ) THEN 'Hispanic or Latino'
        ELSE 'Not Hispanic or Latino'
      END AS ethnicity,
      education_level,
      undergrad_university
    FROM
      (
        SELECT
          eh.employee_number,
          eh.associate_id,
          eh.position_id,
          eh.file_number,
          eh.termination_reason,
          eh.job_title,
          eh.home_department,
          eh.reports_to_associate_id,
          eh.position_status,
          eh.business_unit_code,
          eh.business_unit,
          eh.[location],
          eh.position_effective_start_date,
          eh.position_effective_end_date,
          eh.work_assignment_start_date,
          eh.annual_salary,
          eh.primary_position,
          CAST(NULL AS NVARCHAR(256)) AS job_family,
          CASE
            WHEN eh.associate_id IN (
              SELECT
                reports_to_associate_id
              FROM
                people.manager_history_static
              WHERE
                (
                  -- trunk-ignore(sqlfluff/LT05)
                  CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN reports_to_effective_date AND reports_to_effective_end_date_eoy
                )
            ) THEN 1
            ELSE 0
          END AS is_manager,
          /* dedupe positions */
          ROW_NUMBER() OVER (
            PARTITION BY
              eh.associate_id
            ORDER BY
              eh.primary_position DESC,
              eh.status_effective_start_date DESC,
              CASE
                WHEN eh.position_status = 'Terminated' THEN 0
                ELSE 1
              END DESC,
              eh.effective_start_date DESC
          ) AS rn,
          ea.first_name,
          ea.last_name,
          ea.primary_address_city AS address_city,
          ea.primary_address_state_territory_code AS address_state,
          ea.primary_address_zip_postal_code AS address_zip,
          ea.personal_contact_personal_email AS personal_email,
          CAST(ea.birth_date AS DATE) AS birth_date,
          LEFT(UPPER(ea.gender), 1) AS sex,
          CASE
            WHEN ea.primary_address_address_line_1 IS NOT NULL THEN CONCAT(
              ea.primary_address_address_line_1,
              ', ' + ea.primary_address_address_line_2
            )
          END AS address_street,
          CAST(
            utilities.STRIP_CHARACTERS (
              ea.personal_contact_personal_mobile,
              '^0-9'
            ) AS NVARCHAR(256)
          ) AS personal_mobile,
          COALESCE(
            ea.preferred_gender,
            CASE
              WHEN ea.gender = 'Male' THEN 'Man'
              WHEN ea.gender = 'Female' THEN 'Woman'
            END
          ) AS gender_reporting,
          w.preferred_name_given AS preferred_first_name,
          w.preferred_name_family AS preferred_last_name,
          w.associate_oid,
          COALESCE(
            w.original_hire_date,
            hd.original_hire_date
          ) AS original_hire_date,
          CASE
            WHEN eh.position_status = 'Terminated' THEN COALESCE(
              w.termination_date,
              td.termination_date
            )
          END AS termination_date,
          CASE
            WHEN (
              eh.position_status = 'Prestart'
              AND w.termination_date IS NULL
            ) THEN NULL
            WHEN eh.position_status = 'Prestart' THEN eh.status_effective_start_date
            ELSE rh.rehire_date
          END AS rehire_date,
          COALESCE(
            sdf.years_teaching_any_state,
            cf.[Years Teaching - In any State]
          ) AS years_teaching_in_any_state,
          COALESCE(
            sdf.years_teaching_nj_and_fl,
            cf.[Years Teaching - In NJ or FL]
          ) AS years_teaching_in_nj_or_fl,
          COALESCE(
            sdf.kipp_alumni,
            cf.[KIPP Alumni Status]
          ) AS kipp_alumni_status,
          COALESCE(
            sdf.[professional_experience_before_KIPP],
            cf.[Years of Professional Experience before joining]
          ) AS years_of_professional_experience_before_joining,
          COALESCE(
            sdf.community_live,
            cf.[Life Experience in Communities We Serve]
          ) AS life_experience_in_communities_we_serve,
          COALESCE(
            sdf.teacher_prep,
            cf.[Teacher Prep Program]
          ) AS teacher_prep_program,
          COALESCE(
            sdf.community_work,
            cf.[Professional Experience in Communities We Serve]
          ) AS professional_experience_in_communities_we_serve,
          COALESCE(sdf.relay, cf.[Attended Relay]) AS attended_relay,
          cf.[WFMgr Pay Rule] AS wfmgr_pay_rule,
          COALESCE(
            sdf.preferred_gender,
            cf.[Preferred Gender]
          ) AS preferred_gender,
          sdf.education_level,
          sdf.undergrad_university,
          cw.adp_associate_id AS associate_id_legacy,
          COALESCE(
            p.worker_category_description,
            'Full Time'
          ) AS worker_category,
          p.flsa_description AS flsa,
          REPLACE(
            REPLACE(
              REPLACE(
                COALESCE(
                  sdf.race_ethnicity,
                  cf.[Preferred Race/Ethnicity],
                  CONCAT(
                    ea.race_description,
                    CASE
                      WHEN (
                        ea.ethnicity != 'Not Hispanic or Latino'
                      ) THEN ',Latinx/Hispanic/Chicana(o)'
                    END
                  )
                ),
                'Black or African American',
                'Black/African American'
              ),
              'American Indian or Alaska Native',
              'Native American/First Nation'
            ),
            'Two or more races (Not Hispanic or Latino)',
            'Bi/Multiracial'
          ) AS preferred_race_ethnicity
        FROM
          all_staff AS eh
          INNER JOIN adp.employees_all AS ea ON (
            eh.associate_id = ea.associate_id
          )
          LEFT JOIN adp.workers_clean_static AS w ON eh.associate_id = w.worker_id
          LEFT JOIN hire_dates AS hd ON (
            eh.associate_id = hd.associate_id
          )
          LEFT JOIN termination_dates AS td ON (
            eh.associate_id = td.associate_id
          )
          LEFT JOIN rehire_dates AS rh ON (
            eh.associate_id = rh.associate_id
          )
          -- trunk-ignore(sqlfluff/LT05)
          LEFT JOIN adp.workers_custom_field_group_wide_static AS cf ON (eh.associate_id = cf.worker_id)
          LEFT JOIN people.id_crosswalk_adp AS cw ON (
            eh.employee_number = cw.df_employee_number
            AND cw.rn_curr = 1
          )
          LEFT JOIN adp.employees AS p ON (eh.position_id = p.position_id)
          LEFT JOIN surveys.staff_information_survey_wide_static AS sdf ON (
            eh.employee_number = sdf.employee_number
          )
        WHERE
          eh.employee_number IS NOT NULL
      ) AS sub
    WHERE
      rn = 1
  )
SELECT
  c.employee_number,
  c.associate_id,
  c.associate_oid,
  c.position_id,
  c.file_number,
  c.first_name,
  c.last_name,
  c.position_status,
  c.business_unit,
  c.[location],
  c.home_department,
  c.job_title,
  c.is_manager,
  c.reports_to_associate_id,
  c.annual_salary,
  c.primary_position,
  c.position_effective_start_date,
  c.position_effective_end_date,
  c.work_assignment_start_date,
  c.original_hire_date,
  c.rehire_date,
  c.termination_date,
  c.termination_reason,
  c.job_family,
  c.address_street,
  c.address_city,
  c.address_state,
  c.address_zip,
  c.birth_date,
  c.personal_email,
  c.wfmgr_pay_rule,
  c.worker_category,
  c.flsa,
  c.associate_id_legacy,
  c.preferred_first_name,
  c.preferred_last_name,
  c.business_unit_code,
  c.sex,
  c.preferred_gender,
  c.gender_reporting,
  c.race,
  c.preferred_race_ethnicity,
  c.ethnicity,
  c.is_race_asian,
  c.is_race_black,
  c.is_race_decline,
  c.is_race_mideast,
  c.is_race_multi,
  c.is_race_nhpi,
  c.is_race_other,
  c.is_race_white,
  c.years_teaching_in_any_state,
  c.years_teaching_in_nj_or_fl,
  c.kipp_alumni_status,
  c.years_of_professional_experience_before_joining,
  c.life_experience_in_communities_we_serve,
  c.teacher_prep_program,
  c.professional_experience_in_communities_we_serve,
  c.attended_relay,
  c.preferred_last_name + ', ' + c.preferred_first_name AS preferred_name,
  CONCAT(
    SUBSTRING(c.personal_mobile, 1, 3) + '-',
    SUBSTRING(c.personal_mobile, 4, 3) + '-',
    SUBSTRING(c.personal_mobile, 7, 4)
  ) AS personal_mobile,
  CASE
    WHEN c.business_unit = 'KIPP TEAM and Family Schools Inc.' THEN '9AM'
    WHEN c.business_unit = 'TEAM Academy Charter School' THEN '2Z3'
    WHEN c.business_unit = 'KIPP Cooper Norcross Academy' THEN '3LE'
    WHEN c.business_unit = 'KIPP Miami' THEN '47S'
  END AS payroll_company_code,
  CASE
    WHEN c.business_unit = 'TEAM Academy Charter School' THEN 'kippnewark'
    WHEN c.business_unit = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
    WHEN c.business_unit = 'KIPP Miami' THEN 'kippmiami'
  END AS [db_name],
  CASE
    WHEN c.position_status NOT IN ('Terminated', 'Prestart') THEN 1
    ELSE 0
  END AS is_active,
  CASE
    WHEN c.ethnicity = 'Hispanic or Latino' THEN 1
    WHEN c.ethnicity = 'Not Hispanic or Latino' THEN 0
    ELSE 0
  END AS is_hispanic,
  CASE
    WHEN c.is_race_decline = 1 THEN 'Decline to state'
    WHEN c.ethnicity = 'Hispanic or Latino' THEN 'Latinx/Hispanic/Chicana(o)'
    WHEN c.is_race_multi = 1 THEN 'Bi/Multiracial'
    WHEN ISNULL(c.preferred_race_ethnicity, '') = '' THEN 'Missing'
    ELSE c.preferred_race_ethnicity
  END AS race_ethnicity_reporting,
  s.ps_school_id AS primary_site_schoolid,
  s.reporting_school_id AS primary_site_reporting_schoolid,
  s.school_level AS primary_site_school_level,
  s.is_campus AS is_campus_staff,
  m.employee_number AS manager_employee_number,
  m.associate_id AS manager_associate_id,
  m.preferred_first_name AS manager_preferred_first_name,
  m.preferred_last_name AS manager_preferred_last_name,
  m.preferred_last_name + ', ' + m.preferred_first_name AS manager_name,
  m.business_unit AS manager_business_unit,
  y.years_at_kipp_total,
  (
    y.years_at_kipp_total + c.years_of_professional_experience_before_joining
  ) AS total_professional_experience,
  y.years_teaching_at_kipp,
  y.years_teaching_at_kipp + c.years_teaching_in_nj_or_fl AS nj_fl_total_years_teaching,
  y.years_teaching_at_kipp + c.years_teaching_in_any_state AS total_years_teaching,
  c.education_level,
  c.undergrad_university,
  gl.student_grade_level AS primary_grade_taught,
  ads.userprincipalname
FROM
  clean_staff AS c
  LEFT JOIN people.school_crosswalk AS s ON (
    c.[location] = s.site_name
    AND s._fivetran_deleted = 0
  )
  LEFT JOIN clean_staff AS m ON (
    c.reports_to_associate_id = m.associate_id
  )
  LEFT JOIN people.years_experience AS y ON (
    c.employee_number = y.employee_number
  )
  LEFT JOIN pm.teacher_grade_levels AS gl ON (
    c.employee_number = gl.employee_number
    AND gl.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
    AND gl.is_primary_gl = 1
  )
  LEFT JOIN adsi.user_attributes_static AS ads ON (
    CAST(c.employee_number AS VARCHAR(25)) = ads.employeenumber
  )
