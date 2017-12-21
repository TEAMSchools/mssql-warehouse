USE gabby
GO

CREATE VIEW illuminate_matviews.ss_cube_validation AS 

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  SELECT student_id        
        ,user_id
        ,section_id        
        ,entry_date
        ,leave_date
  FROM matviews.ss_cube  
')