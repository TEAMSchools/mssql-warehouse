SELECT
  sg.[db_name],
  sg.dcid,
  sg.studentid,
  sg.termid,
  sg.storecode,
  sg.schoolid,
  sg.schoolname,
  sg.course_number
FROM
  powerschool.storedgrades AS sg
  LEFT JOIN powerschool.termbins AS tb ON (
    sg.schoolid = tb.schoolid
    AND sg.termid = tb.termid
    AND sg.storecode = tb.storecode
    AND sg.[db_name] = tb.[db_name]
  )
WHERE
  tb.dcid IS NULL
