USE gabby GO
SET
ANSI_NULLS ON GO
SET
QUOTED_IDENTIFIER ON GO CREATE
OR ALTER
TRIGGER utilities.TR_exec_cache_view_AI ON utilities.cache_view_queue AFTER
INSERT
  AS DECLARE @sql NVARCHAR(MAX),
  @schema_name NVARCHAR(MAX),
  @view_name NVARCHAR(MAX),
  @refresh_status INT;

BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET
NOCOUNT ON;

SELECT
  @schema_name = SCHEMA_NAME
FROM
  INSERTED;

SELECT
  @view_name = view_name
FROM
  INSERTED;

SELECT
  @refresh_status = MAX(done)
FROM
  gabby.utilities.cache_view_queue
WHERE
  SCHEMA_NAME = @schema_name
  AND view_name = @view_name
  AND TIMESTAMP BETWEEN DATEADD(MINUTE, -60, GETUTCDATE()) AND GETUTCDATE();

IF @refresh_status = 0 BEGIN
SET
  @sql = 'EXEC gabby.utilities.cache_view ''' + @schema_name + ''', ''' + @view_name + ''';' PRINT (@sql);

EXEC (@sql);

END ELSE BEGIN PRINT ('Nothing to refresh...') END
UPDATE gabby.utilities.cache_view_queue
SET
  done = 1
WHERE
  SCHEMA_NAME = @schema_name
  AND view_name = @view_name
  AND TIMESTAMP BETWEEN DATEADD(MINUTE, -60, GETUTCDATE()) AND GETUTCDATE();

END GO
