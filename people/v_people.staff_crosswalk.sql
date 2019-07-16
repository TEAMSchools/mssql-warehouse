USE gabby
GO

CREATE OR ALTER VIEW people.staff_crosswalk AS

SELECT sr.df_employee_number
      ,sr.preferred_name
      ,sr.preferred_first_name
      ,sr.preferred_last_name
      ,sr.primary_job
      ,sr.position_title
      ,sr.legal_entity_name
      ,sr.primary_site
      ,sr.primary_on_site_department
      ,sr.primary_site_schoolid
      ,sr.primary_site_reporting_schoolid
      ,sr.primary_site_school_level
      ,sr.[status]
      ,sr.is_active
      ,sr.is_campus_staff
      ,sr.original_hire_date
      ,sr.termination_date
      ,sr.grades_taught
      ,sr.manager_df_employee_number
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

      ,c.personal_email
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