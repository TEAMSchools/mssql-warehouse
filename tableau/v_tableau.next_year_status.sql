USE gabby
GO

CREATE OR ALTER VIEW tableau.next_year_status AS

SELECT co.academic_year
      ,co.region
      ,co.schoolid
	  ,co.state_studentnumber
	  ,co.school_name 
      ,co.student_number
      ,co.lastfirst
	  ,co.grade_level
	  ,co.cohort
	  ,CASE
	     WHEN co.iep_status = 'SPED' THEN 'Yes'
		 ELSE NULL END AS sped_status
	  ,CASE
	     WHEN co.is_retained_ever = 1 THEN 'Yes'
		 ELSE 'No' END AS is_retained_ever
	  
	  ,s.next_school
	  ,s.sched_nextyeargrade
	  
	  ,co.enroll_status

	  ,CASE
	     WHEN co.grade_level = s.sched_nextyeargrade THEN 'Retained'		
		 WHEN co.grade_level < s.sched_nextyeargrade THEN 'Promoted'
		 WHEN co.grade_level > s.sched_nextyeargrade THEN 'Demoted'
		 ELSE NULL END AS promo_status

FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.students s
  ON s.student_number = co.student_number
 AND s.db_name = co.db_name

WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.schoolid <> 999999
  AND co.enroll_status IN (0,-1)
  AND co.rn_year = 1
	  