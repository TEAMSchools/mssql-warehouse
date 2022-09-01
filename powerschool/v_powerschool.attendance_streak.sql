CREATE OR ALTER VIEW powerschool.attendance_streak AS

WITH streaks AS (
  SELECT sub.studentid
        ,sub.yearid
        ,sub.calendardate
        ,sub.attendancevalue
        ,sub.att_code
        ,sub.day_number
        ,sub.streak_rn
        ,CONCAT(sub.studentid, '_'
               ,sub.yearid, '_'
               ,sub.att_code, '_'
               ,(sub.day_number - sub.streak_rn)) AS streak_id
        ,CONCAT(sub.studentid, '_'
               ,sub.yearid, '_'
               ,sub.attendancevalue, '_'
               ,(sub.day_number - sub.streak_att_rn)) AS streak_att_id
  FROM
      (
       SELECT mem.studentid
             ,mem.yearid
             ,mem.calendardate
             ,mem.attendancevalue

             ,ISNULL(att.att_code, 'P') AS att_code

             ,CAST(ROW_NUMBER( AS INT) OVER(
                PARTITION BY mem.studentid, mem.yearid
                  ORDER BY mem.calendardate ASC)) AS day_number

             ,CAST(ROW_NUMBER( AS INT) OVER(
                PARTITION BY mem.studentid, mem.yearid, att.att_code
                  ORDER BY mem.calendardate)) AS streak_rn
             ,CAST(ROW_NUMBER( AS INT) OVER(
                PARTITION BY mem.studentid, mem.yearid, mem.attendancevalue
                  ORDER BY mem.calendardate)) AS streak_att_rn
       FROM powerschool.ps_adaadm_daily_ctod mem
       LEFT JOIN powerschool.ps_attendance_daily att
         ON mem.studentid = att.studentid
        AND mem.calendardate = att.att_date
       WHERE mem.membershipvalue = 1
      ) sub
 )

SELECT sub.studentid
      ,sub.yearid
      ,sub.att_code
      ,sub.streak_id
      ,MIN(sub.calendardate) AS streak_start
      ,MAX(sub.calendardate) AS streak_end
      ,DATEDIFF(DAY, MIN(sub.calendardate), MAX(sub.calendardate)) + 1 AS streak_length_calendar
      ,COUNT(sub.calendardate) AS streak_length_membership
FROM streaks sub
GROUP BY sub.studentid
        ,sub.yearid
        ,sub.att_code
        ,sub.streak_id

UNION ALL

SELECT sub.studentid
      ,sub.yearid
      ,CAST(sub.attendancevalue AS VARCHAR) AS att_code
      ,sub.streak_att_id AS streak_id
      ,MIN(sub.calendardate) AS streak_start
      ,MAX(sub.calendardate) AS streak_end
      ,DATEDIFF(DAY, MIN(sub.calendardate), MAX(sub.calendardate)) + 1 AS streak_length_calendar
      ,COUNT(sub.calendardate) AS streak_length_membership
FROM streaks sub
GROUP BY sub.studentid
        ,sub.yearid
        ,sub.attendancevalue
        ,sub.streak_att_id