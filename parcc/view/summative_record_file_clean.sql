USE kippnewark;

GO
CREATE OR ALTER VIEW
  parcc.summative_record_file_clean AS
SELECT
  state_abbreviation,
  COALESCE(
    CAST(testing_district_code AS NVARCHAR(32)),
    eoy_testing_district_identifier
  ) AS testing_district_code,
  COALESCE(
    testing_school_code,
    eoy_testing_school_institution_identifier
  ) AS testing_school_code,
  COALESCE(
    responsible_accountable_district_code,
    responsible_district_code,
    responsible_district_identifier
  ) AS responsible_district_code,
  COALESCE(
    responsible_accountable_school_code,
    responsible_school_code,
    responsible_school_institution_identifier
  ) AS responsible_school_code,
  CAST(state_student_identifier AS NVARCHAR(32)) AS state_student_identifier,
  local_student_identifier,
  COALESCE(
    parccstudent_identifier,
    parcc_student_identifier
  ) AS parccstudent_identifier,
  COALESCE(last_or_surname, last_name) AS last_or_surname,
  first_name,
  middle_name,
  birthdate,
  sex,
  grade_level_when_assessed,
  hispanic_or_latino_ethnicity,
  american_indian_or_alaska_native,
  asian,
  black_or_african_american,
  native_hawaiian_or_other_pacific_islander,
  white,
  two_or_more_races,
  COALESCE(english_learner_el, english_learner) AS english_learner_el,
  title_iiilimited_english_proficient_participation_status,
  COALESCE(giftedand_talented, gifted_and_talented) AS giftedand_talented,
  migrant_status,
  economic_disadvantage_status,
  student_with_disabilities,
  primary_disability_type,
  COALESCE(state_field_1, optional_state_data_1) AS state_field_1,
  COALESCE(state_field_2, optional_state_data_2) AS state_field_2,
  state_field_3,
  state_field_4,
  state_field_5,
  state_field_6,
  state_field_7,
  state_field_8,
  state_field_9,
  state_field_10,
  class_name,
  CAST(test_administrator AS NVARCHAR(32)) AS test_administrator,
  CAST(staff_member_identifier AS NVARCHAR(32)) AS staff_member_identifier,
  test_code,
  retest,
  elaccommodation,
  frequent_breaks,
  separate_alternate_location,
  small_testing_group,
  specialized_equipment_or_furniture,
  specified_area_or_setting,
  time_of_day,
  answer_masking,
  assistive_technology_screen_reader,
  closed_captioning_for_elal,
  COALESCE(
    student_reads_assessment_aloudto_self,
    student_reads_assessment_aloud_to_themselves
  ) AS student_reads_assessment_aloud_to_self,
  human_signer_for_test_directions,
  calculation_device_and_mathematics_tools,
  COALESCE(
    CAST(elalconstructed_response AS NVARCHAR(32)),
    elal_constructed_response
  ) AS elalconstructed_response,
  COALESCE(
    CAST(
      elalselected_response_or_technology_enhanced_items AS NVARCHAR(32)
    ),
    elal_selected_response_or_technology_enhanced_items
  ) AS elalselected_response_or_technology_enhanced_items,
  mathematics_response,
  monitor_test_response,
  word_prediction,
  COALESCE(
    administration_directions_clarifiedin_students_native_language,
    administration_directions_clarified_in_students_native_language
  ) AS administration_directions_clarifiedin_students_native_language,
  administration_directions_read_aloudin_students_native_language
  --,NULL AS mathematics_response_el
  --,NULL AS wordto_word_dictionary_english_native_language
