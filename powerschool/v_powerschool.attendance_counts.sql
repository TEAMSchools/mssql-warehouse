USE gabby
GO

CREATE OR ALTER VIEW powerschool.attendance_counts AS

WITH att_counts AS (
  SELECT studentid
        ,academic_year
        ,reporting_term      
        ,term_name
        ,start_date
        ,end_date
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
              END AS att_code
                  
             ,CONVERT(INT,dates.academic_year) AS academic_year
             ,CONVERT(VARCHAR,dates.time_per_name) AS reporting_term     
             ,CONVERT(VARCHAR,dates.alt_name) AS term_name
             ,dates.start_date
             ,dates.end_date
       FROM gabby.powerschool.ps_attendance_daily_static att
       JOIN gabby.reporting.reporting_terms dates
         ON att.schoolid = dates.schoolid
        AND att.att_date BETWEEN dates.start_date AND dates.end_date
        AND dates.identifier = 'RT' 
       WHERE att.att_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
         AND att.att_code IN ('A','AD','AE','A-E','D','E','EA','ISS','OS','OSS','OSSP','Q','S','T','T10','TLE','X','true')
      ) sub  
  GROUP BY studentid
          ,academic_year            
          ,reporting_term        
          ,att_code
          ,term_name
          ,start_date
          ,end_date
 )

,mem_counts AS (
  SELECT sub.studentid
        ,sub.academic_year
        ,sub.reporting_term
        ,sub.term_name
        ,sub.start_date
        ,sub.end_date
        ,SUM(sub.membershipvalue) AS count_term

        ,'MEM' AS att_code
  FROM
      (
       SELECT mem.studentid             
             ,mem.membershipvalue
             ,(mem.yearid + 1990) AS academic_year

             ,CONVERT(VARCHAR,d.time_per_name) AS reporting_term
             ,CONVERT(VARCHAR,d.alt_name) AS term_name
             ,d.start_date
             ,d.end_date             
       FROM gabby.powerschool.ps_adaadm_daily_ctod_static mem              
       JOIN gabby.reporting.reporting_terms d
         ON mem.schoolid = d.schoolid 
        AND mem.calendardate BETWEEN d.start_date AND d.end_date
        AND d.identifier = 'RT'
       WHERE mem.yearid >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990 - 1)
         AND mem.calendardate <= GETDATE()
      ) sub
  GROUP BY sub.studentid
          ,sub.academic_year
          ,sub.reporting_term
          ,sub.term_name
          ,sub.start_date
          ,sub.end_date
 )

,counts_long AS (
  SELECT studentid
        ,academic_year
        ,reporting_term
        ,term_name
        ,start_date
        ,end_date                
        ,CONVERT(FLOAT,n) AS n
        ,CONCAT(att_code,'_',field) AS pivot_field        
        ,CASE 
          WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date THEN 1 
          WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND start_date = MAX(start_date) OVER(PARTITION BY studentid, academic_year) THEN 1 
          ELSE 0 
         END AS is_curterm
  FROM
      (
       SELECT studentid
             ,academic_year
             ,reporting_term
             ,term_name
             ,start_date
             ,end_date
             ,att_code             
             ,count_term
             ,SUM(count_term) OVER(PARTITION BY studentid, academic_year, att_code ORDER BY start_date) AS count_y1
       FROM att_counts
       
       UNION ALL

       SELECT studentid
             ,academic_year
             ,reporting_term
             ,term_name
             ,start_date
             ,end_date
             ,att_code
             ,count_term 
             ,SUM(count_term) OVER(PARTITION BY studentid, academic_year ORDER BY start_date) AS count_y1
       FROM mem_counts
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