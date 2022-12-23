CREATE OR ALTER VIEW
  tableau.es_remote_learning_grades AS
SELECT
  r.roster_id,
  r.roster_name,
  ra.school_name,
  ra.student_school_id,
  CONCAT(
    ra.last_name,
    ', ',
    ra.first_name
  ) AS student_name,
  NULL AS assignment_name,
  b.behavior_date AS assignment_date,
  b.notes,
  CAST(b.behavior AS INT) AS score,
  b.staff_last_name + ', ' + b.staff_first_name AS staff_name
FROM
  gabby.deanslist.rosters AS r
  INNER JOIN gabby.deanslist.roster_assignments AS ra ON (
    r.roster_id = ra.dlroster_id
    AND r.[db_name] = ra.[db_name]
    AND ra.grade_level IN ('K', '1st', '2nd', '3rd', '4th')
  )
  LEFT JOIN gabby.deanslist.homework AS b ON (
    ra.student_school_id = b.student_school_id
    AND ra.dlroster_id = b.roster_id
    AND r.[db_name] = b.[db_name]
    AND b.behavior_category = 'Remote Learning'
    AND b.is_deleted = 0
  )
WHERE
  r.subject_name IN ('ELA', 'Math')
