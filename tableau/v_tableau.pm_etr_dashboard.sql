USE gabby
GO

CREATE OR ALTER VIEW tableau.pm_etr_dashboard AS

SELECT sr.df_employee_number
      ,sr.preferred_name        
      ,sr.primary_site
      ,sr.primary_on_site_department AS dayforce_department
      ,sr.grades_taught AS dayforce_grade_team
      ,sr.primary_job AS dayforce_role
      ,sr.legal_entity_name        
      ,sr.is_active
      ,sr.primary_site_schoolid
      ,sr.manager_name
      ,sr.original_hire_date

      ,ads.samaccountname AS staff_username

      ,adm.samaccountname AS manager_username

      ,wo.observation_id
      ,wo.observed_at
      ,wo.created      
      ,wo.observer_name
      ,wo.observer_email
      ,wo.rubric_name
      ,wo.score
      ,wo.score_averaged_by_strand
      ,wo.percentage AS percentage_averaged_by_strand
        
      ,wos.score_percentage
      ,wos.score_value
              
      ,wm.name AS measurement_name
      ,wm.scale_min AS measurement_scale_min
      ,wm.scale_max AS measurement_scale_max      

      ,tb.text_box_label
      ,tb.text_box_text

      ,rt.academic_year
      ,rt.time_per_name AS reporting_term
FROM gabby.dayforce.staff_roster sr
LEFT JOIN gabby.adsi.user_attributes_static ads
  ON sr.df_employee_number = ads.employeenumber
 AND ISNUMERIC(ads.employeenumber) = 1
LEFT JOIN gabby.adsi.user_attributes_static adm
  ON sr.manager_df_employee_number = adm.employeenumber
 AND ISNUMERIC(adm.employeenumber) = 1
JOIN gabby.whetstone.observations_clean wo
  ON sr.df_employee_number = wo.teacher_accountingId
 AND wo.rubric_name IN ('Coaching Tool: Coach ETR and Reflection') 
LEFT JOIN gabby.whetstone.observations_scores wos
  ON wo.observation_id = wos.observation_id
LEFT JOIN gabby.whetstone.measurements wm
  ON wos.score_measurement_id = wm._id
LEFT JOIN gabby.whetstone.observations_scores_text_boxes tb
  ON wos.score_id = tb.score_id
JOIN gabby.reporting.reporting_terms rt
  ON wo.observed_at BETWEEN rt.start_date AND rt.end_date 
 AND rt.identifier = 'ETR'
 AND rt.schoolid = 0
 AND rt._fivetran_deleted = 0
WHERE ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)