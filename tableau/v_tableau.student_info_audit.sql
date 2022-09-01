USE gabby
GO

CREATE OR ALTER VIEW tableau.student_info_audit AS 

WITH race AS (
  SELECT sr.studentid
        ,sr.[db_name]
        ,gabby.dbo.GROUP_CONCAT(racecd) AS racecds
  FROM gabby.powerschool.studentrace sr
  GROUP BY sr.studentid, sr.[db_name]
 )

SELECT [db_name]
      ,schoolid
      ,school_name
      ,student_number
      ,region
      ,lastfirst
      ,grade_level
      ,team
      ,'Name Spelling' AS element
      ,lastfirst AS detail
      ,CASE 
        WHEN lastfirst LIKE '%;%' THEN 1
        WHEN lastfirst LIKE '%  %' THEN 1
        WHEN lastfirst LIKE '%/%' THEN 1
        WHEN lastfirst LIKE '%\%' THEN 1
        WHEN lastfirst LIKE '%.%' THEN 1
        WHEN lastfirst LIKE '%`%' THEN 1
        ELSE 0 
       END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND schoolid <> 999999
  AND rn_year = 1

UNION ALL

SELECT [db_name]
      ,schoolid
      ,school_name
      ,student_number
      ,region
      ,lastfirst
      ,grade_level
      ,team
      ,'Missing Ethnicity' AS element
      ,ethnicity AS detail
      ,CASE WHEN ethnicity IS NULL THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND schoolid <> 999999
  AND rn_year = 1

UNION ALL

SELECT [db_name]
      ,schoolid
      ,school_name
      ,student_number
      ,region
      ,lastfirst
      ,grade_level
      ,team
      ,'Missing Gender' AS element
      ,gender AS detail
      ,CASE WHEN gender IS NULL THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND schoolid <> 999999
  AND rn_year = 1

UNION ALL

SELECT co.[db_name]
      ,co.schoolid
      ,co.school_name
      ,co.student_number
      ,co.region
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,'Missing SID' AS element
      ,CAST(co.state_studentnumber AS VARCHAR) AS detail
      ,CASE WHEN co.state_studentnumber IS NULL THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.schoolid <> 999999
  AND rn_year = 1

UNION ALL

SELECT co.[db_name]
      ,co.schoolid
      ,co.school_name
      ,co.student_number
      ,co.region
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,'Missing or Incorrect FTEID' AS element
      ,CASE 
        WHEN co.fteid <> fte.id THEN CONCAT(co.fteid, ' <> ', fte.id)
        WHEN co.fteid IS NULL THEN 'FTE IS NULL'
        WHEN co.fteid = 0 THEN 'FTE = 0'
       END AS detail
      ,CASE 
        WHEN co.fteid <> fte.id THEN 1
        WHEN co.fteid IS NULL THEN 1
        WHEN co.fteid = 0 THEN 1
        ELSE 0
       END AS flag
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.fte
  ON co.schoolid = fte.schoolid
 AND co.yearid = fte.yearid
 AND co.[db_name] = fte.[db_name]
 AND fte.[name] LIKE 'Full Time Student%'
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.schoolid <> 999999
  AND co.rn_year = 1

UNION ALL


SELECT co.[db_name]
      ,co.schoolid
      ,co.school_name
      ,co.student_number
      ,co.region
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,'Missing DOB' AS element
      ,CAST(co.dob AS VARCHAR) AS detail
      ,CASE 
        WHEN co.dob IS NULL THEN 1
        ELSE 0
       END AS flag
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.schoolid <> 999999
  AND co.rn_year = 1

UNION ALL

SELECT co.[db_name]
      ,co.schoolid
      ,co.school_name
      ,co.student_number 
      ,co.region
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,'Missing Race/Ethnicity' AS element
      ,CASE 
        WHEN co.region = 'KMS' THEN co.ethnicity
        WHEN co.region <> 'KMS' THEN r.racecds 
        ELSE NULL
       END AS detail
      ,CASE 
        WHEN co.region = 'KMS' AND co.ethnicity IS NULL THEN 1
        WHEN co.region = 'KMS' AND co.ethnicity = '' THEN 1
        WHEN co.region <> 'KMS' AND r.racecds IS NULL AND s.fedethnicity IS NULL THEN 1 
        ELSE 0
       END AS flag
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.students s
  ON co.student_number = s.student_number
LEFT JOIN race r 
  ON co.studentid = r.studentid
 AND co.[db_name] = r.[db_name]
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.schoolid <> 999999
  AND co.rn_year = 1

UNION ALL

SELECT [db_name]
      ,schoolid
      ,school_name
      ,student_number
      ,region
      ,lastfirst
      ,grade_level
      ,team
      ,'Enrollment Dupes' AS element
      ,CONCAT(course_number, ' - ', section_number, ' - ', dateenrolled, '-', dateleft) AS detail
      ,CASE
        WHEN next_enrollment_date BETWEEN dateenrolled AND DATEADD(DAY, -1, dateleft) THEN 1
        ELSE 0
       END AS flag
FROM
    (
     SELECT ce.[db_name]
           ,ce.schoolid
           ,ce.student_number
           ,ce.course_number
           ,ce.course_name
           ,ce.section_number
           ,ce.dateenrolled
           ,ce.dateleft
           ,LEAD(ce.dateenrolled) OVER(PARTITION BY ce.student_number, ce.course_number ORDER BY ce.dateenrolled) AS next_enrollment_date
           ,co.school_name
           ,co.region
           ,co.lastfirst
           ,co.team
           ,co.grade_level
           ,'Enrollment Dupes' AS element
     FROM gabby.powerschool.course_enrollments_current_static ce
     JOIN gabby.powerschool.cohort_identifiers_static co
       ON ce.student_number = co.student_number
      AND ce.academic_year = co.academic_year
      AND co.rn_year = 1
     WHERE ce.section_enroll_status = 0
       AND ce.course_enroll_status = 0
       AND ce.course_number NOT LIKE 'LOG%'
    ) sub

UNION ALL

SELECT [db_name]
      ,schoolid
      ,school_name
      ,student_number
      ,region
      ,lastfirst
      ,grade_level
      ,team
      ,'Under Enrolled' AS element
      ,CAST(total_sections AS VARCHAR) AS detail
      ,CASE WHEN total_sections < 3 THEN 1 ELSE 0 END AS flag
FROM
    (
     SELECT  co.[db_name]
            ,co.schoolid
            ,co.school_name
            ,co.student_number
            ,co.region
            ,co.lastfirst
            ,co.grade_level
            ,co.team
            ,COUNT(ce.sectionid) AS total_sections
     FROM gabby.powerschool.cohort_identifiers_static co
     LEFT JOIN gabby.powerschool.course_enrollments_current_static ce
       ON ce.student_number = co.student_number
      AND ce.[db_name] = co.[db_name]
      AND co.academic_year = ce.academic_year
      AND ce.course_enroll_status = 0
      AND ce.section_enroll_status = 0
     WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND co.rn_year = 1
       AND co.enroll_status = 0
       AND co.school_name <> 'Out of District'
     GROUP BY co.[db_name]
             ,co.schoolid
             ,co.school_name
             ,co.student_number
             ,co.region
             ,co.lastfirst
             ,co.grade_level
             ,co.team
    ) sub
