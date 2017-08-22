USE gabby
GO

ALTER VIEW powerschool.attendance_counts AS

WITH scaffold AS (
  SELECT DISTINCT 
         co.studentid        
        ,co.academic_year
        
        ,d.time_per_name AS reporting_term
        ,d.alt_name AS term_name
        ,CONVERT(DATE,d.start_date) AS start_date
        ,CONVERT(DATE,d.end_date) AS end_date
        
        ,CASE
          WHEN att.att_code IN ('A','X') THEN 'A'
          WHEN att.att_code IN ('AD','A-E','D') THEN 'AD'
          WHEN att.att_code IN ('AE','E','EA') THEN 'AE'
          WHEN att.att_code IN ('ISS','Q','S') THEN 'ISS'
          WHEN att.att_code IN ('OS','OSS','OSSP') THEN 'OSS'
          WHEN att.att_code IN ('TLE','true','T') THEN 'T'
          WHEN att.att_code = 'T10' THEN 'T10'
          ELSE NULL
         END AS att_code
  FROM gabby.powerschool.cohort_identifiers_static co 
  JOIN gabby.reporting.reporting_terms d
    ON co.schoolid = d.schoolid
   AND co.academic_year = d.academic_year
   AND d.identifier = 'RT'
  JOIN gabby.powerschool.attendance_code att
    ON co.schoolid  = att.schoolid   
   AND d.yearid = att.yearid
  WHERE co.rn_year = 1
    AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
 )

,att_counts AS (
  SELECT studentid
        ,academic_year
        ,reporting_term      
        ,att_code
             
        ,COUNT(studentid) AS count_term
  FROM
      (
       SELECT att.studentid                  
             ,CASE
               WHEN att.att_code IN ('A','X') THEN 'A'
               WHEN att.att_code IN ('AD','A-E','D') THEN 'AD'
               WHEN att.att_code IN ('AE','E','EA') THEN 'AE'
               WHEN att.att_code IN ('ISS','Q','S') THEN 'ISS'
               WHEN att.att_code IN ('OS','OSS','OSSP') THEN 'OSS'
               WHEN att.att_code IN ('TLE','true','T') THEN 'T'
               WHEN att.att_code = 'T10' THEN 'T10'
               ELSE NULL
              END AS att_code
                  
             ,dates.academic_year                  
             ,dates.time_per_name AS reporting_term     
       FROM gabby.powerschool.ps_attendance_daily att WITH(NOEXPAND)
       JOIN gabby.reporting.reporting_terms dates
         ON att.att_date BETWEEN CONVERT(DATE,dates.start_date) AND CONVERT(DATE,dates.end_date)             
        AND att.schoolid = dates.schoolid
        AND dates.identifier = 'RT' 
       WHERE att.att_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
      ) sub
  WHERE att_code IS NOT NULL
  GROUP BY studentid
          ,academic_year            
          ,reporting_term        
          ,att_code
 )



,counts_long AS (
  SELECT studentid
        ,academic_year
        ,reporting_term
        ,term_name
        ,start_date
        ,end_date                
        ,N
        ,CONCAT(att_code,'_',field) AS pivot_field        
        ,CASE 
          WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date THEN 1 
          WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND start_date = MAX(start_date) OVER(PARTITION BY studentid, academic_year) THEN 1 
          ELSE 0 
         END AS is_curterm
  FROM
      (
       SELECT s.studentid
             ,s.academic_year
             ,s.reporting_term
             ,s.term_name
             ,s.start_date
             ,s.end_date
             ,s.att_code
             
             ,ISNULL(a.count_term, 0) AS count_term
             ,SUM(ISNULL(a.count_term, 0)) OVER(PARTITION BY s.studentid, s.academic_year, s.att_code ORDER BY s.start_date) AS count_y1
       FROM scaffold s
       LEFT OUTER JOIN att_counts a
         ON s.studentid = a.studentid
        AND s.academic_year = a.academic_year
        AND s.reporting_term = a.reporting_term
        AND s.att_code = a.att_code
       WHERE s.att_code IS NOT NULL

       UNION ALL

       SELECT studentid
             ,academic_year
             ,reporting_term
             ,term_name
             ,start_date
             ,end_date
             ,att_code
             ,count_term
             ,SUM(count_term) OVER(PARTITION BY studentid, academic_year ORDER BY start_date) AS count_year
       FROM
           (
            SELECT co.studentid
                  ,co.academic_year

                  ,d.time_per_name AS reporting_term
                  ,d.alt_name AS term_name
                  ,CONVERT(DATE,d.start_date) AS start_date
                  ,CONVERT(DATE,d.end_date) AS end_date
                  
                  ,SUM(CONVERT(FLOAT,ISNULL(mem.membershipvalue,0))) AS count_term      

                  ,'MEM' AS att_code
            FROM gabby.powerschool.cohort_identifiers_static co            
            LEFT OUTER JOIN gabby.powerschool.ps_adaadm_daily_ctod_static mem
              ON co.studentid = mem.studentid                          
             AND co.yearid = mem.yearid
            JOIN gabby.reporting.reporting_terms d
              ON co.schoolid = d.schoolid 
             AND mem.calendardate BETWEEN CONVERT(DATE,d.start_date) AND CONVERT(DATE,d.end_date)
             AND d.identifier = 'RT'
            WHERE co.rn_year = 1
              AND co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
            GROUP BY co.studentid
                    ,co.academic_year
                    ,d.time_per_name
                    ,d.alt_name
                    ,CONVERT(DATE,d.start_date)
                    ,CONVERT(DATE,d.end_date)
           ) sub
      ) sub
  UNPIVOT(
    N
    FOR field IN (count_term, count_y1)
   ) u
 )

SELECT studentid
      ,academic_year
      ,reporting_term
      ,term_name
      ,is_curterm
      
      ,a_count_term
      ,a_count_y1
      ,ad_count_term
      ,ad_count_y1
      ,ae_count_term
      ,ae_count_y1
      
      ,iss_count_term
      ,iss_count_y1
      ,oss_count_term
      ,oss_count_y1
      
      ,t_count_term
      ,t_count_y1
      ,t10_count_term
      ,t10_count_y1
      
      ,mem_count_term
      ,mem_count_y1

      ,ISNULL(a_count_y1, 0) + ISNULL(ad_count_y1, 0) AS abs_unexcused_count_y1
      ,ISNULL(a_count_term, 0) + ISNULL(ad_count_term, 0) AS abs_unexcused_count_term
      ,ISNULL(t_count_y1, 0) + ISNULL(t10_count_y1, 0) AS tdy_all_count_y1
      ,ISNULL(t_count_term, 0) + ISNULL(t10_count_term, 0) AS tdy_all_count_term     
FROM counts_long
PIVOT(
  MAX(N)
  FOR pivot_field IN ([a_count_term]
                     ,[a_count_y1]
                     ,[ad_count_term]
                     ,[ad_count_y1]
                     ,[ae_count_term]
                     ,[ae_count_y1]
                     ,[iss_count_term]
                     ,[iss_count_y1]
                     ,[oss_count_term]
                     ,[oss_count_y1]
                     ,[t_count_term]
                     ,[t_count_y1]
                     ,[t10_count_term]
                     ,[t10_count_y1]                     
                     ,[mem_count_term]
                     ,[mem_count_y1])
 ) p