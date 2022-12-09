CREATE OR ALTER VIEW
  deanslist.extracurricular_roster AS
SELECT
  ra.student_school_id AS student_number,
  ra.roster_name,
  r.roster_type
FROM
  deanslist.rosters r
  JOIN deanslist.roster_assignments ra ON r.roster_id = ra.dlroster_id
WHERE
  r.roster_type IN ('Club', 'Athletics')
