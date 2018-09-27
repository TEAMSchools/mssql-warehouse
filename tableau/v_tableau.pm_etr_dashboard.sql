USE gabby
GO

--CREATE OR ALTER VIEW tableau.pm_etr_dashboard AS

WITH teacher_crosswalk AS (
  SELECT sr.df_employee_number
        ,sr.preferred_name        
        ,sr.primary_site
        ,sr.primary_on_site_department AS dayforce_department
        ,sr.grades_taught AS dayforce_grade_team
        ,sr.primary_job AS dayforce_role
        ,sr.legal_entity_name        
        ,sr.is_active
        ,sr.primary_site_schoolid
        ,sr.manager_df_employee_number
        ,sr.manager_name
        ,sr.original_hire_date
        ,CASE
          WHEN sr.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
          WHEN sr.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
          WHEN sr.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
         END AS db_name
      
        ,COALESCE(idps.ps_teachernumber, sr.adp_associate_id, CONVERT(VARCHAR(25),sr.df_employee_number)) AS ps_teachernumber

        ,ads.samaccountname AS staff_username

        ,adm.samaccountname AS manager_username
  FROM gabby.dayforce.staff_roster sr
  LEFT JOIN gabby.people.id_crosswalk_powerschool idps
    ON sr.df_employee_number = idps.df_employee_number
   AND idps.is_master = 1
  LEFT JOIN gabby.adsi.user_attributes_static ads
    ON CONVERT(VARCHAR(25),sr.df_employee_number) = ads.employeenumber
  LEFT JOIN gabby.adsi.user_attributes_static adm
    ON CONVERT(VARCHAR(25),sr.manager_df_employee_number) = adm.employeenumber
  WHERE ISNULL(sr.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
 )
 
 ,whetstone_clean AS (
  SELECT wo.observation_id
        ,wo.is_published
        ,wo.observed_at
        ,wo.created
        ,gabby.utilities.DATE_TO_SY(wo.observed_at) AS academic_year
        ,wo.observer_accountingId
        ,wo.observer_name
        ,wo.observer_email
        ,wo.teacher_accountingId
        ,wo.teacher_name
        ,wo.teacher_email
        ,wo.rubric_name
        ,wo.score
        ,wo.score_averaged_by_strand
        ,wo.percentage AS percentage_averaged_by_strand
        --,MAX() AS last_form_submitted
        
        ,wos.score_id
        ,wos.score_measurement_id
        ,wos.score_percentage
        ,wos.score_value
              
        ,wm.name AS measurement_name
        ,wm.scale_min AS measurement_scale_min
        ,wm.scale_max AS measurement_scale_max      

        ,tb.text_box_id
        ,tb.text_box_label
        ,tb.text_box_text
        
        ,MAX(created) OVER( PARTITION BY gabby.utilities.DATE_TO_SY(wo.observed_at), wo.observer_accountingId, wo.teacher_accountingId) AS last_submitted_form
        
  FROM gabby.whetstone.observations_clean wo
  LEFT JOIN gabby.whetstone.observations_scores wos
    ON wo.observation_id = wos.observation_id
  LEFT JOIN gabby.whetstone.measurements wm
    ON wos.score_measurement_id = wm._id
  LEFT JOIN gabby.whetstone.observations_scores_text_boxes tb
    ON wos.score_id = tb.score_id
  WHERE wo.rubric_name IN ('Coaching Tool: Coach ETR and Reflection')
  AND wo.teaching_assignment_school_name NOT IN ('[Training School]')
  
 )
 
SELECT tc.db_name
      ,tc.df_employee_number
      ,tc.ps_teachernumber
      ,tc.preferred_name
      ,tc.staff_username
      ,tc.primary_site
      ,tc.dayforce_department
      ,tc.dayforce_grade_team
      ,tc.dayforce_role
      ,tc.manager_df_employee_number
      ,tc.manager_name
      ,tc.manager_username
      ,tc.original_hire_date

      ,wc.observation_id
      ,wc.is_published
      ,wc.observed_at
      ,wc.academic_year
      ,wc.observer_accountingId
      ,wc.observer_name
      ,wc.observer_email
      ,wc.teacher_accountingId
      ,wc.teacher_name
      ,wc.teacher_email
      ,wc.rubric_name
      ,wc.score
      ,wc.score_averaged_by_strand
      ,wc.percentage_averaged_by_strand
      ,wc.last_submitted_form --this is a workaround for now, but we'll need to do something with last submitted form for a given term beyond Q1. We'll need to pull in 'term' and parition by that.
      
      ,ROW_NUMBER() OVER( PARTITION BY wc.teacher_accountingId, wc.observer_accountingId, gabby.utilities.DATE_TO_SY(wc.observed_at), wc.score_measurement_id, wc.rubric_name ORDER BY wc.observed_at) AS observation_round
FROM teacher_crosswalk tc
JOIN whetstone_clean wc
  ON tc.df_employee_number = wc.teacher_accountingId