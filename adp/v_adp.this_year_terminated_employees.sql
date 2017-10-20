USE gabby
GO

--CREATE OR ALTER VIEW v_adp.this_year_terminated_employees AS

WITH roster AS
(
     SELECT associate_id
           ,position_id
           ,preferred_first AS preferred_first_name
           ,preferred_last AS preferred_last_name
           ,CONCAT(preferred_first,' ',preferred_last) AS preferred_lastfirst
           ,location_description AS location
           ,location_custom
           ,subject_dept_custom 
           ,job_title_description AS job_title
           ,job_title_custom
           ,reports_to_name AS reports_to
           ,manager_custom_assoc_id
           ,termination_date
           ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,termination_date)) AS SY
                
     FROM gabby.adp.staff_roster
     WHERE rn_curr = 1
     AND position_status = 'Terminated'
     AND gabby.utilities.DATE_TO_SY(CONVERT(DATE,termination_date)) = '2017'
 )    
, emails AS
(
     SELECT employeenumber
           ,mail AS email_addr
     
     FROM adsi.user_attributes
)

SELECT r.termination_date
      ,r.associate_id
      ,r.preferred_first_name
      ,r.preferred_last_name
      ,r.preferred_lastfirst
      ,r.location
      ,r.location_custom
      ,r.subject_dept_custom
      ,r.job_title
      ,r.job_title_custom
      ,r.reports_to
      ,r.manager_custom_assoc_id
      ,e.email_addr

FROM roster r 
     LEFT OUTER JOIN emails e
     ON r.position_id = e.employeenumber