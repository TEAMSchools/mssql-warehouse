USE gabby
GO

CREATE OR ALTER VIEW steptool.component_scores AS

SELECT unique_id
      ,student_id
      ,step AS lvl_num
      ,field
      ,score
      ,CASE WHEN step = 0 THEN 'Pre' ELSE CONVERT(NVARCHAR,step) END AS read_lvl      
      ,CASE               
        WHEN CONVERT(INT,step) = 0 THEN 3280
        WHEN CONVERT(INT,step) = 1 THEN 3281
        WHEN CONVERT(INT,step) = 2 THEN 3282
        WHEN CONVERT(INT,step) = 3 THEN 3380
        WHEN CONVERT(INT,step) = 4 THEN 3397
        WHEN CONVERT(INT,step) = 5 THEN 3411
        WHEN CONVERT(INT,step) = 6 THEN 3425
        WHEN CONVERT(INT,step) = 7 THEN 3441
        WHEN CONVERT(INT,step) = 8 THEN 3458
        WHEN CONVERT(INT,step) = 9 THEN 3474
        WHEN CONVERT(INT,step) = 10 THEN 3493
        WHEN CONVERT(INT,step) = 11 THEN 3511
        WHEN CONVERT(INT,step) = 12 THEN 3527
       END AS testid            
      ,CASE 
        WHEN passed = 1 THEN 'Achieved'
        WHEN passed = 0 THEN 'Did Not Achieve'
       END AS status
