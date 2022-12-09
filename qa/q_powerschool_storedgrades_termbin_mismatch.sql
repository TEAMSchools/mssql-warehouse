select
  sg.[db_name],
  sg.dcid,
  sg.studentid,
  sg.termid,
  sg.storecode,
  sg.schoolid,
  sg.schoolname,
  sg.course_number
from
  gabby.powerschool.storedgrades sg
  left join gabby.powerschool.termbins tb on sg.schoolid = tb.schoolid
  and sg.termid = tb.termid
  and sg.storecode = tb.storecode
  and sg.[db_name] = tb.[db_name]
where
  tb.dcid is null
