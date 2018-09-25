USE gabby
GO

--CREATE OR ALTER VIEW tableau.pm_etr_dashboard AS

WITH teacher_crosswalk AS (
  SELECT sr.df_employee_number
        ,sr.preferred_name        
        ,sr.primary_site
        ,sr.primary_on_site_department
        ,sr.grades_taught
        ,sr.primary_job
        ,sr.legal_entity_name        
        ,sr.is_active
        ,sr.primary_site_schoolid
        ,sr.manager_df_employee_number
        ,sr.manager_name
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


SELECT tc.db_name
      ,tc.df_employee_number
      ,tc.preferred_name
      ,tc.staff_username
      ,tc.primary_site
      ,tc.primary_job
      ,tc.manager_df_employee_number
      ,tc.manager_name
      ,tc.manager_username

      ,wo.observation_id
      ,wo.is_published
      ,wo.observed_at
      ,gabby.utilities.DATE_TO_SY(wo.observed_at) AS academic_year
      ,ROW_NUMBER() OVER( PARTITION BY wo.teacher_accountingId, observer_accountingId, gabby.utilities.DATE_TO_SY(wo.observed_at), wos.score_measurement_id, wo.rubric_name ORDER BY wo.observed_at) AS observation_round
      ,wo.observer_accountingId
      ,wo.observer_name
      ,wo.observer_email
      ,wo.teacher_accountingId
      ,wo.teacher_name
      ,wo.teacher_email
      ,wo.teaching_assignment_gradeLevel_name
      ,wo.teaching_assignment_school_name
      ,wo.rubric_name
      ,wo.score
      ,wo.score_averaged_by_strand
      ,wo.percentage AS percentage_averaged_by_strand

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
FROM teacher_crosswalk tc
JOIN gabby.whetstone.observations_clean wo
  ON tc.df_employee_number = wo.teacher_accountingId
LEFT JOIN gabby.whetstone.observations_scores wos
  ON wo.observation_id = wos.observation_id
LEFT JOIN gabby.whetstone.measurements wm
  ON wos.score_measurement_id = wm._id
LEFT JOIN gabby.whetstone.observations_scores_text_boxes tb
  ON wos.score_id = tb.score_id
WHERE wo.rubric_name IN ('Coaching Tool: Teacher Reflection', 'Coaching Tool: Coach ETR and Reflection')
  AND wo.teaching_assignment_school_name NOT IN ('[Training School]')