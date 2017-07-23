USE gabby
GO

ALTER VIEW illuminate_groups.student_groups AS
      
SELECT s.local_student_id
      
      ,g.group_id
      ,g.group_name
      
      ,aff.start_date
      ,aff.end_date
      ,aff.eligibility_start_date
      ,aff.eligibility_end_date  
      
      ,gabby.utilities.DATE_TO_SY(start_date) AS academic_year           
FROM gabby.illuminate_groups.groups g
JOIN gabby.illuminate_groups.group_student_aff aff
  ON g.group_id = aff.group_id
JOIN gabby.illuminate_public.students s
  ON aff.student_id = s.student_id