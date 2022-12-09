with
  dayforce as (
    select
      e.primary_site as school_name,
      e.preferred_first_name as first_name,
      e.preferred_last_name as last_name,
      e.birth_date as date_of_birth,
      e.gender,
      e.primary_ethnicity as ethnicity,
      e.original_hire_date as start_date_in_this_role,
      e.primary_job as job_title,
      e.grades_taught as grade_taught,
      e.subjects_taught as subject,
      e.salesforce_id,
      e.mail as work_email_address
    from
      gabby.people.staff_crosswalk_static e
    where
      e.original_hire_date >= datefromparts(gabby.utilities.global_academic_year (), 7, 1)
  ),
  salesforce as (
    select
      j.profile_application_c,
      j.job_position_c,
      pr.years_of_full_time_teaching_c as years_teaching,
      pr.kipp_alumus_c as kipp_alumni,
      pr.race_ethnicity_c as ethnicity,
      pr.teacher_prep_program_name_c as atp,
      pr.teacher_prep_program_region_c as atp_city,
      po.name as salesforce_position_id,
      po.grade_c as grade_taught,
      po.subject_area_c as subject
    from
      gabby.recruiting.job_application_c j
      left outer join gabby.recruiting.profile_application_c pr on j.profile_application_c = pr.id
      left outer join gabby.recruiting.job_position_c po on j.job_position_c = po.id
    where
      j.stage_c = 'Hired'
  )
select
  'KIPP New Jersey' as region,
  c.school_name,
  c.first_name,
  c.last_name,
  c.date_of_birth,
  c.gender,
  coalesce(c.ethnicity, s.ethnicity) as ethnicity,
  c.work_email_address,
  c.start_date_in_this_role,
  1 as fte,
  c.job_title,
  isnull(s.kipp_alumni, 'No') as kipp_alumni,
  coalesce(c.grade_taught, s.grade_taught) as grade_taught,
  coalesce(c.subject, s.subject) as subject,
  s.years_teaching,
  s.atp,
  s.atp_city
from
  dayforce c
  left join salesforce s on c.salesforce_id = s.salesforce_position_id
