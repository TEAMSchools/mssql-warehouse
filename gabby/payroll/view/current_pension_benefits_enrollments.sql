CREATE OR ALTER VIEW
  payroll.current_pension_benefits_enrollments AS

SELECT 
  pb.employee_number,
  pb.plan_type,
  pb.plan_name,
  pb.coverage_level,
  pb.effective_date,

  cw.preferred_name,
  cw.primary_race_ethnicity_reporting,
  cw.gender,
  cw.primary_site,
  cw.primary_on_site_department,
  cw.primary_job,
  cw.legal_entity_name,
  cw.[status] AS position_status

FROM gabby.adp.pension_and_benefits_enrollments AS pb
INNER JOIN gabby.people.staff_crosswalk_static AS cw ON (
  pb.employee_number = cw.df_employee_number
  )
