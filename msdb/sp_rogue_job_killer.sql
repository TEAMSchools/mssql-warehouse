use msdb go CREATE
OR ALTER
PROCEDURE rogue_job_killer AS DECLARE @delay_time DATETIME,
@job_id NVARCHAR(MAX),
@job_name NVARCHAR(MAX),
@return_value INT,
@email_subject NVARCHAR(MAX),
@email_body NVARCHAR(MAX);

begin
set
  @delay_time = '00:30:00' waitfor delay @delay_time;

DECLARE job_killer CURSOR FOR
SELECT
  sj.job_id
FROM
  msdb.dbo.sysjobs sj
  JOIN msdb.dbo.syscategories sc ON sj.category_id = sc.category_id
  AND sc.name = 'Data Team';

open job_killer
fetch next
from
  job_killer into @job_id while @@ fetch_status = 0 begin exec @return_value = msdb.dbo.sp_stop_job @job_id = @job_id if @return_value = 0 begin
select
  @job_name = name
from
  msdb.dbo.sysjobs
where
  job_id = @job_id;

set
  @email_subject = 'SQL Server Agent Job Killed'
set
  @email_body = @job_name + n ' was killed because it has been running for over ' + cast(datepart(minute, @delay_time) as nvarchar) + ' minutes';

exec msdb.dbo.sp_send_dbmail @profile_name = 'datarobot',
@recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',
@subject = @email_subject,
@body = @email_body;

end
fetch next
from
  job_killer into @job_id end close job_killer deallocate job_killer end;

go
