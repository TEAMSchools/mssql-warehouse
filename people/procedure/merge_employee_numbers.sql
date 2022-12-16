CREATE
OR ALTER
PROCEDURE people.merge_employee_numbers AS
MERGE INTO
  gabby.people.employee_numbers AS TARGET USING gabby.adp.employees_all AS SOURCE ON Target.associate_id = Source.associate_id
WHEN NOT MATCHED BY TARGET THEN
INSERT
  (associate_id)
VALUES
  (SOURCE.associate_id);