,
  emergency_accommodation,
  extended_time,
  COALESCE(
    student_test_uuid,
    summative_score_record_uuid
  ) AS student_test_uuid,
  COALESCE(paper_form_id, eoy_form_id) AS paper_form_id,
  COALESCE(online_form_id, eoy_form_id) AS online_form_id,
  test_status,
  COALESCE(total_test_items, eoy_total_test_items) AS total_test_items,
  COALESCE(
    test_attemptedness_flag,
    eoy_test_attemptedness_flag
  ) AS test_attemptedness_flag,
  COALESCE(
    total_test_items_attempted,
    eoy_total_test_items_attempted
  ) AS total_test_items_attempted,
  paper_attempt_create_date,
  paper_section_1_total_test_items,
  paper_section_1_numberof_attempted_items,
  paper_section_2_total_test_items,
  paper_section_2_numberof_attempted_items,
  paper_section_3_total_test_items,
  paper_section_3_numberof_attempted_items,
  paper_section_4_total_test_items,
  paper_section_4_numberof_attempted_items,
  student_unit_1_test_uuid,
  unit_1_form_id,
  COALESCE(
    unit_1_total_test_items,
    eoy_unit_1_total_number_of_items
  ) AS unit_1_total_test_items,
  COALESCE(
    unit_1_numberof_attempted_items,
    eoy_unit_1_number_of_attempted_items
  ) AS unit_1_numberof_attempted_items,
  student_unit_2_test_uuid,
  unit_2_form_id,
  COALESCE(
    unit_2_total_test_items,
    eoy_unit_2_total_number_of_items
  ) AS unit_2_total_test_items,
  COALESCE(
    unit_2_number_of_attempted_items,
    eoy_unit_2_number_of_attempted_items
  ) AS unit_2_number_of_attempted_items,
  student_unit_3_test_uuid,
  unit_3_form_id,
  COALESCE(
    unit_3_total_test_items,
    eoy_unit_3_total_number_of_items
  ) AS unit_3_total_test_items,
  COALESCE(
    unit_3_number_of_attempted_items,
    eoy_unit_3_number_of_attempted_items
  ) AS unit_3_number_of_attempted_items,
  student_unit_4_test_uuid,
  unit_4_form_id,
  unit_4_total_test_items,
  unit_4_numberof_attempted_items,
  not_tested_code,
  COALESCE(not_tested_reason, eoy_not_tested_reason) AS not_tested_reason,
  void_score_code,
  void_score_reason,
  ship_report_district_code,
  ship_report_school_code,
  COALESCE(
    summative_flag,
    reported_summative_score_flag
  ) AS summative_flag,
  multiple_test_registration,
  attempt_create_date,
  unit_1_online_test_start_date_time,
  unit_1_online_test_end_date_time,
  unit_2_online_test_start_date_time,
  unit_2_online_test_end_date_time,
  unit_3_online_test_start_date_time,
  unit_3_online_test_end_date_time,
  unit_4_online_test_start_date_time,
  unit_4_online_test_end_date_time,
  assessment_year,
  assessment_grade,
  CAST([subject] AS NVARCHAR(128)) AS [subject],
  federal_race_ethnicity,
  [period],
  testing_organizational_type,
  COALESCE(
    testing_district_name,
    eoy_testing_district_name
  ) AS testing_district_name,
  COALESCE(
    testing_school_name,
    eoy_testing_school_institution_name
  ) AS testing_school_name,
  responsible_organization_code_type,
  responsible_organizational_type,
  responsible_district_name,
  COALESCE(
    responsible_school_name,
    responsible_school_institution_name
  ) AS responsible_school_name,
  COALESCE(test_scale_score, summative_scale_score) AS test_scale_score,
  COALESCE(test_csemprobable_range, summative_csem) AS test_csemprobable_range,
  COALESCE(
    test_performance_level,
    summative_performance_level
  ) AS test_performance_level,
  COALESCE(
    test_reading_scale_score,
    summative_reading_scale_score
  ) AS test_reading_scale_score,
  COALESCE(test_reading_csem, summative_reading_csem) AS test_reading_csem,
  COALESCE(
    test_writing_scale_score,
    summative_writing_scale_score
  ) AS test_writing_scale_score,
  COALESCE(test_writing_csem, summative_writing_csem) AS test_writing_csem,
  subclaim_1_category,
  subclaim_2_category,
  subclaim_3_category,
  subclaim_4_category,
  subclaim_5_category,
  test_score_complete
  --,NULL AS word_prediction_for_elal
