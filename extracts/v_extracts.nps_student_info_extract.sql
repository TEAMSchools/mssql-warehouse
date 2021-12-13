SELECT co.student_number
      ,co.state_studentnumber
      ,CASE WHEN co.grade_level = 0 THEN 'K' ELSE CONVERT(VARCHAR, co.grade_level) END AS grade_level
      ,CONVERT(VARCHAR, co.entrydate) AS entrydate
	  ,co.entrycode
	  ,co.exitcode
	  ,co.exitdate
      ,CONVERT(VARCHAR, co.dob) AS dob
      ,co.gender
	  ,scw.contact_1_phone_primary  AS home_phone --confirm with pedro
      ,scw.contact_1_phone_primary  AS mother_cell
      ,scw.contact_2_phone_primary AS father_cell
      ,scw.contact_1_name AS mother
      ,scw.contact_2_name AS father
      ,COALESCE(scw.contact_1_email_current, scw.contact_2_email_current) AS guardianemail
      ,co.street
	  ,co.city
	  ,co.[state]
	  ,co.zip
      ,co.first_name
      ,co.last_name
      ,co.iep_status
      ,co.lep_status
      ,co.c_504_status
	  ,co.ethnicity --need fed ethnicity
	  ,co.students_dcid
	  ,s.fedethnicity

FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.u_studentsuserfields suf
  ON co.students_dcid = suf.studentsdcid
 AND co.[db_name] = suf.[db_name]
LEFT JOIN gabby.powerschool.studentcorefields scf
  ON co.students_dcid = scf.studentsdcid
 AND co.[db_name] = scf.[db_name]
LEFT JOIN gabby.powerschool.student_contacts_wide_static scw
  ON co.student_number = scw.student_number
 AND co.[db_name] = scw.[db_name]
LEFT JOIN gabby.powerschool.students s
  ON co.[db_name] = s.[db_name]
 AND co.student_number = s.student_number
WHERE co.enroll_status IN (0, -1)
  AND co.rn_all = 1
  AND co.[db_name] = 'kippnewark'