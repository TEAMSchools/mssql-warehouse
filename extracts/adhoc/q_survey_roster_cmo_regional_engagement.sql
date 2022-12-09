select
  df_employee_number,
  userprincipalname,
  preferred_first_name,
  preferred_last_name,
  case
    when legal_entity_name = 'KIPP Cooper Norcross Academy' then 'KCNA'
    when legal_entity_name = 'TEAM Academy Charter Schools' then 'TEAM'
    when legal_entity_name = 'KIPP New Jersey' then 'KIPP New Jersey'
    when legal_entity_name = 'KIPP Miami' then 'Miami'
  end as entity,
  case
    when primary_site in ('Room 9 - 60 Park Pl', 'Room 10 - 121 Market St', 'Room 11 - 1951 NW 7th Ave') then 'Not School Based'
    else 'school-based'
  end as school_based,
  case
    when primary_job = 'Head of Schools' then 'Head of Schools'
    when primary_job = 'Assistant Superintendent' then 'Head of Schools'
    when primary_job in (
      'Teacher',
      'Teacher in Residence',
      'Learning Specialist',
      'Learning Specialist Coordinator',
      'Teacher, ESL',
      'Teacher ESL'
    ) then 'Teacher'
    when primary_job = 'Executive Director' then 'Executive Director'
    when primary_job in ('Associate Director of School Operations') then 'ADSO'
    when primary_job in (
      'Director Campus Operations',
      'Director School Operations',
      'Director of Campus Operations',
      'Fellow School Operations Director'
    ) then 'DSO'
    when primary_job = 'Managing Director of Operations' then 'MDO'
    when primary_job = 'Managing Director of School Operations' then 'MDSO'
    when primary_job = 'School Leader' then 'School Leader'
    when primary_job in (
      'Assistant School Leader',
      'Assistant School Leader, SPED',
      'School Leader in Residence'
    ) then 'AP'
    else 'Other'
  end as usergroup
from
  gabby.people.staff_crosswalk_static
where
  [status] not in ('Terminated', 'Prestart')
