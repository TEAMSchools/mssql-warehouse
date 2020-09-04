USE gabby
GO

CREATE OR ALTER VIEW extracts.cpn_attendance AS 

SELECT ada.academic_year AS [School Year]
      ,ada.student_number AS [Student Id]
      ,ada.calendardate AS [Attendance Date]
      ,ada.att_code AS [Attendance Code]
      ,ada.grade_level AS [Grade Level]
      ,ada.schoolid AS [School Code]
      ,ada.membershipvalue
      ,ada.is_present AS attendancevalue
FROM kippcamden.tableau.attendance_dashboard ada
WHERE ada.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
