USE [gabby]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [illuminate_dna_assessments].[TR_agg_student_responses_AI]
   ON  [illuminate_dna_assessments].[agg_student_responses]
   AFTER INSERT
AS 

BEGIN	
	 SET NOCOUNT ON;
 
  IF (EXISTS(SELECT 1 FROM INSERTED))
  BEGIN
    DELETE FROM [illuminate_dna_assessments].[agg_student_responses]
    WHERE [agg_student_responses].student_assessment_id IN (SELECT student_assessment_id FROM INSERTED)

    INSERT INTO [illuminate_dna_assessments].[agg_student_responses]
    SELECT * FROM INSERTED

    OUTPUT SELECT * FROM INSERTED;
  END;
END
