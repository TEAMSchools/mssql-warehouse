CREATE
OR ALTER
PROCEDURE people.merge_employee_numbers AS
MERGE INTO
  gabby.people.employee_numbers AS tgt USING gabby.adp.employees_all AS src ON (
    tgt.associate_id = src.associate_id
  )
WHEN NOT MATCHED BY TARGET THEN
INSERT
  (associate_id)
VALUES
  (src.associate_id);
