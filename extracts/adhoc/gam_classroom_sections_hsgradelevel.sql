with
  this as (
    select
      concat(
        case
          when co.[db_name] = 'kippnewark' then 'nwk'
          when co.[db_name] = 'kippcamden' then 'cmd'
          when co.[db_name] = 'kippmiami' then 'mia'
        end,
        co.schoolid,
        co.grade_level
      ) as alias,
      co.schoolid,
      concat(co.school_name, ' Grade ', co.grade_level) as [name],
      'all' as section,
      saa.student_web_id + '@teamstudents.org' as email
    from
      gabby.powerschool.cohort_identifiers_static co
      join gabby.powerschool.student_access_accounts_static saa on co.student_number = saa.student_number
    where
      co.academic_year = 2019
      and co.rn_year = 1
      and co.enroll_status = 0
      and co.school_level = 'HS'
  )
  -- /* Section setup
select distinct
  t.alias,
  t.[name],
  t.section,
  case
    when scw.legal_entity_name = 'KIPP Miami' then lower(left(scw.userprincipalname, charindex('@', scw.userprincipalname))) + 'kippmiami.org'
    else lower(left(scw.userprincipalname, charindex('@', scw.userprincipalname))) + 'apps.teamschools.org'
  end as teacher
from
  this t
  join gabby.people.staff_crosswalk_static scw on t.schoolid = scw.primary_site_schoolid
  and scw.primary_job = 'School Leader'
  and scw.[status] not in ('TERMINATED', 'PRESTART')
  -- */
  /*
  SELECT t.alias
  ,t.email
  FROM this t
  --*/
