USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_iready_lessons AS

WITH schoolids AS (
  SELECT DISTINCT u.dlschool_id, sc.ps_school_id
  FROM kippnewark.deanslist.users u -- update with gabby
  JOIN gabby.people.school_crosswalk sc
    ON u.school_name = sc.site_name COLLATE Latin1_General_BIN
 )

,terms AS (
  SELECT t.term_name
        ,DATEADD(YEAR, -1, CONVERT(DATE, JSON_VALUE(t.[start_date], '$.date'))) AS [start_date] -- temp fix until new year data
        ,DATEADD(YEAR, -1, CONVERT(DATE, JSON_VALUE(t.end_date, '$.date'))) AS end_date -- temp fix until new year data

        ,s.ps_school_id
  FROM kippnewark.deanslist.terms t -- update with gabby
  JOIN schoolids s
    ON t.school_id = s.dlschool_id
  WHERE t.term_type = 'Biweeks'
 )

SELECT pl.student_id
      ,pl.[subject]
      ,CAST(SUM(CASE WHEN pl.passed_or_not_passed = 'Passed' THEN 1 ELSE 0 END) AS FLOAT) AS lessons_passed
      ,CAST(COUNT(DISTINCT pl.lesson_id) AS FLOAT) AS total_lessons
      ,ROUND(
          CAST(SUM(CASE WHEN pl.passed_or_not_passed = 'Passed' THEN 1 ELSE 0 END) AS FLOAT)
          / CAST(COUNT(pl.lesson_id) AS FLOAT)
        , 2) * 100 AS pct_passed

     ,t.term_name
FROM gabby.iready.personalized_instruction_by_lesson pl
JOIN gabby.people.school_crosswalk sc
  ON pl.school = sc.site_name
JOIN terms t
  ON sc.ps_school_id = t.ps_school_id
 AND CONVERT(DATE, pl.completion_date) BETWEEN t.[start_date] AND t.end_date
GROUP BY pl.student_id
        ,pl.[subject]
        ,t.term_name
