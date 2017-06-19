USE gabby
GO

ALTER VIEW powerschool.ps_enrollment_all AS 

SELECT s.id AS studentid
      ,s.schoolid 
      ,s.entrydate
      ,s.entrycode 
      ,s.exitdate
      ,s.exitcode 
      ,s.grade_level 
      ,-1 AS programid
      ,s.fteid 
      ,s.membershipshare
      ,s.track
      ,ISNULL(f.dflt_att_mode_code, '-1') AS dflt_att_mode_code
      ,ISNULL(f.dflt_conversion_mode_code, '-1') AS dflt_conversion_mode_code
        
      ,t.yearid        
      ,CASE WHEN p1.value LIKE 'P' then 'Present' ELSE 'Absent' END AS att_calccntpresentabsent
      ,p2.value AS att_intervalduration
FROM gabby.powerschool.students s 
LEFT OUTER JOIN gabby.powerschool.fte f 
  ON s.fteid = f.id 
LEFT OUTER JOIN gabby.powerschool.terms t 
  ON s.schoolid = t.schoolid
 AND s.entrydate BETWEEN t.firstday AND t.lastday
 AND t.isyearrec = 1 
LEFT OUTER JOIN gabby.powerschool.prefs p1
  ON p1.schoolid = s.schoolid 
 AND p1.name = 'ATT_CalcCntPresentsAbsences' 
 AND p1.yearid = t.yearid
LEFT OUTER JOIN gabby.powerschool.prefs p2
  ON p2.schoolid = s.schoolid 
 AND p2.name = 'ATT_IntervalDuration' 
 AND p2.yearid = t.yearid

UNION 

SELECT r.studentid
      ,r.schoolid 
      ,r.entrydate
      ,r.entrycode 
      ,r.exitdate
      ,r.exitcode 
      ,r.grade_level 
      ,-1 AS programid
      ,r.fteid 
      ,r.membershipshare
      ,r.track 
      ,ISNULL(f.dflt_att_mode_code, '-1') AS dflt_att_mode_code
      ,ISNULL(f.dflt_conversion_mode_code, '-1') AS dflt_conversion_mode_code

      ,t.yearid        
      ,CASE WHEN p1.value LIKE 'P' then 'Present' ELSE 'Absent' END AS att_calccntpresentabsent
      ,p2.value AS att_intervalduration
FROM gabby.powerschool.reenrollments r 
LEFT OUTER JOIN gabby.powerschool.fte  f
  ON r.fteid = f.id
LEFT OUTER JOIN gabby.powerschool.terms t 
  ON r.schoolid = t.schoolid
 AND r.entrydate BETWEEN t.firstday AND t.lastday
 AND t.isyearrec = 1 
LEFT OUTER JOIN gabby.powerschool.prefs p1
  ON p1.schoolid = r.schoolid 
 AND p1.name = 'ATT_CalcCntPresentsAbsences' 
 AND p1.yearid = t.yearid
LEFT OUTER JOIN gabby.powerschool.prefs p2
  ON p2.schoolid = r.schoolid 
 AND p2.name = 'ATT_IntervalDuration' 
 AND p2.yearid = t.yearid