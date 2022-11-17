USE gabby
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER TRIGGER lexia.TR_units_to_target_merge_AI
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
         CAST(username AS VARCHAR(125)) AS username
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
        ,CAST(CURRENT_TIMESTAMP AS DATE) AS date
        ,DATEPART(WEEKDAY,CAST(CURRENT_TIMESTAMP AS DATE)) AS day_of_week
        ,CAST(units_to_target AS INT) AS units_to_target
        ,CAST(week_time AS INT) AS week_time               
  INTO #lexia_update
  FROM gabby.lexia.student_progress         
  WHERE DATEPART(WEEKDAY,CAST(CURRENT_TIMESTAMP AS DATE)) = 1;
  
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
           ,TARGET.academic_year = SOURCE.academic_year
           ,TARGET.day_of_week = SOURCE.day_of_week
      WHEN NOT MATCHED BY TARGET THEN
       INSERT
        (username
        ,units_to_target
        ,date
        ,week_time
        ,academic_year
        ,day_of_week)
       VALUES
        (SOURCE.username
        ,SOURCE.units_to_target
        ,SOURCE.date
        ,SOURCE.week_time
        ,SOURCE.academic_year
        ,SOURCE.day_of_week);

END
GO