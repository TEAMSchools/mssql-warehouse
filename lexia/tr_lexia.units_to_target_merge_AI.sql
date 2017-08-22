USE gabby
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER lexia.TR_units_to_target_merge_AI
   ON  lexia.student_progress
   AFTER INSERT
AS

BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID(N'tempdb..#lexia_update') IS NOT NULL 
    BEGIN
      DROP TABLE #lexia_update;
    END
  
  SELECT DISTINCT
         username
        ,CONVERT(DATE,GETDATE()) AS date
        ,CONVERT(INT,units_to_target) AS units_to_target
        ,CONVERT(INT,week_time) AS week_time        
  INTO #lexia_update
  FROM gabby.lexia.student_progress;
  
  IF OBJECT_ID(N'lexia.units_to_target') IS NULL 
    BEGIN

      SELECT *
      INTO gabby.lexia.units_to_target
      FROM #lexia_update

    END

  ELSE
    MERGE gabby.lexia.units_to_target AS TARGET
      USING #lexia_update AS SOURCE
         ON TARGET.username = SOURCE.username
        AND TARGET.date = SOURCE.date
      WHEN MATCHED THEN
       UPDATE
        SET TARGET.units_to_target = SOURCE.units_to_target
           ,TARGET.week_time = SOURCE.week_time
      WHEN NOT MATCHED BY TARGET THEN
       INSERT
        (username
        ,units_to_target
        ,date
        ,week_time)
       VALUES
        (SOURCE.username
        ,SOURCE.units_to_target
        ,SOURCE.date
        ,SOURCE.week_time);

END
GO