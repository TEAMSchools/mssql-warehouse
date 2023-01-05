CREATE
OR ALTER
PROCEDURE people.merge_employee_numbers AS
MERGE INTO
  people.employee_numbers AS tgt USING adp.employees_all AS src ON (
    tgt.associate_id = src.associate_id
  )
WHEN NOT MATCHED BY TARGET THEN
INSERT
  (associate_id)
VALUES
  (src.associate_id);