,
  record_type,
  assessment_accommodation_english_learner,
  assessment_accommodation_504,
  assessment_accommodation_individualized_educational_plan,
  text_to_speech,
  text_to_speech_for_mathematics,
  text_to_speech_for_elal,
  human_reader_or_human_signer,
  human_reader_or_human_signer_for_mathematics,
  human_reader_or_human_signer_for_elal,
  pba_form_id,
  pba_not_tested_reason,
  pba_student_test_uuid,
  pba_test_attemptedness_flag,
  pba_testing_district_identifier,
  pba_testing_district_name,
  pba_testing_school_institution_identifier,
  pba_testing_school_institution_name,
  pba_total_test_items,
  pba_total_test_items_attempted,
  pba_unit_1_number_of_attempted_items,
  pba_unit_1_total_number_of_items,
  pba_unit_2_number_of_attempted_items,
  pba_unit_2_total_number_of_items,
  pba_unit_3_number_of_attempted_items,
  pba_unit_3_total_number_of_items,
  CAST(LEFT(assessment_year, 4) AS INT) AS academic_year
FROM
  kippnewark.parcc.summative_record_file
WHERE
  test_status = 'Attempt'
  AND summative_flag = 'Y'
  AND assessment_year <> '2014-2015'
UNION ALL
SELECT
  state_abbreviation,
  COALESCE(
    CAST(testing_district_code AS NVARCHAR(32)),
    eoy_testing_district_identifier
  ) AS testing_district_code,
  COALESCE(
    testing_school_code,
    eoy_testing_school_institution_identifier
  ) AS testing_school_code,
  COALESCE(
    responsible_accountable_district_code,
    responsible_district_code,
    responsible_district_identifier
  ) AS responsible_district_code,
  COALESCE(
    responsible_accountable_school_code,
    responsible_school_code,
    responsible_school_institution_identifier
  ) AS responsible_school_code,
  CAST(state_student_identifier AS NVARCHAR(32)) AS state_student_identifier,
  local_student_identifier,
  COALESCE(
    parccstudent_identifier,
    parcc_student_identifier
  ) AS parccstudent_identifier,
  COALESCE(last_or_surname, last_name) AS last_or_surname,
  first_name,
  middle_name,
  birthdate,
  sex,
  grade_level_when_assessed,
  hispanic_or_latino_ethnicity,
  american_indian_or_alaska_native,
  asian,
  black_or_african_american,
  native_hawaiian_or_other_pacific_islander,
  white,
  two_or_more_races,
  COALESCE(english_learner_el, english_learner) AS english_learner_el,
  title_iiilimited_english_proficient_participation_status,
  COALESCE(giftedand_talented, gifted_and_talented) AS giftedand_talented,
  migrant_status,
  economic_disadvantage_status,
  student_with_disabilities,
  primary_disability_type,
  COALESCE(state_field_1, optional_state_data_1) AS state_field_1,
  COALESCE(state_field_2, optional_state_data_2) AS state_field_2,
  state_field_3,
  state_field_4,
  state_field_5,
  state_field_6,
  state_field_7,
  state_field_8,
  state_field_9,
  state_field_10,
  class_name,
  CAST(test_administrator AS NVARCHAR(32)) AS test_administrator,
  CAST(staff_member_identifier AS NVARCHAR(32)) AS staff_member_identifier,
  test_code,
  retest,
  elaccommodation,
  frequent_breaks,
  separate_alternate_location,
  small_testing_group,
  specialized_equipment_or_furniture,
  specified_area_or_setting,
  time_of_day,
  answer_masking,
  assistive_technology_screen_reader,
  closed_captioning_for_elal,
  COALESCE(
    student_reads_assessment_aloudto_self,
    student_reads_assessment_aloud_to_themselves
  ) AS student_reads_assessment_aloud_to_self,
  human_signer_for_test_directions,
  calculation_device_and_mathematics_tools,
  COALESCE(
    CAST(elalconstructed_response AS NVARCHAR(32)),
    elal_constructed_response
  ) AS elalconstructed_response,
  COALESCE(
    CAST(
      elalselected_response_or_technology_enhanced_items AS NVARCHAR(32)
    ),
    elal_selected_response_or_technology_enhanced_items
  ) AS elalselected_response_or_technology_enhanced_items,
  mathematics_response,
  monitor_test_response,
  word_prediction,
  COALESCE(
    administration_directions_clarifiedin_students_native_language,
    administration_directions_clarified_in_students_native_language
  ) AS administration_directions_clarifiedin_students_native_language,
  administration_directions_read_aloudin_students_native_language
  --,NULL AS mathematics_response_el
  --,NULL AS wordto_word_dictionary_english_native_language
