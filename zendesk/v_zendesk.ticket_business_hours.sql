USE gabby
GO

CREATE OR ALTER VIEW zendesk.ticket_business_hours AS

WITH solved AS (
  SELECT ticket_id
        ,MAX(updated) AS updated
  FROM gabby.zendesk_v2.ticket_field_history
  WHERE field_name = 'status'
    AND value = 'solved'
  GROUP BY ticket_id
 )

,ticket_dates AS (
  SELECT t.id AS ticket_id	     	     
	       ,t.created_at AS created_timestamp

        ,COALESCE(slv.updated
                 ,CASE WHEN t.status IN ('closed', 'solved') THEN t.updated_at END
                 ,GETDATE()) AS solved_timestamp            
  FROM gabby.zendesk_v2.ticket t
  LEFT JOIN solved slv
    ON t.id = slv.ticket_id
  WHERE t.status != 'deleted'
 )

,business_hours AS (
  SELECT DATEPART(WEEKDAY,business_hours_start) AS dw_numeric        
        ,DATEPART(HOUR,business_hours_start) AS start_hour
        ,DATEPART(HOUR,business_hours_end) AS end_hour
  FROM
      (
       SELECT DATEADD(MINUTE
                     ,start_time
                     ,DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) - 1), CONVERT(DATETIME2,CONVERT(DATE,GETDATE())))) AS business_hours_start
             ,DATEADD(MINUTE
                     ,end_time
                     ,DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) - 1), CONVERT(DATETIME2,CONVERT(DATE,GETDATE())))) AS business_hours_end
       FROM gabby.zendesk_v2.schedule
      ) sub
 )

SELECT ticket_id
      ,SUM(bh_day_minutes) AS total_bh_minutes

      --,MAX(created_timestamp) AS created_timestamp
      --,MAX(solved_timestamp) AS solved_timestamp
      --,MAX(created_outside_bh) AS created_outside_bh
      --,MAX(solved_outside_bh) AS solved_outside_bh
      --,MIN(bh_day_start_timestamp) AS min_bh_day_start_timestamp
      --,MAX(bh_day_end_timestamp) AS max_bh_day_end_timestamp            
      --,SUM(bh_day_minutes) / 60 AS total_bh_hours
      --,SUM(bh_day_minutes) % 60 AS total_bh_hours_remainder
FROM
    (
     SELECT ticket_id      
           ,DATEDIFF(MINUTE, bh_day_start_timestamp, bh_day_end_timestamp) AS bh_day_minutes
           
           --,created_timestamp
           --,solved_timestamp           
           --,bh_day_start_timestamp
           --,bh_day_end_timestamp
           --,created_outside_bh
           --,solved_outside_bh           
     FROM
         (
          SELECT ticket_id
                ,CASE 
                  WHEN solved_timestamp < bh_start_timestamp THEN NULL
                  WHEN created_timestamp BETWEEN bh_start_timestamp AND bh_end_timestamp THEN created_timestamp 
                  WHEN created_timestamp < bh_start_timestamp THEN bh_start_timestamp
                 END AS bh_day_start_timestamp
                ,CASE                   
                  WHEN created_timestamp > bh_end_timestamp THEN NULL
                  WHEN solved_timestamp BETWEEN bh_start_timestamp AND bh_end_timestamp THEN solved_timestamp                   
                  WHEN solved_timestamp > bh_end_timestamp THEN bh_end_timestamp                  
                 END AS bh_day_end_timestamp

                --,dw_numeric
                --,created_timestamp
                --,solved_timestamp
                --,created_outside_bh
                --,solved_outside_bh                
          FROM
              (
               SELECT td.ticket_id
                     ,td.created_timestamp
                     ,td.solved_timestamp
                     
                     ,DATETIME2FROMPARTS(rd.year_part, rd.month_part, rd.day_part, bh.start_hour, 0, 0, 0, 0) AS bh_start_timestamp
                     ,DATETIME2FROMPARTS(rd.year_part, rd.month_part, rd.day_part, bh.end_hour, 0, 0, 0, 0) AS bh_end_timestamp

                     --,rd.dw_numeric
                     --,CASE 
                     --  WHEN bh.dw_numeric IS NULL THEN 1
                     --  WHEN DATEPART(HOUR,td.created_timestamp) BETWEEN bh.start_hour AND (bh.end_hour - 1) THEN 0                       
                     --  ELSE 1
                     -- END AS created_outside_bh
                     --,CASE 
                     --  WHEN bh.dw_numeric IS NULL THEN 1
                     --  WHEN DATEPART(HOUR,td.solved_timestamp) BETWEEN bh.start_hour AND (bh.end_hour - 1) THEN 0
                     --  ELSE 1
                     -- END AS solved_outside_bh                     
               FROM ticket_dates td
               INNER JOIN gabby.utilities.reporting_days rd
                  ON rd.date BETWEEN CONVERT(DATE,td.created_timestamp) AND CONVERT(DATE,td.solved_timestamp)
               LEFT JOIN business_hours bh
                  ON rd.dw_numeric = bh.dw_numeric                              
              ) sub
         ) sub
    ) sub
GROUP BY ticket_id