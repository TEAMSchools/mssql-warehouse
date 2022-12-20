CREATE OR ALTER VIEW
  extracts.cpn_attendance AS
SELECT
  academic_year AS [School Year],
  student_number AS [Student Id],
  calendardate AS [Attendance Date],
  att_code AS [Attendance Code],
  grade_level AS [Grade Level],
  schoolid AS [School Code],
  membershipvalue,
  is_present AS attendancevalue
FROM
  kippcamden.tableau.attendance_dashboard
WHERE
  academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
