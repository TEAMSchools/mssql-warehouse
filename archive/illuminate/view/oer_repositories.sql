USE gabby GO
CREATE OR ALTER VIEW
  illuminate_dna_repositories.oer_repositories AS
SELECT
  ur.repository_id,
  ur.repository_row_id,
  ur.student_id,
  ur.year,
  ur.quarter,
  ur.course,
  CAST(ur.prompt_1_analysis_of_evidence AS FLOAT) AS prompt_1_analysis_of_evidence,
  CAST(ur.prompt_1_choice_of_evidence AS FLOAT) AS prompt_1_choice_of_evidence,
  CAST(ur.prompt_1_context_of_evidence AS FLOAT) AS prompt_1_context_of_evidence,
  CAST(ur.prompt_1_justification AS FLOAT) AS prompt_1_justification,
  CAST(ur.prompt_1_overall AS FLOAT) AS prompt_1_overall,
  CAST(ur.prompt_1_quality_of_ideas AS FLOAT) AS prompt_1_quality_of_ideas,
  CAST(ur.prompt_2_analysis_of_evidence AS FLOAT) AS prompt_2_analysis_of_evidence,
  CAST(ur.prompt_2_choice_of_evidence AS FLOAT) AS prompt_2_choice_of_evidence,
  CAST(ur.prompt_2_context_of_evidence AS FLOAT) AS prompt_2_context_of_evidence,
  CAST(ur.prompt_2_justification AS FLOAT) AS prompt_2_justification,
  CAST(ur.prompt_2_overall AS FLOAT) AS prompt_2_overall,
  CAST(ur.prompt_2_quality_of_ideas AS FLOAT) AS prompt_2_quality_of_ideas,
  CAST(ur.prompt_3_analysis_of_evidence AS FLOAT) AS prompt_3_analysis_of_evidence,
  CAST(ur.prompt_3_choice_of_evidence AS FLOAT) AS prompt_3_choice_of_evidence,
  CAST(ur.prompt_3_context_of_evidence AS FLOAT) AS prompt_3_context_of_evidence,
  CAST(ur.prompt_3_justification AS FLOAT) AS prompt_3_justification,
  CAST(ur.prompt_3_overall AS FLOAT) AS prompt_3_overall,
  CAST(ur.prompt_3_quality_of_ideas AS FLOAT) AS prompt_3_quality_of_ideas,
  CAST(ur.prompt_4_analysis_of_evidence AS FLOAT) AS prompt_4_analysis_of_evidence,
  CAST(ur.prompt_4_choice_of_evidence AS FLOAT) AS prompt_4_choice_of_evidence,
  CAST(ur.prompt_4_context_of_evidence AS FLOAT) AS prompt_4_context_of_evidence,
  CAST(ur.prompt_4_justification AS FLOAT) AS prompt_4_justification,
  CAST(ur.prompt_4_overall AS FLOAT) AS prompt_4_overall,
  CAST(ur.prompt_4_quality_of_ideas AS FLOAT) AS prompt_4_quality_of_ideas
FROM
  gabby.illuminate_dna_repositories.oer_repositories_archive AS ur
  --WHERE CONCAT(ur.repository_id, '_', ur.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)
