CREATE OR ALTER VIEW powerschool.district_entry_date AS

WITH district_entry AS (
  SELECT studentid
        ,entrycode
        ,exitcode
        ,entrydate
        ,exitdate
        ,LAG(exitcode, 1) OVER(PARTITION BY student_number ORDER BY entrydate ASC) AS exitcode_prev
  FROM powerschool.cohort_static
  WHERE schoolid <> 999999
 )

SELECT de.studentid
      ,de.entrydate
      ,de.exitdate
      ,de.exitcode_prev
      ,de.entrycode
      ,ROW_NUMBER() OVER(PARTITION BY de.studentid ORDER BY de.entrydate DESC) AS rn_entry

      ,MIN(ada.calendardate) AS district_entry_date
FROM district_entry de
INNER JOIN powerschool.ps_adaadm_daily_ctod ada
  ON de.studentid = ada.studentid
 AND ada.calendardate BETWEEN de.entrydate AND de.exitdate
 AND ada.membershipvalue = 1
 AND ada.attendancevalue = 1
WHERE de.exitcode_prev IS NULL OR de.exitcode_prev NOT IN ('T1', 'T2')
GROUP BY de.studentid
        ,de.entrycode
        ,de.exitcode
        ,de.exitcode_prev
        ,de.entrydate
        ,de.exitdate
