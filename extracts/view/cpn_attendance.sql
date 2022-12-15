USE gabby GO
CREATE OR ALTER VIEW
  extracts.cpn_attendance AS
SELECT
  ADA.academic_year AS [School Year],
  ADA.student_number AS [Student Id],
  ADA.calendardate AS [Attendance Date],
  ADA.att_code AS [Attendance Code],
  ADA.grade_level AS [Grade Level],
  ADA.schoolid AS [School Code],
  ADA.membershipvalue,
  ADA.is_present AS attendancevalue
FROM
  kippcamden.tableau.attendance_dashboard AS ADA
WHERE
  ADA.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
