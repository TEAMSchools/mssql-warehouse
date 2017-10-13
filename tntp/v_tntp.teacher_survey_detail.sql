USE gabby
GO

CREATE OR ALTER VIEW tntp.teacher_survey_detail AS

WITH survey_long AS (
  SELECT row_id
        ,academic_year
        ,term_name
        ,region_id
        ,region
        ,school_id
        ,school
        ,UPPER(CASE
                WHEN variable LIKE '%strategies%' THEN STUFF(REPLACE(variable, 't_', 'T'), 4, 1, '')
                ELSE REPLACE(variable, 't_', 'T') 
               END) AS variable
        ,value
  FROM gabby.tntp.teacher_survey_raw_data
  UNPIVOT(
    value 
    FOR variable IN (t_120
                    ,t_135
                    ,t_138
                    ,t_32_b
                    ,t_136
                    ,t_152
                    ,t_139
                    ,t_822
                    ,t_1064
                    ,t_1065
                    ,t_12_e
                    ,t_51_dev_b
                    ,t_125
                    ,t_128
                    ,t_126
                    ,t_127
                    ,t_12_a
                    ,t_130
                    ,t_133
                    ,t_131
                    ,t_132
                    ,t_12_d
                    ,t_25_b
                    ,t_25_g
                    ,t_25_c
                    ,t_25_f
                    ,t_26_b
                    ,t_26_c
                    ,t_140
                    ,t_107
                    ,t_108
                    ,t_145
                    ,t_141
                    ,t_146
                    ,t_23_a
                    ,t_23_b
                    ,t_23_h
                    ,t_23_d
                    ,t_23_e
                    ,t_23_f
                    ,t_23_i
                    ,t_1066
                    ,t_1067
                    ,t_13_d
                    ,t_403
                    ,t_407
                    ,t_435
                    ,t_436
                    ,t_437
                    ,t_1101
                    ,t_1102
                    ,t_1103
                    ,t_1104
                    ,t_1111
                    ,t_1112
                    ,t_1113
                    ,t_1123
                    ,t_1124
                    ,t_1127
                    ,t_1128
                    ,t_1130
                    ,t_415
                    ,t_416
                    ,t_412
                    ,t_413
                    ,t_414
                    ,t_417
                    ,t_160
                    ,t_33_timeframe
                    ,t_33_b
                    ,t_33_c
                    ,t_33_d
                    ,t_71_a_strategies
                    ,t_71_b_strategies
                    ,t_71_c_strategies
                    ,t_71_d_strategies
                    ,t_71_e_strategies
                    ,t_71_f_strategies
                    ,t_71_g_strategies
                    ,t_71_h_strategies
                    ,t_52_dev_goal
                    ,t_53_adv_oppor
                    ,t_191
                    ,t_192
                    ,t_204
                    ,t_836
                    ,t_838
                    ,t_113
                    ,t_110
                    ,t_420
                    ,t_421
                    ,t_422
                    ,t_423
                    ,t_424
                    ,t_425
                    ,t_842
                    ,t_430
                    ,t_431
                    ,t_432
                    ,t_433
                    ,t_834
                    ,t_832
                    ,t_438
                    ,t_439
                    ,t_440
                    ,t_441
                    ,t_442
                    ,t_443
                    ,t_1207
                    ,t_934
                    ,t_1206
                    ,t_1208
                    ,t_1103_c
                    ,t_1102_c)
   ) u
 )

SELECT s.academic_year
      ,s.term_name      
      ,s.row_id
      ,s.region_id
      ,s.region
      ,s.school_id
      ,s.school
      ,s.variable AS question_variable
      ,s.value AS response_value
      
      ,vr.label AS question_label

      ,vl.label AS value_label
FROM survey_long s
JOIN gabby.tntp.teacher_insight_variables vr
  ON s.variable = vr.variable
LEFT OUTER JOIN gabby.tntp.teacher_insight_values vl
  ON s.variable = vl.variable
 AND s.value = vl.value