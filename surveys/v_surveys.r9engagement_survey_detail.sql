USE gabby
GO

CREATE OR ALTER VIEW surveys.r9engagement_survey_detail AS

WITH survey_unpivoted AS (
  SELECT academic_year
        ,reporting_term
        ,term_name
        ,participant_id
        ,location
        ,n
        ,REPLACE(question_code, '_', '') AS question_code
        ,response_value
  FROM
      (
       SELECT academic_year
             ,reporting_term
             ,term_name
             ,participant_id
             ,location
             ,n
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_1_s) AS academicsupportdataanalyticsandstudentinformation_1_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_2_s) AS academicsupportdataanalyticsandstudentinformation_2_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_3_s) AS academicsupportdataanalyticsandstudentinformation_3_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_4_s) AS academicsupportdataanalyticsandstudentinformation_4_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_5_s) AS academicsupportdataanalyticsandstudentinformation_5_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_6_s) AS academicsupportdataanalyticsandstudentinformation_6_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_7_s) AS academicsupportdataanalyticsandstudentinformation_7_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_8_s) AS academicsupportdataanalyticsandstudentinformation_8_s
             ,CONVERT(FLOAT,academicsupportdataanalyticsandstudentinformation_9_s) AS academicsupportdataanalyticsandstudentinformation_9_s
             ,CONVERT(FLOAT,academicsupportteam_1) AS academicsupportteam_1
             ,CONVERT(FLOAT,academicsupportteam_10) AS academicsupportteam_10
             ,CONVERT(FLOAT,academicsupportteam_11) AS academicsupportteam_11
             ,CONVERT(FLOAT,academicsupportteam_2) AS academicsupportteam_2
             ,CONVERT(FLOAT,academicsupportteam_3) AS academicsupportteam_3
             ,CONVERT(FLOAT,academicsupportteam_4) AS academicsupportteam_4
             ,CONVERT(FLOAT,academicsupportteam_5) AS academicsupportteam_5
             ,CONVERT(FLOAT,academicsupportteam_6) AS academicsupportteam_6
             ,CONVERT(FLOAT,academicsupportteam_7) AS academicsupportteam_7
             ,CONVERT(FLOAT,academicsupportteam_8) AS academicsupportteam_8
             ,CONVERT(FLOAT,academicsupportteam_9) AS academicsupportteam_9
             ,CONVERT(FLOAT,advocacysl_1) AS advocacysl_1
             ,CONVERT(FLOAT,advocacysl_2) AS advocacysl_2
             ,CONVERT(FLOAT,advocacysl_3) AS advocacysl_3
             ,CONVERT(FLOAT,benefits_1) AS benefits_1
             ,CONVERT(FLOAT,benefits_2) AS benefits_2
             ,CONVERT(FLOAT,benefits_3) AS benefits_3
             ,CONVERT(FLOAT,blendedlearning_1) AS blendedlearning_1
             ,CONVERT(FLOAT,blendedlearning_2) AS blendedlearning_2
             ,CONVERT(FLOAT,blendedlearning_3) AS blendedlearning_3
             ,CONVERT(FLOAT,dataandanalysis_1) AS dataandanalysis_1
             ,CONVERT(FLOAT,dataandanalysis_2) AS dataandanalysis_2
             ,CONVERT(FLOAT,enrollmentschoolleadersonly_1) AS enrollmentschoolleadersonly_1
             ,CONVERT(FLOAT,enrollmentschoolleadersonly_2) AS enrollmentschoolleadersonly_2
             ,CONVERT(FLOAT,enrollmentschoolleadersonly_3) AS enrollmentschoolleadersonly_3
             ,CONVERT(FLOAT,enrollmentschoolleadersonly_4) AS enrollmentschoolleadersonly_4
             ,CONVERT(FLOAT,enrollmentschoolleadersonly_5) AS enrollmentschoolleadersonly_5
             ,CONVERT(FLOAT,enrollmentschoolleadersonly_6) AS enrollmentschoolleadersonly_6
             ,CONVERT(FLOAT,facilities_1) AS facilities_1
             ,CONVERT(FLOAT,facilities_1_s) AS facilities_1_s
             ,CONVERT(FLOAT,facilities_2) AS facilities_2
             ,CONVERT(FLOAT,facilities_2_s) AS facilities_2_s
             ,CONVERT(FLOAT,facilities_3) AS facilities_3
             ,CONVERT(FLOAT,facilities_3_s) AS facilities_3_s
             ,CONVERT(FLOAT,facilities_4) AS facilities_4
             ,CONVERT(FLOAT,facilities_4_s) AS facilities_4_s
             ,CONVERT(FLOAT,facilities_5) AS facilities_5
             ,CONVERT(FLOAT,facilities_6) AS facilities_6
             ,CONVERT(FLOAT,facilitiesschoolleadersonly_1) AS facilitiesschoolleadersonly_1
             ,CONVERT(FLOAT,facilitiesschoolleadersonly_2) AS facilitiesschoolleadersonly_2
             ,CONVERT(FLOAT,facilitiesschoolleadersonly_3) AS facilitiesschoolleadersonly_3
             ,CONVERT(FLOAT,facilitiessl) AS facilitiessl
             ,CONVERT(FLOAT,financeaccounting_1_s) AS financeaccounting_1_s
             ,CONVERT(FLOAT,financeaccounting_2_s) AS financeaccounting_2_s
             ,CONVERT(FLOAT,financeaccounting_3_s) AS financeaccounting_3_s
             ,CONVERT(FLOAT,financeaccounting_4_s) AS financeaccounting_4_s
             ,CONVERT(FLOAT,financeaccountingschoolleadersonly_1_s) AS financeaccountingschoolleadersonly_1_s
             ,CONVERT(FLOAT,financeaccountingschoolleadersonly_2_s) AS financeaccountingschoolleadersonly_2_s
             ,CONVERT(FLOAT,financeaccountingschoolleadersonly_3_s) AS financeaccountingschoolleadersonly_3_s
             ,CONVERT(FLOAT,financeaccountingsl_1) AS financeaccountingsl_1
             ,CONVERT(FLOAT,financeaccountingsl_2) AS financeaccountingsl_2
             ,CONVERT(FLOAT,financeaccountingsl_3) AS financeaccountingsl_3
             ,CONVERT(FLOAT,financeaccountingsl_4) AS financeaccountingsl_4
             ,CONVERT(FLOAT,financeaccountingsl_5) AS financeaccountingsl_5
             ,CONVERT(FLOAT,financeaccountingsl_6) AS financeaccountingsl_6
             ,CONVERT(FLOAT,financeaccountingsl_7) AS financeaccountingsl_7
             ,CONVERT(FLOAT,hasl) AS hasl
             ,CONVERT(FLOAT,humanassets_1) AS humanassets_1
             ,CONVERT(FLOAT,humanassets_1_s) AS humanassets_1_s
             ,CONVERT(FLOAT,humanassets_10) AS humanassets_10
             ,CONVERT(FLOAT,humanassets_11) AS humanassets_11
             ,CONVERT(FLOAT,humanassets_12) AS humanassets_12
             ,CONVERT(FLOAT,humanassets_13) AS humanassets_13
             ,CONVERT(FLOAT,humanassets_14) AS humanassets_14
             ,CONVERT(FLOAT,humanassets_15) AS humanassets_15
             ,CONVERT(FLOAT,humanassets_16) AS humanassets_16
             ,CONVERT(FLOAT,humanassets_2) AS humanassets_2
             ,CONVERT(FLOAT,humanassets_2_s) AS humanassets_2_s
             ,CONVERT(FLOAT,humanassets_3) AS humanassets_3
             ,CONVERT(FLOAT,humanassets_3_s) AS humanassets_3_s
             ,CONVERT(FLOAT,humanassets_4) AS humanassets_4
             ,CONVERT(FLOAT,humanassets_4_s) AS humanassets_4_s
             ,CONVERT(FLOAT,humanassets_5) AS humanassets_5
             ,CONVERT(FLOAT,humanassets_5_s) AS humanassets_5_s
             ,CONVERT(FLOAT,humanassets_6) AS humanassets_6
             ,CONVERT(FLOAT,humanassets_6_s) AS humanassets_6_s
             ,CONVERT(FLOAT,humanassets_7) AS humanassets_7
             ,CONVERT(FLOAT,humanassets_8) AS humanassets_8
             ,CONVERT(FLOAT,humanassets_9) AS humanassets_9
             ,CONVERT(FLOAT,humanassetsschoolleadersonly_1) AS humanassetsschoolleadersonly_1
             ,CONVERT(FLOAT,humanassetsschoolleadersonly_2) AS humanassetsschoolleadersonly_2
             ,CONVERT(FLOAT,humanassetsschoolleadersonly_3) AS humanassetsschoolleadersonly_3
             ,CONVERT(FLOAT,kippsharefrequency_5_s) AS kippsharefrequency_5_s
             ,CONVERT(FLOAT,kippthroughcollege_1) AS kippthroughcollege_1
             ,CONVERT(FLOAT,maintenance_1) AS maintenance_1
             ,CONVERT(FLOAT,maintenance_11) AS maintenance_11
             ,CONVERT(FLOAT,maintenance_12) AS maintenance_12
             ,CONVERT(FLOAT,maintenance_13) AS maintenance_13
             ,CONVERT(FLOAT,maintenance_14) AS maintenance_14
             ,CONVERT(FLOAT,maintenance_15) AS maintenance_15
             ,CONVERT(FLOAT,maintenance_2) AS maintenance_2
             ,CONVERT(FLOAT,maintenance_21) AS maintenance_21
             ,CONVERT(FLOAT,maintenance_22) AS maintenance_22
             ,CONVERT(FLOAT,maintenance_23) AS maintenance_23
             ,CONVERT(FLOAT,maintenance_3) AS maintenance_3
             ,CONVERT(FLOAT,maintenance_4) AS maintenance_4
             ,CONVERT(FLOAT,maintenance_5) AS maintenance_5
             ,CONVERT(FLOAT,maintenance_6) AS maintenance_6
             ,CONVERT(FLOAT,maintenance_7) AS maintenance_7
             ,CONVERT(FLOAT,maintenance_8) AS maintenance_8
             ,CONVERT(FLOAT,maintenance_9_a) AS maintenance_9_a
             ,CONVERT(FLOAT,maintenance_9_b) AS maintenance_9_b
             ,CONVERT(FLOAT,maintenance_9_c) AS maintenance_9_c
             ,CONVERT(FLOAT,maintenance_9_d) AS maintenance_9_d
             ,CONVERT(FLOAT,maintenance_9_e) AS maintenance_9_e
             ,CONVERT(FLOAT,marketing_1) AS marketing_1
             ,CONVERT(FLOAT,marketing_2) AS marketing_2
             ,CONVERT(FLOAT,marketingschoolleadersonly_1) AS marketingschoolleadersonly_1
             ,CONVERT(FLOAT,marketingschoolleadersonly_2) AS marketingschoolleadersonly_2
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_1) AS noninstructionalhiringdsor_9_directors_1
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_2) AS noninstructionalhiringdsor_9_directors_2
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_3) AS noninstructionalhiringdsor_9_directors_3
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_4) AS noninstructionalhiringdsor_9_directors_4
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_5) AS noninstructionalhiringdsor_9_directors_5
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_6) AS noninstructionalhiringdsor_9_directors_6
             ,CONVERT(FLOAT,noninstructionalhiringdsor_9_directors_7) AS noninstructionalhiringdsor_9_directors_7
             ,CONVERT(FLOAT,nutritionprogramfoodservice_1) AS nutritionprogramfoodservice_1
             ,CONVERT(FLOAT,nutritionprogramfoodservice_1_s) AS nutritionprogramfoodservice_1_s
             ,CONVERT(FLOAT,nutritionprogramfoodservice_2) AS nutritionprogramfoodservice_2
             ,CONVERT(FLOAT,nutritionprogramfoodservice_3) AS nutritionprogramfoodservice_3
             ,CONVERT(FLOAT,nutritionprogramfoodservice_4) AS nutritionprogramfoodservice_4
             ,CONVERT(FLOAT,nutritionprogramfoodservice_5) AS nutritionprogramfoodservice_5
             ,CONVERT(FLOAT,nutritionprogramfoodservice_6) AS nutritionprogramfoodservice_6
             ,CONVERT(FLOAT,nutritionprogramfoodservice_7) AS nutritionprogramfoodservice_7
             ,CONVERT(FLOAT,nutritionprogramfoodserviceschoolleadersonly_1) AS nutritionprogramfoodserviceschoolleadersonly_1
             ,CONVERT(FLOAT,nutritionprogramfoodserviceschoolleadersonly_2) AS nutritionprogramfoodserviceschoolleadersonly_2
             ,CONVERT(FLOAT,nutritionprogramfoodserviceschoolleadersonly_3) AS nutritionprogramfoodserviceschoolleadersonly_3
             ,CONVERT(FLOAT,nutritionschoolleadersonly_1) AS nutritionschoolleadersonly_1
             ,CONVERT(FLOAT,nutritionschoolleadersonly_2) AS nutritionschoolleadersonly_2
             ,CONVERT(FLOAT,nutritionschoolleadersonly_3) AS nutritionschoolleadersonly_3
             ,CONVERT(FLOAT,nutritionschoolleadersonly_4) AS nutritionschoolleadersonly_4
             ,CONVERT(FLOAT,purchasing_1) AS purchasing_1
             ,CONVERT(FLOAT,purchasing_1_s) AS purchasing_1_s
             ,CONVERT(FLOAT,purchasing_2) AS purchasing_2
             ,CONVERT(FLOAT,purchasing_2_s) AS purchasing_2_s
             ,CONVERT(FLOAT,purchasing_3) AS purchasing_3
             ,CONVERT(FLOAT,purchasing_3_s) AS purchasing_3_s
             ,CONVERT(FLOAT,purchasing_4) AS purchasing_4
             ,CONVERT(FLOAT,purchasing_4_s) AS purchasing_4_s
             ,CONVERT(FLOAT,purchasing_5) AS purchasing_5
             ,CONVERT(FLOAT,purchasing_5_s) AS purchasing_5_s
             ,CONVERT(FLOAT,purchasing_6) AS purchasing_6
             ,CONVERT(FLOAT,purchasing_7) AS purchasing_7
             ,CONVERT(FLOAT,purchasing_8) AS purchasing_8
             ,CONVERT(FLOAT,purchasingsl) AS purchasingsl
             ,CONVERT(FLOAT,r_9_q_1201) AS r_9_q_1201
             ,CONVERT(FLOAT,r_9_q_1202) AS r_9_q_1202
             ,CONVERT(FLOAT,r_9_q_1203) AS r_9_q_1203
             ,CONVERT(FLOAT,r_9_q_1204) AS r_9_q_1204
             ,CONVERT(FLOAT,r_9_q_1205) AS r_9_q_1205
             ,CONVERT(FLOAT,r_9_q_1206) AS r_9_q_1206
             ,CONVERT(FLOAT,r_9_q_1207) AS r_9_q_1207
             ,CONVERT(FLOAT,r_9_q_1208) AS r_9_q_1208
             ,CONVERT(FLOAT,r_9_q_1209) AS r_9_q_1209
             ,CONVERT(FLOAT,r_9_q_1210) AS r_9_q_1210
             ,CONVERT(FLOAT,r_9_q_1211) AS r_9_q_1211
             ,CONVERT(FLOAT,r_9_q_1212) AS r_9_q_1212
             ,CONVERT(FLOAT,recruitingschoolleadersonly_1_s) AS recruitingschoolleadersonly_1_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_10_s) AS recruitingschoolleadersonly_10_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_2_s) AS recruitingschoolleadersonly_2_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_3_s) AS recruitingschoolleadersonly_3_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_4_s) AS recruitingschoolleadersonly_4_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_5_s) AS recruitingschoolleadersonly_5_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_6_s) AS recruitingschoolleadersonly_6_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_7_s) AS recruitingschoolleadersonly_7_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_8_s) AS recruitingschoolleadersonly_8_s
             ,CONVERT(FLOAT,recruitingschoolleadersonly_9_s) AS recruitingschoolleadersonly_9_s
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_1) AS recruitmentschoolleadersonly_1
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_10) AS recruitmentschoolleadersonly_10
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_11) AS recruitmentschoolleadersonly_11
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_2) AS recruitmentschoolleadersonly_2
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_3) AS recruitmentschoolleadersonly_3
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_4) AS recruitmentschoolleadersonly_4
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_5) AS recruitmentschoolleadersonly_5
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_6) AS recruitmentschoolleadersonly_6
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_7) AS recruitmentschoolleadersonly_7
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_8) AS recruitmentschoolleadersonly_8
             ,CONVERT(FLOAT,recruitmentschoolleadersonly_9) AS recruitmentschoolleadersonly_9
             ,CONVERT(FLOAT,schooloperations_1) AS schooloperations_1
             ,CONVERT(FLOAT,schooloperations_10) AS schooloperations_10
             ,CONVERT(FLOAT,schooloperations_2) AS schooloperations_2
             ,CONVERT(FLOAT,schooloperations_3) AS schooloperations_3
             ,CONVERT(FLOAT,schooloperations_4) AS schooloperations_4
             ,CONVERT(FLOAT,schooloperations_5) AS schooloperations_5
             ,CONVERT(FLOAT,schooloperations_6) AS schooloperations_6
             ,CONVERT(FLOAT,schooloperations_7) AS schooloperations_7
             ,CONVERT(FLOAT,schooloperations_8) AS schooloperations_8
             ,CONVERT(FLOAT,schooloperations_9) AS schooloperations_9
             ,CONVERT(FLOAT,sharing_1_s) AS sharing_1_s
             ,CONVERT(FLOAT,sharing_2_s) AS sharing_2_s
             ,CONVERT(FLOAT,sharing_3_s) AS sharing_3_s
             ,CONVERT(FLOAT,sharing_4_s) AS sharing_4_s
             ,CONVERT(FLOAT,specialed_1) AS specialed_1
             ,CONVERT(FLOAT,specialeducation_1) AS specialeducation_1
             ,CONVERT(FLOAT,specialeducation_1_s) AS specialeducation_1_s
             ,CONVERT(FLOAT,specialeducation_2) AS specialeducation_2
             ,CONVERT(FLOAT,specialeducation_2_s) AS specialeducation_2_s
             ,CONVERT(FLOAT,specialeducation_3) AS specialeducation_3
             ,CONVERT(FLOAT,specialeducation_4) AS specialeducation_4
             ,CONVERT(FLOAT,specialeducation_5) AS specialeducation_5
             ,CONVERT(FLOAT,studentinformation_1) AS studentinformation_1
             ,CONVERT(FLOAT,studentinformation_2) AS studentinformation_2
             ,CONVERT(FLOAT,studentinformation_3) AS studentinformation_3
             ,CONVERT(FLOAT,teachinglearning_1) AS teachinglearning_1
             ,CONVERT(FLOAT,teachinglearning_10) AS teachinglearning_10
             ,CONVERT(FLOAT,teachinglearning_2) AS teachinglearning_2
             ,CONVERT(FLOAT,teachinglearning_3) AS teachinglearning_3
             ,CONVERT(FLOAT,teachinglearning_4) AS teachinglearning_4
             ,CONVERT(FLOAT,teachinglearning_5) AS teachinglearning_5
             ,CONVERT(FLOAT,teachinglearning_6) AS teachinglearning_6
             ,CONVERT(FLOAT,teachinglearning_7) AS teachinglearning_7
             ,CONVERT(FLOAT,teachinglearning_8) AS teachinglearning_8
             ,CONVERT(FLOAT,teachinglearning_9) AS teachinglearning_9
             ,CONVERT(FLOAT,technology_1) AS technology_1
             ,CONVERT(FLOAT,technology_1_s) AS technology_1_s
             ,CONVERT(FLOAT,technology_2) AS technology_2
             ,CONVERT(FLOAT,technology_2_s) AS technology_2_s
             ,CONVERT(FLOAT,technology_3) AS technology_3
             ,CONVERT(FLOAT,technology_3_s) AS technology_3_s
             ,CONVERT(FLOAT,technology_4) AS technology_4
             ,CONVERT(FLOAT,technology_4_s) AS technology_4_s
             ,CONVERT(FLOAT,technology_5) AS technology_5
             ,CONVERT(FLOAT,technology_6) AS technology_6
             ,CONVERT(FLOAT,technologyschoolleadersonly_1) AS technologyschoolleadersonly_1
             ,CONVERT(FLOAT,technologyschoolleadersonly_2) AS technologyschoolleadersonly_2
             ,CONVERT(FLOAT,technologyschoolleadersonly_3) AS technologyschoolleadersonly_3
             ,CONVERT(FLOAT,technologysl) AS technologysl
       FROM gabby.surveys.r9engagement_survey_archive
      ) sub
  UNPIVOT(
    response_value
    FOR question_code IN (academicsupportdataanalyticsandstudentinformation_1_s
                         ,academicsupportdataanalyticsandstudentinformation_2_s
                         ,academicsupportdataanalyticsandstudentinformation_3_s
                         ,academicsupportdataanalyticsandstudentinformation_4_s
                         ,academicsupportdataanalyticsandstudentinformation_5_s
                         ,academicsupportdataanalyticsandstudentinformation_6_s
                         ,academicsupportdataanalyticsandstudentinformation_7_s
                         ,academicsupportdataanalyticsandstudentinformation_8_s
                         ,academicsupportdataanalyticsandstudentinformation_9_s
                         ,academicsupportteam_1
                         ,academicsupportteam_10
                         ,academicsupportteam_11
                         ,academicsupportteam_2
                         ,academicsupportteam_3
                         ,academicsupportteam_4
                         ,academicsupportteam_5
                         ,academicsupportteam_6
                         ,academicsupportteam_7
                         ,academicsupportteam_8
                         ,academicsupportteam_9
                         ,advocacysl_1
                         ,advocacysl_2
                         ,advocacysl_3
                         ,benefits_1
                         ,benefits_2
                         ,benefits_3
                         ,blendedlearning_1
                         ,blendedlearning_2
                         ,blendedlearning_3
                         ,dataandanalysis_1
                         ,dataandanalysis_2
                         ,enrollmentschoolleadersonly_1
                         ,enrollmentschoolleadersonly_2
                         ,enrollmentschoolleadersonly_3
                         ,enrollmentschoolleadersonly_4
                         ,enrollmentschoolleadersonly_5
                         ,enrollmentschoolleadersonly_6
                         ,facilities_1
                         ,facilities_1_s
                         ,facilities_2
                         ,facilities_2_s
                         ,facilities_3
                         ,facilities_3_s
                         ,facilities_4
                         ,facilities_4_s
                         ,facilities_5
                         ,facilities_6
                         ,facilitiesschoolleadersonly_1
                         ,facilitiesschoolleadersonly_2
                         ,facilitiesschoolleadersonly_3
                         ,facilitiessl
                         ,financeaccounting_1_s
                         ,financeaccounting_2_s
                         ,financeaccounting_3_s
                         ,financeaccounting_4_s
                         ,financeaccountingschoolleadersonly_1_s
                         ,financeaccountingschoolleadersonly_2_s
                         ,financeaccountingschoolleadersonly_3_s
                         ,financeaccountingsl_1
                         ,financeaccountingsl_2
                         ,financeaccountingsl_3
                         ,financeaccountingsl_4
                         ,financeaccountingsl_5
                         ,financeaccountingsl_6
                         ,financeaccountingsl_7
                         ,hasl
                         ,humanassets_1
                         ,humanassets_1_s
                         ,humanassets_10
                         ,humanassets_11
                         ,humanassets_12
                         ,humanassets_13
                         ,humanassets_14
                         ,humanassets_15
                         ,humanassets_16
                         ,humanassets_2
                         ,humanassets_2_s
                         ,humanassets_3
                         ,humanassets_3_s
                         ,humanassets_4
                         ,humanassets_4_s
                         ,humanassets_5
                         ,humanassets_5_s
                         ,humanassets_6
                         ,humanassets_6_s
                         ,humanassets_7
                         ,humanassets_8
                         ,humanassets_9
                         ,humanassetsschoolleadersonly_1
                         ,humanassetsschoolleadersonly_2
                         ,humanassetsschoolleadersonly_3
                         ,kippsharefrequency_5_s
                         ,kippthroughcollege_1
                         ,maintenance_1
                         ,maintenance_11
                         ,maintenance_12
                         ,maintenance_13
                         ,maintenance_14
                         ,maintenance_15
                         ,maintenance_2
                         ,maintenance_21
                         ,maintenance_22
                         ,maintenance_23
                         ,maintenance_3
                         ,maintenance_4
                         ,maintenance_5
                         ,maintenance_6
                         ,maintenance_7
                         ,maintenance_8
                         ,maintenance_9_a
                         ,maintenance_9_b
                         ,maintenance_9_c
                         ,maintenance_9_d
                         ,maintenance_9_e
                         ,marketing_1
                         ,marketing_2
                         ,marketingschoolleadersonly_1
                         ,marketingschoolleadersonly_2
                         ,noninstructionalhiringdsor_9_directors_1
                         ,noninstructionalhiringdsor_9_directors_2
                         ,noninstructionalhiringdsor_9_directors_3
                         ,noninstructionalhiringdsor_9_directors_4
                         ,noninstructionalhiringdsor_9_directors_5
                         ,noninstructionalhiringdsor_9_directors_6
                         ,noninstructionalhiringdsor_9_directors_7
                         ,nutritionprogramfoodservice_1
                         ,nutritionprogramfoodservice_1_s
                         ,nutritionprogramfoodservice_2
                         ,nutritionprogramfoodservice_3
                         ,nutritionprogramfoodservice_4
                         ,nutritionprogramfoodservice_5
                         ,nutritionprogramfoodservice_6
                         ,nutritionprogramfoodservice_7
                         ,nutritionprogramfoodserviceschoolleadersonly_1
                         ,nutritionprogramfoodserviceschoolleadersonly_2
                         ,nutritionprogramfoodserviceschoolleadersonly_3
                         ,nutritionschoolleadersonly_1
                         ,nutritionschoolleadersonly_2
                         ,nutritionschoolleadersonly_3
                         ,nutritionschoolleadersonly_4
                         ,purchasing_1
                         ,purchasing_1_s
                         ,purchasing_2
                         ,purchasing_2_s
                         ,purchasing_3
                         ,purchasing_3_s
                         ,purchasing_4
                         ,purchasing_4_s
                         ,purchasing_5
                         ,purchasing_5_s
                         ,purchasing_6
                         ,purchasing_7
                         ,purchasing_8
                         ,purchasingsl
                         ,r_9_q_1201
                         ,r_9_q_1202
                         ,r_9_q_1203
                         ,r_9_q_1204
                         ,r_9_q_1205
                         ,r_9_q_1206
                         ,r_9_q_1207
                         ,r_9_q_1208
                         ,r_9_q_1209
                         ,r_9_q_1210
                         ,r_9_q_1211
                         ,r_9_q_1212
                         ,recruitingschoolleadersonly_1_s
                         ,recruitingschoolleadersonly_10_s
                         ,recruitingschoolleadersonly_2_s
                         ,recruitingschoolleadersonly_3_s
                         ,recruitingschoolleadersonly_4_s
                         ,recruitingschoolleadersonly_5_s
                         ,recruitingschoolleadersonly_6_s
                         ,recruitingschoolleadersonly_7_s
                         ,recruitingschoolleadersonly_8_s
                         ,recruitingschoolleadersonly_9_s
                         ,recruitmentschoolleadersonly_1
                         ,recruitmentschoolleadersonly_11
                         ,recruitmentschoolleadersonly_2
                         ,recruitmentschoolleadersonly_3
                         ,recruitmentschoolleadersonly_4
                         ,recruitmentschoolleadersonly_5
                         ,recruitmentschoolleadersonly_6
                         ,recruitmentschoolleadersonly_7
                         ,recruitmentschoolleadersonly_8
                         ,recruitmentschoolleadersonly_9
                         ,recruitmentschoolleadersonly_10
                         ,schooloperations_1
                         ,schooloperations_10
                         ,schooloperations_2
                         ,schooloperations_3
                         ,schooloperations_4
                         ,schooloperations_5
                         ,schooloperations_6
                         ,schooloperations_7
                         ,schooloperations_8
                         ,schooloperations_9
                         ,sharing_1_s
                         ,sharing_2_s
                         ,sharing_3_s
                         ,sharing_4_s
                         ,specialed_1
                         ,specialeducation_1
                         ,specialeducation_1_s
                         ,specialeducation_2
                         ,specialeducation_2_s
                         ,specialeducation_3
                         ,specialeducation_4
                         ,specialeducation_5
                         ,studentinformation_1
                         ,studentinformation_2
                         ,studentinformation_3
                         ,teachinglearning_1
                         ,teachinglearning_10
                         ,teachinglearning_2
                         ,teachinglearning_3
                         ,teachinglearning_4
                         ,teachinglearning_5
                         ,teachinglearning_6
                         ,teachinglearning_7
                         ,teachinglearning_8
                         ,teachinglearning_9
                         ,technology_1
                         ,technology_1_s
                         ,technology_2
                         ,technology_2_s
                         ,technology_3
                         ,technology_3_s
                         ,technology_4
                         ,technology_4_s
                         ,technology_5
                         ,technology_6
                         ,technologyschoolleadersonly_1
                         ,technologyschoolleadersonly_2
                         ,technologyschoolleadersonly_3
                         ,technologysl)
   ) u
 )

 SELECT su.academic_year
       ,su.reporting_term
       ,su.term_name
       ,su.participant_id
       ,su.location
       ,su.n
       ,su.question_code
       ,su.response_value
       ,CASE 
         WHEN location = 'TEAM' THEN 133570965
         WHEN location = 'Life Lower' THEN 73257
         WHEN location = 'Life Upper' THEN 73257
         WHEN location = 'NCA' THEN 73253
         WHEN location = 'Revolution' THEN 179901
         WHEN location = 'Rise' THEN 73252
         WHEN location = 'Seek' THEN 73256
         WHEN location = 'SPARK' THEN 73254
         WHEN location = 'TEAM' THEN 133570965
         WHEN location = 'THRIVE' THEN 73255
        END AS reporting_schoolid
       ,CASE 
         WHEN location IN ('TEAM','Life Lower','Life Upper','NCA','Rise','Seek','SPARK','TEAM','THRIVE') THEN 'TEAM'
         WHEN location IN ('Revolution') THEN 'KCNA'
        END AS region
       ,CASE 
         WHEN location IN ('Life Lower','Life Upper','Revolution','Seek','SPARK','THRIVE') THEN 'ES'
         WHEN location IN ('TEAM','Rise') THEN 'MS'
         WHEN location IN ('NCA') THEN 'HS'
        END AS school_level

       ,qk.survey_type
       ,qk.competency
       ,qk.question_text
 FROM survey_unpivoted su
 LEFT OUTER JOIN gabby.surveys.question_key qk
   ON su.question_code = qk.question_code
  AND su.academic_year = ISNULL(qk.academic_year, su.academic_year)
  AND qk.survey_type = 'R9'