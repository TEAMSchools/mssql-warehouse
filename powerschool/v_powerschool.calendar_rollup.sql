CREATE OR ALTER VIEW powerschool.calendar_rollup AS

WITH cal_long AS (
  SELECT u.schoolid
        ,u.date_value
        ,u.yearid
        ,CONVERT(VARCHAR(1), UPPER(u.field)) AS track
        ,u.[value]
  FROM
      (
       SELECT CONVERT(INT, cd.schoolid) AS schoolid
             ,cd.date_value
             ,cd.a
             ,cd.b
             ,cd.c
             ,cd.d
             ,cd.e
             ,cd.f

             ,CONVERT(INT, t.yearid) AS yearid
       FROM powerschool.calendar_day cd
       JOIN powerschool.schools s
         ON cd.schoolid = s.school_number
       JOIN powerschool.cycle_day cy
         ON cd.cycle_day_id = cy.id
       JOIN powerschool.terms t
         ON cd.schoolid = t.schoolid
        AND cd.date_value BETWEEN t.firstday AND t.lastday
        AND t.isyearrec = 1
       WHERE cd.insession = 1
         AND cd.membershipvalue > 0
         AND cd.bell_schedule_id IN (SELECT bs.id FROM powerschool.bell_schedule bs)
      ) sub
  UNPIVOT(
    [value]
    FOR field IN (sub.a, sub.b, sub.c, sub.d, sub.e, sub.f)
   ) u
 )

SELECT cl.schoolid
      ,cl.yearid
      ,cl.track
      ,MIN(cl.date_value) AS min_calendardate
      ,MAX(cl.date_value) AS max_calendardate
      ,COUNT(cl.date_value) AS days_total
      ,SUM(CASE WHEN cl.date_value > GETDATE() THEN 1 ELSE 0 END) AS days_remaining
FROM cal_long cl
WHERE cl.[value] = 1
GROUP BY cl.schoolid
        ,cl.yearid
        ,cl.track
