CREATE OR ALTER VIEW
  extracts.renlearn_teachers AS
SELECT
  cs.Staff_id AS id,
  cs.Staff_id AS teachernumber,
  cs.School_id AS schoolid,
  cs.Last_name AS last_name,
  cs.First_name AS first_name,
  NULL AS middle_name,
  cs.Username AS teacherloginid,
  cs.Staff_email AS staff_email
FROM
  gabby.extracts.clever_staff AS cs
  INNER JOIN gabby.extracts.clever_schools AS ch ON cs.School_id = ch.School_id
  AND (
    ch.High_grade = 8
    OR ch.School_number = 73256
  ) /* ad hoc rule for Seek */