,
  emergency_accommodation,
  extended_time,
  COALESCE(
    student_test_uuid,
    summative_score_record_uuid
  ) AS student_test_uuid,
  COALESCE(paper_form_id, eoy_form_id) AS paper_form_id,
  COALESCE(online_form_id, eoy_form_id) AS online_form_id,
  test_status,
  COALESCE(total_test_items, eoy_total_test_items) AS total_test_items,
  COALESCE(
    test_attemptedness_flag,
    eoy_test_attemptedness_flag
  ) AS test_attemptedness_flag,
  COALESCE(
    total_test_items_attempted,
    eoy_total_test_items_attempted
  ) AS total_test_items_attempted,
  paper_attempt_create_date,
  paper_section_1_total_test_items,
  paper_section_1_numberof_attempted_items,
  paper_section_2_total_test_items,
  paper_section_2_numberof_attempted_items,
  paper_section_3_total_test_items,
  paper_section_3_numberof_attempted_items,
  paper_section_4_total_test_items,
  paper_section_4_numberof_attempted_items,
  student_unit_1_test_uuid,
  unit_1_form_id,
  COALESCE(
    unit_1_total_test_items,
    eoy_unit_1_total_number_of_items
  ) AS unit_1_total_test_items,
  COALESCE(
    unit_1_numberof_attempted_items,
    eoy_unit_1_number_of_attempted_items
  ) AS unit_1_numberof_attempted_items,
  student_unit_2_test_uuid,
  unit_2_form_id,
  COALESCE(
    unit_2_total_test_items,
    eoy_unit_2_total_number_of_items
  ) AS unit_2_total_test_items,
  COALESCE(
    unit_2_number_of_attempted_items,
    eoy_unit_2_number_of_attempted_items
  ) AS unit_2_number_of_attempted_items,
  student_unit_3_test_uuid,
  unit_3_form_id,
  COALESCE(
    unit_3_total_test_items,
    eoy_unit_3_total_number_of_items
  ) AS unit_3_total_test_items,
  COALESCE(
    unit_3_number_of_attempted_items,
    eoy_unit_3_number_of_attempted_items
  ) AS unit_3_number_of_attempted_items,
  student_unit_4_test_uuid,
  unit_4_form_id,
  unit_4_total_test_items,
  unit_4_numberof_attempted_items,
  not_tested_code,
  COALESCE(not_tested_reason, eoy_not_tested_reason) AS not_tested_reason,
  void_score_code,
  void_score_reason,
  ship_report_district_code,
  ship_report_school_code,
  COALESCE(
    summative_flag,
    reported_summative_score_flag
  ) AS summative_flag,
  multiple_test_registration,
  attempt_create_date,
  unit_1_online_test_start_date_time,
  unit_1_online_test_end_date_time,
  unit_2_online_test_start_date_time,
  unit_2_online_test_end_date_time,
  unit_3_online_test_start_date_time,
  unit_3_online_test_end_date_time,
  unit_4_online_test_start_date_time,
  unit_4_online_test_end_date_time,
  assessment_year,
  assessment_grade,
  CAST([subject] AS NVARCHAR(128)) AS [subject],
  federal_race_ethnicity,
  [period],
  testing_organizational_type,
  COALESCE(
    testing_district_name,
    eoy_testing_district_name
  ) AS testing_district_name,
  COALESCE(
    testing_school_name,
    eoy_testing_school_institution_name
  ) AS testing_school_name,
  responsible_organization_code_type,
  responsible_organizational_type,
  responsible_district_name,
  COALESCE(
    responsible_school_name,
    responsible_school_institution_name
  ) AS responsible_school_name,
  COALESCE(test_scale_score, summative_scale_score) AS test_scale_score,
  COALESCE(test_csemprobable_range, summative_csem) AS test_csemprobable_range,
  COALESCE(
    test_performance_level,
    summative_performance_level
  ) AS test_performance_level,
  COALESCE(
    test_reading_scale_score,
    summative_reading_scale_score
  ) AS test_reading_scale_score,
  COALESCE(test_reading_csem, summative_reading_csem) AS test_reading_csem,
  COALESCE(
    test_writing_scale_score,
    summative_writing_scale_score
  ) AS test_writing_scale_score,
  COALESCE(test_writing_csem, summative_writing_csem) AS test_writing_csem,
  subclaim_1_category,
  subclaim_2_category,
  subclaim_3_category,
  subclaim_4_category,
  subclaim_5_category,
  test_score_complete
  --,NULL AS word_prediction_for_elal
