USE gabby
GO

ALTER PROCEDURE utilities.cache_view_schedule AS

BEGIN
  
  EXEC gabby.utilities.cache_view 'lit', 'achieved_by_round';

END
GO