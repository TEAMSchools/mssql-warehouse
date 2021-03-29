CREATE OR ALTER VIEW powerschool.ps_enrollment_all AS 

SELECT CONVERT(INT, s.id) AS studentid
      ,CONVERT(INT, s.schoolid) AS schoolid
      ,s.entrydate
      ,CONVERT(VARCHAR(5), s.entrycode) AS entrycode
      ,s.exitdate
      ,CONVERT(VARCHAR(5), s.exitcode) AS exitcode
      ,CONVERT(INT, s.grade_level) AS grade_level
      ,-1 AS programid
      ,CONVERT(INT, s.fteid) AS fteid
      ,CONVERT(INT, s.membershipshare) AS membershipshare
      ,CONVERT(VARCHAR(1), s.track) AS track
      ,CONVERT(VARCHAR(25), ISNULL(f.dflt_att_mode_code, '-1')) AS dflt_att_mode_code
      ,CONVERT(VARCHAR(25), ISNULL(f.dflt_conversion_mode_code, '-1')) AS dflt_conversion_mode_code

      ,CONVERT(INT, t.yearid) AS yearid
      ,CASE WHEN p1.[value] LIKE 'P' THEN 'Present' ELSE 'Absent' END AS att_calccntpresentabsent
      ,CONVERT(VARCHAR(1), p2.[value]) AS att_intervalduration
FROM powerschool.students s 
LEFT JOIN powerschool.fte f 
  ON s.fteid = f.id 
LEFT JOIN powerschool.terms t 
  ON s.schoolid = t.schoolid
 AND s.entrydate BETWEEN t.firstday AND t.lastday
 AND t.isyearrec = 1 
LEFT JOIN powerschool.prefs p1
  ON p1.schoolid = s.schoolid
 AND p1.yearid = t.yearid
 AND p1.[name] = 'ATT_CalcCntPresentsAbsences'
LEFT JOIN powerschool.prefs p2
  ON p2.schoolid = s.schoolid
 AND p2.yearid = t.yearid
 AND p2.[name] = 'ATT_IntervalDuration'
WHERE s.entrydate IS NOT NULL

UNION 

SELECT CONVERT(INT, r.studentid) AS studentid
      ,CONVERT(INT, r.schoolid) AS schoolid
      ,r.entrydate
      ,CONVERT(VARCHAR(5), r.entrycode) AS entrycode
      ,r.exitdate
      ,CONVERT(VARCHAR(5), r.exitcode) AS exitcode
      ,CONVERT(INT, r.grade_level) AS grade_level
      ,-1 AS programid
      ,CONVERT(INT, r.fteid) AS fteid
      ,CONVERT(INT, r.membershipshare) AS membershipshare
      ,CONVERT(VARCHAR(1), r.track) AS track
      ,CONVERT(VARCHAR(25), ISNULL(f.dflt_att_mode_code, '-1')) AS dflt_att_mode_code
      ,CONVERT(VARCHAR(25), ISNULL(f.dflt_conversion_mode_code, '-1')) AS dflt_conversion_mode_code

      ,CONVERT(INT, t.yearid) AS yearid
      ,CASE WHEN p1.[value] LIKE 'P' THEN 'Present' ELSE 'Absent' END AS att_calccntpresentabsent
      ,CONVERT(VARCHAR(1), p2.[value]) AS att_intervalduration
FROM powerschool.reenrollments r 
LEFT JOIN powerschool.fte  f
  ON r.fteid = f.id
LEFT JOIN powerschool.terms t 
  ON r.schoolid = t.schoolid
 AND r.entrydate BETWEEN t.firstday AND t.lastday
 AND t.isyearrec = 1 
LEFT JOIN powerschool.prefs p1
  ON p1.schoolid = r.schoolid
 AND p1.yearid = t.yearid
 AND p1.[name] = 'ATT_CalcCntPresentsAbsences'
LEFT JOIN powerschool.prefs p2
  ON p2.schoolid = r.schoolid
 AND p2.yearid = t.yearid
 AND p2.[name] = 'ATT_IntervalDuration'
WHERE r.entrydate IS NOT NULL
