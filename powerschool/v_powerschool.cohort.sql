USE gabby
GO

CREATE OR ALTER VIEW powerschool.cohort AS

SELECT studentid
      ,schoolid
      ,grade_level
      ,entrydate
      ,exitdate
      ,entrycode
      ,exitcode
      ,exitcomment
      ,lunchstatus
      ,fteid
      ,yearid
      ,academic_year      
      ,rn_year
      ,rn_school
      ,rn_undergrad
      ,rn_all
      ,CASE
        WHEN rn_year > 1 THEN NULL
        ELSE ROW_NUMBER() OVER(
               PARTITION BY sub.studentid, sub.schoolid, sub.rn_year
                 ORDER BY sub.yearid ASC, sub.exitdate ASC) 
       END AS year_in_school
      ,CASE
        WHEN rn_year > 1 THEN NULL
        ELSE ROW_NUMBER() OVER(
               PARTITION BY sub.studentid, sub.rn_year
                 ORDER BY sub.yearid ASC, sub.exitdate ASC) 
       END AS year_in_network
      ,MIN(prev_grade_level) OVER(PARTITION BY studentid, yearid ORDER BY yearid ASC) AS prev_grade_level
      ,CASE
        WHEN grade_level != 99 
         AND sub.grade_level <= MIN(prev_grade_level) OVER(PARTITION BY studentid, yearid ORDER BY yearid ASC) 
             THEN 1
        ELSE 0
       END AS is_retained_year
FROM
    (
     SELECT sub.studentid      
           ,sub.schoolid      
           ,sub.grade_level      
           ,sub.entrydate
           ,sub.exitdate
           ,sub.entrycode
           ,sub.exitcode      
           ,sub.exitcomment
           ,sub.lunchstatus
           ,sub.fteid      
           ,sub.yearid
           ,(sub.yearid + 1990) AS academic_year            
           ,LAG(grade_level, 1) OVER(PARTITION BY sub.studentid ORDER BY sub.yearid ASC) AS prev_grade_level

           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, sub.yearid
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, sub.schoolid
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_school
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, CASE WHEN sub.grade_level = 99 THEN 1 ELSE 0 END
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_undergrad
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_all
     FROM
         (
          /* terminal (current & transfers) */
          SELECT CONVERT(INT,s.id) AS studentid
                ,CONVERT(INT,s.grade_level) AS grade_level
                ,CONVERT(INT,s.schoolid) AS schoolid
                ,s.entrydate
                ,s.exitdate
                ,CONVERT(VARCHAR,s.entrycode) AS entrycode
                ,CONVERT(VARCHAR,s.exitcode) AS exitcode
                ,CONVERT(VARCHAR(250),s.exitcomment) AS exitcomment
                ,CONVERT(VARCHAR,CASE WHEN s.lunchstatus = 'false' THEN 'F' ELSE s.lunchstatus END) AS lunchstatus
                ,CONVERT(INT,s.fteid) AS fteid
                
                ,CONVERT(INT,terms.yearid) AS yearid
          FROM gabby.powerschool.students s
          JOIN gabby.powerschool.terms terms
            ON s.schoolid = terms.schoolid 
           AND s.entrydate BETWEEN terms.firstday AND terms.lastday
           AND terms.portion = 1
          WHERE s.enroll_status IN (0, 2)            
            AND s.exitdate > s.entrydate
     
          UNION ALL

          /* terminal (grads) */
          SELECT CONVERT(INT,s.id) AS studentid
                ,CONVERT(INT,s.grade_level) AS grade_level
                ,CONVERT(INT,s.schoolid) AS schoolid        
                ,NULL AS entrydate
                ,NULL AS exitdate        
                ,NULL AS entrycode
                ,NULL AS exitcode
                ,NULL AS exitcomment
                ,NULL AS lunchstatus
                ,NULL AS fteid
                
                ,CONVERT(INT,terms.yearid) AS yearid
          FROM gabby.powerschool.students s
          JOIN gabby.powerschool.terms terms
            ON s.schoolid = terms.schoolid
           AND s.entrydate <= terms.firstday
           AND terms.portion = 1
          WHERE s.enroll_status = 3

          UNION ALL

          /* re-enrollments */
          SELECT CONVERT(INT,re.studentid) AS studentid
                ,CONVERT(INT,re.grade_level) AS grade_level
                ,CONVERT(INT,re.schoolid) AS schoolid
                ,re.entrydate
                ,re.exitdate
                ,CONVERT(VARCHAR,re.entrycode) AS entrycode
                ,CONVERT(VARCHAR,re.exitcode) AS exitcode
                ,CONVERT(VARCHAR(250),re.exitcomment) AS exitcomment
                ,CONVERT(VARCHAR,CASE WHEN re.lunchstatus = 'false' THEN 'F' ELSE re.lunchstatus END) AS lunchstatus
                ,CONVERT(INT,re.fteid) AS fteid
                
                ,CONVERT(INT,terms.yearid) AS yearid
          FROM gabby.powerschool.reenrollments re       
          JOIN gabby.powerschool.terms terms
            ON re.schoolid = terms.schoolid       
           AND re.entrydate BETWEEN terms.firstday AND terms.lastday
           AND terms.portion = 1     
          WHERE re.schoolid != 12345 /* filter out summer school */
            AND re.exitdate > re.entrydate            
         ) sub
    ) sub