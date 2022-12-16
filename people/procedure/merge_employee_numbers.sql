USE [gabby] GOCREATE
OR ALTER
PROCEDURE people.merge_employee_numbers AS
MERGE INTO
  [gabby].[people].[employee_numbers] AS [Target] USING [gabby].[adp].[employees_all] AS [Source] ON [Target].[associate_id] = [Source].[associate_id]
WHEN NOT MATCHED BY TARGET THEN
INSERT
  ([associate_id])
VALUES
  ([Source].[associate_id]);
