USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_staff_roster AS

SELECT CONVERT(NVARCHAR,adp.associate_id) AS associate_id
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
      ,CONVERT(NVARCHAR,adp.termination_date) AS termination_date
       
      ,dir.mail AS email_addr 
FROM gabby.adp.staff_roster adp
LEFT OUTER JOIN gabby.adsi.user_attributes dir
  ON adp.associate_id = dir.idautopersonalternateid
WHERE rn_curr = 1 