USE [gabby]
GO

CREATE OR ALTER PROCEDURE people.merge_employee_numbers AS

MERGE INTO [gabby].[people].[employee_numbers] AS [Target]
USING (SELECT [associate_id] FROM [gabby].[adp].[employees_all] WHERE [file_number] IS NOT NULL) AS [Source]
   ON [Target].[associate_id] = [Source].[associate_id]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([associate_id])
 VALUES([Source].[associate_id]);
