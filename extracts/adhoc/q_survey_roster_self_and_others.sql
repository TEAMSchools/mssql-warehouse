select
  df_employee_number,
  preferred_first_name,
  preferred_last_name,
  userprincipalname,
  primary_site,
  primary_job
from
  gabby.people.staff_crosswalk_static
where
  [status] <> 'Terminated'
  and (
    (
      primary_job in ('Dean', 'Dean of Students', 'Dean of Students and Families')
      and is_manager = 'No'
    )
    or (
      primary_on_site_department = 'KTC'
      and primary_site = 'KIPP Newark Collegiate Academy'
    )
    or (
      primary_job in (
        'Learning Specialist',
        'Learning Specialist Coordinator',
        'Teacher',
        'Teacher in Residence',
        'Teacher, ESL',
        'Teacher ESL',
        'Social Worker',
        'Paraprofessional',
        'Behavior Analyst',
        'Behavior Specialist',
        'Speech Therapist',
        'Speech Language Pathologist',
        'Occupational Therapist',
        'School Psychologist',
        'Learning Disabilities Teacher Consultant',
        'Assistant Dean',
        'Aide (instructional)',
        'School Leader',
        'Assistant School Leader',
        'Assistant School Leader, SPED',
        'School Leader',
        'School Leader in Residence',
        'Director',
        'Director Campus Operations',
        'Director School Operations',
        'Director of Campus Operations',
        'Associate Director of School Operations',
        'Fellow School Operations Director',
        'Academic Operations Manager',
        'School Operations Manager',
        'Receptionist',
        'Custodian',
        'Senior Custodian',
        'Nurse',
        'Student Support Advocate'
      )
    )
  )
