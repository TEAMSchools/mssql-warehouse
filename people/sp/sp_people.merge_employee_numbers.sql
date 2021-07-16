USE [gabby]
GO

CREATE OR ALTER PROCEDURE people.merge_employee_numbers AS

SET NOCOUNT ON

MERGE INTO [gabby].[people].[employee_numbers] AS [Target]
USING (SELECT [associate_id] FROM [gabby].[adp].[employees_all] WHERE [file_number] IS NOT NULL) AS [Source]
   ON [Target].[associate_id] = [Source].[associate_id]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([associate_id])
 VALUES([Source].[associate_id]);

DECLARE @mergeError INT
       ,@mergeCount INT
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [people].[employee_numbers]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[people].[employee_numbers] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO
