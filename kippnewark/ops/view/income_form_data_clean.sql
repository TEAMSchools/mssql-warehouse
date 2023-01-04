CREATE OR ALTER VIEW
  ops.income_form_data_clean AS
SELECT
  student_identifier AS student_number,
  academic_year_clean AS academic_year,
  eligibility_name + ' - ' + 'Income Form' AS lunch_app_status,
  eligibility_name AS lunch_status,
  rn,
  DB_NAME() AS [db_name]
FROM
  titan.income_form_data_clean
