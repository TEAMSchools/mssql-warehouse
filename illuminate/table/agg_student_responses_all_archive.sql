SELECT
  * INTO illuminate_dna_assessments.agg_student_responses_all_archive
FROM
  illuminate_dna_assessments.agg_student_responses_all
WHERE
  academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
