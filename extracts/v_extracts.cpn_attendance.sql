USE gabby
GO

CREATE OR ALTER VIEW extracts.cpn_attendance AS 

SELECT ada.academic_year AS [School Year]
      ,ada.student_number AS [Student Id]
      ,ada.calendardate AS [Attendance Date]
      ,ada.att_code AS [Attendance Code]
      ,NULL AS [Attendance Code Description]
      ,ada.grade_level AS [Grade Level]
      ,ada.schoolid AS [School Code]
      ,ada.membershipvalue
      ,ada.is_present AS attendancevalue
FROM gabby.tableau.attendance_dashboard_current_static ada