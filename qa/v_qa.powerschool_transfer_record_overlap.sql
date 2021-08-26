USE gabby
GO

CREATE OR ALTER VIEW qa.powerschool_transfer_record_overlap AS

SELECT [db_name]
      ,student_number
      ,academic_year
      ,schoolid
      ,grade_level
      ,entrydate
      ,exitdate_prev
FROM
    (
     SELECT [db_name]
           ,student_number
           ,academic_year
           ,schoolid
           ,grade_level
           ,entrydate
           ,exitdate
           ,LAG(exitdate) OVER(PARTITION BY student_number, academic_year ORDER BY exitdate) AS exitdate_prev
     FROM gabby.powerschool.cohort_identifiers_static
    ) sub
WHERE entrydate = exitdate_prev
