with
  slap as (
    select
      scw.primary_site_schoolid,
      case
        when scw.legal_entity_name = 'KIPP Miami' then lower(left(scw.userprincipalname, charindex('@', scw.userprincipalname))) + 'kippmiami.org'
        else lower(left(scw.userprincipalname, charindex('@', scw.userprincipalname))) + 'apps.teamschools.org'
      end as gsuite_email
    from
      gabby.people.staff_crosswalk_static scw
    where
      scw.[status] not in ('TERMINATED', 'PRESTART')
      and scw.primary_job in ('School Leader', 'Assistant School Leader')
  )
select distinct
  concat(
    case
      when s.[db_name] = 'kippnewark' then 'nwk'
      when s.[db_name] = 'kippcamden' then 'cmd'
      when s.[db_name] = 'kippmiami' then 'mia'
    end,
    s.teacher,
    s.course_number_clean
  ) as alias,
  sl.gsuite_email as teacher
from
  gabby.powerschool.sections s
  join gabby.powerschool.courses c on s.course_number_clean = c.course_number_clean
  and s.[db_name] = c.[db_name]
  and c.credittype <> 'LOG'
  join slap sl on s.schoolid = sl.primary_site_schoolid
where
  s.yearid = (gabby.utilities.global_academic_year () - 1990)
order by
  sl.gsuite_email,
  alias
