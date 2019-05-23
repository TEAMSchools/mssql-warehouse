CREATE OR ALTER VIEW powerschool.attendance_streak AS

WITH valid_dates AS (
  SELECT schoolid
        ,academic_year
        ,date_value        
        ,CONVERT(INT,ROW_NUMBER() OVER(
           PARTITION BY schoolid, academic_year
             ORDER BY date_value ASC)) AS day_number
  FROM
      (
       SELECT CONVERT(INT,schoolid) AS schoolid
             ,date_value
             ,gabby.utilities.DATE_TO_SY(date_value) AS academic_year
       FROM powerschool.calendar_day
       WHERE insession = 1
         AND membershipvalue = 1
         AND date_value >= DATEFROMPARTS((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1), 7, 1)
      ) sub
 )

SELECT student_number
      ,academic_year      
      ,att_code
      ,streak_id
      ,MIN(date_value) AS streak_start
      ,MAX(date_value) AS streak_end
      ,DATEDIFF(DAY, MIN(date_value), MAX(date_value)) + 1 AS streak_length
      ,COUNT(date_value) AS streak_length_membership      
FROM
    (
     SELECT student_number
           ,academic_year
           ,date_value
           ,day_number
           ,att_code
           ,streak_rn
           ,CONCAT(student_number, '_', academic_year, '_', att_code, (day_number - streak_rn)) AS streak_id
     FROM
         (
          SELECT co.student_number
                ,co.academic_year

                ,d.date_value
                ,d.day_number

                ,ISNULL(att.att_code, 'P') AS att_code

                ,CONVERT(INT,ROW_NUMBER() OVER(
                   PARTITION BY co.academic_year, co.student_number, att.att_code 
                     ORDER BY d.date_value)) AS streak_rn
          FROM powerschool.cohort_identifiers_static co
          JOIN valid_dates d
            ON co.schoolid = d.schoolid
           AND co.academic_year = d.academic_year
          LEFT JOIN powerschool.ps_attendance_daily att 
            ON co.studentid = att.studentid
           AND d.date_value = att.att_date     
          WHERE co.rn_year = 1
            AND co.academic_year IN (gabby.utilities.GLOBAL_ACADEMIC_YEAR(), (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1))
         ) sub
    ) sub
GROUP BY academic_year
        ,student_number        
        ,att_code
        ,streak_id