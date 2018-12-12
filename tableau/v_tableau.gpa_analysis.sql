SELECT co.db_name
	  ,co.lastfirst
	  ,co.team
	  ,co.gender
	  ,co.ethnicity
	  ,co.lunchstatus
	  ,co.cohort
	  ,co.year_in_network


	  ,co.iep_status
	  ,co.lep_status
	  ,co.c_504_status
	  ,co.is_pathways

	  ,co.region
	  ,co.school_level
	  ,co.school_name

	  ,co.boy_status
	  ,co.is_retained_year
	  ,co.is_retained_ever

	  ,gpad.*

	  ,gpac.*

FROM powerschool.cohort_identifiers_static co
LEFT JOIN powerschool.gpa_detail gpad
  ON co.student_number = gpad.student_number
 AND co.academic_year = gpad.academic_year
 AND co.schoolid = gpad.schoolid
 AND gpad.grade_level = co.grade_level
 AND co.db_name = gpad.db_name

LEFT JOIN powerschool.gpa_cumulative gpac
  ON gpac.studentid = co.studentid
 AND gpac.studentid = co.studentid
 AND gpac.db_name = co.db_name

WHERE co.grade_level >= 5
  AND co.rn_year = 1