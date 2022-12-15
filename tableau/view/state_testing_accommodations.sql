USE gabby GO
CREATE OR ALTER VIEW
  tableau.state_testing_accommodations AS
WITH
  accom AS (
    SELECT
      [db_name],
      studentsdcid,
      accommodation,
      accommodation_value
    FROM
      (
        SELECT
          [db_name],
          studentsdcid,
          CAST(parcc_ell_paper_accom AS VARCHAR(25)) AS parcc_ell_paper_accom,
          CAST(alternate_access AS VARCHAR(25)) AS alternate_access,
          CAST(access_test_format_override AS VARCHAR(25)) AS access_test_format_override,
          CAST(asmt_frequent_breaks AS VARCHAR(25)) AS asmt_frequent_breaks,
          CAST(asmt_alternate_location AS VARCHAR(25)) AS asmt_alternate_location,
          CAST(asmt_small_group AS VARCHAR(25)) AS asmt_small_group,
          CAST(asmt_special_equip AS VARCHAR(25)) AS asmt_special_equip,
          CAST(asmt_specified_area AS VARCHAR(25)) AS asmt_specified_area,
          CAST(asmt_time_of_day AS VARCHAR(25)) AS asmt_time_of_day,
          CAST(asmt_answer_masking AS VARCHAR(25)) AS asmt_answer_masking,
          CAST(asmt_read_aloud AS VARCHAR(25)) AS asmt_read_aloud,
          CAST(asmt_asl_video AS VARCHAR(25)) AS asmt_asl_video,
          CAST(asmt_non_screen_reader AS VARCHAR(25)) AS asmt_non_screen_reader,
          CAST(asmt_closed_caption_ela AS VARCHAR(25)) AS asmt_closed_caption_ela,
          CAST(asmt_refresh_braille_ela AS VARCHAR(25)) AS asmt_refresh_braille_ela,
          CAST(asmt_alt_rep_paper AS VARCHAR(25)) AS asmt_alt_rep_paper,
          CAST(parcc_large_print_paper AS VARCHAR(25)) AS parcc_large_print_paper,
          CAST(asmt_human_signer AS VARCHAR(25)) AS asmt_human_signer,
          CAST(asmt_answers_recorded_paper AS VARCHAR(25)) AS asmt_answers_recorded_paper,
          CAST(
            calculation_device_math_tools AS VARCHAR(25)
          ) AS calculation_device_math_tools,
          CAST(
            parcc_constructed_response_ela AS VARCHAR(25)
          ) AS parcc_constructed_response_ela,
          CAST(asmt_selected_response_ela AS VARCHAR(25)) AS asmt_selected_response_ela,
          CAST(asmt_math_response AS VARCHAR(25)) AS asmt_math_response,
          CAST(asmt_monitor_response AS VARCHAR(25)) AS asmt_monitor_response,
          CAST(asmt_word_prediction AS VARCHAR(25)) AS asmt_word_prediction,
          CAST(asmt_directions_clarified AS VARCHAR(25)) AS asmt_directions_clarified,
          CAST(asmt_directions_aloud AS VARCHAR(25)) AS asmt_directions_aloud,
          CAST(asmt_math_response_el AS VARCHAR(25)) AS asmt_math_response_el,
          CAST(parcc_translation_math_paper AS VARCHAR(25)) AS parcc_translation_math_paper
          --,CAST(asmt_dictionary AS VARCHAR(25)) AS asmt_dictionary
,
          CAST(parcc_text_to_speech AS VARCHAR(25)) AS parcc_text_to_speech,
          CAST(parcc_text_to_speech_math AS VARCHAR(25)) AS parcc_text_to_speech_math,
          CAST(asmt_humanreader_signer AS VARCHAR(25)) AS asmt_humanreader_signer,
          CAST(asmt_unique_accommodation AS VARCHAR(25)) AS asmt_unique_accommodation,
          CAST(asmt_extended_time AS VARCHAR(25)) AS asmt_extended_time,
          CAST(asmt_extended_time_math AS VARCHAR(25)) AS asmt_extended_time_math
        FROM
          gabby.powerschool.s_nj_stu_x AS nj
      ) sub UNPIVOT (
        accommodation_value FOR accommodation IN (
          parcc_ell_paper_accom,
          alternate_access,
          access_test_format_override,
          asmt_frequent_breaks,
          asmt_alternate_location,
          asmt_small_group,
          asmt_special_equip,
          asmt_specified_area,
          asmt_time_of_day,
          asmt_answer_masking,
          asmt_read_aloud,
          asmt_asl_video,
          asmt_non_screen_reader,
          asmt_closed_caption_ela,
          asmt_refresh_braille_ela,
          asmt_alt_rep_paper,
          parcc_large_print_paper,
          asmt_human_signer,
          asmt_answers_recorded_paper,
          calculation_device_math_tools,
          parcc_constructed_response_ela,
          asmt_selected_response_ela,
          asmt_math_response,
          asmt_monitor_response,
          asmt_word_prediction,
          asmt_directions_clarified,
          asmt_directions_aloud,
          asmt_math_response_el,
          parcc_translation_math_paper
          --,asmt_dictionary
,
          parcc_text_to_speech,
          parcc_text_to_speech_math,
          asmt_humanreader_signer,
          asmt_unique_accommodation,
          asmt_extended_time,
          asmt_extended_time_math
        )
      ) u
  )
SELECT
  co.student_number,
  co.state_studentnumber,
  co.lastfirst,
  co.academic_year,
  co.region,
  co.school_level,
  co.school_name,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.iep_status,
  co.specialed_classification,
  co.lep_status,
  co.c_504_status,
  nj.asmt_exclude_ela,
  nj.asmt_exclude_math,
  nj.parcc_test_format,
  nj.state_assessment_name,
  nj.math_state_assessment_name,
  ac.accommodation,
  ac.accommodation_value
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.powerschool.s_nj_stu_x AS nj ON co.students_dcid = nj.studentsdcid
  AND co.[db_name] = nj.[db_name]
  LEFT JOIN accom AS ac ON co.students_dcid = ac.studentsdcid
  AND co.[db_name] = ac.[db_name]
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND co.region IN ('TEAM', 'KCNA')
