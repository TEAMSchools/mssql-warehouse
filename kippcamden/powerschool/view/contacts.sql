CREATE OR ALTER VIEW
  powerschool.contacts AS
SELECT
  s.student_number,
  s.family_ident,
  sca.personid,
  sca.contactpriorityorder,
  COALESCE(
    ocm.originalcontacttype,
    CONCAT(
      'contact',
      sca.contactpriorityorder
    )
  ) AS person_type,
  p.firstname,
  p.lastname,
  scd.isemergency,
  scd.iscustodial,
  scd.liveswithflg,
  scd.schoolpickupflg,
  sccs.code AS relationship_type
FROM
  powerschool.students AS s
  INNER JOIN powerschool.studentcontactassoc AS sca ON (s.dcid = sca.studentdcid)
  INNER JOIN powerschool.person AS p ON (sca.personid = p.id)
  INNER JOIN powerschool.studentcontactdetail AS scd ON (
    sca.studentcontactassocid = scd.studentcontactassocid
    AND scd.isactive = 1
  )
  INNER JOIN powerschool.codeset AS sccs ON (
    scd.relationshiptypecodesetid = sccs.codesetid
  )
  LEFT JOIN powerschool.originalcontactmap AS ocm ON (
    sca.studentcontactassocid = ocm.studentcontactassocid
  )
UNION ALL
SELECT
  s.student_number,
  s.family_ident,
  p.id AS personid,
  0 AS contactpriorityorder,
  'self' AS person_type,
  p.firstname,
  p.lastname,
  0 AS isemergency,
  0 AS iscustodial,
  0 AS liveswithflg,
  0 AS schoolpickupflg,
  'Self' AS relationship_type
FROM
  powerschool.students AS s
  INNER JOIN powerschool.person AS p ON (
    s.person_id = p.id
    AND p.isactive = 1
  )
