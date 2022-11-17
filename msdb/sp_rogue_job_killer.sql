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
  SET @delay_time = '00:30:00'
  WAITFOR DELAY @delay_time;
  
  DECLARE job_killer CURSOR FOR  
    SELECT sj.job_id
    FROM msdb.dbo.sysjobs sj
    JOIN msdb.dbo.syscategories sc
      ON sj.category_id = sc.category_id
     AND sc.name = 'Data Team';

  OPEN job_killer   
  FETCH NEXT FROM job_killer INTO @job_id   

  WHILE @@FETCH_STATUS = 0
  BEGIN    
    EXEC	@return_value = msdb.dbo.sp_stop_job @job_id = @job_id
    IF @return_value = 0
      BEGIN       
        SELECT @job_name = name FROM msdb.dbo.sysjobs WHERE job_id = @job_id;
        SET @email_subject = 'SQL Server Agent Job Killed'
        SET @email_body = @job_name + N' was killed because it has been running for over ' + CAST(DATEPART(MINUTE, @delay_time) AS NVARCHAR) + ' minutes';
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