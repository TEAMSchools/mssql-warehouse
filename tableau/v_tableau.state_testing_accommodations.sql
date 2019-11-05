USE gabby
GO

CREATE OR ALTER VIEW tableau.state_testing_accommodations AS

WITH accom AS (
  SELECT db_name
        ,studentsdcid
        ,parcc_test_format
        ,state_assessment_name
        ,math_state_assessment_name
        ,asmt_exclude_ela
        ,asmt_exclude_math
        ,accommodation
        ,accom_value

  FROM 
      (
       SELECT db_name
             ,studentsdcid
             ,CAST(parcc_ell_paper_accom AS varchar(255)) AS parcc_ell_paper_accom
             ,CAST(alternate_access AS varchar(255)) AS alternate_access
             ,state_assessment_name
             ,math_state_assessment_name
             ,asmt_exclude_ela
             ,asmt_exclude_math
             ,CAST(parcc_test_format AS varchar(255)) AS parcc_test_format
             ,CAST(access_test_format_override AS varchar(255)) AS access_test_format_override
             ,CAST(asmt_frequent_breaks AS varchar(255)) AS asmt_frequent_breaks
             ,CAST(asmt_alternate_location AS varchar(255)) AS asmt_alternate_location
             ,CAST(asmt_small_group AS varchar(255)) AS asmt_small_group
             ,CAST(asmt_special_equip AS varchar(255)) AS asmt_special_equip
             ,CAST(asmt_specified_area AS varchar(255)) AS asmt_specified_area
             ,CAST(asmt_time_of_day AS varchar(255)) AS asmt_time_of_day
             ,CAST(asmt_answer_masking AS varchar(255)) AS asmt_answer_masking
             ,CAST(asmt_read_aloud AS varchar(255)) AS asmt_read_aloud
             ,CAST(asmt_asl_video AS varchar(255)) AS asmt_asl_video
             ,CAST(asmt_non_screen_reader AS varchar(255)) AS asmt_non_screen_reader
             ,CAST(asmt_closed_caption_ela AS varchar(255)) AS asmt_closed_caption_ela
             ,CAST(asmt_refresh_braille_ela AS varchar(255)) AS asmt_refresh_braille_ela
             ,CAST(asmt_alt_rep_paper AS varchar(255)) AS asmt_alt_rep_paper
             ,CAST(parcc_large_print_paper AS varchar(255)) AS parcc_large_print_paper
             ,CAST(asmt_human_signer AS varchar(255)) AS asmt_human_signer
             ,CAST(asmt_answers_recorded_paper AS varchar(255)) AS asmt_answers_recorded_paper
             ,CAST(calculation_device_math_tools AS varchar(255)) AS calculation_device_math_tools
             ,CAST(parcc_constructed_response_ela AS varchar(255)) AS parcc_constructed_response_ela
             ,CAST(asmt_selected_response_ela AS varchar(255)) AS asmt_selected_response_ela
             ,CAST(asmt_math_response AS varchar(255)) AS asmt_math_response
             ,CAST(asmt_monitor_response AS varchar(255)) AS asmt_monitor_response
             ,CAST(asmt_word_prediction AS varchar(255)) AS asmt_word_prediction
             ,CAST(asmt_directions_clarified AS varchar(255)) AS asmt_directions_clarified
             ,CAST(asmt_directions_aloud AS varchar(255)) AS asmt_directions_aloud
             ,CAST(asmt_math_response_el AS varchar(255)) AS asmt_math_response_el
             ,CAST(parcc_translation_math_paper AS varchar(255)) AS parcc_translation_math_paper
             ,CAST(asmt_dictionary AS varchar(255)) AS asmt_dictionary
             ,CAST(parcc_text_to_speech AS varchar(255)) AS parcc_text_to_speech
             ,CAST(parcc_text_to_speech_math AS varchar(255)) AS parcc_text_to_speech_math
             ,CAST(asmt_humanreader_signer AS varchar(255)) AS asmt_humanreader_signer
             ,CAST(asmt_unique_accommodation AS varchar(255)) AS asmt_unique_accommodation
             ,CAST(asmt_extended_time AS varchar(255)) AS asmt_extended_time
             ,CAST(asmt_extended_time_math AS varchar(255)) AS asmt_extended_time_math

       FROM gabby.powerschool.s_nj_stu_x nj
    ) AS sub
       UNPIVOT
              (accom_value FOR accommodation in 
              (parcc_ell_paper_accom
              ,alternate_access
              ,access_test_format_override
              ,asmt_frequent_breaks
              ,asmt_alternate_location
              ,asmt_small_group
              ,asmt_special_equip
              ,asmt_specified_area
              ,asmt_time_of_day
              ,asmt_answer_masking
              ,asmt_read_aloud
              ,asmt_asl_video
              ,asmt_non_screen_reader
              ,asmt_closed_caption_ela
              ,asmt_refresh_braille_ela
              ,asmt_alt_rep_paper
              ,parcc_large_print_paper
              ,asmt_human_signer
              ,asmt_answers_recorded_paper
              ,calculation_device_math_tools
              ,parcc_constructed_response_ela
              ,asmt_selected_response_ela
              ,asmt_math_response
              ,asmt_monitor_response
              ,asmt_word_prediction
              ,asmt_directions_clarified
              ,asmt_directions_aloud
              ,asmt_math_response_el
              ,parcc_translation_math_paper
              ,asmt_dictionary
              ,parcc_text_to_speech
              ,parcc_text_to_speech_math
              ,asmt_humanreader_signer
              ,asmt_unique_accommodation
              ,asmt_extended_time
              ,asmt_extended_time_math)
              ) AS nj_unpivot
)

SELECT co.db_name
      ,region
      ,school_level
      ,school_name
      ,student_number
      ,state_studentnumber
      ,lastfirst
      ,grade_level
      ,team
      ,advisor_name
      ,iep_status
      ,specialed_classification
      ,lep_status
      ,c_504_status
      ,parcc_test_format
      ,state_assessment_name
      ,math_state_assessment_name
      ,asmt_exclude_ela
      ,asmt_exclude_math
      ,accommodation
      ,accom_value

FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN accom ac
  ON co.students_dcid = ac.studentsdcid
 AND co.db_name = ac.db_name

WHERE co.academic_year = 2019
  AND co.rn_year = 1
  AND co.db_name <> 'kippmiami'
  AND co.enroll_status = 0
  AND co.grade_level <> 99
     

