select
  'H1' as cola,
  /* account number */
  '601193' as colb,
  '00' as colc,
  /* organization name */
  'KIPP THROUGH COLLEGE NEW JERSEY' as cold,
  /* file creation date */
  /* inquiry purpose */
  cast(replace(cast(current_timestamp as date), '-', '') as varchar) as cole,
  'DA' as colf,
  'S' as colg,
  null as colh,
  null as coli,
  null as colj,
  null as colk,
  null as coll
union all
select
  'D1' as cola,
  /* leave blank */
  null as colb,
  first_name as colc,
  /* middle initial */
  null as cold,
  last_name as cole,
  /* name suffix */
  null as colf,
  /* date of birth */
  /* search begin date */
  cast(replace(cast(dob as date), '-', '') as varchar) as colg,
  /* leave blank */
  cast(replace(cast(exitdate as date), '-', '') as varchar) as colh,
  null as coli,
  /* leave blank */
  null as colj,
  '00' as colk,
  /* requestor return field */
  cast(student_number as varchar) as coll
from
  gabby.powerschool.cohort_identifiers_static
where
  rn_undergrad = 1
  and exitcode = 'G1'
  and grade_level <> 99
  and cohort <= gabby.utilities.global_academic_year ()
union all
select
  'T1',
  cast(count(student_number) + 2 as varchar),
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null
from
  gabby.powerschool.cohort_identifiers_static
where
  rn_undergrad = 1
  and exitcode = 'G1'
  and grade_level <> 99
  and cohort <= gabby.utilities.global_academic_year ()
