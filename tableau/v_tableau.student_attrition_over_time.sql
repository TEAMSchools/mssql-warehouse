USE gabby
GO

ALTER VIEW tableau.student_attrition_over_time AS

WITH enrolled_oct1 AS (
  SELECT student_number
        ,lastfirst
        ,academic_year
        ,reporting_schoolid
        ,grade_level
        ,entrydate
        ,exitdate
        ,exitcode
        ,exitcomment
        ,enroll_status
  FROM gabby.powerschool.cohort_identifiers_static
  WHERE DATEFROMPARTS(academic_year, 10, 01) BETWEEN entrydate AND exitdate
 )

,attrition_dates AS (
  SELECT date
        ,CASE 
          WHEN DATEPART(MONTH,date) >= 10 THEN DATEPART(YEAR,date)
          ELSE DATEPART(YEAR,date) - 1
         END AS attrition_year
  FROM gabby.utilities.reporting_days
 )

SELECT y1.student_number
      ,y1.lastfirst
      ,y1.academic_year AS year
      ,y1.reporting_schoolid
      ,y1.grade_level
      ,y1.entrydate
      ,y1.exitdate
      ,y1.exitcode
      ,y1.exitcomment
      ,y1.enroll_status

      ,y2.entrydate AS next_entrydate
      ,y2.exitdate AS next_exitdate
      ,COALESCE(y2.exitdate, y1.exitdate) AS transferdate
      ,d.date
      ,CASE
        WHEN y1.exitcode = 'G1' THEN 0 /* graduates != attrition */
        WHEN y1.exitdate <= d.date AND y2.entrydate IS NULL THEN 1 /* was not enrolled on 10/1 next year */
        ELSE 0
       END AS is_attrition
      ,NULL AS is_graduation
FROM enrolled_oct1 y1
LEFT OUTER JOIN gabby.powerschool.cohort_identifiers_static y2
  ON y1.STUDENT_NUMBER = y2.STUDENT_NUMBER
 AND y1.academic_year = (y2.academic_year - 1)
 AND DATEFROMPARTS(y2.academic_year, 10, 01) BETWEEN y2.entrydate AND y2.exitdate
JOIN attrition_dates d
  ON y1.academic_year = d.attrition_year
 AND d.date <= CONVERT(DATE,GETDATE())