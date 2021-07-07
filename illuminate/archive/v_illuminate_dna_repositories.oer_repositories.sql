USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_repositories.oer_repositories AS

SELECT ur.repository_id
      ,ur.repository_row_id
      ,ur.student_id      
      ,ur.year
      ,ur.quarter
      ,ur.course
      ,CONVERT(FLOAT,ur.prompt_1_analysis_of_evidence) AS prompt_1_analysis_of_evidence
      ,CONVERT(FLOAT,ur.prompt_1_choice_of_evidence) AS prompt_1_choice_of_evidence
      ,CONVERT(FLOAT,ur.prompt_1_context_of_evidence) AS prompt_1_context_of_evidence
      ,CONVERT(FLOAT,ur.prompt_1_justification) AS prompt_1_justification
      ,CONVERT(FLOAT,ur.prompt_1_overall) AS prompt_1_overall
      ,CONVERT(FLOAT,ur.prompt_1_quality_of_ideas) AS prompt_1_quality_of_ideas
      ,CONVERT(FLOAT,ur.prompt_2_analysis_of_evidence) AS prompt_2_analysis_of_evidence
      ,CONVERT(FLOAT,ur.prompt_2_choice_of_evidence) AS prompt_2_choice_of_evidence
      ,CONVERT(FLOAT,ur.prompt_2_context_of_evidence) AS prompt_2_context_of_evidence
      ,CONVERT(FLOAT,ur.prompt_2_justification) AS prompt_2_justification
      ,CONVERT(FLOAT,ur.prompt_2_overall) AS prompt_2_overall
      ,CONVERT(FLOAT,ur.prompt_2_quality_of_ideas) AS prompt_2_quality_of_ideas
      ,CONVERT(FLOAT,ur.prompt_3_analysis_of_evidence) AS prompt_3_analysis_of_evidence
      ,CONVERT(FLOAT,ur.prompt_3_choice_of_evidence) AS prompt_3_choice_of_evidence
      ,CONVERT(FLOAT,ur.prompt_3_context_of_evidence) AS prompt_3_context_of_evidence
      ,CONVERT(FLOAT,ur.prompt_3_justification) AS prompt_3_justification
      ,CONVERT(FLOAT,ur.prompt_3_overall) AS prompt_3_overall
      ,CONVERT(FLOAT,ur.prompt_3_quality_of_ideas) AS prompt_3_quality_of_ideas
      ,CONVERT(FLOAT,ur.prompt_4_analysis_of_evidence) AS prompt_4_analysis_of_evidence
      ,CONVERT(FLOAT,ur.prompt_4_choice_of_evidence) AS prompt_4_choice_of_evidence
      ,CONVERT(FLOAT,ur.prompt_4_context_of_evidence) AS prompt_4_context_of_evidence
      ,CONVERT(FLOAT,ur.prompt_4_justification) AS prompt_4_justification
      ,CONVERT(FLOAT,ur.prompt_4_overall) AS prompt_4_overall
      ,CONVERT(FLOAT,ur.prompt_4_quality_of_ideas) AS prompt_4_quality_of_ideas
FROM gabby.illuminate_dna_repositories.oer_repositories_archive ur
--WHERE CONCAT(ur.repository_id, '_', ur.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)