,
  record_type,
  assessment_accommodation_english_learner,
  assessment_accommodation_504,
  assessment_accommodation_individualized_educational_plan,
  text_to_speech,
  text_to_speech_for_mathematics,
  text_to_speech_for_elal,
  human_reader_or_human_signer,
  human_reader_or_human_signer_for_mathematics,
  human_reader_or_human_signer_for_elal,
  pba_form_id,
  pba_not_tested_reason,
  pba_student_test_uuid,
  pba_test_attemptedness_flag,
  pba_testing_district_identifier,
  pba_testing_district_name,
  pba_testing_school_institution_identifier,
  pba_testing_school_institution_name,
  pba_total_test_items,
  pba_total_test_items_attempted,
  pba_unit_1_number_of_attempted_items,
  pba_unit_1_total_number_of_items,
  pba_unit_2_number_of_attempted_items,
  pba_unit_2_total_number_of_items,
  pba_unit_3_number_of_attempted_items,
  pba_unit_3_total_number_of_items,
  CAST(LEFT(assessment_year, 4) AS INT) AS academic_year
FROM
  kippnewark.parcc.summative_record_file
WHERE
  assessment_year = '2014-2015'
  AND record_type = 1
  AND reported_summative_score_flag = 'Y';

GO USE kippcamden;

GO
CREATE OR ALTER VIEW
  parcc.summative_record_file_clean AS
SELECT
  state_abbreviation,
  CAST(testing_district_code AS NVARCHAR(32)) AS testing_district_code,
  testing_school_code,
  COALESCE(
    responsible_accountable_district_code,
    responsible_district_code
  ) AS responsible_district_code,
  COALESCE(
    responsible_accountable_school_code,
    responsible_school_code
  ) AS responsible_school_code,
  CAST(state_student_identifier AS NVARCHAR(32)) AS state_student_identifier,
  local_student_identifier,
  parccstudent_identifier,
  last_or_surname AS last_or_surname,
  first_name,
  middle_name,
  birthdate,
  sex,
  grade_level_when_assessed,
  hispanic_or_latino_ethnicity,
  american_indian_or_alaska_native,
  asian,
  black_or_african_american,
  native_hawaiian_or_other_pacific_islander,
  white,
  two_or_more_races,
  english_learner_el,
  title_iiilimited_english_proficient_participation_status,
  giftedand_talented,
  migrant_status,
  economic_disadvantage_status,
  student_with_disabilities,
  primary_disability_type,
  state_field_1,
  state_field_2,
  state_field_3,
  state_field_4,
  state_field_5,
  state_field_6,
  state_field_7,
  state_field_8,
  state_field_9,
  NULL AS state_field_10,
  class_name,
  CAST(test_administrator AS NVARCHAR(32)) AS test_administrator,
  CAST(staff_member_identifier AS NVARCHAR(32)) AS staff_member_identifier,
  test_code,
  retest,
  elaccommodation,
  frequent_breaks,
  separate_alternate_location,
  small_testing_group,
  specialized_equipment_or_furniture,
  specified_area_or_setting,
  time_of_day,
  answer_masking,
  NULL AS assistive_technology_screen_reader,
  NULL AS closed_captioning_for_elal,
  student_reads_assessment_aloudto_self,
  human_signer_for_test_directions,
  calculation_device_and_mathematics_tools,
  elalconstructed_response,
  elalselected_response_or_technology_enhanced_items,
  NULL AS mathematics_response,
  NULL AS monitor_test_response,
  word_prediction,
  administration_directions_clarifiedin_students_native_language,
  administration_directions_read_aloudin_students_native_language
  --,mathematics_response_el
  --,wordto_word_dictionary_english_native_language
