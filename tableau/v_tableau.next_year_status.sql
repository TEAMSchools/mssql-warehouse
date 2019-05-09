USE gabby;
GO

CREATE OR ALTER VIEW tableau.next_year_status AS

SELECT s.student_number
      ,s.state_studentnumber
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level
      ,s.enroll_status
      ,s.gender
      ,s.dob
      ,s.home_phone
      ,s.guardianemail
      ,s.next_school
      ,s.sched_nextyeargrade
      ,CONCAT(s.street, ', ', s.city, ', ', s.state, ' ', s.zip) AS student_address
      ,REPLACE(CONCAT(s.street, '+', s.city, '+', s.state, '+', s.zip), ' ', '+') AS gmaps_address
      ,CASE WHEN s.home_phone IS NOT NULL THEN REPLACE(CONCAT('+1', s.home_phone), '-', '') END AS tel_home_phone

      ,co.academic_year
      ,co.region
      ,co.school_name
      ,co.iep_status
      ,co.cohort
      ,co.is_retained_ever
      ,co.is_retained_year
      ,co.year_in_school
      ,co.mother_cell
      ,co.father_cell
      ,co.boy_status
      ,CASE WHEN co.mother_cell IS NOT NULL THEN REPLACE(CONCAT('+1', co.mother_cell), '-', '') END AS tel_mother_cell
      ,CASE WHEN co.father_cell IS NOT NULL THEN REPLACE(CONCAT('+1', co.father_cell), '-', '') END AS tel_father_cell
FROM gabby.powerschool.students s
LEFT JOIN gabby.powerschool.cohort_identifiers_static co
  ON s.student_number = co.student_number
 AND s.db_name = co.db_name 
 AND co.rn_all = 1
WHERE s.enroll_status IN (0, -1)
  AND s.grade_level <> 99;