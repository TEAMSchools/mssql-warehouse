USE gabby
GO

CREATE OR ALTER VIEW tableau.next_year_status AS

SELECT co.student_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.academic_year
      ,co.region
      ,co.schoolid
      ,co.school_name 
      ,co.grade_level
      ,co.iep_status
      ,co.cohort
      ,co.is_retained_ever
	  ,co.is_retained_year
	  ,co.year_in_school
      ,co.enroll_status
	  ,co.gender
	  ,co.dob
	  ,co.home_phone
	  ,co.mother_cell
	  ,co.father_cell
	  ,co.guardianemail
	  ,CONCAT(co.street,', ',co.city,', ',co.state,' ',co.zip) AS student_address


      ,s.next_school
      ,s.sched_nextyeargrade



FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.students s
  ON co.student_number = s.student_number
 AND co.db_name = s.db_name
WHERE co.academic_year = 2018
  AND co.rn_year = 1
  AND co.enroll_status IN (0,-1)
  AND co.grade_level <> 99