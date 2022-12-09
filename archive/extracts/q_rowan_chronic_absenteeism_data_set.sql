with
  ada as (
    select
      studentid,
      yearid,
      avg(cast(attendancevalue as float)) as ada
    from
      gabby.powerschool.ps_adaadm_daily_ctod_static
    group by
      studentid,
      yearid
  ),
  suspensions as (
    select
      studentid,
      gabby.utilities.date_to_sy (att_date) as academic_year,
      max(
        case
          when att_code = 'OSS' then 'Y'
          else 'N'
        end
      ) as oss,
      max(
        case
          when att_code = 'ISS' then 'Y'
          else 'N'
        end
      ) as iss
    from
      gabby.powerschool.ps_attendance_daily_static
    group by
      studentid,
      gabby.utilities.date_to_sy (att_date)
  )
select
  co.student_number,
  concat(co.first_name, ' ', co.last_name) as student_name,
  co.dob,
  concat(co.street, ', ', co.city, ', ', co.state, ' ', co.zip) as home_address,
  co.ethnicity,
  nj.home_language,
  co.academic_year,
  co.entrydate,
  co.exitdate,
  co.school_name,
  co.grade_level,
  co.iep_status,
  co.lunchstatus,
  gpa.gpa_y1,
  lit.read_lvl,
  ada.ada,
  sus.iss,
  sus.oss,
  null as transportation_method
from
  gabby.powerschool.cohort_identifiers_static co
  left outer join gabby.powerschool.s_nj_stu_x nj on co.students_dcid = nj.studentsdcid
  left outer join gabby.powerschool.gpa_detail gpa on co.student_number = gpa.student_number
  and co.academic_year = gpa.academic_year
  and gpa.is_curterm = 1
  left outer join gabby.lit.achieved_by_round_static lit on co.student_number = lit.student_number
  and co.academic_year = lit.academic_year
  and lit.is_curterm = 1
  left outer join ada on co.studentid = ada.studentid
  and co.yearid = ada.yearid
  left outer join suspensions sus on co.studentid = sus.studentid
  and co.academic_year = sus.academic_year
where
  co.region = 'KCNA'
  and co.academic_year >= 2015
  and co.rn_year = 1
