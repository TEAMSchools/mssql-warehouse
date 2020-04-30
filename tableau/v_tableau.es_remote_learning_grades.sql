SELECT r.roster_id
      ,r.roster_name
      ,ra.school_name
      ,ra.student_school_id
      ,CONCAT(ra.last_name,', ',ra.first_name) AS student_name
      ,b.behavior_date AS assignment_date
      ,CASE WHEN b.staff_last_name IS NULL THEN NULL
            ELSE CONCAT(b.staff_last_name,', ',b.staff_first_name) END AS staff_name
      ,b.assignment AS assignment_name
      ,CAST(b.behavior AS int) AS score
      ,b.notes
FROM gabby.deanslist.rosters_all r
JOIN gabby.deanslist.roster_assignments ra
  ON r.roster_id = ra.dlroster_id
LEFT JOIN gabby.deanslist.behavior b
  ON ra.student_school_id = b.student_school_id
 AND ra.dlroster_id = b.roster_id
 AND b.behavior_category = 'Remote Learning'
 AND b.is_deleted = 0
WHERE r.subject_name IN ('ELA', 'Math')