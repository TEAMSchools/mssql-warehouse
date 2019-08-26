USE gabby
GO

CREATE OR ALTER VIEW people.staff_crosswalk AS

SELECT sr.df_employee_number
      ,sr.adp_associate_id
      ,sr.salesforce_id
      ,sr.first_name
      ,sr.last_name
      ,sr.gender
      ,sr.primary_ethnicity
      ,sr.is_hispanic
      ,sr.address
      ,sr.city
      ,sr.state
      ,sr.postal_code
      ,sr.birth_date
      ,sr.original_hire_date
      ,sr.termination_date
      ,sr.rehire_date
      ,sr.status
      ,sr.status_reason
      ,sr.is_manager
      ,sr.leadership_role
      ,sr.preferred_first_name
      ,sr.preferred_last_name
      ,sr.primary_job
      ,sr.primary_on_site_department
      ,sr.primary_site
      ,sr.is_regional_staff
      ,sr.legal_entity_name
      ,sr.job_family
      ,sr.position_effective_from_date
      ,sr.position_effective_to_date
      ,sr.manager_df_employee_number
      ,sr.payclass
      ,sr.paytype
      ,sr.flsa_status
      ,sr.annual_salary
      ,sr.grades_taught
      ,sr.subjects_taught
      ,sr.position_title
      ,sr.primary_on_site_department_entity
      ,sr.primary_site_entity
      ,sr.preferred_name
      ,sr.mobile_number
      ,sr.payroll_company_code
      ,sr.is_active
      ,sr.is_campus_staff
      ,sr.primary_site_schoolid
      ,sr.primary_site_reporting_schoolid
      ,sr.primary_site_school_level
      ,sr.manager_adp_associate_id
      ,sr.manager_preferred_first_name
      ,sr.manager_preferred_last_name
      ,sr.manager_name
      ,sr.[db_name]

      ,COALESCE(idps.ps_teachernumber
               ,sr.adp_associate_id
               ,CONVERT(VARCHAR(25),sr.df_employee_number)) AS ps_teachernumber

      ,ads.samaccountname
      ,ads.userprincipalname
      ,ads.mail

      ,adm.samaccountname AS manager_samaccountname
      ,adm.userprincipalname AS manager_userprincipalname
      ,adm.mail AS manager_mail

      ,CASE WHEN c.personal_email != '' THEN c.personal_email END AS personal_email
FROM gabby.dayforce.staff_roster sr
LEFT JOIN gabby.people.id_crosswalk_powerschool idps
  ON sr.df_employee_number = idps.df_employee_number
 AND idps.is_master = 1
LEFT JOIN gabby.adsi.user_attributes_static ads
  ON CONVERT(VARCHAR(25),sr.df_employee_number) = ads.employeenumber
LEFT JOIN gabby.adsi.user_attributes_static adm
  ON CONVERT(VARCHAR(25),sr.manager_df_employee_number) = adm.employeenumber
LEFT JOIN gabby.dayforce.personal_contact_info c
  ON sr.df_employee_number = c.employee_number