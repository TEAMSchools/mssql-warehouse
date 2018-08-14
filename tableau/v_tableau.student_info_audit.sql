USE gabby
GO

CREATE OR ALTER VIEW tableau.student_info_audit AS 

SELECT schoolid
      ,school_name
      ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Name Spelling' AS element
	     ,lastfirst AS detail
	     ,CASE 
        WHEN lastfirst LIKE '%;%' THEN 1
		      WHEN lastfirst LIKE '%  %' THEN 1
		      WHEN lastfirst LIKE '%/%' THEN 1
		      WHEN lastfirst LIKE '%\%' THEN 1
		      WHEN lastfirst LIKE '%.%' THEN 1
		      ELSE 0 
       END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1

UNION ALL

SELECT schoolid
      ,school_name
      ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Email' AS element
	     ,CASE WHEN guardianemail IS NULL THEN '[Missing]' ELSE guardianemail END AS detail
	     ,CASE 
        WHEN guardianemail LIKE '%;%' THEN 1
		      WHEN guardianemail LIKE '%:%' THEN 1
		      WHEN guardianemail LIKE '% %' THEN 1
		      WHEN guardianemail LIKE '%  %' THEN 1
		      WHEN guardianemail LIKE '%/%' THEN 1
		      WHEN guardianemail LIKE '%\%' THEN 1
		      WHEN guardianemail LIKE '%''%' THEN 1
		      WHEN guardianemail LIKE '%@ %' THEN 1
		      WHEN guardianemail IS NULL THEN 1
		      ELSE 0 
       END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1

UNION ALL
	        
SELECT schoolid
      ,school_name
      ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Phone - Mother Cell' AS element
	     ,mother_cell AS detail
	     ,CASE WHEN mother_cell NOT LIKE '%-%-%' THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1
      
UNION ALL
      
SELECT schoolid
      ,school_name
      ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Phone - Father Cell' AS element
	     ,FATHER_CELL AS detail
	     ,CASE WHEN father_cell NOT LIKE '%-%-%' THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1

UNION ALL

SELECT schoolid
      ,school_name
      ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Phone - Home' AS element
	     ,FATHER_CELL AS detail
	     ,CASE WHEN home_phone NOT LIKE '%-%-%' THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1

UNION ALL

SELECT schoolid
      ,school_name
      ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Missing Ethnicity' AS element
	     ,ethnicity AS detail
	     ,CASE WHEN ethnicity IS NULL THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1

UNION ALL

SELECT schoolid
	     ,school_name
	     ,student_number
	     ,lastfirst
	     ,grade_level
	     ,'Missing Gender' AS element
	     ,gender AS detail
	     ,CASE WHEN gender IS NULL THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static
WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND schoolid != 999999
  AND rn_year = 1

UNION ALL

SELECT co.schoolid
	     ,co.school_name
	     ,co.student_number
	     ,co.lastfirst
	     ,co.grade_level
	     ,'Missing SID' AS element
	     ,CONVERT(VARCHAR,co.state_studentnumber) AS detail
	     ,CASE WHEN co.state_studentnumber IS NULL THEN 1 ELSE 0 END AS flag
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND co.schoolid != 999999
  AND rn_year = 1

UNION ALL

SELECT co.schoolid
	     ,co.school_name
	     ,co.student_number
	     ,co.lastfirst
	     ,co.grade_level
	     ,'Missing or Incorrect FTEID' AS element
	     ,CONVERT(VARCHAR,co.fteid) AS detail
	     ,CASE 
		      WHEN co.fteid != fte.id THEN 1
        WHEN co.fteid IS NULL THEN 1
		      WHEN co.fteid = 0 THEN 1
		      ELSE 0
	      END AS flag
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.fte
  ON co.schoolid = fte.schoolid
 AND co.yearid = fte.yearid
 AND co.db_name = fte.db_name
 AND fte.name = 'Full Time Students'
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
	 AND co.schoolid != 999999  