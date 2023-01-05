CREATE OR ALTER VIEW
  powerschool.sections_identifiers AS
SELECT
  sec.id AS sectionid,
  sec.course_number_clean AS course_number,
  sec.termid,
  sec.section_number,
  sec.section_type,
  sec.external_expression,
  sec.room,
  sec.no_of_students,
  c.course_name,
  sch.name AS school_name,
  st.teacherid,
  st.start_date,
  st.end_date,
  st.roleid,
  CASE
    WHEN st.roleid IN (41, 25) THEN 'Lead teacher'
    WHEN st.roleid IN (42, 26) THEN 'Co-teacher'
    WHEN st.roleid = 841 THEN 'Gradebook access'
  END AS role_name,
  t.teachernumber,
  t.lastfirst AS teacher_lastfirst
FROM
  powerschool.sections AS sec
  INNER JOIN powerschool.courses AS c ON sec.course_number_clean = c.course_number_clean
  INNER JOIN powerschool.schools AS sch ON sec.schoolid = sch.school_number
  LEFT JOIN powerschool.sectionteacher AS st ON sec.id = st.sectionid
  LEFT JOIN powerschool.teachers_static AS t ON st.teacherid = t.id
