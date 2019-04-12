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
      ,co.enroll_status

      ,s.next_school
      ,s.sched_nextyeargrade

      ,CASE
        WHEN co.grade_level = s.sched_nextyeargrade THEN 'Retained'
        WHEN co.grade_level < s.sched_nextyeargrade THEN 'Promoted'
        WHEN co.grade_level > s.sched_nextyeargrade THEN 'Demoted'
       END AS promo_status
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.students s
  ON co.student_number = s.student_number
 AND co.db_name = s.db_name
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.enroll_status IN (0,-1)
  AND co.grade_level <> 99