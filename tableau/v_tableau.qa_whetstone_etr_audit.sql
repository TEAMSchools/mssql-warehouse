USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_whetstone_etr_audit AS

SELECT r.df_employee_number
      ,r.preferred_name
      ,r.primary_site AS location_description
      ,r.primary_job AS job_title_description
      ,r.legal_entity_name
      ,r.manager_df_employee_number
      ,r.manager_name
      ,r.status AS position_status

      ,s.value AS reporting_term

      ,rt.academic_year
      ,rt.alt_name
      
      ,wo.observer_name
      ,wo.score
FROM gabby.dayforce.staff_roster r
LEFT JOIN gabby.adsi.user_attributes_static ads
  ON r.df_employee_number = ads.employeenumber
 AND ISNUMERIC(ads.employeenumber) = 1
CROSS JOIN STRING_SPLIT('ETR1,ETR2,ETR3,ETR4', ',') s
LEFT JOIN gabby.reporting.reporting_terms rt
  ON s.value = rt.time_per_name
 AND rt.identifier = 'ETR'
 AND rt.schoolid = 0
 AND rt._fivetran_deleted = 0
LEFT JOIN gabby.whetstone.observations_clean wo
  ON r.df_employee_number = wo.teacher_accountingId
 AND wo.observed_at BETWEEN rt.start_date AND rt.end_date
 AND wo.rubric_name = 'Coaching Tool: Coach ETR and Reflection'
 AND ads.samaccountname != LEFT(wo.observer_email, CHARINDEX('@', wo.observer_email) - 1)
WHERE r.is_active = 1