FROM 
    (
     SELECT CONCAT('UC', gabby.utilities.DATE_TO_SY(date), [_line]) AS unique_id
           ,CONVERT(INT,CONVERT(FLOAT,student_id)) AS student_id
           ,step      
           ,passed              
             
           ,CONVERT(NVARCHAR(8),c_confusion_10_) AS c_confusion_10_
           ,CONVERT(NVARCHAR(8),c_confusion_11_) AS c_confusion_11_
           ,CONVERT(NVARCHAR(8),c_confusion_12_) AS c_confusion_12_
           ,CONVERT(NVARCHAR(8),c_confusion_2_) AS c_confusion_2_
           ,CONVERT(NVARCHAR(8),c_confusion_3_) AS c_confusion_3_
           ,CONVERT(NVARCHAR(8),c_confusion_4_) AS c_confusion_4_
           ,CONVERT(NVARCHAR(8),c_confusion_5_) AS c_confusion_5_
           ,CONVERT(NVARCHAR(8),c_confusion_6_) AS c_confusion_6_
           ,CONVERT(NVARCHAR(8),c_confusion_7_) AS c_confusion_7_
           ,CONVERT(NVARCHAR(8),c_confusion_8_) AS c_confusion_8_
           ,CONVERT(NVARCHAR(8),c_confusion_9_) AS c_confusion_9_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_2_) AS comprehension_conversation_2_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_3_) AS comprehension_conversation_3_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_4_) AS comprehension_conversation_4_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_5_) AS comprehension_conversation_5_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_8_) AS comprehension_conversation_8_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_critical_thinking_3_) AS comprehension_conversation_critical_thinking_3_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_critical_thinking_4_) AS comprehension_conversation_critical_thinking_4_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_critical_thinking_5_) AS comprehension_conversation_critical_thinking_5_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_critical_thinking_8_) AS comprehension_conversation_critical_thinking_8_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_factual_2_) AS comprehension_conversation_factual_2_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_factual_3_) AS comprehension_conversation_factual_3_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_factual_4_) AS comprehension_conversation_factual_4_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_factual_5_) AS comprehension_conversation_factual_5_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_factual_8_) AS comprehension_conversation_factual_8_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_inferential_2_) AS comprehension_conversation_inferential_2_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_inferential_3_) AS comprehension_conversation_inferential_3_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_inferential_4_) AS comprehension_conversation_inferential_4_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_inferential_5_) AS comprehension_conversation_inferential_5_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_inferential_8_) AS comprehension_conversation_inferential_8_
           ,CONVERT(NVARCHAR(8),comprehension_conversation_other_2_) AS comprehension_conversation_other_2_
           ,CONVERT(NVARCHAR(8),concepts_about_print_0_) AS concepts_about_print_0_
           ,CONVERT(NVARCHAR(8),concepts_about_print_1_) AS concepts_about_print_1_
           ,CONVERT(NVARCHAR(8),concepts_about_print_one_to_one_matching_0_) AS concepts_about_print_one_to_one_matching_0_
           ,CONVERT(NVARCHAR(8),concepts_about_print_one_to_one_matching_1_) AS concepts_about_print_one_to_one_matching_1_
           ,CONVERT(NVARCHAR(8),concepts_about_print_orientation_0_) AS concepts_about_print_orientation_0_
           ,CONVERT(NVARCHAR(8),concepts_about_print_orientation_1_) AS concepts_about_print_orientation_1_
           ,CONVERT(NVARCHAR(8),concepts_about_print_sense_of_letter_vs_word_0_) AS concepts_about_print_sense_of_letter_vs_word_0_
           ,CONVERT(NVARCHAR(8),concepts_about_print_sense_of_letter_vs_word_1_) AS concepts_about_print_sense_of_letter_vs_word_1_
           ,CONVERT(NVARCHAR(8),developmental_spelling_1_) AS developmental_spelling_1_
           ,CONVERT(NVARCHAR(8),developmental_spelling_10_) AS developmental_spelling_10_
           ,CONVERT(NVARCHAR(8),developmental_spelling_11_) AS developmental_spelling_11_
           ,CONVERT(NVARCHAR(8),developmental_spelling_12_) AS developmental_spelling_12_
           ,CONVERT(NVARCHAR(8),developmental_spelling_2_) AS developmental_spelling_2_
           ,CONVERT(NVARCHAR(8),developmental_spelling_3_) AS developmental_spelling_3_
           ,CONVERT(NVARCHAR(8),developmental_spelling_4_) AS developmental_spelling_4_
           ,CONVERT(NVARCHAR(8),developmental_spelling_5_) AS developmental_spelling_5_
           ,CONVERT(NVARCHAR(8),developmental_spelling_6_) AS developmental_spelling_6_
           ,CONVERT(NVARCHAR(8),developmental_spelling_7_) AS developmental_spelling_7_
           ,CONVERT(NVARCHAR(8),developmental_spelling_8_) AS developmental_spelling_8_
           ,CONVERT(NVARCHAR(8),developmental_spelling_9_) AS developmental_spelling_9_
           ,CONVERT(NVARCHAR(8),developmental_spelling_complex_blend_10_) AS developmental_spelling_complex_blend_10_
           ,CONVERT(NVARCHAR(8),developmental_spelling_complex_blend_8_) AS developmental_spelling_complex_blend_8_
           ,CONVERT(NVARCHAR(8),developmental_spelling_complex_blend_9_) AS developmental_spelling_complex_blend_9_
           ,CONVERT(NVARCHAR(8),developmental_spelling_doubling_at_syllable_juncture_11_) AS developmental_spelling_doubling_at_syllable_juncture_11_
           ,CONVERT(NVARCHAR(8),developmental_spelling_doubling_at_syllable_juncture_12_) AS developmental_spelling_doubling_at_syllable_juncture_12_
           ,CONVERT(NVARCHAR(8),developmental_spelling_ed_ing_endings_11_) AS developmental_spelling_ed_ing_endings_11_
           ,CONVERT(NVARCHAR(8),developmental_spelling_ed_ing_endings_12_) AS developmental_spelling_ed_ing_endings_12_
           ,CONVERT(NVARCHAR(8),developmental_spelling_final_sound_1_) AS developmental_spelling_final_sound_1_
           ,CONVERT(NVARCHAR(8),developmental_spelling_final_sound_2_) AS developmental_spelling_final_sound_2_
           ,CONVERT(NVARCHAR(8),developmental_spelling_final_sound_3_) AS developmental_spelling_final_sound_3_
           ,CONVERT(NVARCHAR(8),developmental_spelling_first_sound_1_) AS developmental_spelling_first_sound_1_
           ,CONVERT(NVARCHAR(8),developmental_spelling_first_sound_2_) AS developmental_spelling_first_sound_2_
           ,CONVERT(NVARCHAR(8),developmental_spelling_first_sound_3_) AS developmental_spelling_first_sound_3_
           ,CONVERT(NVARCHAR(8),developmental_spelling_initial_final_blend_digraph_5_) AS developmental_spelling_initial_final_blend_digraph_5_
           ,CONVERT(NVARCHAR(8),developmental_spelling_initial_final_blend_digraphs_4_) AS developmental_spelling_initial_final_blend_digraphs_4_
           ,CONVERT(NVARCHAR(8),developmental_spelling_long_vowel_2_syllable_words_11_) AS developmental_spelling_long_vowel_2_syllable_words_11_
           ,CONVERT(NVARCHAR(8),developmental_spelling_long_vowel_2_syllable_words_12_) AS developmental_spelling_long_vowel_2_syllable_words_12_
           ,CONVERT(NVARCHAR(8),developmental_spelling_long_vowel_pattern_10_) AS developmental_spelling_long_vowel_pattern_10_
           ,CONVERT(NVARCHAR(8),developmental_spelling_long_vowel_pattern_6_) AS developmental_spelling_long_vowel_pattern_6_
           ,CONVERT(NVARCHAR(8),developmental_spelling_long_vowel_pattern_8_) AS developmental_spelling_long_vowel_pattern_8_
           ,CONVERT(NVARCHAR(8),developmental_spelling_long_vowel_pattern_9_) AS developmental_spelling_long_vowel_pattern_9_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_2_syllable_words_11_) AS developmental_spelling_r_controlled_2_syllable_words_11_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_2_syllable_words_12_) AS developmental_spelling_r_controlled_2_syllable_words_12_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_vowel_10_) AS developmental_spelling_r_controlled_vowel_10_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_vowel_6_) AS developmental_spelling_r_controlled_vowel_6_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_vowel_7_) AS developmental_spelling_r_controlled_vowel_7_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_vowel_8_) AS developmental_spelling_r_controlled_vowel_8_
           ,CONVERT(NVARCHAR(8),developmental_spelling_r_controlled_vowel_9_) AS developmental_spelling_r_controlled_vowel_9_
           ,CONVERT(NVARCHAR(8),developmental_spelling_short_vowel_sound_1_) AS developmental_spelling_short_vowel_sound_1_
           ,CONVERT(NVARCHAR(8),developmental_spelling_short_vowel_sound_2_) AS developmental_spelling_short_vowel_sound_2_
           ,CONVERT(NVARCHAR(8),developmental_spelling_short_vowel_sound_3_) AS developmental_spelling_short_vowel_sound_3_
           ,CONVERT(NVARCHAR(8),developmental_spelling_short_vowel_sound_4_) AS developmental_spelling_short_vowel_sound_4_
           ,CONVERT(NVARCHAR(8),developmental_spelling_short_vowel_sound_5_) AS developmental_spelling_short_vowel_sound_5_
           ,CONVERT(NVARCHAR(8),developmental_spelling_v_c_e_long_vowel_pattern_7_) AS developmental_spelling_v_c_e_long_vowel_pattern_7_
           ,CONVERT(NVARCHAR(8),developmental_spelling_vowel_digraphs_10_) AS developmental_spelling_vowel_digraphs_10_
           ,CONVERT(NVARCHAR(8),developmental_spelling_vowel_digraphs_8_) AS developmental_spelling_vowel_digraphs_8_
           ,CONVERT(NVARCHAR(8),developmental_spelling_vowel_digraphs_9_) AS developmental_spelling_vowel_digraphs_9_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_10_) AS f_overreliance_on_facts_for_the_text_10_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_11_) AS f_overreliance_on_facts_for_the_text_11_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_12_) AS f_overreliance_on_facts_for_the_text_12_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_2_) AS f_overreliance_on_facts_for_the_text_2_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_3_) AS f_overreliance_on_facts_for_the_text_3_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_4_) AS f_overreliance_on_facts_for_the_text_4_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_5_) AS f_overreliance_on_facts_for_the_text_5_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_6_) AS f_overreliance_on_facts_for_the_text_6_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_7_) AS f_overreliance_on_facts_for_the_text_7_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_8_) AS f_overreliance_on_facts_for_the_text_8_
           ,CONVERT(NVARCHAR(8),f_overreliance_on_facts_for_the_text_9_) AS f_overreliance_on_facts_for_the_text_9_
           ,CONVERT(NVARCHAR(8),fluency_10_) AS fluency_10_
           ,CONVERT(NVARCHAR(8),fluency_11_) AS fluency_11_
           ,CONVERT(NVARCHAR(8),fluency_12_) AS fluency_12_
           ,CONVERT(NVARCHAR(8),fluency_4_) AS fluency_4_
           ,CONVERT(NVARCHAR(8),fluency_5_) AS fluency_5_
           ,CONVERT(NVARCHAR(8),fluency_6_) AS fluency_6_
           ,CONVERT(NVARCHAR(8),fluency_7_) AS fluency_7_
           ,CONVERT(NVARCHAR(8),fluency_8_) AS fluency_8_
           ,CONVERT(NVARCHAR(8),fluency_9_) AS fluency_9_
           ,CONVERT(NVARCHAR(8),l_limited_10_) AS l_limited_10_
           ,CONVERT(NVARCHAR(8),l_limited_11_) AS l_limited_11_
           ,CONVERT(NVARCHAR(8),l_limited_12_) AS l_limited_12_
           ,CONVERT(NVARCHAR(8),l_limited_2_) AS l_limited_2_
           ,CONVERT(NVARCHAR(8),l_limited_3_) AS l_limited_3_
           ,CONVERT(NVARCHAR(8),l_limited_4_) AS l_limited_4_
           ,CONVERT(NVARCHAR(8),l_limited_5_) AS l_limited_5_
           ,CONVERT(NVARCHAR(8),l_limited_6_) AS l_limited_6_
           ,CONVERT(NVARCHAR(8),l_limited_7_) AS l_limited_7_
           ,CONVERT(NVARCHAR(8),l_limited_8_) AS l_limited_8_
           ,CONVERT(NVARCHAR(8),l_limited_9_) AS l_limited_9_
           ,CONVERT(NVARCHAR(8),letter_name_identification_0_) AS letter_name_identification_0_
           ,CONVERT(NVARCHAR(8),letter_name_identification_1_) AS letter_name_identification_1_
           ,CONVERT(NVARCHAR(8),letter_name_identification_2_) AS letter_name_identification_2_
           ,CONVERT(NVARCHAR(8),letter_sound_identification_0_) AS letter_sound_identification_0_
           ,CONVERT(NVARCHAR(8),letter_sound_identification_1_) AS letter_sound_identification_1_
           ,CONVERT(NVARCHAR(8),letter_sound_identification_2_) AS letter_sound_identification_2_
           ,CONVERT(NVARCHAR(8),letter_sound_identification_3_) AS letter_sound_identification_3_
           ,CONVERT(NVARCHAR(8),meaning_10_) AS meaning_10_
           ,CONVERT(NVARCHAR(8),meaning_11_) AS meaning_11_
           ,CONVERT(NVARCHAR(8),meaning_12_) AS meaning_12_
           ,CONVERT(NVARCHAR(8),meaning_3_) AS meaning_3_
           ,CONVERT(NVARCHAR(8),meaning_4_) AS meaning_4_
           ,CONVERT(NVARCHAR(8),meaning_5_) AS meaning_5_
           ,CONVERT(NVARCHAR(8),meaning_6_) AS meaning_6_
           ,CONVERT(NVARCHAR(8),meaning_7_) AS meaning_7_
           ,CONVERT(NVARCHAR(8),meaning_8_) AS meaning_8_
           ,CONVERT(NVARCHAR(8),meaning_9_) AS meaning_9_
           ,CONVERT(NVARCHAR(8),name_assessment_0_) AS name_assessment_0_
           ,CONVERT(NVARCHAR(8),oral_comprehension_10_) AS oral_comprehension_10_
           ,CONVERT(NVARCHAR(8),oral_comprehension_11_) AS oral_comprehension_11_
           ,CONVERT(NVARCHAR(8),oral_comprehension_12_) AS oral_comprehension_12_
           ,CONVERT(NVARCHAR(8),oral_comprehension_6_) AS oral_comprehension_6_
           ,CONVERT(NVARCHAR(8),oral_comprehension_7_) AS oral_comprehension_7_
           ,CONVERT(NVARCHAR(8),oral_comprehension_9_) AS oral_comprehension_9_
           ,CONVERT(NVARCHAR(8),oral_comprehension_critical_thinking_10_) AS oral_comprehension_critical_thinking_10_
           ,CONVERT(NVARCHAR(8),oral_comprehension_critical_thinking_11_) AS oral_comprehension_critical_thinking_11_
           ,CONVERT(NVARCHAR(8),oral_comprehension_critical_thinking_12_) AS oral_comprehension_critical_thinking_12_
           ,CONVERT(NVARCHAR(8),oral_comprehension_critical_thinking_6_purple_only_) AS oral_comprehension_critical_thinking_6_purple_only_
           ,CONVERT(NVARCHAR(8),oral_comprehension_critical_thinking_7_purple_only_) AS oral_comprehension_critical_thinking_7_purple_only_
           ,CONVERT(NVARCHAR(8),oral_comprehension_critical_thinking_9_) AS oral_comprehension_critical_thinking_9_
           ,CONVERT(NVARCHAR(8),oral_comprehension_factual_10_yellow_only_) AS oral_comprehension_factual_10_yellow_only_
           ,CONVERT(NVARCHAR(8),oral_comprehension_factual_11_yellow_only_) AS oral_comprehension_factual_11_yellow_only_
           ,CONVERT(NVARCHAR(8),oral_comprehension_factual_12_) AS oral_comprehension_factual_12_
           ,CONVERT(NVARCHAR(8),oral_comprehension_factual_6_) AS oral_comprehension_factual_6_
           ,CONVERT(NVARCHAR(8),oral_comprehension_factual_7_) AS oral_comprehension_factual_7_
           ,CONVERT(NVARCHAR(8),oral_comprehension_factual_9_) AS oral_comprehension_factual_9_
           ,CONVERT(NVARCHAR(8),oral_comprehension_inferential_10_) AS oral_comprehension_inferential_10_
           ,CONVERT(NVARCHAR(8),oral_comprehension_inferential_11_) AS oral_comprehension_inferential_11_
           ,CONVERT(NVARCHAR(8),oral_comprehension_inferential_12_) AS oral_comprehension_inferential_12_
           ,CONVERT(NVARCHAR(8),oral_comprehension_inferential_6_yellow_only_) AS oral_comprehension_inferential_6_yellow_only_
           ,CONVERT(NVARCHAR(8),oral_comprehension_inferential_7_) AS oral_comprehension_inferential_7_
           ,CONVERT(NVARCHAR(8),oral_comprehension_inferential_9_) AS oral_comprehension_inferential_9_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_10_) AS pe_personal_experience_10_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_11_) AS pe_personal_experience_11_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_12_) AS pe_personal_experience_12_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_2_) AS pe_personal_experience_2_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_3_) AS pe_personal_experience_3_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_4_) AS pe_personal_experience_4_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_5_) AS pe_personal_experience_5_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_6_) AS pe_personal_experience_6_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_7_) AS pe_personal_experience_7_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_8_) AS pe_personal_experience_8_
           ,CONVERT(NVARCHAR(8),pe_personal_experience_9_) AS pe_personal_experience_9_
           ,CONVERT(NVARCHAR(8),phonemic_awareness_matching_first_sounds_1_) AS phonemic_awareness_matching_first_sounds_1_
           ,CONVERT(NVARCHAR(8),phonemic_awareness_rhyming_words_0_) AS phonemic_awareness_rhyming_words_0_
           ,CONVERT(NVARCHAR(8),phonemic_awareness_segmentation_2_) AS phonemic_awareness_segmentation_2_
           ,CONVERT(NVARCHAR(8),phonemic_awareness_segmentation_3_) AS phonemic_awareness_segmentation_3_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_10_) AS q_answers_a_different_question_10_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_11_) AS q_answers_a_different_question_11_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_12_) AS q_answers_a_different_question_12_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_2_) AS q_answers_a_different_question_2_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_3_) AS q_answers_a_different_question_3_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_4_) AS q_answers_a_different_question_4_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_5_) AS q_answers_a_different_question_5_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_6_) AS q_answers_a_different_question_6_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_7_) AS q_answers_a_different_question_7_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_8_) AS q_answers_a_different_question_8_
           ,CONVERT(NVARCHAR(8),q_answers_a_different_question_9_) AS q_answers_a_different_question_9_
           ,CONVERT(NVARCHAR(8),reading_accuracy_10_) AS reading_accuracy_10_
           ,CONVERT(NVARCHAR(8),reading_accuracy_11_) AS reading_accuracy_11_
           ,CONVERT(NVARCHAR(8),reading_accuracy_12_) AS reading_accuracy_12_
           ,CONVERT(NVARCHAR(8),reading_accuracy_2_) AS reading_accuracy_2_
           ,CONVERT(NVARCHAR(8),reading_accuracy_2_2_) AS reading_accuracy_2_2_
           ,CONVERT(NVARCHAR(8),reading_accuracy_3_) AS reading_accuracy_3_
           ,CONVERT(NVARCHAR(8),reading_accuracy_4_) AS reading_accuracy_4_
           ,CONVERT(NVARCHAR(8),reading_accuracy_5_) AS reading_accuracy_5_
           ,CONVERT(NVARCHAR(8),reading_accuracy_6_) AS reading_accuracy_6_
           ,CONVERT(NVARCHAR(8),reading_accuracy_7_) AS reading_accuracy_7_
           ,CONVERT(NVARCHAR(8),reading_accuracy_8_) AS reading_accuracy_8_
           ,CONVERT(NVARCHAR(8),reading_accuracy_9_) AS reading_accuracy_9_
           ,CONVERT(NVARCHAR(8),reading_rate_10_) AS reading_rate_10_
           ,CONVERT(NVARCHAR(8),reading_rate_11_) AS reading_rate_11_
           ,CONVERT(NVARCHAR(8),reading_rate_12_) AS reading_rate_12_
           ,CONVERT(NVARCHAR(8),reading_rate_4_) AS reading_rate_4_
           ,CONVERT(NVARCHAR(8),reading_rate_5_) AS reading_rate_5_
           ,CONVERT(NVARCHAR(8),reading_rate_6_) AS reading_rate_6_
           ,CONVERT(NVARCHAR(8),reading_rate_7_) AS reading_rate_7_
           ,CONVERT(NVARCHAR(8),reading_rate_8_) AS reading_rate_8_
           ,CONVERT(NVARCHAR(8),reading_rate_9_) AS reading_rate_9_
           ,CONVERT(NVARCHAR(8),reading_record_1_) AS reading_record_1_
           ,CONVERT(NVARCHAR(8),reading_record_holds_pattern_1_) AS reading_record_holds_pattern_1_
           ,CONVERT(NVARCHAR(8),reading_record_one_to_one_matching_1_) AS reading_record_one_to_one_matching_1_
           ,CONVERT(NVARCHAR(8),reading_record_understanding_1_) AS reading_record_understanding_1_
           ,CONVERT(NVARCHAR(8),retelling_10_) AS retelling_10_
           ,CONVERT(NVARCHAR(8),retelling_11_) AS retelling_11_
           ,CONVERT(NVARCHAR(8),retelling_12_) AS retelling_12_
           ,CONVERT(NVARCHAR(8),retelling_8_) AS retelling_8_
           ,CONVERT(NVARCHAR(8),retelling_9_) AS retelling_9_
           ,CONVERT(NVARCHAR(8),silent_comprehension_6_) AS silent_comprehension_6_
           ,CONVERT(NVARCHAR(8),silent_comprehension_7_) AS silent_comprehension_7_
           ,CONVERT(NVARCHAR(8),silent_comprehension_critical_thinking_6_) AS silent_comprehension_critical_thinking_6_
           ,CONVERT(NVARCHAR(8),silent_comprehension_critical_thinking_7_) AS silent_comprehension_critical_thinking_7_
           ,CONVERT(NVARCHAR(8),silent_comprehension_factual_6_) AS silent_comprehension_factual_6_
           ,CONVERT(NVARCHAR(8),silent_comprehension_factual_7_) AS silent_comprehension_factual_7_
           ,CONVERT(NVARCHAR(8),silent_comprehension_inferential_6_) AS silent_comprehension_inferential_6_
           ,CONVERT(NVARCHAR(8),silent_comprehension_inferential_7_) AS silent_comprehension_inferential_7_
           ,CONVERT(NVARCHAR(8),syntax_10_) AS syntax_10_
           ,CONVERT(NVARCHAR(8),syntax_11_) AS syntax_11_
           ,CONVERT(NVARCHAR(8),syntax_12_) AS syntax_12_
           ,CONVERT(NVARCHAR(8),syntax_3_) AS syntax_3_
           ,CONVERT(NVARCHAR(8),syntax_4_) AS syntax_4_
           ,CONVERT(NVARCHAR(8),syntax_5_) AS syntax_5_
           ,CONVERT(NVARCHAR(8),syntax_6_) AS syntax_6_
           ,CONVERT(NVARCHAR(8),syntax_7_) AS syntax_7_
           ,CONVERT(NVARCHAR(8),syntax_8_) AS syntax_8_
           ,CONVERT(NVARCHAR(8),syntax_9_) AS syntax_9_
           ,CONVERT(NVARCHAR(8),total_vowel_attempts_3_) AS total_vowel_attempts_3_
           ,CONVERT(NVARCHAR(8),visual_10_) AS visual_10_
           ,CONVERT(NVARCHAR(8),visual_11_) AS visual_11_
           ,CONVERT(NVARCHAR(8),visual_12_) AS visual_12_
           ,CONVERT(NVARCHAR(8),visual_3_) AS visual_3_
           ,CONVERT(NVARCHAR(8),visual_4_) AS visual_4_
           ,CONVERT(NVARCHAR(8),visual_5_) AS visual_5_
           ,CONVERT(NVARCHAR(8),visual_6_) AS visual_6_
           ,CONVERT(NVARCHAR(8),visual_7_) AS visual_7_
           ,CONVERT(NVARCHAR(8),visual_8_) AS visual_8_
           ,CONVERT(NVARCHAR(8),visual_9_) AS visual_9_
           ,CONVERT(NVARCHAR(8),written_comprehension_10_) AS written_comprehension_10_
           ,CONVERT(NVARCHAR(8),written_comprehension_11_) AS written_comprehension_11_
           ,CONVERT(NVARCHAR(8),written_comprehension_12_) AS written_comprehension_12_
           ,CONVERT(NVARCHAR(8),written_comprehension_9_) AS written_comprehension_9_
           ,CONVERT(NVARCHAR(8),written_comprehension_critical_thinking_10_) AS written_comprehension_critical_thinking_10_
           ,CONVERT(NVARCHAR(8),written_comprehension_critical_thinking_11_) AS written_comprehension_critical_thinking_11_
           ,CONVERT(NVARCHAR(8),written_comprehension_critical_thinking_12_) AS written_comprehension_critical_thinking_12_
           ,CONVERT(NVARCHAR(8),written_comprehension_critical_thinking_9_yellow_only_) AS written_comprehension_critical_thinking_9_yellow_only_
           ,CONVERT(NVARCHAR(8),written_comprehension_factual_10_) AS written_comprehension_factual_10_
           ,CONVERT(NVARCHAR(8),written_comprehension_factual_11_) AS written_comprehension_factual_11_
           ,CONVERT(NVARCHAR(8),written_comprehension_factual_12_) AS written_comprehension_factual_12_
           ,CONVERT(NVARCHAR(8),written_comprehension_factual_9_) AS written_comprehension_factual_9_
           ,CONVERT(NVARCHAR(8),written_comprehension_inferential_10_) AS written_comprehension_inferential_10_
           ,CONVERT(NVARCHAR(8),written_comprehension_inferential_11_purple_only_) AS written_comprehension_inferential_11_purple_only_
           ,CONVERT(NVARCHAR(8),written_comprehension_inferential_12_) AS written_comprehension_inferential_12_
           ,CONVERT(NVARCHAR(8),written_comprehension_inferential_9_) AS written_comprehension_inferential_9_
     FROM gabby.steptool.all_steps
     WHERE student_id IS NOT NULL
    ) sub
