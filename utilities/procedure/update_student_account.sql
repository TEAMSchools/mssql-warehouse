SET
ANSI_NULLS ON;

GO
SET
QUOTED_IDENTIFIER ON;

GOCREATE
OR ALTER
PROCEDURE utilities.update_student_account @username_orig NVARCHAR(MAX),
@username_new NVARCHAR(MAX) AS BEGIN
SET
XACT_ABORT ON;

IF EXISTS (
  SELECT
    1
  FROM
    gabby.powerschool.student_access_accounts_static
  WHERE
    student_web_id = @username_new
) BEGIN RAISERROR (
  'New username already exists! Terminating...',
  18,
  -1
);

END ELSE BEGIN RAISERROR (
  'Updating username %s to %s...',
  0,
  1,
  @username_orig,
  @username_new
)
WITH
  NOWAIT;

UPDATE gabby.powerschool.student_access_accounts_static
SET
  student_web_id = @username_new,
  manual_override = 1
WHERE
  student_web_id = @username_orig;

RAISERROR ('Success!', 0, 1)
WITH
  NOWAIT;

END END
