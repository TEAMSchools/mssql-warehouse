USE gabby
GO

CREATE OR ALTER VIEW powerschool.student_access_accounts AS 

WITH clean_names AS (
  SELECT student_number
        ,schoolid
        ,grade_level
        ,enroll_status
        ,first_init
        ,dob_month
        ,dob_day
        ,dob_year
        ,first_name_clean
        ,last_name_clean
        ,school_abbreviation
        ,CONCAT(last_name_clean, dob_month, dob_day) AS base_username
        ,CONCAT(first_name_clean, dob_month, dob_day) AS alt_username
  FROM
      (
       SELECT s.student_number
             ,s.schoolid
             ,s.grade_level
             ,s.enroll_status
             ,LEFT(LOWER(s.first_name), 1) AS first_init
             ,DATEPART(MONTH, s.dob) AS dob_month
             ,DATEPART(DAY, s.dob) AS dob_day
             ,RIGHT(DATEPART(YEAR, s.dob), 2) AS dob_year
             ,gabby.utilities.STRIP_CHARACTERS(LOWER(s.first_name), '^A-Z') AS first_name_clean
             ,gabby.utilities.STRIP_CHARACTERS(LOWER(
                CASE
                 WHEN s.last_name LIKE 'St[. ]%' THEN s.last_name
                 WHEN s.last_name LIKE '% II%' THEN LEFT(s.last_name, CHARINDEX(' I', s.last_name) - 1)
                 WHEN CHARINDEX('-', s.last_name) + CHARINDEX(' ', s.last_name) = 0 THEN REPLACE(s.last_name, ' JR', '')
                 WHEN CHARINDEX(' ', s.last_name) > 0 
                  AND CHARINDEX('-', s.last_name) > 0
                  AND CHARINDEX(' ', s.last_name) < CHARINDEX('-', s.last_name) 
                      THEN LEFT(s.last_name, CHARINDEX(' ', s.last_name) - 1)
                 WHEN CHARINDEX('-', s.last_name) > 0 
                  AND CHARINDEX(' ', s.last_name) > 0 
                  AND CHARINDEX('-', s.last_name) < CHARINDEX(' ', s.last_name)
                      THEN LEFT(s.last_name, CHARINDEX('-', s.last_name) - 1)
                 WHEN s.last_name NOT LIKE 'De %' 
                  AND CHARINDEX(' ', s.last_name) > 0 
                      THEN LEFT(s.last_name, CHARINDEX(' ', s.last_name) - 1)
                 WHEN CHARINDEX('-', s.last_name) > 0 THEN LEFT(s.last_name, CHARINDEX('-', s.last_name) - 1)
                 ELSE REPLACE(s.last_name, ' JR', '')
                END), '^A-Z') AS last_name_clean

             ,sch.abbreviation AS school_abbreviation
       FROM gabby.powerschool.students s
       INNER JOIN gabby.powerschool.schools sch
         ON s.schoolid = sch.school_number
        AND s.[db_name] = sch.[db_name]
       WHERE s.enroll_status = 0
         AND s.dob IS NOT NULL
      ) sub
 )

,base_username AS (
  SELECT cn.student_number
        ,cn.schoolid
        ,cn.school_abbreviation
        ,cn.grade_level
        ,cn.enroll_status
        ,cn.first_name_clean
        ,cn.first_init
        ,cn.last_name_clean
        ,cn.dob_month
        ,cn.dob_day
        ,cn.dob_year
        ,cn.base_username
        ,cn.alt_username
        ,CASE 
          WHEN sa.student_web_id IS NOT NULL THEN 1 
          WHEN ROW_NUMBER() OVER(
                 PARTITION BY cn.base_username 
                   ORDER BY cn.student_number) > 1 THEN 1
          ELSE 0
         END AS base_dupe_audit
  FROM clean_names cn
  LEFT JOIN gabby.powerschool.student_access_accounts_static sa
    ON cn.base_username = sa.student_web_id
   AND cn.student_number <> sa.student_number
 )

,alt_username AS (
  SELECT bu.student_number
        ,bu.schoolid
        ,bu.school_abbreviation
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
        ,CASE
          WHEN bu.base_dupe_audit = 1 THEN 1
          WHEN LEN(bu.base_username) > 16 THEN 1
          WHEN bu.base_dupe_audit <> 1 THEN 0
          WHEN LEN(bu.base_username) <= 16 THEN 0
          WHEN sa.student_web_id IS NOT NULL THEN 1
          WHEN ROW_NUMBER() OVER(
                 PARTITION BY bu.alt_username 
                   ORDER BY bu.student_number) > 1 THEN 1
          ELSE 0
         END AS alt_dupe_audit
  FROM base_username bu
  LEFT JOIN gabby.powerschool.student_access_accounts_static sa
    ON bu.alt_username = sa.student_web_id
   AND bu.student_number <> sa.student_number
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
      ,CASE
        WHEN au.alt_dupe_audit = 1 THEN CONCAT(au.first_init, au.last_name_clean, au.dob_month, au.dob_day)
        WHEN au.uses_alt = 1 THEN au.alt_username
        ELSE au.base_username
       END AS student_web_id
      ,CASE
        WHEN spo.default_password IS NOT NULL THEN spo.default_password
        WHEN au.grade_level <= 2
         AND LEN(CONCAT(last_name_clean, dob_year)) <= 7 
             THEN CONCAT(au.last_name_clean, au.dob_year, RIGHT(au.student_number, 4))
        ELSE CONCAT(au.last_name_clean, au.dob_year)
       END AS student_web_password
FROM alt_username au
LEFT JOIN gabby.people.student_password_override spo
  ON au.student_number = spo.student_number
