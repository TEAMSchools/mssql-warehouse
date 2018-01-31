USE msdb
GO

CREATE OR ALTER PROCEDURE rogue_job_killer AS

DECLARE	@delay_time DATETIME
       ,@job_id NVARCHAR(MAX)
       ,@job_name NVARCHAR(MAX)
       ,@return_value INT
       ,@email_subject NVARCHAR(MAX)
       ,@email_body NVARCHAR(MAX);

BEGIN
  SET @delay_time = '00:20:00'
  WAITFOR DELAY @delay_time;
  
  DECLARE job_killer CURSOR FOR  
    SELECT '2E8F379D-3606-46B8-8C18-0359B7FD3800' AS job_id UNION /* Scheduled | Refresh Static Views | PS Attendance | Hourly (45s) */ 
    SELECT 'B8EF30A2-5EEE-4F15-9F33-89A4DB81FE95' AS job_id UNION /* Scheduled | Refresh Static Views | PS Grades | Hourly (45s) */
    SELECT '2242F09A-6757-4B77-A363-DB59D9AB06C3' AS job_id;      /* Scheduled | Refresh Static Views | Illuminate | Hourly (45s) */

  OPEN job_killer   
  FETCH NEXT FROM job_killer INTO @job_id   

  WHILE @@FETCH_STATUS = 0
  BEGIN    
    EXEC	@return_value = msdb.dbo.sp_stop_job @job_id = @job_id
    IF @return_value = 0
      BEGIN       
        SELECT @job_name = name FROM msdb.dbo.sysjobs WHERE job_id = @job_id;
        SET @email_subject = 'SQL Server Agent Job Killed'
        SET @email_body = @job_name + N' was killed because it has been running for over ' + CONVERT(NVARCHAR,DATEPART(MINUTE, @delay_time)) + ' minutes';
        EXEC msdb.dbo.sp_send_dbmail  
          @profile_name = 'datarobot',
          @recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',
          @subject = @email_subject,
          @body = @email_body;
      END

    FETCH NEXT FROM job_killer INTO @job_id
  END   

  CLOSE job_killer   
  DEALLOCATE job_killer

END;

GO