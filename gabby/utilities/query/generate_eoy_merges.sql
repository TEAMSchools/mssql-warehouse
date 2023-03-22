EXEC sp_generate_merge @table_name = 'agg_student_responses_all_current',
@target_table = 'agg_student_responses_all_archive',
@schema = 'illuminate_dna_assessments',
-- trunk-ignore(sqlfluff/LT05)
@cols_to_join_on = "'assessment_id','standard_id','local_student_id','is_replacement','response_type'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'student_assessment_scaffold_current_static',
@target_table = 'student_assessment_scaffold_archive',
@schema = 'illuminate_dna_assessments',
@cols_to_join_on = "'assessment_id','student_id'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'sight_words_data_current_static',
@target_table = 'sight_words_data_archive',
@schema = 'illuminate_dna_repositories',
@cols_to_join_on = "'repository_id','repository_row_id','label'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'ar_goals_current_static',
@target_table = 'ar_goals_archive',
@schema = 'renaissance',
@cols_to_join_on = "'student_number','academic_year','reporting_term'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'ar_time_series_current_static',
@target_table = 'ar_time_series_archive',
@schema = 'tableau',
@cols_to_join_on = "'student_number','date'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'survey_response_clean_current_static',
@target_table = 'survey_response_clean_archive',
@schema = 'surveygizmo',
@cols_to_join_on = "'survey_id','survey_response_id'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'survey_response_data_current_static',
@target_table = 'survey_response_data_archive',
@schema = 'surveygizmo',
@cols_to_join_on = "'survey_id','survey_response_id','question_id'",
@include_values = 0,
@delete_if_not_matched = 0;

EXEC sp_generate_merge @table_name = 'survey_response_data_options_current_static',
@target_table = 'survey_response_data_options_archive',
@schema = 'surveygizmo',
@cols_to_join_on = "'survey_id','survey_response_id','question_id','option_id'",
@include_values = 0,
@delete_if_not_matched = 0;

/*
TRUNCATE TABLE illuminate_dna_assessments.student_assessment_scaffold_current_static;
TRUNCATE TABLE illuminate_dna_repositories.sight_words_data_current_static;
TRUNCATE TABLE renaissance.ar_goals_current_static;
TRUNCATE TABLE tableau.ar_time_series_current_static;
TRUNCATE TABLE surveygizmo.survey_response_clean_current_static;
TRUNCATE TABLE surveygizmo.survey_response_data_current_static;
TRUNCATE TABLE surveygizmo.survey_response_data_options_current_static;
--*/
