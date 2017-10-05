USE gabby
GO

CREATE OR ALTER VIEW illuminate_public.student_session_aff_validation AS 

SELECT stu_sess_id
FROM OPENQUERY(ILLUMINATE,'
  SELECT stu_sess_id
  FROM public.student_session_aff
')