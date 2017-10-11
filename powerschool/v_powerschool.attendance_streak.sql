USE gabby
GO

CREATE OR ALTER VIEW powerschool.attendance_streak AS

WITH valid_dates AS (
  SELECT schoolid
        ,date_value
        ,gabby.utilities.DATE_TO_SY(date_value) AS academic_year
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid, gabby.utilities.DATE_TO_SY(date_value)
             ORDER BY date_value ASC) AS day_number
  FROM gabby.powerschool.calendar_day
  WHERE date_value >= DATEFROMPARTS((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1), 7, 1)
    AND membershipvalue = 1
    AND insession = 1
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
     SELECT co.student_number           
           ,co.academic_year
           
           ,d.date_value
           ,d.day_number
           
           ,ISNULL(att.att_code, 'P') AS att_code           
           ,CONCAT(co.student_number, '_'
                  ,co.academic_year, '_'
                  ,ISNULL(att.att_code, 'P')
                  ,d.day_number - ROW_NUMBER() OVER(
                                    PARTITION BY co.academic_year, co.student_number, att.att_code 
                                      ORDER BY d.date_value)) AS streak_id
     FROM gabby.powerschool.cohort_identifiers_static co
     JOIN valid_dates d
       ON co.schoolid = d.schoolid
      AND co.academic_year = d.academic_year
     LEFT OUTER JOIN gabby.powerschool.ps_attendance_daily_static att 
       ON co.studentid = att.studentid
      AND d.date_value = att.att_date     
     WHERE co.academic_year = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
       AND co.rn_year = 1
    ) sub
GROUP BY academic_year
        ,student_number        
        ,att_code
        ,streak_id