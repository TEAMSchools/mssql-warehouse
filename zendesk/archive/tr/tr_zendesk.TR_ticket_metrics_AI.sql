USE [gabby]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER TRIGGER [zendesk].[TR_ticket_metrics_AI]
   ON  [zendesk].[ticket_metrics]
   AFTER INSERT
AS 

BEGIN	
	 SET NOCOUNT ON;
 
  IF (EXISTS(SELECT 1 FROM INSERTED))
  BEGIN
    DELETE FROM [zendesk].[ticket_metrics]
    WHERE [ticket_metrics].[id] IN (SELECT id FROM INSERTED);

    INSERT INTO [zendesk].[ticket_metrics]
    SELECT * FROM INSERTED
  END;
END
