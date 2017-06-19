USE [gabby]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [illuminate_dna_assessments].[TR_agg_student_responses_standard_AI]
   ON  [illuminate_dna_assessments].[agg_student_responses_standard]
   AFTER INSERT
AS 

BEGIN	
	 SET NOCOUNT ON;
 
  IF (EXISTS(SELECT 1 FROM INSERTED))
  BEGIN
    DELETE FROM [illuminate_dna_assessments].[agg_student_responses_standard]
    WHERE CONCAT([agg_student_responses_standard].student_assessment_id, '_', [agg_student_responses_standard].standard_id) IN (SELECT CONCAT(student_assessment_id, '_', standard_id) FROM INSERTED)

    INSERT INTO [illuminate_dna_assessments].[agg_student_responses_standard]
    SELECT * FROM INSERTED

    OUTPUT SELECT * FROM INSERTED;
  END;
END
