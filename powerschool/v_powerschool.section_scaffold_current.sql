CREATE OR ALTER VIEW powerschool.section_scaffold_current AS 

SELECT studentid
      ,course_number
      ,yearid
      ,abs_sectionid
      ,gradescaleid
      ,term_name
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, yearid, course_number, term_name
           ORDER BY is_dropped, dateleft DESC, sectionid DESC) AS rn_term
FROM
    (
     SELECT CONVERT(INT, cc.studentid) AS studentid
           ,CONVERT(VARCHAR(25), cc.course_number) AS course_number
           ,CONVERT(INT, cc.sectionid) AS sectionid
           ,cc.dateleft
           ,CONVERT(INT, LEFT(ABS(cc.termid), 2)) AS yearid
           ,cc.abs_sectionid
           ,CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END AS is_dropped

           ,CONVERT(INT, sec.gradescaleid) AS gradescaleid

           ,CASE
             WHEN terms.alt_name = 'Summer School' THEN 'Q1'
             ELSE CONVERT(VARCHAR, terms.alt_name) COLLATE Latin1_General_BIN
            END AS term_name
     FROM powerschool.cc
     JOIN powerschool.sections sec
       ON cc.abs_sectionid = sec.id
     JOIN gabby.reporting.reporting_terms terms
       ON cc.schoolid = terms.schoolid
      AND terms.identifier = 'RT'
      AND cc.dateenrolled BETWEEN terms.[start_date] AND terms.end_date
     WHERE cc.dateenrolled BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND CONVERT(DATE, GETDATE())
    ) sub
