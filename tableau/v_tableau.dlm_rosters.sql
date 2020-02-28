USE gabby
GO

CREATE OR ALTER VIEW tableau.dlm_rosters AS

SELECT co.region
      ,co.schoolid
      ,co.grade_level

      ,CONCAT(co.school_name,' ',LEFT(ce.teacher_name,CHARINDEX(',',ce.teacher_name)-1),' ELA') AS 'Roster Name'
      ,'ELA' AS 'Subject'
      ,'' AS Course
      ,807325965 AS 'School Identifier'
      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1 AS 'School Year'
      ,co.state_studentnumber AS 'State Student Identifier'
      ,co.student_number AS 'Local Student Identifier'
      ,co.first_name AS 'Student Legal First Name'
      ,co.last_name AS 'Student Legal Last Name'
      ,ce.teachernumber AS 'Educator Identifier'
      ,RIGHT(ce.teacher_name,LEN(ce.teacher_name) - CHARINDEX(',',ce.teacher_name) - 1) AS 'Educator First Name'
      ,LEFT(ce.teacher_name,CHARINDEX(',',ce.teacher_name)-1) AS 'Educator Last Name'
      ,'' AS 'Remove from Roster'

FROM powerschool.cohort_identifiers_static co
LEFT JOIN powerschool.students s
  ON s.student_number = co.student_number
LEFT JOIN powerschool.course_enrollments_static ce
  ON ce.student_number = co.student_number
 AND ce.academic_year = co.academic_year
LEFT JOIN powerschool.s_nj_stu_x nj
  ON nj.studentsdcid = s.dcid
 AND nj.db_name = s.db_name

WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND ce.section_enroll_status = 0
  AND ce.credittype = 'ENG' 
  AND s.grade_level IN (3,4,5,6,7,8,11)
  AND nj.state_assessment_name IN (3,4)

UNION ALL

SELECT co.region
      ,co.schoolid
      ,co.grade_level

      ,CONCAT(co.school_name,' ',LEFT(ce.teacher_name,CHARINDEX(',',ce.teacher_name)-1),' Math') AS 'Roster Name'
      ,'M' AS 'Subject'
      ,'' AS Course
      ,807325965 AS 'School Identifier'
      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1 AS 'School Year'
      ,co.state_studentnumber AS 'State Student Identifier'
      ,co.student_number AS 'Local Student Identifier'
      ,co.first_name AS 'Student Legal First Name'
      ,co.last_name AS 'Student Legal Last Name'
      ,ce.teachernumber AS 'Educator Identifier'
      ,RIGHT(ce.teacher_name,LEN(ce.teacher_name) - CHARINDEX(',',ce.teacher_name) - 1) AS 'Educator First Name'
      ,LEFT(ce.teacher_name,CHARINDEX(',',ce.teacher_name)-1) AS 'Educator Last Name'
      ,'' AS 'Remove from Roster'

FROM powerschool.cohort_identifiers_static co
LEFT JOIN powerschool.students s
  ON s.student_number = co.student_number
LEFT JOIN powerschool.course_enrollments_static ce
  ON ce.student_number = co.student_number
 AND ce.academic_year = co.academic_year
LEFT JOIN powerschool.s_nj_stu_x nj
  ON nj.studentsdcid = s.dcid
 AND nj.db_name = s.db_name

WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND ce.section_enroll_status = 0
  AND ce.credittype = 'MATH'
  AND s.grade_level IN (3,4,5,6,7,8,11)
  AND nj.math_state_assessment_name = 3