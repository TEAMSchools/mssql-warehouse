USE gabby
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER utilities.TR_exec_cache_view_AI
   ON  utilities.cache_view_queue
   AFTER INSERT
AS 

DECLARE @sql NVARCHAR(MAX)
       ,@schema_name NVARCHAR(MAX)
       ,@view_name NVARCHAR(MAX);

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT @schema_name = schema_name FROM INSERTED;
 SELECT @view_name = view_name FROM INSERTED; 
 SET @sql = 'EXEC gabby.utilities.cache_view ''' + @schema_name + ''', ''' + @view_name + ''';'
 
 PRINT(@sql);
 EXEC(@sql);

END
GO
 