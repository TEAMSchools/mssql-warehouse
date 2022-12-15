USE gabby GO
CREATE OR ALTER VIEW
  tableau.pm_pir_scores AS
SELECT
  rs.mentor_school_leader,
  rs.df_employee_number,
  rs.[type],
  rs.skill_number,
  rs.skill_text,
  rs.expected_date,
  rs.proficient_or_completed,
  rs.date_completed_or_observed,
  rs.rated_by_or_level_of_ownership,
  rs.notes,
  rs.year,
  r.preferred_name,
  r.primary_on_site_department,
  r.original_hire_date,
  r.primary_job,
  r.legal_entity_name,
  r.[status],
  r.primary_site,
  r.manager_name,
  r.manager_df_employee_number,
  r.userprincipalname,
  r.manager_mail
FROM
  gabby.pm.pir_rubric_scores AS rs
  LEFT JOIN gabby.people.staff_crosswalk_static AS r ON rs.df_employee_number = r.df_employee_number
