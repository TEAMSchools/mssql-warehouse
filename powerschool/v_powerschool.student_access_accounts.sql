USE gabby
GO

ALTER VIEW powerschool.student_access_accounts AS 

WITH clean_names AS (
  SELECT CONVERT(INT,s.student_number) AS student_number
        ,CONVERT(INT,s.schoolid) AS schoolid
        ,s.grade_level        
        ,s.first_name
        ,s.last_name
        ,s.enroll_status
        ,LEFT(LOWER(s.first_name),1) AS first_init           
        ,CONVERT(NVARCHAR,DATEPART(MONTH,s.dob)) AS dob_month
        ,CONVERT(NVARCHAR,RIGHT(DATEPART(DAY,s.dob),2)) AS dob_day
        ,CONVERT(NVARCHAR,RIGHT(DATEPART(YEAR,s.dob),2)) AS dob_year                

        ,sch.abbreviation AS school_name
        
        ,gabby.utilities.STRIP_CHARACTERS(LOWER(s.first_name), '^A-Z') AS first_name_clean
        ,gabby.utilities.STRIP_CHARACTERS(LOWER(
           CASE
            WHEN s.last_name LIKE 'St %' OR s.last_name LIKE 'St. %' THEN s.last_name
            WHEN s.last_name LIKE '% II%' THEN LEFT(s.last_name,CHARINDEX(' I',s.last_name) - 1)
            WHEN CHARINDEX('-',s.last_name) + CHARINDEX(' ',s.last_name) = 0 THEN REPLACE(s.last_name, ' JR', '')
            WHEN CHARINDEX(' ',s.last_name) > 0 AND CHARINDEX('-',s.last_name) > 0 AND CHARINDEX(' ',s.last_name) < CHARINDEX('-',s.last_name) THEN LEFT(s.last_name,CHARINDEX(' ',s.last_name) - 1)        
            WHEN CHARINDEX('-',s.last_name) > 0 AND CHARINDEX(' ',s.last_name) > 0 AND CHARINDEX('-',s.last_name) < CHARINDEX(' ',s.last_name) THEN LEFT(s.last_name,CHARINDEX('-',s.last_name) - 1)
            WHEN s.last_name NOT LIKE 'De %' AND CHARINDEX(' ',s.last_name) > 0 THEN LEFT(s.last_name,CHARINDEX(' ',s.last_name) - 1)        
            WHEN CHARINDEX('-',s.last_name) > 0 THEN LEFT(s.last_name,CHARINDEX('-',s.last_name) - 1)
            ELSE REPLACE(s.last_name, ' JR', '')
           END), '^A-Z') AS last_name_clean        
        ,LEFT(CASE 
               WHEN s.schoolid = 73253 THEN adv.advisory_name
               WHEN s.schoolid IN (179902, 133570965) THEN gabby.utilities.STRIP_CHARACTERS(s.team,'0-9')
               ELSE adv.advisory_name
              END, 10) AS team
  FROM gabby.powerschool.students s 
  JOIN gabby.powerschool.schools sch
    ON s.schoolid = sch.school_number  
  LEFT OUTER JOIN gabby.powerschool.advisory adv
    ON s.id = adv.studentid
   AND adv.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)
   AND adv.rn_year = 1
  WHERE s.enroll_status != -1
    AND s.dob IS NOT NULL
 )

SELECT student_number
      ,schoolid
      ,enroll_status
      ,team
      ,base_username
      ,alt_username
      
      ,CASE         
        WHEN alt_dupe_audit > 1 THEN first_init + last_name_clean + dob_month + dob_day        
        WHEN uses_alt = 1 THEN alt_username 
        ELSE base_username 
       END AS student_web_id      
      ,CASE
        WHEN student_number IN (11085, 10611) THEN first_name_clean + dob_month /* manual override of passwords */        
        WHEN student_number IN (15343, 18022, 16702) THEN first_name_clean + CONVERT(VARCHAR(20),student_number) /* manual override of passwords */		      
        WHEN grade_level >= 2 THEN last_name_clean + dob_year 
        ELSE LOWER(school_name) + '1'
       END AS student_web_password
      
      ,uses_alt
      ,base_dupe_audit
      ,alt_dupe_audit
FROM
    (
     SELECT student_number
           ,schoolid
           ,grade_level
           ,enroll_status
           ,school_name
           ,team
           ,first_name_clean
           ,first_init
           ,last_name_clean
           ,dob_month
           ,dob_day
           ,dob_year
           ,base_username
           ,alt_username
           ,base_dupe_audit
           
           ,CASE 
             WHEN base_dupe_audit > 1 THEN 1 
             WHEN LEN(base_username) > 16 THEN 1 
             ELSE 0 
            END AS uses_alt
           
           ,ROW_NUMBER() OVER(
             PARTITION BY CASE WHEN base_dupe_audit > 1 THEN alt_username ELSE base_username END
               ORDER BY student_number) AS alt_dupe_audit
     FROM
         (         
          SELECT student_number
                ,schoolid
                ,enroll_status
                ,grade_level
                ,team
                ,school_name
                ,first_name_clean
                ,first_init
                ,last_name_clean
                ,dob_month
                ,dob_day
                ,dob_year
                ,last_name_clean + dob_month + dob_day AS base_username
                ,first_name_clean + dob_month + dob_day AS alt_username
                ,ROW_NUMBER() OVER(
                   PARTITION BY last_name_clean + dob_month + dob_day
                     ORDER BY student_number) AS base_dupe_audit           
          FROM clean_names
         ) sub
    ) sub