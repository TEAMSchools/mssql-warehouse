USE gabby
GO

CREATE OR ALTER VIEW powerschool.student_access_accounts AS 

WITH clean_names AS (
  SELECT sub.student_number
        ,sub.schoolid
        ,sub.school_name
        ,sub.grade_level
        ,sub.enroll_status
        ,LEFT(LOWER(sub.first_name), 1) AS first_init
        ,CONVERT(VARCHAR, DATEPART(MONTH, sub.dob)) AS dob_month
        ,RIGHT(DATEPART(DAY, sub.dob), 2) AS dob_day
        ,RIGHT(DATEPART(YEAR, sub.dob), 2) AS dob_year
        ,gabby.utilities.STRIP_CHARACTERS(LOWER(sub.first_name), '^A-Z') AS first_name_clean
        ,gabby.utilities.STRIP_CHARACTERS(LOWER(
           CASE
            WHEN sub.last_name LIKE 'St %' OR sub.last_name LIKE 'St. %' THEN sub.last_name
            WHEN sub.last_name LIKE '% II%' THEN LEFT(sub.last_name,CHARINDEX(' I',sub.last_name) - 1)
            WHEN CHARINDEX('-',sub.last_name) + CHARINDEX(' ',sub.last_name) = 0 THEN REPLACE(sub.last_name, ' JR', '')
            WHEN CHARINDEX(' ',sub.last_name) > 0 AND CHARINDEX('-',sub.last_name) > 0 AND CHARINDEX(' ',sub.last_name) < CHARINDEX('-',sub.last_name) THEN LEFT(sub.last_name,CHARINDEX(' ',sub.last_name) - 1)
            WHEN CHARINDEX('-',sub.last_name) > 0 AND CHARINDEX(' ',sub.last_name) > 0 AND CHARINDEX('-',sub.last_name) < CHARINDEX(' ',sub.last_name) THEN LEFT(sub.last_name,CHARINDEX('-',sub.last_name) - 1)
            WHEN sub.last_name NOT LIKE 'De %' AND CHARINDEX(' ',sub.last_name) > 0 THEN LEFT(sub.last_name,CHARINDEX(' ',sub.last_name) - 1)
            WHEN CHARINDEX('-',sub.last_name) > 0 THEN LEFT(sub.last_name,CHARINDEX('-',sub.last_name) - 1)
            ELSE REPLACE(sub.last_name, ' JR', '')
           END), '^A-Z') AS last_name_clean
  FROM
      (
       SELECT CONVERT(INT, s.student_number) AS student_number
             ,CONVERT(INT, s.schoolid) AS schoolid
             ,CONVERT(INT, s.grade_level) AS grade_level
             ,CONVERT(INT, s.enroll_status) AS enroll_status
             ,CONVERT(VARCHAR(125), s.first_name) COLLATE SQL_Latin1_General_CP1253_CI_AI AS first_name
             ,CONVERT(VARCHAR(125), s.last_name) COLLATE SQL_Latin1_General_CP1253_CI_AI AS last_name
             ,CONVERT(VARCHAR, s.dob) COLLATE SQL_Latin1_General_CP1253_CI_AI AS dob

             ,CONVERT(VARCHAR(25), sch.abbreviation) AS school_name
       FROM gabby.powerschool.students s
       JOIN gabby.powerschool.schools sch
         ON s.schoolid = sch.school_number
        AND s.[db_name] = sch.[db_name]
       WHERE s.enroll_status <> -1
         AND s.dob IS NOT NULL
      ) sub
 )

,base_username AS (
  SELECT sub.student_number
        ,sub.schoolid
        ,sub.school_name
        ,sub.grade_level
        ,sub.enroll_status
        ,sub.first_name_clean
        ,sub.first_init
        ,sub.last_name_clean
        ,sub.dob_month
        ,sub.dob_day
        ,sub.dob_year
        ,sub.base_username
        ,sub.alt_username
        ,CASE 
          WHEN sa.student_web_id IS NOT NULL THEN 1 
          WHEN ROW_NUMBER() OVER(PARTITION BY sub.base_username ORDER BY sub.student_number) > 1 THEN 1
          ELSE 0
         END AS base_dupe_audit
  FROM
      (
       SELECT student_number
             ,schoolid
             ,school_name
             ,grade_level
             ,enroll_status
             ,first_name_clean
             ,first_init
             ,last_name_clean
             ,dob_month
             ,dob_day
             ,dob_year
             ,last_name_clean + dob_month + dob_day AS base_username
             ,first_name_clean + dob_month + dob_day AS alt_username
       FROM clean_names
      ) sub
  LEFT JOIN gabby.powerschool.student_access_accounts_static sa
    ON sub.base_username = sa.student_web_id
   AND sub.student_number <> sa.student_number
 )

,alt_username AS (
  SELECT sub.student_number
        ,sub.schoolid
        ,sub.school_name
        ,sub.grade_level
        ,sub.enroll_status
        ,sub.first_name_clean
        ,sub.first_init
        ,sub.last_name_clean
        ,sub.dob_month
        ,sub.dob_day
        ,sub.dob_year
        ,sub.base_username
        ,sub.alt_username
        ,sub.base_dupe_audit
        ,sub.uses_alt
        ,CASE
          WHEN sub.uses_alt = 0 THEN 0
          WHEN sa.student_web_id IS NOT NULL THEN 1
          WHEN ROW_NUMBER() OVER(PARTITION BY sub.alt_username ORDER BY sub.student_number) > 1 THEN 1
          ELSE 0
         END AS alt_dupe_audit
  FROM
      (
       SELECT bu.student_number
             ,bu.schoolid
             ,bu.school_name
             ,bu.grade_level
             ,bu.enroll_status
             ,bu.first_name_clean
             ,bu.first_init
             ,bu.last_name_clean
             ,bu.dob_month
             ,bu.dob_day
             ,bu.dob_year
             ,bu.base_username
             ,bu.alt_username
             ,bu.base_dupe_audit
             ,CASE
               WHEN bu.base_dupe_audit = 1 THEN 1
               WHEN LEN(bu.base_username) > 16 THEN 1
               ELSE 0
              END AS uses_alt
       FROM base_username bu
       ) sub
  LEFT JOIN gabby.powerschool.student_access_accounts_static sa
    ON sub.alt_username = sa.student_web_id
   AND sub.student_number <> sa.student_number
 )

SELECT au.student_number
      ,au.schoolid
      ,au.enroll_status
      ,au.base_username
      ,au.alt_username
      ,au.uses_alt
      ,au.base_dupe_audit
      ,au.alt_dupe_audit
      ,au.first_init
      ,au.last_name_clean
      ,CONVERT(VARCHAR(125),
         CASE
          WHEN au.alt_dupe_audit = 1 THEN au.first_init + au.last_name_clean + au.dob_month + au.dob_day
          WHEN au.uses_alt = 1 THEN au.alt_username
          ELSE au.base_username
         END) AS student_web_id
      ,CONVERT(VARCHAR(125),
         CASE
          WHEN spo.student_number IS NOT NULL THEN spo.default_password COLLATE Latin1_General_BIN
          ELSE last_name_clean + dob_year
         END) AS student_web_password
FROM alt_username au
LEFT JOIN gabby.people.student_password_override spo
  ON au.student_number = spo.student_number
