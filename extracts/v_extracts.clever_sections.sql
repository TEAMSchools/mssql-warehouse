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
  WHERE df.[status] != 'TERMINATED'
    AND df.primary_job IN ('Director of Campus Operations', 'Director Campus Operations', 'Director School Operations')
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
                    ORDER BY sub.is_lead_teacher DESC, sub.Teacher_id)
               ,'_id') AS pivot_field
  FROM
      (
       SELECT sec.schoolid AS [School_id]
             ,CONCAT(CASE 
                      WHEN sec.[db_name] = 'kippnewark' THEN 'NWK'
                      WHEN sec.[db_name] = 'kippcamden' THEN 'CMD'
                      WHEN sec.[db_name] = 'kippmiami' THEN 'MIA'
                     END
                    ,sec.id) AS [Section_id]
             ,NULL AS [Name]
             ,sec.section_number AS [Section_number]
             ,NULL AS [Grade]
             ,c.course_name AS [Course_name]
             ,sec.course_number_clean AS [Course_number]
             ,NULL AS [Course_description]
             ,sec.expression AS [Period]
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
             ,CONVERT(VARCHAR(25), terms.firstday, 101) AS [Term_start]
             ,CONVERT(VARCHAR(25), terms.lastday, 101) AS [Term_end]

             ,t.teachernumber AS [Teacher_id]
             ,CASE WHEN sec.teacher = st.teacherid THEN 1 END  AS is_lead_teacher
       FROM gabby.powerschool.sections sec
       JOIN gabby.powerschool.sectionteacher st
         ON sec.id = st.sectionid
        AND sec.[db_name] = st.[db_name]
        AND CONVERT(DATE, GETDATE()) BETWEEN st.[start_date] AND st.end_date
       JOIN gabby.powerschool.teachers_static t
         ON st.teacherid = t.id
        AND sec.schoolid = t.schoolid
        AND sec.[db_name] = t.[db_name]
       JOIN gabby.powerschool.courses c
         ON sec.course_number_clean = c.course_number_clean
        AND sec.[db_name] = c.[db_name]
       JOIN gabby.powerschool.terms
         ON sec.termid = terms.id
        AND sec.schoolid = terms.schoolid
        AND sec.[db_name] = terms.[db_name]
       WHERE sec.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)

       UNION ALL

       SELECT DISTINCT 
              co.schoolid AS [School_id]
             ,CONCAT(co.yearid, co.schoolid, RIGHT(CONCAT(0, co.grade_level),2)) AS [Section_id]
             ,NULL AS [Name]
             ,CONCAT(co.academic_year, s.abbreviation, co.grade_level) AS [Section_number]
             ,CASE WHEN co.grade_level = 0 THEN 'Kindergarten' ELSE CONVERT(VARCHAR(5), co.grade_level) END AS [Grade]
             ,'Enroll' AS [Course_name]
             ,'ENR' AS [Course_number]
             ,NULL AS [Course_description]
             ,CASE
               WHEN co.grade_level = 0 THEN '0(A)'
               WHEN co.grade_level = 1 THEN '1(A)'
               WHEN co.grade_level = 2 THEN '2(A)'
               WHEN co.grade_level = 3 THEN '3(A)'
               WHEN co.grade_level = 4 THEN '4(A)'
               WHEN co.grade_level = 5 THEN '5(A)'
               WHEN co.grade_level = 6 THEN '6(A)'
               WHEN co.grade_level = 7 THEN '7(A)'
               WHEN co.grade_level = 8 THEN '8(A)'
               WHEN co.grade_level = 9 THEN '9(A)'
               WHEN co.grade_level = 10 THEN '10(A)'
               WHEN co.grade_level = 11 THEN '11(A)'
               WHEN co.grade_level = 12 THEN '12(A)'
              END AS [Period]
             ,'Homeroom/advisory' AS [Subject]
             ,CONCAT(RIGHT(co.academic_year, 2), '-', RIGHT(co.academic_year + 1, 2))  [Term_name]
             ,CONVERT(VARCHAR(25), DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1), 101) AS [Term_start]
             ,CONVERT(VARCHAR(25), DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 6, 30), 101) AS [Term_end]

             ,dsos.[Teacher_id]
             ,1 AS is_lead_teacher
       FROM gabby.powerschool.cohort_identifiers_static co
       JOIN gabby.powerschool.schools s
         ON co.schoolid = s.school_number
        AND co.[db_name] = s.[db_name]
       JOIN dsos
         ON s.school_number = dsos.School_id
       WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
         AND co.rn_year = 1
         AND co.grade_level != 99

       UNION ALL

       /* demo sections */
       SELECT sec.schoolid AS [School_id]
             ,CONCAT(CASE 
                      WHEN sec.[db_name] = 'kippnewark' THEN 'NWK'
                      WHEN sec.[db_name] = 'kippcamden' THEN 'CMD'
                      WHEN sec.[db_name] = 'kippmiami' THEN 'MIA'
                     END
                    ,sec.id) AS [Section_id]
             ,NULL AS [Name]
             ,sec.section_number AS [Section_number]
             ,NULL AS [Grade]
             ,c.course_name AS [Course_name]
             ,sec.course_number_clean AS [Course_number]
             ,NULL AS [Course_description]
             ,sec.expression AS [Period]
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
             ,CONVERT(VARCHAR(25), terms.firstday, 101) AS [Term_start]
             ,CONVERT(VARCHAR(25), terms.lastday, 101) AS [Term_end]

             ,CONCAT('ADMIN', t.teachernumber) AS [Teacher_id]
             ,0 AS is_lead_teacher
       FROM gabby.powerschool.sections sec
       JOIN gabby.powerschool.teachers_static t
         ON sec.teacher = t.id
        AND sec.schoolid = t.schoolid
        AND sec.[db_name] = t.[db_name]
        AND t.teachernumber IN ('JX5DVZDW1', '50013')
       JOIN gabby.powerschool.courses c
         ON sec.course_number_clean = c.course_number_clean
        AND sec.[db_name] = c.[db_name]
       JOIN gabby.powerschool.terms
         ON sec.termid = terms.id
        AND sec.schoolid = terms.schoolid
        AND sec.[db_name] = terms.[db_name]
       WHERE sec.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)
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