UNPIVOT(
  score
  FOR field IN (c_confusion_10_
      ,c_confusion_11_
      ,c_confusion_12_
      ,c_confusion_2_
      ,c_confusion_3_
      ,c_confusion_4_
      ,c_confusion_5_
      ,c_confusion_6_
      ,c_confusion_7_
      ,c_confusion_8_
      ,c_confusion_9_
      ,comprehension_conversation_2_
      ,comprehension_conversation_3_
      ,comprehension_conversation_4_
      ,comprehension_conversation_5_
      ,comprehension_conversation_8_
      ,comprehension_conversation_critical_thinking_3_
      ,comprehension_conversation_critical_thinking_4_
      ,comprehension_conversation_critical_thinking_5_
      ,comprehension_conversation_critical_thinking_8_
      ,comprehension_conversation_factual_2_
      ,comprehension_conversation_factual_3_
      ,comprehension_conversation_factual_4_
      ,comprehension_conversation_factual_5_
      ,comprehension_conversation_factual_8_
      ,comprehension_conversation_inferential_2_
      ,comprehension_conversation_inferential_3_
      ,comprehension_conversation_inferential_4_
      ,comprehension_conversation_inferential_5_
      ,comprehension_conversation_inferential_8_
      ,comprehension_conversation_other_2_
      ,concepts_about_print_0_
      ,concepts_about_print_1_
      ,concepts_about_print_one_to_one_matching_0_
      ,concepts_about_print_one_to_one_matching_1_
      ,concepts_about_print_orientation_0_
      ,concepts_about_print_orientation_1_
      ,concepts_about_print_sense_of_letter_vs_word_0_
      ,concepts_about_print_sense_of_letter_vs_word_1_
      ,developmental_spelling_1_
      ,developmental_spelling_10_
      ,developmental_spelling_11_
      ,developmental_spelling_12_
      ,developmental_spelling_2_
      ,developmental_spelling_3_
      ,developmental_spelling_4_
      ,developmental_spelling_5_
      ,developmental_spelling_6_
      ,developmental_spelling_7_
      ,developmental_spelling_8_
      ,developmental_spelling_9_
      ,developmental_spelling_complex_blend_10_
      ,developmental_spelling_complex_blend_8_
      ,developmental_spelling_complex_blend_9_
      ,developmental_spelling_doubling_at_syllable_juncture_11_
      ,developmental_spelling_doubling_at_syllable_juncture_12_
      ,developmental_spelling_ed_ing_endings_11_
      ,developmental_spelling_ed_ing_endings_12_
      ,developmental_spelling_final_sound_1_
      ,developmental_spelling_final_sound_2_
      ,developmental_spelling_final_sound_3_
      ,developmental_spelling_first_sound_1_
      ,developmental_spelling_first_sound_2_
      ,developmental_spelling_first_sound_3_
      ,developmental_spelling_initial_final_blend_digraph_5_
      ,developmental_spelling_initial_final_blend_digraphs_4_
      ,developmental_spelling_long_vowel_2_syllable_words_11_
      ,developmental_spelling_long_vowel_2_syllable_words_12_
      ,developmental_spelling_long_vowel_pattern_10_
      ,developmental_spelling_long_vowel_pattern_6_
      ,developmental_spelling_long_vowel_pattern_8_
      ,developmental_spelling_long_vowel_pattern_9_
      ,developmental_spelling_r_controlled_2_syllable_words_11_
      ,developmental_spelling_r_controlled_2_syllable_words_12_
      ,developmental_spelling_r_controlled_vowel_10_
      ,developmental_spelling_r_controlled_vowel_6_
      ,developmental_spelling_r_controlled_vowel_7_
      ,developmental_spelling_r_controlled_vowel_8_
      ,developmental_spelling_r_controlled_vowel_9_
      ,developmental_spelling_short_vowel_sound_1_
      ,developmental_spelling_short_vowel_sound_2_
      ,developmental_spelling_short_vowel_sound_3_
      ,developmental_spelling_short_vowel_sound_4_
      ,developmental_spelling_short_vowel_sound_5_
      ,developmental_spelling_v_c_e_long_vowel_pattern_7_
      ,developmental_spelling_vowel_digraphs_10_
      ,developmental_spelling_vowel_digraphs_8_
      ,developmental_spelling_vowel_digraphs_9_
      ,f_overreliance_on_facts_for_the_text_10_
      ,f_overreliance_on_facts_for_the_text_11_
      ,f_overreliance_on_facts_for_the_text_12_
      ,f_overreliance_on_facts_for_the_text_2_
      ,f_overreliance_on_facts_for_the_text_3_
      ,f_overreliance_on_facts_for_the_text_4_
      ,f_overreliance_on_facts_for_the_text_5_
      ,f_overreliance_on_facts_for_the_text_6_
      ,f_overreliance_on_facts_for_the_text_7_
      ,f_overreliance_on_facts_for_the_text_8_
      ,f_overreliance_on_facts_for_the_text_9_    
      ,fluency_10_
      ,fluency_11_
      ,fluency_12_
      ,fluency_4_
      ,fluency_5_
      ,fluency_6_
      ,fluency_7_
      ,fluency_8_
      ,fluency_9_
      ,l_limited_10_
      ,l_limited_11_
      ,l_limited_12_
      ,l_limited_2_
      ,l_limited_3_
      ,l_limited_4_
      ,l_limited_5_
      ,l_limited_6_
      ,l_limited_7_
      ,l_limited_8_
      ,l_limited_9_
      ,letter_name_identification_0_
      ,letter_name_identification_1_
      ,letter_name_identification_2_
      ,letter_sound_identification_0_
      ,letter_sound_identification_1_
      ,letter_sound_identification_2_
      ,letter_sound_identification_3_
      ,meaning_10_
      ,meaning_11_
      ,meaning_12_
      ,meaning_3_
      ,meaning_4_
      ,meaning_5_
      ,meaning_6_
      ,meaning_7_
      ,meaning_8_
      ,meaning_9_
      ,name_assessment_0_
      ,oral_comprehension_10_
      ,oral_comprehension_11_
      ,oral_comprehension_12_
      ,oral_comprehension_6_
      ,oral_comprehension_7_
      ,oral_comprehension_9_
      ,oral_comprehension_critical_thinking_10_
      ,oral_comprehension_critical_thinking_11_
      ,oral_comprehension_critical_thinking_12_
      ,oral_comprehension_critical_thinking_6_purple_only_
      ,oral_comprehension_critical_thinking_7_purple_only_
      ,oral_comprehension_critical_thinking_9_
      ,oral_comprehension_factual_10_yellow_only_
      ,oral_comprehension_factual_11_yellow_only_
      ,oral_comprehension_factual_12_
      ,oral_comprehension_factual_6_
      ,oral_comprehension_factual_7_
      ,oral_comprehension_factual_9_
      ,oral_comprehension_inferential_10_
      ,oral_comprehension_inferential_11_
      ,oral_comprehension_inferential_12_
      ,oral_comprehension_inferential_6_yellow_only_
      ,oral_comprehension_inferential_7_
      ,oral_comprehension_inferential_9_
      ,pe_personal_experience_10_
      ,pe_personal_experience_11_
      ,pe_personal_experience_12_
      ,pe_personal_experience_2_
      ,pe_personal_experience_3_
      ,pe_personal_experience_4_
      ,pe_personal_experience_5_
      ,pe_personal_experience_6_
      ,pe_personal_experience_7_
      ,pe_personal_experience_8_
      ,pe_personal_experience_9_
      ,phonemic_awareness_matching_first_sounds_1_
      ,phonemic_awareness_rhyming_words_0_
      ,phonemic_awareness_segmentation_2_
      ,phonemic_awareness_segmentation_3_
      ,q_answers_a_different_question_10_
      ,q_answers_a_different_question_11_
      ,q_answers_a_different_question_12_
      ,q_answers_a_different_question_2_
      ,q_answers_a_different_question_3_
      ,q_answers_a_different_question_4_
      ,q_answers_a_different_question_5_
      ,q_answers_a_different_question_6_
      ,q_answers_a_different_question_7_
      ,q_answers_a_different_question_8_
      ,q_answers_a_different_question_9_
      ,reading_accuracy_10_
      ,reading_accuracy_11_
      ,reading_accuracy_12_
      ,reading_accuracy_2_
      ,reading_accuracy_2_2_
      ,reading_accuracy_3_
      ,reading_accuracy_4_
      ,reading_accuracy_5_
      ,reading_accuracy_6_
      ,reading_accuracy_7_
      ,reading_accuracy_8_
      ,reading_accuracy_9_
      ,reading_rate_10_
      ,reading_rate_11_
      ,reading_rate_12_
      ,reading_rate_4_
      ,reading_rate_5_
      ,reading_rate_6_
      ,reading_rate_7_
      ,reading_rate_8_
      ,reading_rate_9_
      ,reading_record_1_
      ,reading_record_holds_pattern_1_
      ,reading_record_one_to_one_matching_1_
      ,reading_record_understanding_1_
      ,retelling_10_
      ,retelling_11_
      ,retelling_12_
      ,retelling_8_
      ,retelling_9_
      ,silent_comprehension_6_
      ,silent_comprehension_7_
      ,silent_comprehension_critical_thinking_6_
      ,silent_comprehension_critical_thinking_7_
      ,silent_comprehension_factual_6_
      ,silent_comprehension_factual_7_
      ,silent_comprehension_inferential_6_
      ,silent_comprehension_inferential_7_
      ,syntax_10_
      ,syntax_11_
      ,syntax_12_
      ,syntax_3_
      ,syntax_4_
      ,syntax_5_
      ,syntax_6_
      ,syntax_7_
      ,syntax_8_
      ,syntax_9_
      ,total_vowel_attempts_3_
      ,visual_10_
      ,visual_11_
      ,visual_12_
      ,visual_3_
      ,visual_4_
      ,visual_5_
      ,visual_6_
      ,visual_7_
      ,visual_8_
      ,visual_9_
      ,written_comprehension_10_
      ,written_comprehension_11_
      ,written_comprehension_12_
      ,written_comprehension_9_
      ,written_comprehension_critical_thinking_10_
      ,written_comprehension_critical_thinking_11_
      ,written_comprehension_critical_thinking_12_
      ,written_comprehension_critical_thinking_9_yellow_only_
      ,written_comprehension_factual_10_
      ,written_comprehension_factual_11_
      ,written_comprehension_factual_12_
      ,written_comprehension_factual_9_
      ,written_comprehension_inferential_10_
      ,written_comprehension_inferential_11_purple_only_
      ,written_comprehension_inferential_12_
      ,written_comprehension_inferential_9_)
 ) u