USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_staff_roster AS

SELECT CONVERT(VARCHAR,adp.associate_id) AS associate_id
      ,adp.preferred_first AS preferred_first_name
      ,adp.preferred_last AS preferred_last_name
      ,CONCAT(adp.preferred_last, ', ', adp.preferred_first) AS preferred_lastfirst
      ,adp.location_description AS location
      ,adp.location_custom
      ,adp.home_department_description AS department
      ,adp.subject_dept_custom
      ,adp.job_title_description AS job_title 
      ,adp.job_title_custom
      ,adp.reports_to_name AS reports_to
      ,adp.manager_custom_assoc_id
      ,adp.position_status
      ,CONVERT(VARCHAR,adp.termination_date) AS termination_date
       
      ,dir.mail AS email_addr 

      ,CONVERT(VARCHAR,adp.hire_date) AS hire_date
      ,CONVERT(VARCHAR,adp.position_start_date) AS position_start_date
FROM gabby.adp.staff_roster adp
LEFT OUTER JOIN gabby.adsi.user_attributes_static dir
  ON adp.associate_id = dir.idautopersonalternateid
WHERE rn_curr = 1 

/*
SELECT CONVERT(VARCHAR,df.adp_associate_id) AS associate_id
      ,df.preferred_first_name
      ,df.preferred_last_name
      ,df.preferred_name AS preferred_lastfirst
      ,df.primary_site AS location
      ,df.primary_site AS location_custom
      ,df.primary_on_site_department AS department
      ,df.primary_on_site_department AS subject_dept_custom
      ,df.primary_job AS job_title 
      ,df.primary_job AS job_title_custom
      ,df.manager_name AS reports_to
      ,df.manager_adp_associate_id AS manager_custom_assoc_id
      ,df.status AS position_status
      ,CONVERT(VARCHAR,df.termination_date) AS termination_date
       
      ,dir.mail AS email_addr 

      ,CONVERT(VARCHAR,df.original_hire_date) AS hire_date
      ,CONVERT(VARCHAR,df.position_effective_from_date) AS position_start_date
      ,df.legal_entity_name
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.adsi.user_attributes_static dir
  ON COALESCE(df.adp_associate_id, CONVERT(VARCHAR,df.df_employee_number)) = dir.idautopersonalternateid
*/