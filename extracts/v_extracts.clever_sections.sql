USE gabby
GO

CREATE OR ALTER VIEW extracts.clever_sections AS

WITH dsos AS (
  SELECT df.ps_teachernumber COLLATE Latin1_General_BIN AS [Teacher_id]
        ,COALESCE(ccw.ps_school_id, df.primary_site_schoolid) AS [School_id]
  FROM gabby.people.staff_crosswalk_static df
  LEFT JOIN gabby.people.campus_crosswalk ccw
    ON df.primary_site = ccw.campus_name
   AND ccw._fivetran_deleted = 0
   AND ccw.is_pathways = 0
  WHERE df.[status] <> 'TERMINATED'
    AND df.primary_job IN ('Director of Campus Operations', 'Director Campus Operations', 'Director School Operations', 'School Leader')
 )

,teachers_long AS (
  SELECT sub.School_id
        ,sub.Section_id
        ,sub.[Name]
        ,sub.Section_number
        ,sub.Grade
        ,sub.Course_name
        ,sub.Course_number
        ,sub.Course_description
        ,sub.[Period]
        ,sub.[Subject]
        ,sub.Term_name
        ,sub.Term_start
        ,sub.Term_end
        ,sub.Teacher_id
      
        ,CONCAT('Teacher_'
               ,ROW_NUMBER() OVER(
                  PARTITION BY sub.Section_id
                    ORDER BY sub.sortorder ASC)
               ,'_id') AS pivot_field
  FROM
      (
       SELECT sec.schoolid AS [School_id]
             ,sec.section_number AS [Section_number]
             ,sec.course_number AS [Course_number]
             ,sec.section_number AS [Period]
             ,CONCAT(CASE 
                      WHEN sec.[db_name] = 'kippnewark' THEN 'NWK'
                      WHEN sec.[db_name] = 'kippcamden' THEN 'CMD'
                      WHEN sec.[db_name] = 'kippmiami' THEN 'MIA'
                     END
                    ,sec.id) AS [Section_id]

             ,r.sortorder

             ,t.teachernumber AS [Teacher_id]

             ,c.course_name AS [Course_name]
             ,CASE
               WHEN c.credittype = 'ART' THEN 'Arts and music'
               WHEN c.credittype = 'CAREER' THEN 'other'
               WHEN c.credittype = 'COCUR' THEN 'other'
               WHEN c.credittype = 'ELEC' THEN 'other'
               WHEN c.credittype = 'ENG' THEN 'English/language arts'
               WHEN c.credittype = 'LOG' THEN 'other'
               WHEN c.credittype = 'MATH' THEN 'Math'
               WHEN c.credittype = 'NULL' THEN 'Homeroom/advisory'
               WHEN c.credittype = 'PHYSED' THEN 'PE and health'
               WHEN c.credittype = 'RHET' THEN 'English/language arts'
               WHEN c.credittype = 'SCI' THEN 'Science'
               WHEN c.credittype = 'SOC' THEN 'Social studies'
               WHEN c.credittype = 'STUDY' THEN 'other'
               WHEN c.credittype = 'WLANG' THEN 'Language'
              END AS [Subject]

             ,terms.abbreviation [Term_name]
             ,CAST(terms.firstday, 101 AS VARCHAR(25)) AS [Term_start]
             ,CAST(terms.lastday, 101 AS VARCHAR(25)) AS [Term_end]

             ,NULL AS [Name]
             ,NULL AS [Grade]
             ,NULL AS [Course_description]
       FROM gabby.powerschool.sections sec
       JOIN gabby.powerschool.sectionteacher st
         ON sec.id = st.sectionid
        AND sec.[db_name] = st.[db_name]
       JOIN gabby.powerschool.roledef r
         ON st.roleid = r.id
        AND st.[db_name] = r.[db_name]
       JOIN gabby.powerschool.teachers_static t
         ON st.teacherid = t.id
        AND sec.schoolid = t.schoolid
        AND sec.[db_name] = t.[db_name]
       JOIN gabby.powerschool.courses c
         ON sec.course_number = c.course_number
        AND sec.[db_name] = c.[db_name]
       JOIN gabby.powerschool.terms
         ON sec.termid = terms.id
        AND sec.schoolid = terms.schoolid
        AND sec.[db_name] = terms.[db_name]
        AND CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN terms.firstday AND terms.lastday
       WHERE sec.no_of_students > 0

       UNION ALL

       SELECT dsos.School_id
             ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                    ,s.abbreviation
                    ,r.n) AS [Section_number]
             ,'ENR' AS [Course_number]
             ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                    ,s.abbreviation
                    ,r.n) AS [Period]
             ,CONCAT(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990
                    ,dsos.School_id
                    ,RIGHT(CONCAT(0, r.n), 2)) AS [Section_id]

             ,1 AS sortorder

             ,dsos.[Teacher_id]

             ,'Enroll' AS [Course_name]
             ,'Homeroom/advisory' AS [Subject]

             ,CONCAT(RIGHT(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 2), '-'
                    ,RIGHT(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 2))  [Term_name]
             ,CAST(DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1), 101 AS VARCHAR(25)) AS [Term_start]
             ,CAST(DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 6, 30), 101 AS VARCHAR(25)) AS [Term_end]

             ,NULL AS [Name]
             ,CASE WHEN r.n = 0 THEN 'Kindergarten' ELSE CAST(r.n AS VARCHAR(5)) END AS [Grade]
             ,NULL AS [Course_description]
       FROM dsos
       JOIN gabby.powerschool.schools s
         ON dsos.School_id = s.school_number
       JOIN gabby.utilities.row_generator_smallint r
         ON r.n BETWEEN s.low_grade AND s.high_grade
      ) sub
 )

SELECT p.School_id
      ,p.Section_id
      ,p.Teacher_1_id AS Teacher_id
      ,p.Teacher_2_id
      ,p.Teacher_3_id
      ,p.Teacher_4_id
      ,p.Teacher_5_id
      ,p.Teacher_6_id
      ,p.Teacher_7_id
      ,p.Teacher_8_id
      ,p.Teacher_9_id
      ,p.Teacher_10_id
      ,p.[Name]
      ,p.Section_number
      ,p.Grade
      ,p.Course_name
      ,p.Course_number
      ,p.Course_description
      ,p.[Period]
      ,p.[Subject]
      ,p.Term_name
      ,p.Term_start
      ,p.Term_end
FROM teachers_long
PIVOT(
  MAX([Teacher_id])
  FOR pivot_field IN ([Teacher_1_id]
                     ,[Teacher_2_id]
                     ,[Teacher_3_id]
                     ,[Teacher_4_id]
                     ,[Teacher_5_id]
                     ,[Teacher_6_id]
                     ,[Teacher_7_id]
                     ,[Teacher_8_id]
                     ,[Teacher_9_id]
                     ,[Teacher_10_id])
 ) p
