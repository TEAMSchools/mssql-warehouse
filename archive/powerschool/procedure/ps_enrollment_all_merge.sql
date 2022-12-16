CREATE
OR ALTER
PROCEDURE powerschool.ps_enrollment_all_merge AS
SET
ANSI_NULLS ON;

SET
QUOTED_IDENTIFIER ON;

BEGIN;

DECLARE @email_subject NVARCHAR(MAX),
@email_body NVARCHAR(MAX);

BEGIN TRY;

IF OBJECT_ID(N'#ps_enrollment_all_temp') IS NOT NULL BEGIN;

DROP TABLE #ps_enrollment_all_temp;

END;

SELECT
  * INTO #ps_enrollment_all_temp
FROM
  powerschool.ps_enrollment_all;

MERGE
  gabby.powerschool.ps_enrollment_all_static AS TARGET USING #ps_enrollment_all_temp AS SOURCE ON TARGET.studentid = SOURCE.studentid
  AND TARGET.schoolid = SOURCE.schoolid
  AND TARGET.entrydate = SOURCE.entrydate
WHEN MATCHED THEN
UPDATE SET
  TARGET.entrycode = SOURCE.entrycode,
  TARGET.exitdate = SOURCE.exitdate,
  TARGET.exitcode = SOURCE.exitcode,
  TARGET.grade_level = SOURCE.grade_level,
  TARGET.programid = SOURCE.programid,
  TARGET.fteid = SOURCE.fteid,
  TARGET.membershipshare = SOURCE.membershipshare,
  TARGET.track = SOURCE.track,
  TARGET.dflt_att_mode_code = SOURCE.dflt_att_mode_code,
  TARGET.dflt_conversion_mode_code = SOURCE.dflt_conversion_mode_code,
  TARGET.yearid = SOURCE.yearid,
  TARGET.att_calccntpresentabsent = SOURCE.att_calccntpresentabsent,
  TARGET.att_intervalduration = SOURCE.att_intervalduration
WHEN NOT MATCHED BY TARGET THEN
INSERT
  (
    studentid,
    schoolid,
    entrydate,
    entrycode,
    exitdate,
    exitcode,
    grade_level,
    programid,
    fteid,
    membershipshare,
    track,
    dflt_att_mode_code,
    dflt_conversion_mode_code,
    yearid,
    att_calccntpresentabsent,
    att_intervalduration
  )
VALUES
  (
    SOURCE.studentid,
    SOURCE.schoolid,
    SOURCE.entrydate,
    SOURCE.entrycode,
    SOURCE.exitdate,
    SOURCE.exitcode,
    SOURCE.grade_level,
    SOURCE.programid,
    SOURCE.fteid,
    SOURCE.membershipshare,
    SOURCE.track,
    SOURCE.dflt_att_mode_code,
    SOURCE.dflt_conversion_mode_code,
    SOURCE.yearid,
    SOURCE.att_calccntpresentabsent,
    SOURCE.att_intervalduration
  )
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

INSERT INTO
  [utilities].[cache_view_log] ([view_name], [timestamp])
VALUES
  (
    'powerschool.ps_enrollment_all',
    GETUTCDATE()
  );

END TRY BEGIN CATCH;

PRINT (ERROR_MESSAGE());

SET
  @email_subject = 'ps_enrollment_all static refresh failed';

SET
  @email_body = 'The refresh procedure for ps_enrollment_all failed.' + CHAR(10) + ERROR_MESSAGE();

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'datarobot',
@recipients = 'u7c1r1b1c5n4p0q0@kippnj.slack.com',
@subject = @email_subject,
@body = @email_body;

END CATCH;

END;
