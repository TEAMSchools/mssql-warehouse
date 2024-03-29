CREATE OR ALTER VIEW
  people.staff_crosswalk AS
SELECT
  sub.employee_number AS df_employee_number,
  sub.associate_id AS adp_associate_id,
  sub.position_id,
  sub.file_number,
  CAST(NULL AS NVARCHAR(32)) AS salesforce_id,
  sub.first_name,
  sub.last_name,
  CAST(
    sub.gender_reporting AS NVARCHAR(32)
  ) AS gender,
  sub.ethnicity AS primary_ethnicity,
  sub.race_ethnicity_reporting AS primary_race_ethnicity_reporting,
  sub.is_hispanic,
  sub.address_street AS [address],
  sub.address_city AS city,
  sub.address_state AS [state],
  sub.address_zip AS postal_code,
  sub.birth_date,
  sub.original_hire_date,
  sub.termination_date,
  sub.rehire_date,
  sub.[status],
  sub.termination_reason AS status_reason,
  sub.is_manager,
  NULL AS leadership_role,
  sub.preferred_first_name,
  sub.preferred_last_name,
  sub.job_title AS primary_job,
  sub.home_department AS primary_on_site_department,
  sub.[location] AS primary_site,
  NULL AS is_regional_staff,
  sub.business_unit AS legal_entity_name,
  sub.job_family,
  sub.position_effective_start_date AS position_effective_from_date,
  sub.position_effective_end_date AS position_effective_to_date,
  sub.work_assignment_start_date,
  sub.manager_employee_number AS manager_df_employee_number,
  sub.worker_category AS payclass,
  sub.wfmgr_pay_rule AS paytype,
  sub.flsa AS flsa_status,
  sub.annual_salary,
  gl.student_grade_level AS grades_taught,
  NULL AS subjects_taught,
  NULL AS position_title,
  NULL AS primary_on_site_department_entity,
  NULL AS primary_site_entity,
  sub.preferred_name,
  sub.personal_mobile AS mobile_number,
  sub.payroll_company_code,
  sub.is_active,
  sub.is_campus_staff,
  sub.primary_site_schoolid,
  sub.primary_site_reporting_schoolid,
  sub.primary_site_school_level,
  sub.manager_associate_id AS manager_adp_associate_id,
  sub.manager_preferred_first_name,
  sub.manager_preferred_last_name,
  sub.manager_name,
  sub.manager_business_unit,
  sub.[db_name],
  sub.associate_id_legacy AS adp_associate_id_legacy,
  sub.ps_teachernumber,
  sub.samaccountname,
  sub.userprincipalname,
  sub.mail,
  sub.is_active_ad,
  sub.google_email,
  sub.manager_samaccountname,
  sub.manager_userprincipalname,
  sub.manager_mail,
  sub.personal_email
FROM
  (
    SELECT
      sr.employee_number,
      sr.associate_id,
      sr.position_id,
      sr.file_number,
      sr.first_name,
      sr.last_name,
      sr.gender_reporting,
      sr.ethnicity,
      sr.race_ethnicity_reporting,
      sr.is_hispanic,
      sr.address_street,
      sr.address_city,
      sr.address_state,
      sr.address_zip,
      sr.birth_date,
      sr.original_hire_date,
      sr.termination_date,
      sr.rehire_date,
      sr.termination_reason,
      sr.is_manager,
      sr.preferred_first_name,
      sr.preferred_last_name,
      sr.job_title,
      sr.home_department,
      sr.[location],
      sr.business_unit,
      sr.job_family,
      sr.position_effective_start_date,
      sr.position_effective_end_date,
      sr.work_assignment_start_date,
      sr.manager_employee_number,
      sr.worker_category,
      sr.wfmgr_pay_rule,
      sr.flsa,
      sr.annual_salary,
      sr.preferred_name,
      sr.personal_mobile,
      sr.payroll_company_code,
      sr.is_active,
      sr.is_campus_staff,
      sr.primary_site_schoolid,
      sr.primary_site_reporting_schoolid,
      sr.primary_site_school_level,
      sr.manager_associate_id,
      sr.manager_preferred_first_name,
      sr.manager_preferred_last_name,
      sr.manager_name,
      sr.manager_business_unit,
      sr.[db_name],
      sr.associate_id_legacy,
      sr.personal_email,
      CASE
        WHEN sr.position_status = 'Leave' THEN 'INACTIVE'
        ELSE UPPER(sr.position_status)
      END AS [status],
      COALESCE(
        idps.ps_teachernumber,
        sr.associate_id_legacy,
        CAST(
          sr.employee_number AS VARCHAR(25)
        )
      ) AS ps_teachernumber,
      ads.samaccountname,
      ads.userprincipalname,
      ads.mail,
      ads.is_active AS is_active_ad,
      CASE
        WHEN sr.business_unit = 'KIPP Miami' THEN LOWER(
          LEFT(
            ads.userprincipalname,
            CHARINDEX('@', ads.userprincipalname)
          )
        ) + 'kippmiami.org'
        ELSE LOWER(
          LEFT(
            ads.userprincipalname,
            CHARINDEX('@', ads.userprincipalname)
          )
        ) + 'apps.teamschools.org'
      END AS google_email,
      adm.samaccountname AS manager_samaccountname,
      adm.userprincipalname AS manager_userprincipalname,
      adm.mail AS manager_mail
    FROM
      people.staff_roster AS sr
      LEFT JOIN people.id_crosswalk_powerschool AS idps ON (
        sr.employee_number = idps.df_employee_number
        AND idps.is_master = 1
        AND idps._fivetran_deleted = 0
      )
      LEFT JOIN adsi.user_attributes_static AS ads ON (
        CAST(
          sr.employee_number AS VARCHAR(25)
        ) = ads.employeenumber
      )
      LEFT JOIN adsi.user_attributes_static AS adm ON (
        CAST(
          sr.manager_employee_number AS VARCHAR(25)
        ) = adm.employeenumber
      )
  ) AS sub
  LEFT JOIN pm.teacher_grade_levels AS gl ON (
    sub.ps_teachernumber = gl.teachernumber
    AND gl.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
    AND gl.is_primary_gl = 1
  )
