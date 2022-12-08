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

SET
    @schema_name = 'powerschool'
SET
    @view_name = 'final_grades' BEGIN BEGIN TRY
    /* get list of tables referenced by view */
    /* only include non-static table objects */
SET
    @stage = 'referenced tables' IF OBJECT_ID(N'tempdb..#referenced_tables') IS NOT NULL BEGIN
DROP TABLE #referenced_tables;

END;

SELECT
    table_name INTO #referenced_tables
FROM
    utilities.dependent_objects
WHERE
    usedbyschemaname = @schema_name
    AND usedbyobjectname = @view_name
    AND table_name NOT IN ('reporting_terms');

/* manual exclude */
/* get list of tables updated during current hour */
SET
    @stage = 'updated tables' IF OBJECT_ID(N'tempdb..#updated_tables') IS NOT NULL BEGIN
DROP TABLE #updated_tables;

END
SELECT
    [table] AS table_name INTO #updated_tables
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
SET
    @stage = 'referenced table check'
SELECT
    @is_referenced_table = CASE
        WHEN COUNT([table]) > 0 THEN 1
        ELSE 0
    END
FROM
    INSERTED
WHERE
    [table] IN (
        SELECT
            table_name
        FROM
            #referenced_tables
    );

IF @is_referenced_table = 0 BEGIN PRINT ('INSERTED table is not included in target view');

RETURN END
/* check if all tables included in view has been updated */
SET
    @stage = 'updated table check'
SELECT
    @update_status = CASE
        WHEN COUNT(rt.table_name) = COUNT(ut.table_name) THEN 1
        ELSE 0
    END
FROM
    #referenced_tables rt
    LEFT OUTER JOIN #updated_tables ut ON rt.table_name = ut.table_name;

IF @update_status = 0 BEGIN PRINT (
    'All tables referenced by view have not yet been updated this hour'
);

RETURN END
/* run refresh */
SET
    @stage = 'queue' PRINT ('Adding to cache_view queue') BEGIN
INSERT INTO
    [utilities].[cache_view_queue] (schema_name, view_name, timestamp)
VALUES
    (@schema_name, @view_name, GETUTCDATE());

END END TRY BEGIN CATCH
SET
    @email_subject = @view_name + ' static refresh failed'
SET
    @email_body = 'During the trigger, the refresh procedure for ' + @view_name + 'failed during the ' + @stage + 'stage.';

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'datarobot',
@recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',
@subject = @email_subject,
@body = @email_body;

END CATCH END GO