,
  emergency_accommodation,
  extended_time,
  student_test_uuid,
  NULL AS paper_form_id,
  online_form_id,
  test_status,
  total_test_items,
  test_attemptedness_flag,
  total_test_items_attempted,
  NULL AS paper_attempt_create_date,
  NULL AS paper_section_1_total_test_items,
  NULL AS paper_section_1_numberof_attempted_items,
  NULL AS paper_section_2_total_test_items,
  NULL AS paper_section_2_numberof_attempted_items,
  NULL AS paper_section_3_total_test_items,
  NULL AS paper_section_3_numberof_attempted_items,
  NULL AS paper_section_4_total_test_items,
  NULL AS paper_section_4_numberof_attempted_items,
  student_unit_1_test_uuid,
  unit_1_form_id,
  unit_1_total_test_items,
  unit_1_numberof_attempted_items,
  student_unit_2_test_uuid,
  unit_2_form_id,
  unit_2_total_test_items,
  unit_2_number_of_attempted_items,
  student_unit_3_test_uuid,
  unit_3_form_id,
  unit_3_total_test_items,
  unit_3_number_of_attempted_items,
  student_unit_4_test_uuid,
  unit_4_form_id,
  unit_4_total_test_items,
  unit_4_numberof_attempted_items,
  not_tested_code,
  not_tested_reason,
  void_score_code,
  void_score_reason,
  ship_report_district_code,
  ship_report_school_code,
  summative_flag,
  multiple_test_registration,
  attempt_create_date,
  unit_1_online_test_start_date_time,
  unit_1_online_test_end_date_time,
  unit_2_online_test_start_date_time,
  unit_2_online_test_end_date_time,
  unit_3_online_test_start_date_time,
  unit_3_online_test_end_date_time,
  unit_4_online_test_start_date_time,
  unit_4_online_test_end_date_time,
  assessment_year,
  assessment_grade,
  CAST([subject] AS NVARCHAR(128)) AS [subject],
  federal_race_ethnicity,
  [period],
  testing_organizational_type,
  testing_district_name,
  testing_school_name,
  responsible_organization_code_type,
  responsible_organizational_type,
  responsible_district_name,
  responsible_school_name,
  test_scale_score,
  test_csemprobable_range,
  test_performance_level,
  test_reading_scale_score,
  test_reading_csem,
  test_writing_scale_score,
  test_writing_csem,
  subclaim_1_category,
  subclaim_2_category,
  subclaim_3_category,
  subclaim_4_category,
  subclaim_5_category,
  test_score_complete
  --,word_prediction_for_elal
,
  NULL AS record_type,
  NULL AS assessment_accommodation_english_learner,
  NULL AS assessment_accommodation_504,
  NULL AS assessment_accommodation_individualized_educational_plan,
  text_to_speech,
  NULL AS text_to_speech_for_mathematics,
  NULL AS text_to_speech_for_elal,
  human_reader_or_human_signer,
  NULL AS human_reader_or_human_signer_for_mathematics,
  NULL AS human_reader_or_human_signer_for_elal,
  NULL AS pba_form_id,
  NULL AS pba_not_tested_reason,
  NULL AS pba_student_test_uuid,
  NULL AS pba_test_attemptedness_flag,
  NULL AS pba_testing_district_identifier,
  NULL AS pba_testing_district_name,
  NULL AS pba_testing_school_institution_identifier,
  NULL AS pba_testing_school_institution_name,
  NULL AS pba_total_test_items,
  NULL AS pba_total_test_items_attempted,
  NULL AS pba_unit_1_number_of_attempted_items,
  NULL AS pba_unit_1_total_number_of_items,
  NULL AS pba_unit_2_number_of_attempted_items,
  NULL AS pba_unit_2_total_number_of_items,
  NULL AS pba_unit_3_number_of_attempted_items,
  NULL AS pba_unit_3_total_number_of_items,
  CAST(LEFT(assessment_year, 4) AS INT) AS academic_year
FROM
  parcc.summative_record_file
WHERE
  test_status = 'Attempt'
  AND summative_flag = 'Y';

GO
