USE gabby
GO

CREATE OR ALTER VIEW tableau.pm_pir_scores AS:

SELECT rs.mentor_school_leader
      ,rs.df_employee_number
      ,rs.type
      ,rs.skill_number
      ,rs.skill_text
      ,rs.expected_date
      ,rs.proficient_or_completed
      ,rs.date_completed_or_observed
      ,rs.rated_by_or_level_of_ownership
      ,rs.notes

      ,r.preferred_name
      ,r.subject_dept_custom
      ,r.original_hire_date
      ,r.job_title_custom
      ,r.legal_entity_name
      ,r.position_status
      ,r.location_description
      ,r.reports_to_name
      ,r.manager_df_employee_number
      ,r.userprincipalname
      ,r.manager_mail
      
FROM gabby.pm.pir_rubric_scores rs LEFT OUTER JOIN gabby.tableau.staff_roster r
  ON rs.df_employee_number = r.df_employee_number