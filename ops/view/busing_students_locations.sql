CREATE OR ALTER VIEW
  ops.busing_students_locations AS
SELECT
  s.nen AS student_number,
  NULL AS schoolid,
  s.grade_level,
  s.first AS first_name,
  s.last AS last_name,
  s.street,
  s.city,
  s.zip,
  1 AS is_new,
  CASE
    WHEN s.grade_level <= 4 THEN 'ES'
    WHEN s.grade_level <= 8 THEN 'MS'
    WHEN s.grade_level <= 12 THEN 'HS'
  END AS school_level,
  s.geocode,
  l.type AS location_type,
  l.name AS location_name,
  l.address AS location_address
FROM
  gabby.ops.busing_locations AS l
  INNER JOIN gabby.ops.busing_students_new AS s ON l.school_level = CASE
    WHEN s.grade_level <= 4 THEN 'ES'
    WHEN s.grade_level <= 8 THEN 'MS'
    WHEN s.grade_level <= 12 THEN 'HS'
  END
