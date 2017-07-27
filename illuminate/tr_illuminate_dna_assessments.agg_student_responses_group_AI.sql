USE [gabby]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [illuminate_dna_assessments].[TR_agg_student_responses_group_AI]
   ON  [illuminate_dna_assessments].[agg_student_responses_group]
   AFTER INSERT
AS 

BEGIN	
	 SET NOCOUNT ON;
 
  IF (EXISTS(SELECT 1 FROM INSERTED))
  BEGIN
    DELETE FROM [illuminate_dna_assessments].[agg_student_responses_group]
    WHERE CONCAT([agg_student_responses_group].student_assessment_id, '_', [agg_student_responses_group].reporting_group_id) IN (SELECT CONCAT(student_assessment_id, '_', reporting_group_id) FROM INSERTED)

    INSERT INTO [illuminate_dna_assessments].[agg_student_responses_group]
    SELECT * FROM INSERTED

    OUTPUT SELECT * FROM INSERTED;
  END;
END
