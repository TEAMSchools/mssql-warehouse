CREATE OR ALTER VIEW
  steptool.component_scores AS
SELECT
  unique_id,
  student_id,
  step AS lvl_num,
  CAST(field AS VARCHAR(125)) AS field,
  score,
  CASE
    WHEN step = 0 THEN 'Pre'
    ELSE CAST(step AS VARCHAR(5))
  END AS read_lvl,
  CASE
    WHEN step = 0 THEN 3280
    WHEN step = 1 THEN 3281
    WHEN step = 2 THEN 3282
    WHEN step = 3 THEN 3380
    WHEN step = 4 THEN 3397
    WHEN step = 5 THEN 3411
    WHEN step = 6 THEN 3425
    WHEN step = 7 THEN 3441
    WHEN step = 8 THEN 3458
    WHEN step = 9 THEN 3474
    WHEN step = 10 THEN 3493
    WHEN step = 11 THEN 3511
    WHEN step = 12 THEN 3527
  END AS testid,
  CASE
    WHEN passed = 1 THEN 'Achieved'
    WHEN passed = 0 THEN 'Did Not Achieve'
  END AS [status]
FROM
  (
    SELECT
      CAST(
        CONCAT(
          'UC',
          utilities.DATE_TO_SY (DATE),
          [_line]
        ) AS VARCHAR(125)
      ) AS unique_id,
      CAST(CAST(student_id AS FLOAT) AS INT) AS student_id,
      CAST(step AS INT) AS step,
      passed,
      CAST(c_confusion_10_ AS VARCHAR(25)) AS c_confusion_10_,
      CAST(c_confusion_11_ AS VARCHAR(25)) AS c_confusion_11_,
      CAST(c_confusion_12_ AS VARCHAR(25)) AS c_confusion_12_,
      CAST(c_confusion_2_ AS VARCHAR(25)) AS c_confusion_2_,
      CAST(c_confusion_3_ AS VARCHAR(25)) AS c_confusion_3_,
      CAST(c_confusion_4_ AS VARCHAR(25)) AS c_confusion_4_,
      CAST(c_confusion_5_ AS VARCHAR(25)) AS c_confusion_5_,
      CAST(c_confusion_6_ AS VARCHAR(25)) AS c_confusion_6_,
      CAST(c_confusion_7_ AS VARCHAR(25)) AS c_confusion_7_,
      CAST(c_confusion_8_ AS VARCHAR(25)) AS c_confusion_8_,
      CAST(c_confusion_9_ AS VARCHAR(25)) AS c_confusion_9_,
      CAST(
        comprehension_conversation_2_ AS VARCHAR(25)
      ) AS comprehension_conversation_2_,
      CAST(
        comprehension_conversation_3_ AS VARCHAR(25)
      ) AS comprehension_conversation_3_,
      CAST(
        comprehension_conversation_4_ AS VARCHAR(25)
      ) AS comprehension_conversation_4_,
      CAST(
        comprehension_conversation_5_ AS VARCHAR(25)
      ) AS comprehension_conversation_5_,
      CAST(
        comprehension_conversation_8_ AS VARCHAR(25)
      ) AS comprehension_conversation_8_,
      CAST(
        comprehension_conversation_critical_thinking_3_ AS VARCHAR(25)
      ) AS comprehension_conversation_critical_thinking_3_,
      CAST(
        comprehension_conversation_critical_thinking_4_ AS VARCHAR(25)
      ) AS comprehension_conversation_critical_thinking_4_,
      CAST(
        comprehension_conversation_critical_thinking_5_ AS VARCHAR(25)
      ) AS comprehension_conversation_critical_thinking_5_,
      CAST(
        comprehension_conversation_critical_thinking_8_ AS VARCHAR(25)
      ) AS comprehension_conversation_critical_thinking_8_,
      CAST(
        comprehension_conversation_factual_2_ AS VARCHAR(25)
      ) AS comprehension_conversation_factual_2_,
      CAST(
        comprehension_conversation_factual_3_ AS VARCHAR(25)
      ) AS comprehension_conversation_factual_3_,
      CAST(
        comprehension_conversation_factual_4_ AS VARCHAR(25)
      ) AS comprehension_conversation_factual_4_,
      CAST(
        comprehension_conversation_factual_5_ AS VARCHAR(25)
      ) AS comprehension_conversation_factual_5_,
      CAST(
        comprehension_conversation_factual_8_ AS VARCHAR(25)
      ) AS comprehension_conversation_factual_8_,
      CAST(
        comprehension_conversation_inferential_2_ AS VARCHAR(25)
      ) AS comprehension_conversation_inferential_2_,
      CAST(
        comprehension_conversation_inferential_3_ AS VARCHAR(25)
      ) AS comprehension_conversation_inferential_3_,
      CAST(
        comprehension_conversation_inferential_4_ AS VARCHAR(25)
      ) AS comprehension_conversation_inferential_4_,
      CAST(
        comprehension_conversation_inferential_5_ AS VARCHAR(25)
      ) AS comprehension_conversation_inferential_5_,
      CAST(
        comprehension_conversation_inferential_8_ AS VARCHAR(25)
      ) AS comprehension_conversation_inferential_8_,
      CAST(
        comprehension_conversation_other_2_ AS VARCHAR(25)
      ) AS comprehension_conversation_other_2_,
      CAST(
        concepts_about_print_0_ AS VARCHAR(25)
      ) AS concepts_about_print_0_,
      CAST(
        concepts_about_print_1_ AS VARCHAR(25)
      ) AS concepts_about_print_1_,
      CAST(
        concepts_about_print_one_to_one_matching_0_ AS VARCHAR(25)
      ) AS concepts_about_print_one_to_one_matching_0_,
      CAST(
        concepts_about_print_one_to_one_matching_1_ AS VARCHAR(25)
      ) AS concepts_about_print_one_to_one_matching_1_,
      CAST(
        concepts_about_print_orientation_0_ AS VARCHAR(25)
      ) AS concepts_about_print_orientation_0_,
      CAST(
        concepts_about_print_orientation_1_ AS VARCHAR(25)
      ) AS concepts_about_print_orientation_1_,
      CAST(
        concepts_about_print_sense_of_letter_vs_word_0_ AS VARCHAR(25)
      ) AS concepts_about_print_sense_of_letter_vs_word_0_,
      CAST(
        concepts_about_print_sense_of_letter_vs_word_1_ AS VARCHAR(25)
      ) AS concepts_about_print_sense_of_letter_vs_word_1_,
      CAST(
        developmental_spelling_1_ AS VARCHAR(25)
      ) AS developmental_spelling_1_,
      CAST(
        developmental_spelling_10_ AS VARCHAR(25)
      ) AS developmental_spelling_10_,
      CAST(
        developmental_spelling_11_ AS VARCHAR(25)
      ) AS developmental_spelling_11_,
      CAST(
        developmental_spelling_12_ AS VARCHAR(25)
      ) AS developmental_spelling_12_,
      CAST(
        developmental_spelling_2_ AS VARCHAR(25)
      ) AS developmental_spelling_2_,
      CAST(
        developmental_spelling_3_ AS VARCHAR(25)
      ) AS developmental_spelling_3_,
      CAST(
        developmental_spelling_4_ AS VARCHAR(25)
      ) AS developmental_spelling_4_,
      CAST(
        developmental_spelling_5_ AS VARCHAR(25)
      ) AS developmental_spelling_5_,
      CAST(
        developmental_spelling_6_ AS VARCHAR(25)
      ) AS developmental_spelling_6_,
      CAST(
        developmental_spelling_7_ AS VARCHAR(25)
      ) AS developmental_spelling_7_,
      CAST(
        developmental_spelling_8_ AS VARCHAR(25)
      ) AS developmental_spelling_8_,
      CAST(
        developmental_spelling_9_ AS VARCHAR(25)
      ) AS developmental_spelling_9_,
      CAST(
        developmental_spelling_complex_blend_10_ AS VARCHAR(25)
      ) AS developmental_spelling_complex_blend_10_,
      CAST(
        developmental_spelling_complex_blend_8_ AS VARCHAR(25)
      ) AS developmental_spelling_complex_blend_8_,
      CAST(
        developmental_spelling_complex_blend_9_ AS VARCHAR(25)
      ) AS developmental_spelling_complex_blend_9_,
      CAST(
        developmental_spelling_doubling_at_syllable_juncture_11_ AS VARCHAR(25)
      ) AS developmental_spelling_doubling_at_syllable_juncture_11_,
      CAST(
        developmental_spelling_doubling_at_syllable_juncture_12_ AS VARCHAR(25)
      ) AS developmental_spelling_doubling_at_syllable_juncture_12_,
      CAST(
        developmental_spelling_ed_ing_endings_11_ AS VARCHAR(25)
      ) AS developmental_spelling_ed_ing_endings_11_,
      CAST(
        developmental_spelling_ed_ing_endings_12_ AS VARCHAR(25)
      ) AS developmental_spelling_ed_ing_endings_12_,
      CAST(
        developmental_spelling_final_sound_1_ AS VARCHAR(25)
      ) AS developmental_spelling_final_sound_1_,
      CAST(
        developmental_spelling_final_sound_2_ AS VARCHAR(25)
      ) AS developmental_spelling_final_sound_2_,
      CAST(
        developmental_spelling_final_sound_3_ AS VARCHAR(25)
      ) AS developmental_spelling_final_sound_3_,
      CAST(
        developmental_spelling_first_sound_1_ AS VARCHAR(25)
      ) AS developmental_spelling_first_sound_1_,
      CAST(
        developmental_spelling_first_sound_2_ AS VARCHAR(25)
      ) AS developmental_spelling_first_sound_2_,
      CAST(
        developmental_spelling_first_sound_3_ AS VARCHAR(25)
      ) AS developmental_spelling_first_sound_3_,
      CAST(
        developmental_spelling_initial_final_blend_digraph_5_ AS VARCHAR(25)
      ) AS developmental_spelling_initial_final_blend_digraph_5_,
      CAST(
        developmental_spelling_initial_final_blend_digraphs_4_ AS VARCHAR(25)
      ) AS developmental_spelling_initial_final_blend_digraphs_4_,
      CAST(
        developmental_spelling_long_vowel_2_syllable_words_11_ AS VARCHAR(25)
      ) AS developmental_spelling_long_vowel_2_syllable_words_11_,
      CAST(
        developmental_spelling_long_vowel_2_syllable_words_12_ AS VARCHAR(25)
      ) AS developmental_spelling_long_vowel_2_syllable_words_12_,
      CAST(
        developmental_spelling_long_vowel_pattern_10_ AS VARCHAR(25)
      ) AS developmental_spelling_long_vowel_pattern_10_,
      CAST(
        developmental_spelling_long_vowel_pattern_6_ AS VARCHAR(25)
      ) AS developmental_spelling_long_vowel_pattern_6_,
      CAST(
        developmental_spelling_long_vowel_pattern_8_ AS VARCHAR(25)
      ) AS developmental_spelling_long_vowel_pattern_8_,
      CAST(
        developmental_spelling_long_vowel_pattern_9_ AS VARCHAR(25)
      ) AS developmental_spelling_long_vowel_pattern_9_,
      CAST(
        developmental_spelling_r_controlled_2_syllable_words_11_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_2_syllable_words_11_,
      CAST(
        developmental_spelling_r_controlled_2_syllable_words_12_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_2_syllable_words_12_,
      CAST(
        developmental_spelling_r_controlled_vowel_10_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_vowel_10_,
      CAST(
        developmental_spelling_r_controlled_vowel_6_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_vowel_6_,
      CAST(
        developmental_spelling_r_controlled_vowel_7_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_vowel_7_,
      CAST(
        developmental_spelling_r_controlled_vowel_8_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_vowel_8_,
      CAST(
        developmental_spelling_r_controlled_vowel_9_ AS VARCHAR(25)
      ) AS developmental_spelling_r_controlled_vowel_9_,
      CAST(
        developmental_spelling_short_vowel_sound_1_ AS VARCHAR(25)
      ) AS developmental_spelling_short_vowel_sound_1_,
      CAST(
        developmental_spelling_short_vowel_sound_2_ AS VARCHAR(25)
      ) AS developmental_spelling_short_vowel_sound_2_,
      CAST(
        developmental_spelling_short_vowel_sound_3_ AS VARCHAR(25)
      ) AS developmental_spelling_short_vowel_sound_3_,
      CAST(
        developmental_spelling_short_vowel_sound_4_ AS VARCHAR(25)
      ) AS developmental_spelling_short_vowel_sound_4_,
      CAST(
        developmental_spelling_short_vowel_sound_5_ AS VARCHAR(25)
      ) AS developmental_spelling_short_vowel_sound_5_,
      CAST(
        developmental_spelling_v_c_e_long_vowel_pattern_7_ AS VARCHAR(25)
      ) AS developmental_spelling_v_c_e_long_vowel_pattern_7_,
      CAST(
        developmental_spelling_vowel_digraphs_10_ AS VARCHAR(25)
      ) AS developmental_spelling_vowel_digraphs_10_,
      CAST(
        developmental_spelling_vowel_digraphs_8_ AS VARCHAR(25)
      ) AS developmental_spelling_vowel_digraphs_8_,
      CAST(
        developmental_spelling_vowel_digraphs_9_ AS VARCHAR(25)
      ) AS developmental_spelling_vowel_digraphs_9_,
      CAST(
        f_overreliance_on_facts_for_the_text_10_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_10_,
      CAST(
        f_overreliance_on_facts_for_the_text_11_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_11_,
      CAST(
        f_overreliance_on_facts_for_the_text_12_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_12_,
      CAST(
        f_overreliance_on_facts_for_the_text_2_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_2_,
      CAST(
        f_overreliance_on_facts_for_the_text_3_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_3_,
      CAST(
        f_overreliance_on_facts_for_the_text_4_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_4_,
      CAST(
        f_overreliance_on_facts_for_the_text_5_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_5_,
      CAST(
        f_overreliance_on_facts_for_the_text_6_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_6_,
      CAST(
        f_overreliance_on_facts_for_the_text_7_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_7_,
      CAST(
        f_overreliance_on_facts_for_the_text_8_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_8_,
      CAST(
        f_overreliance_on_facts_for_the_text_9_ AS VARCHAR(25)
      ) AS f_overreliance_on_facts_for_the_text_9_,
      CAST(fluency_10_ AS VARCHAR(25)) AS fluency_10_,
      CAST(fluency_11_ AS VARCHAR(25)) AS fluency_11_,
      CAST(fluency_12_ AS VARCHAR(25)) AS fluency_12_,
      CAST(fluency_4_ AS VARCHAR(25)) AS fluency_4_,
      CAST(fluency_5_ AS VARCHAR(25)) AS fluency_5_,
      CAST(fluency_6_ AS VARCHAR(25)) AS fluency_6_,
      CAST(fluency_7_ AS VARCHAR(25)) AS fluency_7_,
      CAST(fluency_8_ AS VARCHAR(25)) AS fluency_8_,
      CAST(fluency_9_ AS VARCHAR(25)) AS fluency_9_,
      CAST(l_limited_10_ AS VARCHAR(25)) AS l_limited_10_,
      CAST(l_limited_11_ AS VARCHAR(25)) AS l_limited_11_,
      CAST(l_limited_12_ AS VARCHAR(25)) AS l_limited_12_,
      CAST(l_limited_2_ AS VARCHAR(25)) AS l_limited_2_,
      CAST(l_limited_3_ AS VARCHAR(25)) AS l_limited_3_,
      CAST(l_limited_4_ AS VARCHAR(25)) AS l_limited_4_,
      CAST(l_limited_5_ AS VARCHAR(25)) AS l_limited_5_,
      CAST(l_limited_6_ AS VARCHAR(25)) AS l_limited_6_,
      CAST(l_limited_7_ AS VARCHAR(25)) AS l_limited_7_,
      CAST(l_limited_8_ AS VARCHAR(25)) AS l_limited_8_,
      CAST(l_limited_9_ AS VARCHAR(25)) AS l_limited_9_,
      CAST(
        letter_name_identification_0_ AS VARCHAR(25)
      ) AS letter_name_identification_0_,
      CAST(
        letter_name_identification_1_ AS VARCHAR(25)
      ) AS letter_name_identification_1_,
      CAST(
        letter_name_identification_2_ AS VARCHAR(25)
      ) AS letter_name_identification_2_,
      CAST(
        letter_sound_identification_0_ AS VARCHAR(25)
      ) AS letter_sound_identification_0_,
      CAST(
        letter_sound_identification_1_ AS VARCHAR(25)
      ) AS letter_sound_identification_1_,
      CAST(
        letter_sound_identification_2_ AS VARCHAR(25)
      ) AS letter_sound_identification_2_,
      CAST(
        letter_sound_identification_3_ AS VARCHAR(25)
      ) AS letter_sound_identification_3_,
      CAST(meaning_10_ AS VARCHAR(25)) AS meaning_10_,
      CAST(meaning_11_ AS VARCHAR(25)) AS meaning_11_,
      CAST(meaning_12_ AS VARCHAR(25)) AS meaning_12_,
      CAST(meaning_3_ AS VARCHAR(25)) AS meaning_3_,
      CAST(meaning_4_ AS VARCHAR(25)) AS meaning_4_,
      CAST(meaning_5_ AS VARCHAR(25)) AS meaning_5_,
      CAST(meaning_6_ AS VARCHAR(25)) AS meaning_6_,
      CAST(meaning_7_ AS VARCHAR(25)) AS meaning_7_,
      CAST(meaning_8_ AS VARCHAR(25)) AS meaning_8_,
      CAST(meaning_9_ AS VARCHAR(25)) AS meaning_9_,
      CAST(
        name_assessment_0_ AS VARCHAR(25)
      ) AS name_assessment_0_,
      CAST(
        oral_comprehension_10_ AS VARCHAR(25)
      ) AS oral_comprehension_10_,
      CAST(
        oral_comprehension_11_ AS VARCHAR(25)
      ) AS oral_comprehension_11_,
      CAST(
        oral_comprehension_12_ AS VARCHAR(25)
      ) AS oral_comprehension_12_,
      CAST(
        oral_comprehension_6_ AS VARCHAR(25)
      ) AS oral_comprehension_6_,
      CAST(
        oral_comprehension_7_ AS VARCHAR(25)
      ) AS oral_comprehension_7_,
      CAST(
        oral_comprehension_9_ AS VARCHAR(25)
      ) AS oral_comprehension_9_,
      CAST(
        oral_comprehension_critical_thinking_10_ AS VARCHAR(25)
      ) AS oral_comprehension_critical_thinking_10_,
      CAST(
        oral_comprehension_critical_thinking_11_ AS VARCHAR(25)
      ) AS oral_comprehension_critical_thinking_11_,
      CAST(
        oral_comprehension_critical_thinking_12_ AS VARCHAR(25)
      ) AS oral_comprehension_critical_thinking_12_,
      CAST(
        oral_comprehension_critical_thinking_6_purple_only_ AS VARCHAR(25)
      ) AS oral_comprehension_critical_thinking_6_purple_only_,
      CAST(
        oral_comprehension_critical_thinking_7_purple_only_ AS VARCHAR(25)
      ) AS oral_comprehension_critical_thinking_7_purple_only_,
      CAST(
        oral_comprehension_critical_thinking_9_ AS VARCHAR(25)
      ) AS oral_comprehension_critical_thinking_9_,
      CAST(
        oral_comprehension_factual_10_yellow_only_ AS VARCHAR(25)
      ) AS oral_comprehension_factual_10_yellow_only_,
      CAST(
        oral_comprehension_factual_11_yellow_only_ AS VARCHAR(25)
      ) AS oral_comprehension_factual_11_yellow_only_,
      CAST(
        oral_comprehension_factual_12_ AS VARCHAR(25)
      ) AS oral_comprehension_factual_12_,
      CAST(
        oral_comprehension_factual_6_ AS VARCHAR(25)
      ) AS oral_comprehension_factual_6_,
      CAST(
        oral_comprehension_factual_7_ AS VARCHAR(25)
      ) AS oral_comprehension_factual_7_,
      CAST(
        oral_comprehension_factual_9_ AS VARCHAR(25)
      ) AS oral_comprehension_factual_9_,
      CAST(
        oral_comprehension_inferential_10_ AS VARCHAR(25)
      ) AS oral_comprehension_inferential_10_,
      CAST(
        oral_comprehension_inferential_11_ AS VARCHAR(25)
      ) AS oral_comprehension_inferential_11_,
      CAST(
        oral_comprehension_inferential_12_ AS VARCHAR(25)
      ) AS oral_comprehension_inferential_12_,
      CAST(
        oral_comprehension_inferential_6_yellow_only_ AS VARCHAR(25)
      ) AS oral_comprehension_inferential_6_yellow_only_,
      CAST(
        oral_comprehension_inferential_7_ AS VARCHAR(25)
      ) AS oral_comprehension_inferential_7_,
      CAST(
        oral_comprehension_inferential_9_ AS VARCHAR(25)
      ) AS oral_comprehension_inferential_9_,
      CAST(
        pe_personal_experience_10_ AS VARCHAR(25)
      ) AS pe_personal_experience_10_,
      CAST(
        pe_personal_experience_11_ AS VARCHAR(25)
      ) AS pe_personal_experience_11_,
      CAST(
        pe_personal_experience_12_ AS VARCHAR(25)
      ) AS pe_personal_experience_12_,
      CAST(
        pe_personal_experience_2_ AS VARCHAR(25)
      ) AS pe_personal_experience_2_,
      CAST(
        pe_personal_experience_3_ AS VARCHAR(25)
      ) AS pe_personal_experience_3_,
      CAST(
        pe_personal_experience_4_ AS VARCHAR(25)
      ) AS pe_personal_experience_4_,
      CAST(
        pe_personal_experience_5_ AS VARCHAR(25)
      ) AS pe_personal_experience_5_,
      CAST(
        pe_personal_experience_6_ AS VARCHAR(25)
      ) AS pe_personal_experience_6_,
      CAST(
        pe_personal_experience_7_ AS VARCHAR(25)
      ) AS pe_personal_experience_7_,
      CAST(
        pe_personal_experience_8_ AS VARCHAR(25)
      ) AS pe_personal_experience_8_,
      CAST(
        pe_personal_experience_9_ AS VARCHAR(25)
      ) AS pe_personal_experience_9_,
      CAST(
        phonemic_awareness_matching_first_sounds_1_ AS VARCHAR(25)
      ) AS phonemic_awareness_matching_first_sounds_1_,
      CAST(
        phonemic_awareness_rhyming_words_0_ AS VARCHAR(25)
      ) AS phonemic_awareness_rhyming_words_0_,
      CAST(
        phonemic_awareness_segmentation_2_ AS VARCHAR(25)
      ) AS phonemic_awareness_segmentation_2_,
      CAST(
        phonemic_awareness_segmentation_3_ AS VARCHAR(25)
      ) AS phonemic_awareness_segmentation_3_,
      CAST(
        q_answers_a_different_question_10_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_10_,
      CAST(
        q_answers_a_different_question_11_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_11_,
      CAST(
        q_answers_a_different_question_12_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_12_,
      CAST(
        q_answers_a_different_question_2_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_2_,
      CAST(
        q_answers_a_different_question_3_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_3_,
      CAST(
        q_answers_a_different_question_4_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_4_,
      CAST(
        q_answers_a_different_question_5_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_5_,
      CAST(
        q_answers_a_different_question_6_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_6_,
      CAST(
        q_answers_a_different_question_7_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_7_,
      CAST(
        q_answers_a_different_question_8_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_8_,
      CAST(
        q_answers_a_different_question_9_ AS VARCHAR(25)
      ) AS q_answers_a_different_question_9_,
      CAST(
        reading_accuracy_10_ AS VARCHAR(25)
      ) AS reading_accuracy_10_,
      CAST(
        reading_accuracy_11_ AS VARCHAR(25)
      ) AS reading_accuracy_11_,
      CAST(
        reading_accuracy_12_ AS VARCHAR(25)
      ) AS reading_accuracy_12_,
      CAST(
        reading_accuracy_2_ AS VARCHAR(25)
      ) AS reading_accuracy_2_,
      CAST(
        reading_accuracy_2_2_ AS VARCHAR(25)
      ) AS reading_accuracy_2_2_,
      CAST(
        reading_accuracy_3_ AS VARCHAR(25)
      ) AS reading_accuracy_3_,
      CAST(
        reading_accuracy_4_ AS VARCHAR(25)
      ) AS reading_accuracy_4_,
      CAST(
        reading_accuracy_5_ AS VARCHAR(25)
      ) AS reading_accuracy_5_,
      CAST(
        reading_accuracy_6_ AS VARCHAR(25)
      ) AS reading_accuracy_6_,
      CAST(
        reading_accuracy_7_ AS VARCHAR(25)
      ) AS reading_accuracy_7_,
      CAST(
        reading_accuracy_8_ AS VARCHAR(25)
      ) AS reading_accuracy_8_,
      CAST(
        reading_accuracy_9_ AS VARCHAR(25)
      ) AS reading_accuracy_9_,
      CAST(reading_rate_10_ AS VARCHAR(25)) AS reading_rate_10_,
      CAST(reading_rate_11_ AS VARCHAR(25)) AS reading_rate_11_,
      CAST(reading_rate_12_ AS VARCHAR(25)) AS reading_rate_12_,
      CAST(reading_rate_4_ AS VARCHAR(25)) AS reading_rate_4_,
      CAST(reading_rate_5_ AS VARCHAR(25)) AS reading_rate_5_,
      CAST(reading_rate_6_ AS VARCHAR(25)) AS reading_rate_6_,
      CAST(reading_rate_7_ AS VARCHAR(25)) AS reading_rate_7_,
      CAST(reading_rate_8_ AS VARCHAR(25)) AS reading_rate_8_,
      CAST(reading_rate_9_ AS VARCHAR(25)) AS reading_rate_9_,
      CAST(reading_record_1_ AS VARCHAR(25)) AS reading_record_1_,
      CAST(
        reading_record_holds_pattern_1_ AS VARCHAR(25)
      ) AS reading_record_holds_pattern_1_,
      CAST(
        reading_record_one_to_one_matching_1_ AS VARCHAR(25)
      ) AS reading_record_one_to_one_matching_1_,
      CAST(
        reading_record_understanding_1_ AS VARCHAR(25)
      ) AS reading_record_understanding_1_,
      CAST(retelling_10_ AS VARCHAR(25)) AS retelling_10_,
      CAST(retelling_11_ AS VARCHAR(25)) AS retelling_11_,
      CAST(retelling_12_ AS VARCHAR(25)) AS retelling_12_,
      CAST(retelling_8_ AS VARCHAR(25)) AS retelling_8_,
      CAST(retelling_9_ AS VARCHAR(25)) AS retelling_9_,
      CAST(
        silent_comprehension_6_ AS VARCHAR(25)
      ) AS silent_comprehension_6_,
      CAST(
        silent_comprehension_7_ AS VARCHAR(25)
      ) AS silent_comprehension_7_,
      CAST(
        silent_comprehension_critical_thinking_6_ AS VARCHAR(25)
      ) AS silent_comprehension_critical_thinking_6_,
      CAST(
        silent_comprehension_critical_thinking_7_ AS VARCHAR(25)
      ) AS silent_comprehension_critical_thinking_7_,
      CAST(
        silent_comprehension_factual_6_ AS VARCHAR(25)
      ) AS silent_comprehension_factual_6_,
      CAST(
        silent_comprehension_factual_7_ AS VARCHAR(25)
      ) AS silent_comprehension_factual_7_,
      CAST(
        silent_comprehension_inferential_6_ AS VARCHAR(25)
      ) AS silent_comprehension_inferential_6_,
      CAST(
        silent_comprehension_inferential_7_ AS VARCHAR(25)
      ) AS silent_comprehension_inferential_7_,
      CAST(syntax_10_ AS VARCHAR(25)) AS syntax_10_,
      CAST(syntax_11_ AS VARCHAR(25)) AS syntax_11_,
      CAST(syntax_12_ AS VARCHAR(25)) AS syntax_12_,
      CAST(syntax_3_ AS VARCHAR(25)) AS syntax_3_,
      CAST(syntax_4_ AS VARCHAR(25)) AS syntax_4_,
      CAST(syntax_5_ AS VARCHAR(25)) AS syntax_5_,
      CAST(syntax_6_ AS VARCHAR(25)) AS syntax_6_,
      CAST(syntax_7_ AS VARCHAR(25)) AS syntax_7_,
      CAST(syntax_8_ AS VARCHAR(25)) AS syntax_8_,
      CAST(syntax_9_ AS VARCHAR(25)) AS syntax_9_,
      CAST(
        total_vowel_attempts_3_ AS VARCHAR(25)
      ) AS total_vowel_attempts_3_,
      CAST(visual_10_ AS VARCHAR(25)) AS visual_10_,
      CAST(visual_11_ AS VARCHAR(25)) AS visual_11_,
      CAST(visual_12_ AS VARCHAR(25)) AS visual_12_,
      CAST(visual_3_ AS VARCHAR(25)) AS visual_3_,
      CAST(visual_4_ AS VARCHAR(25)) AS visual_4_,
      CAST(visual_5_ AS VARCHAR(25)) AS visual_5_,
      CAST(visual_6_ AS VARCHAR(25)) AS visual_6_,
      CAST(visual_7_ AS VARCHAR(25)) AS visual_7_,
      CAST(visual_8_ AS VARCHAR(25)) AS visual_8_,
      CAST(visual_9_ AS VARCHAR(25)) AS visual_9_,
      CAST(
        written_comprehension_10_ AS VARCHAR(25)
      ) AS written_comprehension_10_,
      CAST(
        written_comprehension_11_ AS VARCHAR(25)
      ) AS written_comprehension_11_,
      CAST(
        written_comprehension_12_ AS VARCHAR(25)
      ) AS written_comprehension_12_,
      CAST(
        written_comprehension_9_ AS VARCHAR(25)
      ) AS written_comprehension_9_,
      CAST(
        written_comprehension_critical_thinking_10_ AS VARCHAR(25)
      ) AS written_comprehension_critical_thinking_10_,
      CAST(
        written_comprehension_critical_thinking_11_ AS VARCHAR(25)
      ) AS written_comprehension_critical_thinking_11_,
      CAST(
        written_comprehension_critical_thinking_12_ AS VARCHAR(25)
      ) AS written_comprehension_critical_thinking_12_,
      CAST(
        written_comprehension_critical_thinking_9_yellow_only_ AS VARCHAR(25)
      ) AS written_comprehension_critical_thinking_9_yellow_only_,
      CAST(
        written_comprehension_factual_10_ AS VARCHAR(25)
      ) AS written_comprehension_factual_10_,
      CAST(
        written_comprehension_factual_11_ AS VARCHAR(25)
      ) AS written_comprehension_factual_11_,
      CAST(
        written_comprehension_factual_12_ AS VARCHAR(25)
      ) AS written_comprehension_factual_12_,
      CAST(
        written_comprehension_factual_9_ AS VARCHAR(25)
      ) AS written_comprehension_factual_9_,
      CAST(
        written_comprehension_inferential_10_ AS VARCHAR(25)
      ) AS written_comprehension_inferential_10_,
      CAST(
        written_comprehension_inferential_11_purple_only_ AS VARCHAR(25)
      ) AS written_comprehension_inferential_11_purple_only_,
      CAST(
        written_comprehension_inferential_12_ AS VARCHAR(25)
      ) AS written_comprehension_inferential_12_,
      CAST(
        written_comprehension_inferential_9_ AS VARCHAR(25)
      ) AS written_comprehension_inferential_9_
    FROM
      steptool.all_steps
    WHERE
      student_id IS NOT NULL
  ) AS sub UNPIVOT (
    score FOR field IN (
      c_confusion_10_,
      c_confusion_11_,
      c_confusion_12_,
      c_confusion_2_,
      c_confusion_3_,
      c_confusion_4_,
      c_confusion_5_,
      c_confusion_6_,
      c_confusion_7_,
      c_confusion_8_,
      c_confusion_9_,
      comprehension_conversation_2_,
      comprehension_conversation_3_,
      comprehension_conversation_4_,
      comprehension_conversation_5_,
      comprehension_conversation_8_,
      comprehension_conversation_critical_thinking_3_,
      comprehension_conversation_critical_thinking_4_,
      comprehension_conversation_critical_thinking_5_,
      comprehension_conversation_critical_thinking_8_,
      comprehension_conversation_factual_2_,
      comprehension_conversation_factual_3_,
      comprehension_conversation_factual_4_,
      comprehension_conversation_factual_5_,
      comprehension_conversation_factual_8_,
      comprehension_conversation_inferential_2_,
      comprehension_conversation_inferential_3_,
      comprehension_conversation_inferential_4_,
      comprehension_conversation_inferential_5_,
      comprehension_conversation_inferential_8_,
      comprehension_conversation_other_2_,
      concepts_about_print_0_,
      concepts_about_print_1_,
      concepts_about_print_one_to_one_matching_0_,
      concepts_about_print_one_to_one_matching_1_,
      concepts_about_print_orientation_0_,
      concepts_about_print_orientation_1_,
      concepts_about_print_sense_of_letter_vs_word_0_,
      concepts_about_print_sense_of_letter_vs_word_1_,
      developmental_spelling_1_,
      developmental_spelling_10_,
      developmental_spelling_11_,
      developmental_spelling_12_,
      developmental_spelling_2_,
      developmental_spelling_3_,
      developmental_spelling_4_,
      developmental_spelling_5_,
      developmental_spelling_6_,
      developmental_spelling_7_,
      developmental_spelling_8_,
      developmental_spelling_9_,
      developmental_spelling_complex_blend_10_,
      developmental_spelling_complex_blend_8_,
      developmental_spelling_complex_blend_9_,
      developmental_spelling_doubling_at_syllable_juncture_11_,
      developmental_spelling_doubling_at_syllable_juncture_12_,
      developmental_spelling_ed_ing_endings_11_,
      developmental_spelling_ed_ing_endings_12_,
      developmental_spelling_final_sound_1_,
      developmental_spelling_final_sound_2_,
      developmental_spelling_final_sound_3_,
      developmental_spelling_first_sound_1_,
      developmental_spelling_first_sound_2_,
      developmental_spelling_first_sound_3_,
      developmental_spelling_initial_final_blend_digraph_5_,
      developmental_spelling_initial_final_blend_digraphs_4_,
      developmental_spelling_long_vowel_2_syllable_words_11_,
      developmental_spelling_long_vowel_2_syllable_words_12_,
      developmental_spelling_long_vowel_pattern_10_,
      developmental_spelling_long_vowel_pattern_6_,
      developmental_spelling_long_vowel_pattern_8_,
      developmental_spelling_long_vowel_pattern_9_,
      developmental_spelling_r_controlled_2_syllable_words_11_,
      developmental_spelling_r_controlled_2_syllable_words_12_,
      developmental_spelling_r_controlled_vowel_10_,
      developmental_spelling_r_controlled_vowel_6_,
      developmental_spelling_r_controlled_vowel_7_,
      developmental_spelling_r_controlled_vowel_8_,
      developmental_spelling_r_controlled_vowel_9_,
      developmental_spelling_short_vowel_sound_1_,
      developmental_spelling_short_vowel_sound_2_,
      developmental_spelling_short_vowel_sound_3_,
      developmental_spelling_short_vowel_sound_4_,
      developmental_spelling_short_vowel_sound_5_,
      developmental_spelling_v_c_e_long_vowel_pattern_7_,
      developmental_spelling_vowel_digraphs_10_,
      developmental_spelling_vowel_digraphs_8_,
      developmental_spelling_vowel_digraphs_9_,
      f_overreliance_on_facts_for_the_text_10_,
      f_overreliance_on_facts_for_the_text_11_,
      f_overreliance_on_facts_for_the_text_12_,
      f_overreliance_on_facts_for_the_text_2_,
      f_overreliance_on_facts_for_the_text_3_,
      f_overreliance_on_facts_for_the_text_4_,
      f_overreliance_on_facts_for_the_text_5_,
      f_overreliance_on_facts_for_the_text_6_,
      f_overreliance_on_facts_for_the_text_7_,
      f_overreliance_on_facts_for_the_text_8_,
      f_overreliance_on_facts_for_the_text_9_,
      fluency_10_,
      fluency_11_,
      fluency_12_,
      fluency_4_,
      fluency_5_,
      fluency_6_,
      fluency_7_,
      fluency_8_,
      fluency_9_,
      l_limited_10_,
      l_limited_11_,
      l_limited_12_,
      l_limited_2_,
      l_limited_3_,
      l_limited_4_,
      l_limited_5_,
      l_limited_6_,
      l_limited_7_,
      l_limited_8_,
      l_limited_9_,
      letter_name_identification_0_,
      letter_name_identification_1_,
      letter_name_identification_2_,
      letter_sound_identification_0_,
      letter_sound_identification_1_,
      letter_sound_identification_2_,
      letter_sound_identification_3_,
      meaning_10_,
      meaning_11_,
      meaning_12_,
      meaning_3_,
      meaning_4_,
      meaning_5_,
      meaning_6_,
      meaning_7_,
      meaning_8_,
      meaning_9_,
      name_assessment_0_,
      oral_comprehension_10_,
      oral_comprehension_11_,
      oral_comprehension_12_,
      oral_comprehension_6_,
      oral_comprehension_7_,
      oral_comprehension_9_,
      oral_comprehension_critical_thinking_10_,
      oral_comprehension_critical_thinking_11_,
      oral_comprehension_critical_thinking_12_,
      oral_comprehension_critical_thinking_6_purple_only_,
      oral_comprehension_critical_thinking_7_purple_only_,
      oral_comprehension_critical_thinking_9_,
      oral_comprehension_factual_10_yellow_only_,
      oral_comprehension_factual_11_yellow_only_,
      oral_comprehension_factual_12_,
      oral_comprehension_factual_6_,
      oral_comprehension_factual_7_,
      oral_comprehension_factual_9_,
      oral_comprehension_inferential_10_,
      oral_comprehension_inferential_11_,
      oral_comprehension_inferential_12_,
      oral_comprehension_inferential_6_yellow_only_,
      oral_comprehension_inferential_7_,
      oral_comprehension_inferential_9_,
      pe_personal_experience_10_,
      pe_personal_experience_11_,
      pe_personal_experience_12_,
      pe_personal_experience_2_,
      pe_personal_experience_3_,
      pe_personal_experience_4_,
      pe_personal_experience_5_,
      pe_personal_experience_6_,
      pe_personal_experience_7_,
      pe_personal_experience_8_,
      pe_personal_experience_9_,
      phonemic_awareness_matching_first_sounds_1_,
      phonemic_awareness_rhyming_words_0_,
      phonemic_awareness_segmentation_2_,
      phonemic_awareness_segmentation_3_,
      q_answers_a_different_question_10_,
      q_answers_a_different_question_11_,
      q_answers_a_different_question_12_,
      q_answers_a_different_question_2_,
      q_answers_a_different_question_3_,
      q_answers_a_different_question_4_,
      q_answers_a_different_question_5_,
      q_answers_a_different_question_6_,
      q_answers_a_different_question_7_,
      q_answers_a_different_question_8_,
      q_answers_a_different_question_9_,
      reading_accuracy_10_,
      reading_accuracy_11_,
      reading_accuracy_12_,
      reading_accuracy_2_,
      reading_accuracy_2_2_,
      reading_accuracy_3_,
      reading_accuracy_4_,
      reading_accuracy_5_,
      reading_accuracy_6_,
      reading_accuracy_7_,
      reading_accuracy_8_,
      reading_accuracy_9_,
      reading_rate_10_,
      reading_rate_11_,
      reading_rate_12_,
      reading_rate_4_,
      reading_rate_5_,
      reading_rate_6_,
      reading_rate_7_,
      reading_rate_8_,
      reading_rate_9_,
      reading_record_1_,
      reading_record_holds_pattern_1_,
      reading_record_one_to_one_matching_1_,
      reading_record_understanding_1_,
      retelling_10_,
      retelling_11_,
      retelling_12_,
      retelling_8_,
      retelling_9_,
      silent_comprehension_6_,
      silent_comprehension_7_,
      silent_comprehension_critical_thinking_6_,
      silent_comprehension_critical_thinking_7_,
      silent_comprehension_factual_6_,
      silent_comprehension_factual_7_,
      silent_comprehension_inferential_6_,
      silent_comprehension_inferential_7_,
      syntax_10_,
      syntax_11_,
      syntax_12_,
      syntax_3_,
      syntax_4_,
      syntax_5_,
      syntax_6_,
      syntax_7_,
      syntax_8_,
      syntax_9_,
      total_vowel_attempts_3_,
      visual_10_,
      visual_11_,
      visual_12_,
      visual_3_,
      visual_4_,
      visual_5_,
      visual_6_,
      visual_7_,
      visual_8_,
      visual_9_,
      written_comprehension_10_,
      written_comprehension_11_,
      written_comprehension_12_,
      written_comprehension_9_,
      written_comprehension_critical_thinking_10_,
      written_comprehension_critical_thinking_11_,
      written_comprehension_critical_thinking_12_,
      written_comprehension_critical_thinking_9_yellow_only_,
      written_comprehension_factual_10_,
      written_comprehension_factual_11_,
      written_comprehension_factual_12_,
      written_comprehension_factual_9_,
      written_comprehension_inferential_10_,
      written_comprehension_inferential_11_purple_only_,
      written_comprehension_inferential_12_,
      written_comprehension_inferential_9_
    )
  ) AS u
