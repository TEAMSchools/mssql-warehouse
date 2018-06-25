USE gabby
GO

CREATE OR ALTER VIEW powerschool.attendance_clean_current AS

SELECT CONVERT(INT,att.id) AS id
      ,CONVERT(INT,att.studentid) AS studentid
      ,CONVERT(INT,att.schoolid) AS schoolid
      ,att.att_date
      ,CONVERT(INT,att.attendance_codeid) AS attendance_codeid
      ,CONVERT(VARCHAR(25),att.att_mode_code) AS att_mode_code
      ,CONVERT(INT,att.calendar_dayid) AS calendar_dayid
      ,CONVERT(INT,att.att_interval) AS att_interval
      ,CONVERT(INT,att.ccid) AS ccid
      ,CONVERT(INT,att.periodid) AS periodid
      ,CONVERT(INT,att.programid) AS programid
      ,CONVERT(INT,att.total_minutes) AS total_minutes            
      ,CONVERT(VARCHAR(1000),att.att_comment) AS att_comment
FROM gabby.powerschool.attendance att
WHERE att.att_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7 , 1)