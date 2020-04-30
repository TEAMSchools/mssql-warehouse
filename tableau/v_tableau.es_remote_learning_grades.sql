USE gabby
GO

CREATE OR ALTER VIEW tableau.es_remote_learning_grades AS 

SELECT r.roster_id
      ,r.roster_name

      ,ra.school_name
      ,ra.student_school_id
      ,CONCAT(ra.last_name,', ',ra.first_name) AS student_name

      ,b.assignment AS assignment_name
      ,b.behavior_date AS assignment_date
      ,b.notes
      ,CAST(b.behavior AS INT) AS score
      ,b.staff_last_name + ', ' + b.staff_first_name AS staff_name
FROM gabby.deanslist.rosters_all r
JOIN gabby.deanslist.roster_assignments ra
  ON r.roster_id = ra.dlroster_id
LEFT JOIN gabby.deanslist.behavior b
  ON ra.student_school_id = b.student_school_id
 AND ra.dlroster_id = b.roster_id
 AND b.behavior_category = 'Remote Learning'
 AND b.is_deleted = 0
WHERE r.subject_name IN ('ELA', 'Math')
