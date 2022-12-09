select
  'PH3' as cola, -- account code
  '10046698' as colb, -- account name
  'KIPP NEWARK COLLEGIATE ACADEMY' as colc,
  'P' as cold, -- file transmission date
  -- diploma period
  cast(replace(cast(current_timestamp as date), '-', '') as varchar) as cole,
  concat(min(cohort), '-', max(cohort)) as colf,
  null as colg,
  null as colh,
  null as coli,
  null as colj,
  null as colk,
  null as coll,
  null as colm,
  null as coln,
  null as colo,
  null as colp,
  null as colq,
  null as colr,
  null as cols,
  null as colt,
  null as colu,
  null as colv,
  null as colw,
  null as colx,
  null as coly,
  null as colz,
  null as colaa,
  null as colab
from
  gabby.powerschool.cohort_identifiers_static co
where
  co.grade_level = 12
  and co.exitcode = 'G1'
union all
select
  'PD3' as cola,
  'NO SSN' as colb, -- first name
  co.first_name colc, -- middle name
  null as cold, -- last name
  co.last_name as cole, -- name suffix
  null as colf, -- prev last name
  null as colg, -- prev first name
  null as colh, -- date of birth
  cast(replace(cast(co.dob as date), '-', '') as varchar) as coli, -- student ID
  co.student_number as colj, -- diploma type
  'Regular Diploma' as colk, -- HS graduation date
  -- FERPA block
  cast(replace(cast(co.exitdate as date), '-', '') as varchar) as coll,
  'N' as colm, -- high school name
  'KIPP NEWARK COLLEGIATE ACADEMY' as coln, -- ACT code
  '310986' as colo, -- gender
  null as colp, -- ethnicity
  null as colq, -- econ disadvantaged
  null as colr, -- 8th gr state assessment - math
  null as cols, -- 8th gr state assessment - ela
  null as colt, -- HS state assessment - math
  null as colu, -- HS gr state assessment - ela
  null as colv, -- ELL
  null as colw, -- # semseters of math
  null as colx, -- dual enrollment
  null as coly, -- disability code
  null as colz, -- program code
  null as colaa,
  'ED' as colab
from
  gabby.powerschool.cohort_identifiers_static co
where
  co.school_level = 'HS'
  and co.exitcode = 'G1'
union all
select
  'PT3' as cola,
  cast(count(student_number) + 2 as varchar) as colb,
  null as colc,
  null as cold,
  null as cole,
  null as colf,
  null as colg,
  null as colh,
  null as coli,
  null as colj,
  null as colk,
  null as coll,
  null as colm,
  null as coln,
  null as colo,
  null as colp,
  null as colq,
  null as colr,
  null as cols,
  null as colt,
  null as colu,
  null as colv,
  null as colw,
  null as colx,
  null as coly,
  null as colz,
  null as colaa,
  null as colab
from
  gabby.powerschool.cohort_identifiers_static co
where
  co.school_level = 'HS'
  and co.exitcode = 'G1'
