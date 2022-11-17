CREATE OR ALTER VIEW powerschool.calendar_rollup AS

WITH cal_long AS (
  SELECT u.schoolid
        ,u.date_value
        ,u.yearid
        ,CAST(UPPER(u.field) AS NVARCHAR(1)) AS track
        ,u.[value]
  FROM
      (
       SELECT cd.schoolid
             ,cd.date_value
             ,cd.a
             ,cd.b
             ,cd.c
             ,cd.d
             ,cd.e
             ,cd.f

             ,t.yearid
       FROM powerschool.calendar_day cd
       INNER JOIN powerschool.schools s
         ON cd.schoolid = s.school_number
       INNER JOIN powerschool.cycle_day cy
         ON cd.cycle_day_id = cy.id
       INNER JOIN powerschool.terms t
         ON cd.schoolid = t.schoolid
        AND cd.date_value BETWEEN t.firstday AND t.lastday
        AND t.isyearrec = 1
       INNER JOIN powerschool.bell_schedule bs
         ON t.schoolid = bs.schoolid
        AND t.yearid = bs.year_id
        AND cd.bell_schedule_id = bs.id
       WHERE cd.insession = 1
         AND cd.membershipvalue > 0
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
      ,SUM(CASE WHEN cl.date_value > CURRENT_TIMESTAMP THEN 1 ELSE 0 END) AS days_remaining
FROM cal_long cl
WHERE cl.[value] = 1
GROUP BY cl.schoolid
        ,cl.yearid
        ,cl.track
