CREATE OR ALTER VIEW powerschool.contacts AS 

SELECT s.student_number
      ,s.family_ident

      ,sca.personid
      ,sca.contactpriorityorder

      ,COALESCE(ocm.originalcontacttype, CONCAT('contact', sca.contactpriorityorder)) AS person_type

      ,p.firstname
      ,p.lastname

      ,scd.isemergency
      ,scd.iscustodial
      ,scd.liveswithflg
      ,scd.schoolpickupflg

      ,sccs.code AS relationship_type
FROM powerschool.students s
JOIN powerschool.studentcontactassoc sca
  ON s.dcid = sca.studentdcid
LEFT JOIN powerschool.originalcontactmap ocm
  ON sca.studentcontactassocid = ocm.studentcontactassocid
JOIN powerschool.person p
  ON sca.personid = p.id
JOIN powerschool.studentcontactdetail scd
  ON sca.studentcontactassocid = scd.studentcontactassocid
 AND scd.isactive = 1
JOIN powerschool.codeset sccs
  ON scd.relationshiptypecodesetid = sccs.codesetid

UNION ALL

SELECT s.student_number
      ,s.family_ident

      ,p.id AS personid
      ,0 AS contactpriorityorder

      ,'self' AS person_type

      ,p.firstname
      ,p.lastname

      ,0 AS isemergency
      ,0 AS iscustodial
      ,0 AS liveswithflg
      ,0 AS schoolpickupflg

      ,'Self' AS relationship_type
FROM powerschool.students s
JOIN powerschool.person p
  ON s.person_id = p.id
 AND p.isactive = 1
