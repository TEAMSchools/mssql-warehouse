USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_missing_assignments AS

SELECT a.student_number      
      ,a.grade_category            
      ,a.assign_name      
      ,CONVERT(DATE,a.assign_date) AS assign_date

      ,c.course_name

      ,t.lastfirst AS teacher_name
FROM gabby.tableau.gradebook_assignment_detail a
JOIN gabby.powerschool.sections sec 
  ON a.sectionid = sec.id
JOIN gabby.powerschool.teachers t
  ON sec.teacher = t.id
JOIN gabby.powerschool.courses c
  ON sec.course_number_clean = c.course_number_clean
WHERE a.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND a.ismissing = 1
  AND a.finalgrade_category = 'Q'
  AND ISNULL(a.score, 0) = 0