with
  this as (
    select
      *,
      row_number() over (
        partition by
          location,
          home_department,
          job_title
        order by
          egencia_traveler_group desc
      ) as rn
    from
      (
        select
          [location],
          home_department,
          job_title,
          egencia_traveler_group
        from
          gabby.egencia.traveler_groups
        union all
        select distinct
          scw.[location],
          scw.home_department,
          scw.job_title,
          null
        from
          gabby.people.staff_roster scw
        where
          (
            scw.worker_category not in ('Intern', 'Part Time')
            or scw.worker_category is null
          )
          and coalesce(scw.termination_date, current_timestamp) >= datefromparts(gabby.utilities.global_academic_year (), 7, 1)
        union all
        select distinct
          scw.[location],
          scw.home_department,
          'Default',
          null
        from
          gabby.people.staff_roster scw
        where
          (
            scw.worker_category not in ('Intern', 'Part Time')
            or scw.worker_category is null
          )
          and coalesce(scw.termination_date, current_timestamp) >= datefromparts(gabby.utilities.global_academic_year (), 7, 1)
        union all
        select distinct
          scw.[location],
          'Default',
          'Default',
          null
        from
          gabby.people.staff_roster scw
        where
          (
            scw.worker_category not in ('Intern', 'Part Time')
            or scw.worker_category is null
          )
          and coalesce(scw.termination_date, current_timestamp) >= datefromparts(gabby.utilities.global_academic_year (), 7, 1)
      ) sub
  )
select
  [location],
  home_department,
  job_title,
  egencia_traveler_group
from
  this
where
  rn = 1
  and [location] is not null
  and home_department is not null
  and job_title is not null
order by
  [location],
  home_department,
  job_title
