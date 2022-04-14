USE gabby
GO

CREATE OR ALTER VIEW tableau.hs_community_service AS

SELECT co.student_number
	  ,co.lastfirst
	  ,co.gender
	  ,co.ethnicity
	  ,co.iep_status
	  ,co.lep_status
	  ,co.c_504_status
	  ,co.enroll_status
      ,sch.[name] AS school_name
	  ,co.grade_level
	  ,co.advisor_name
      ,b.behavior_date
	  ,CONCAT(b.staff_last_name, ', ', b.staff_first_name) AS staff_name
	  ,b.behavior
	  ,b.notes
	  ,CAST(LEFT(b.behavior, LEN(b.behavior) - 5) AS INTEGER) AS cs_hours

FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.deanslist.behavior b
  ON co.student_number = b.student_school_id
 AND b.behavior_category = 'Community Service'
LEFT JOIN gabby.powerschool.schools sch
  ON co.schoolid = sch.school_number
 AND co.[db_name] = sch.[db_name]
	
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.grade_level >= 9
