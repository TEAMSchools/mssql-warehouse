USE gabby
GO

CREATE OR ALTER VIEW extracts.pikmykid_absenteelist AS

SELECT CONVERT(VARCHAR,s.student_number) AS [SIS_StudentID]
      ,COALESCE(LEFT(ac.presence_status_cd, 1), 'P') AS [Attendance]
FROM gabby.powerschool.students s WITH(NOLOCK)
LEFT JOIN gabby.powerschool.attendance a WITH(NOLOCK)
  ON s.id = a.studentid
 AND s.db_name = s.db_name 
 AND a.att_mode_code = 'ATT_ModeDaily'
 AND a.att_date = CONVERT(DATE,GETDATE())
LEFT JOIN gabby.powerschool.attendance_code ac WITH(NOLOCK)
  ON a.attendance_codeid = ac.id
 AND ac.db_name = a.db_name
WHERE s.enroll_status = 0