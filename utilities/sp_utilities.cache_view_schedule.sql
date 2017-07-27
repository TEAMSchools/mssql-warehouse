USE gabby
GO

ALTER PROCEDURE utilities.cache_view_schedule AS

BEGIN
  
  EXEC gabby.utilities.cache_view 'lit', 'achieved_by_round';
  EXEC gabby.utilities.cache_view 'illuminate_dna_assessments','student_assessment_scaffold';
  EXEC gabby.illuminate_dna_repositories.repository_row_ids_merge;

END
GO