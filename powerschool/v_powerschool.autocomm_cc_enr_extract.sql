USE gabby
GO

ALTER VIEW powerschool.autocomm_cc_enr_extract AS

SELECT co.schoolid
	     ,co.student_number
	     ,CONCAT(co.yearid, '00') AS termid
	     ,'ENR' AS course_number
      ,CONCAT(LEFT(LOWER(REPLACE(co.school_name,' ','')), 8), co.grade_level) AS section_number
	     ,co.entrydate AS dateenrolled
	     ,co.exitdate AS dateleft
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.enroll_status = 0
  AND co.entrydate >= DATEADD(DAY, -1, entrydate)