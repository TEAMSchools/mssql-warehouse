USE gabby GO IF OBJECT_ID('powerschool.TR_final_grades_refresh_AI', 'TR') IS NOT NULL DROP
TRIGGER powerschool.TR_final_grades_refresh_AI;

GO CREATE
TRIGGER powerschool.TR_final_grades_refresh_AI ON powerschool.fivetran_audit AFTER
INSERT
  AS DECLARE @schema_name NVARCHAR(MAX),
  @view_name NVARCHAR(MAX),
  @is_referenced_table INT,
  @update_status INT,
  @email_subject NVARCHAR(MAX),
  @email_body NVARCHAR(MAX),
  @stage NVARCHAR(MAX);

set
  @schema_name = 'powerschool'
set
  @view_name = 'final_grades' begin begin try
  /* get list of tables referenced by view */
  /* only include non-static table objects */
set
  @stage = 'referenced tables' if object_id(n 'tempdb..#referenced_tables') is not null begin
DROP TABLE # referenced_tables;

END;

select
  table_name into # referenced_tables
from
  utilities.dependent_objects
where
  usedbyschemaname = @schema_name
  and usedbyobjectname = @view_name
  and table_name not in ('reporting_terms');

/* manual exclude */
/* get list of tables updated during current hour */
set
  @stage = 'updated tables' if object_id(n 'tempdb..#updated_tables') is not null begin
DROP TABLE # updated_tables;

END
SELECT
  [table] AS table_name INTO # updated_tables
FROM
  powerschool.fivetran_audit
WITH
  (NOLOCK)
WHERE
  update_started BETWEEN DATETIMEFROMPARTS(
    DATEPART(YEAR, DATEADD(MINUTE, -60, GETUTCDATE())),
    DATEPART(MONTH, DATEADD(MINUTE, -60, GETUTCDATE())),
    DATEPART(DAY, DATEADD(MINUTE, -60, GETUTCDATE())),
    DATEPART(HOUR, DATEADD(MINUTE, -60, GETUTCDATE())),
    30,
    0,
    0
  ) AND GETUTCDATE();

/* check if updated table is included in view */
set
  @stage = 'referenced table check'
select
  @is_referenced_table = case
    when count([table]) > 0 then 1
    else 0
  end
from
  inserted # referenced_tables
where
  [table] in (
    select
      table_name
    from
  );

if @is_referenced_table = 0 begin print ('INSERTED table is not included in target view');

return end
/* check if all tables included in view has been updated */
set
  @stage = 'updated table check'
select
  @update_status = case
    when count(rt.table_name) = count(ut.table_name) then 1
    else 0
  end
from
  # referenced_tables rt # updated_tables ut ON rt.table_name = ut.table_name;

left outer join if @update_status = 0 begin print ('All tables referenced by view have not yet been updated this hour');

return end
/* run refresh */
set
  @stage = 'queue' print ('Adding to cache_view queue') begin
INSERT INTO
  [utilities].[cache_view_queue] (schema_name, view_name, timestamp)
VALUES
  (@schema_name, @view_name, GETUTCDATE());

end end try begin catch
set
  @email_subject = @view_name + ' static refresh failed'
set
  @email_body = 'During the trigger, the refresh procedure for ' + @view_name + 'failed during the ' + @stage + 'stage.';

exec msdb.dbo.sp_send_dbmail @profile_name = 'datarobot',
@recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',
@subject = @email_subject,
@body = @email_body;

end catch end go
