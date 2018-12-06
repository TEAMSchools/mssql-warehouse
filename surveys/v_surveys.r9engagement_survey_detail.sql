USE gabby
GO

CREATE OR ALTER VIEW surveys.r9engagement_survey_detail AS

WITH survey_unpivoted AS (
  SELECT academic_year
        ,reporting_term
        ,term_name
        ,participant_id
        ,associate_id
        ,email
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
             ,associate_id
             ,email
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
             ,CONVERT(FLOAT,NULL) AS data_1
             ,CONVERT(FLOAT,NULL) AS data_2
             ,CONVERT(FLOAT,NULL) AS ER_1
             ,CONVERT(FLOAT,NULL) AS ER_2
             ,CONVERT(FLOAT,NULL) AS facilities_7
             ,CONVERT(FLOAT,NULL) AS facilities_8
             ,CONVERT(FLOAT,NULL) AS humanresources_1
             ,CONVERT(FLOAT,NULL) AS humanresources_2
             ,CONVERT(FLOAT,NULL) AS humanresource_3
             ,CONVERT(FLOAT,NULL) AS marketing_3
             ,CONVERT(FLOAT,NULL) AS purchasing_9
             ,CONVERT(FLOAT,NULL) AS purchasing_10
             ,CONVERT(FLOAT,NULL) AS specialeducation_7
             ,CONVERT(FLOAT,NULL) AS specialeducation_6
             ,CONVERT(FLOAT,NULL) AS region_1
             ,CONVERT(FLOAT,NULL) AS region_2
             ,CONVERT(FLOAT,NULL) AS schooloperations_11
             ,CONVERT(FLOAT,NULL) AS region_3
             ,CONVERT(FLOAT,NULL) AS region_4
             ,CONVERT(FLOAT,NULL) AS region_5
             ,CONVERT(FLOAT,NULL) AS teachinglearning_11
             ,CONVERT(FLOAT,NULL) AS teachinglearning_12
             ,CONVERT(FLOAT,NULL) AS teachinglearning_13
             ,CONVERT(FLOAT,NULL) AS technology_14
             ,CONVERT(FLOAT,NULL) AS technology_16
             ,CONVERT(FLOAT,NULL) AS technology_15
             ,CONVERT(FLOAT,NULL) AS region_8
       FROM gabby.surveys.r9engagement_survey_archive

       UNION ALL

       SELECT academic_year
             ,reporting_term
             ,term_name
             ,participant_id
             ,associate_id
             ,email
             ,location
             ,NULL AS n
             ,NULL AS academicsupportdataanalyticsandstudentinformation_1_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_2_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_3_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_4_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_5_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_6_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_7_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_8_s
             ,NULL AS academicsupportdataanalyticsandstudentinformation_9_s
             ,NULL AS academicsupportteam_1
             ,NULL AS academicsupportteam_10
             ,NULL AS academicsupportteam_11
             ,NULL AS academicsupportteam_2
             ,NULL AS academicsupportteam_3
             ,NULL AS academicsupportteam_4
             ,NULL AS academicsupportteam_5
             ,NULL AS academicsupportteam_6
             ,NULL AS academicsupportteam_7
             ,NULL AS academicsupportteam_8
             ,NULL AS academicsupportteam_9
             ,NULL AS advocacysl_1
             ,NULL AS advocacysl_2
             ,NULL AS advocacysl_3
             ,NULL AS benefits_1
             ,NULL AS benefits_2
             ,NULL AS benefits_3
             ,NULL AS blendedlearning_1
             ,NULL AS blendedlearning_2
             ,NULL AS blendedlearning_3
             ,NULL AS dataandanalysis_1
             ,NULL AS dataandanalysis_2
             ,NULL AS enrollmentschoolleadersonly_1
             ,NULL AS enrollmentschoolleadersonly_2
             ,NULL AS enrollmentschoolleadersonly_3
             ,NULL AS enrollmentschoolleadersonly_4
             ,NULL AS enrollmentschoolleadersonly_5
             ,NULL AS enrollmentschoolleadersonly_6
             ,NULL AS facilities_1
             ,NULL AS facilities_1_s
             ,NULL AS facilities_2
             ,NULL AS facilities_2_s
             ,NULL AS facilities_3
             ,NULL AS facilities_3_s
             ,NULL AS facilities_4
             ,NULL AS facilities_4_s
             ,NULL AS facilities_5
             ,NULL AS facilities_6
             ,NULL AS facilitiesschoolleadersonly_1
             ,NULL AS facilitiesschoolleadersonly_2
             ,NULL AS facilitiesschoolleadersonly_3
             ,NULL AS facilitiessl
             ,NULL AS financeaccounting_1_s
             ,NULL AS financeaccounting_2_s
             ,NULL AS financeaccounting_3_s
             ,NULL AS financeaccounting_4_s
             ,NULL AS financeaccountingschoolleadersonly_1_s
             ,NULL AS financeaccountingschoolleadersonly_2_s
             ,NULL AS financeaccountingschoolleadersonly_3_s
             ,NULL AS financeaccountingsl_1
             ,NULL AS financeaccountingsl_2
             ,NULL AS financeaccountingsl_3
             ,NULL AS financeaccountingsl_4
             ,NULL AS financeaccountingsl_5
             ,NULL AS financeaccountingsl_6
             ,NULL AS financeaccountingsl_7
             ,NULL AS hasl
             ,NULL AS humanassets_1
             ,NULL AS humanassets_1_s
             ,NULL AS humanassets_10
             ,NULL AS humanassets_11
             ,NULL AS humanassets_12
             ,NULL AS humanassets_13
             ,NULL AS humanassets_14
             ,NULL AS humanassets_15
             ,NULL AS humanassets_16
             ,NULL AS humanassets_2
             ,NULL AS humanassets_2_s
             ,NULL AS humanassets_3
             ,NULL AS humanassets_3_s
             ,NULL AS humanassets_4
             ,NULL AS humanassets_4_s
             ,NULL AS humanassets_5
             ,NULL AS humanassets_5_s
             ,NULL AS humanassets_6
             ,NULL AS humanassets_6_s
             ,NULL AS humanassets_7
             ,NULL AS humanassets_8
             ,NULL AS humanassets_9
             ,NULL AS humanassetsschoolleadersonly_1
             ,NULL AS humanassetsschoolleadersonly_2
             ,NULL AS humanassetsschoolleadersonly_3
             ,NULL AS kippsharefrequency_5_s
             ,NULL AS kippthroughcollege_1
             ,NULL AS maintenance_1
             ,NULL AS maintenance_11
             ,NULL AS maintenance_12
             ,NULL AS maintenance_13
             ,NULL AS maintenance_14
             ,NULL AS maintenance_15
             ,NULL AS maintenance_2
             ,NULL AS maintenance_21
             ,NULL AS maintenance_22
             ,NULL AS maintenance_23
             ,NULL AS maintenance_3
             ,NULL AS maintenance_4
             ,NULL AS maintenance_5
             ,NULL AS maintenance_6
             ,NULL AS maintenance_7
             ,NULL AS maintenance_8
             ,NULL AS maintenance_9_a
             ,NULL AS maintenance_9_b
             ,NULL AS maintenance_9_c
             ,NULL AS maintenance_9_d
             ,NULL AS maintenance_9_e
             ,NULL AS marketing_1
             ,NULL AS marketing_2
             ,NULL AS marketingschoolleadersonly_1
             ,NULL AS marketingschoolleadersonly_2
             ,NULL AS noninstructionalhiringdsor_9_directors_1
             ,NULL AS noninstructionalhiringdsor_9_directors_2
             ,NULL AS noninstructionalhiringdsor_9_directors_3
             ,NULL AS noninstructionalhiringdsor_9_directors_4
             ,NULL AS noninstructionalhiringdsor_9_directors_5
             ,NULL AS noninstructionalhiringdsor_9_directors_6
             ,NULL AS noninstructionalhiringdsor_9_directors_7
             ,NULL AS nutritionprogramfoodservice_1
             ,NULL AS nutritionprogramfoodservice_1_s
             ,NULL AS nutritionprogramfoodservice_2
             ,NULL AS nutritionprogramfoodservice_3
             ,NULL AS nutritionprogramfoodservice_4
             ,NULL AS nutritionprogramfoodservice_5
             ,NULL AS nutritionprogramfoodservice_6
             ,NULL AS nutritionprogramfoodservice_7
             ,NULL AS nutritionprogramfoodserviceschoolleadersonly_1
             ,NULL AS nutritionprogramfoodserviceschoolleadersonly_2
             ,NULL AS nutritionprogramfoodserviceschoolleadersonly_3
             ,NULL AS nutritionschoolleadersonly_1
             ,NULL AS nutritionschoolleadersonly_2
             ,NULL AS nutritionschoolleadersonly_3
             ,NULL AS nutritionschoolleadersonly_4
             ,NULL AS purchasing_1
             ,NULL AS purchasing_1_s
             ,NULL AS purchasing_2
             ,NULL AS purchasing_2_s
             ,NULL AS purchasing_3
             ,NULL AS purchasing_3_s
             ,NULL AS purchasing_4
             ,NULL AS purchasing_4_s
             ,NULL AS purchasing_5
             ,NULL AS purchasing_5_s
             ,NULL AS purchasing_6
             ,NULL AS purchasing_7
             ,NULL AS purchasing_8
             ,NULL AS purchasingsl
             ,CASE
               WHEN r_9_q_1201 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1201 = 'Agree' THEN 4.0	
               WHEN r_9_q_1201 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1201 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1201 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1201
             ,CASE
               WHEN r_9_q_1202 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1202 = 'Agree' THEN 4.0	
               WHEN r_9_q_1202 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1202 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1202 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1202 
             ,CASE
               WHEN r_9_q_1203 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1203 = 'Agree' THEN 4.0	
               WHEN r_9_q_1203 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1203 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1203 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1203 
             ,CASE
               WHEN r_9_q_1204 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1204 = 'Agree' THEN 4.0	
               WHEN r_9_q_1204 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1204 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1204 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1204 
             ,CASE
               WHEN r_9_q_1205 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1205 = 'Agree' THEN 4.0	
               WHEN r_9_q_1205 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1205 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1205 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1205 
             ,CASE
               WHEN r_9_q_1206 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1206 = 'Agree' THEN 4.0	
               WHEN r_9_q_1206 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1206 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1206 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1206 
             ,CASE
               WHEN r_9_q_1207 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1207 = 'Agree' THEN 4.0	
               WHEN r_9_q_1207 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1207 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1207 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1207 
             ,CASE
               WHEN r_9_q_1208 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1208 = 'Agree' THEN 4.0	
               WHEN r_9_q_1208 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1208 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1208 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1208 
             ,CASE
               WHEN r_9_q_1209 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1209 = 'Agree' THEN 4.0	
               WHEN r_9_q_1209 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1209 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1209 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1209 
             ,CASE
               WHEN r_9_q_1210 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1210 = 'Agree' THEN 4.0	
               WHEN r_9_q_1210 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1210 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1210 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1210 
             ,CASE
               WHEN r_9_q_1211 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1211 = 'Agree' THEN 4.0	
               WHEN r_9_q_1211 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1211 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1211 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1211 
             ,CASE
               WHEN r_9_q_1212 = 'Strongly agree' THEN 5.0	
               WHEN r_9_q_1212 = 'Agree' THEN 4.0	
               WHEN r_9_q_1212 = 'Neutral' THEN 3.0	
               WHEN r_9_q_1212 = 'Disagree' THEN 2.0	
               WHEN r_9_q_1212 = 'Strongly disagree' THEN 1.0
              END AS r_9_q_1212
             ,NULL AS recruitingschoolleadersonly_1_s
             ,NULL AS recruitingschoolleadersonly_10_s
             ,NULL AS recruitingschoolleadersonly_2_s
             ,NULL AS recruitingschoolleadersonly_3_s
             ,NULL AS recruitingschoolleadersonly_4_s
             ,NULL AS recruitingschoolleadersonly_5_s
             ,NULL AS recruitingschoolleadersonly_6_s
             ,NULL AS recruitingschoolleadersonly_7_s
             ,NULL AS recruitingschoolleadersonly_8_s
             ,NULL AS recruitingschoolleadersonly_9_s
             ,NULL AS recruitmentschoolleadersonly_1
             ,NULL AS recruitmentschoolleadersonly_10
             ,NULL AS recruitmentschoolleadersonly_11
             ,NULL AS recruitmentschoolleadersonly_2
             ,NULL AS recruitmentschoolleadersonly_3
             ,NULL AS recruitmentschoolleadersonly_4
             ,NULL AS recruitmentschoolleadersonly_5
             ,NULL AS recruitmentschoolleadersonly_6
             ,NULL AS recruitmentschoolleadersonly_7
             ,NULL AS recruitmentschoolleadersonly_8
             ,NULL AS recruitmentschoolleadersonly_9
             ,NULL AS schooloperations_1
             ,NULL AS schooloperations_10
             ,NULL AS schooloperations_2
             ,NULL AS schooloperations_3
             ,NULL AS schooloperations_4
             ,NULL AS schooloperations_5
             ,NULL AS schooloperations_6
             ,NULL AS schooloperations_7
             ,NULL AS schooloperations_8
             ,NULL AS schooloperations_9
             ,NULL AS sharing_1_s
             ,NULL AS sharing_2_s
             ,NULL AS sharing_3_s
             ,NULL AS sharing_4_s
             ,NULL AS specialed_1
             ,NULL AS specialeducation_1
             ,NULL AS specialeducation_1_s
             ,NULL AS specialeducation_2
             ,NULL AS specialeducation_2_s
             ,NULL AS specialeducation_3
             ,NULL AS specialeducation_4
             ,NULL AS specialeducation_5
             ,NULL AS studentinformation_1
             ,NULL AS studentinformation_2
             ,NULL AS studentinformation_3
             ,NULL AS teachinglearning_1
             ,NULL AS teachinglearning_10
             ,NULL AS teachinglearning_2
             ,NULL AS teachinglearning_3
             ,NULL AS teachinglearning_4
             ,NULL AS teachinglearning_5
             ,NULL AS teachinglearning_6
             ,NULL AS teachinglearning_7
             ,NULL AS teachinglearning_8
             ,NULL AS teachinglearning_9
             ,NULL AS technology_1
             ,NULL AS technology_1_s
             ,NULL AS technology_2
             ,NULL AS technology_2_s
             ,NULL AS technology_3
             ,NULL AS technology_3_s
             ,NULL AS technology_4
             ,NULL AS technology_4_s
             ,NULL AS technology_5
             ,NULL AS technology_6
             ,NULL AS technologyschoolleadersonly_1
             ,NULL AS technologyschoolleadersonly_2
             ,NULL AS technologyschoolleadersonly_3
             ,NULL AS technologysl
             ,CASE
               WHEN data_1 = 'Strongly agree' THEN 5.0	
               WHEN data_1 = 'Agree' THEN 4.0	
               WHEN data_1 = 'Neutral' THEN 3.0	
               WHEN data_1 = 'Disagree' THEN 2.0	
               WHEN data_1 = 'Strongly disagree' THEN 1.0
               WHEN data_1 = 'Not Applicable' THEN NULL
              END AS  data_1
             ,CASE
               WHEN data_2 = 'Strongly agree' THEN 5.0	
               WHEN data_2 = 'Agree' THEN 4.0	
               WHEN data_2 = 'Neutral' THEN 3.0	
               WHEN data_2 = 'Disagree' THEN 2.0	
               WHEN data_2 = 'Strongly disagree' THEN 1.0
               WHEN data_2 = 'Not Applicable' THEN NULL
              END AS data_2
             ,CASE
               WHEN ER_1 = 'Strongly agree' THEN 5.0	
               WHEN ER_1 = 'Agree' THEN 4.0	
               WHEN ER_1 = 'Neutral' THEN 3.0	
               WHEN ER_1 = 'Disagree' THEN 2.0	
               WHEN ER_1 = 'Strongly disagree' THEN 1.0
               WHEN ER_1 = 'Not Applicable' THEN NULL
              END AS ER_1
             ,CASE
               WHEN ER_2 = 'Strongly agree' THEN 5.0	
               WHEN ER_2 = 'Agree' THEN 4.0	
               WHEN ER_2 = 'Neutral' THEN 3.0	
               WHEN ER_2 = 'Disagree' THEN 2.0	
               WHEN ER_2 = 'Strongly disagree' THEN 1.0
               WHEN ER_2 = 'Not Applicable' THEN NULL
              END AS ER_2
             ,CASE
               WHEN facilities_7 = 'Strongly agree' THEN 5.0	
               WHEN facilities_7 = 'Agree' THEN 4.0	
               WHEN facilities_7 = 'Neutral' THEN 3.0	
               WHEN facilities_7 = 'Disagree' THEN 2.0	
               WHEN facilities_7 = 'Strongly disagree' THEN 1.0
               WHEN facilities_7 = 'Not Applicable' THEN NULL
              END AS facilities_7
             ,CASE
               WHEN facilities_8 = 'Strongly agree' THEN 5.0	
               WHEN facilities_8 = 'Agree' THEN 4.0	
               WHEN facilities_8 = 'Neutral' THEN 3.0	
               WHEN facilities_8 = 'Disagree' THEN 2.0	
               WHEN facilities_8 = 'Strongly disagree' THEN 1.0
               WHEN facilities_8 = 'Not Applicable' THEN NULL
              END AS facilities_8
             ,CASE
               WHEN humanresources_1 = 'Strongly agree' THEN 5.0	
               WHEN humanresources_1 = 'Agree' THEN 4.0	
               WHEN humanresources_1 = 'Neutral' THEN 3.0	
               WHEN humanresources_1 = 'Disagree' THEN 2.0	
               WHEN humanresources_1 = 'Strongly disagree' THEN 1.0
               WHEN humanresources_1 = 'Not Applicable' THEN NULL
              END AS humanresourcess_1
             ,CASE
               WHEN humanresources_2 = 'Strongly agree' THEN 5.0	
               WHEN humanresources_2 = 'Agree' THEN 4.0	
               WHEN humanresources_2 = 'Neutral' THEN 3.0	
               WHEN humanresources_2 = 'Disagree' THEN 2.0	
               WHEN humanresources_2 = 'Strongly disagree' THEN 1.0
               WHEN humanresources_2 = 'Not Applicable' THEN NULL
              END AS humanresources_2
             ,CASE
               WHEN humanresource_3 = 'Strongly agree' THEN 5.0	
               WHEN humanresource_3 = 'Agree' THEN 4.0	
               WHEN humanresource_3 = 'Neutral' THEN 3.0	
               WHEN humanresource_3 = 'Disagree' THEN 2.0	
               WHEN humanresource_3 = 'Strongly disagree' THEN 1.0
               WHEN humanresource_3 = 'Not Applicable' THEN NULL
              END AS humanresource_3
             ,CASE
               WHEN marketing_3 = 'Strongly agree' THEN 5.0	
               WHEN marketing_3 = 'Agree' THEN 4.0	
               WHEN marketing_3 = 'Neutral' THEN 3.0	
               WHEN marketing_3 = 'Disagree' THEN 2.0	
               WHEN marketing_3 = 'Strongly disagree' THEN 1.0
               WHEN marketing_3 = 'Not Applicable' THEN NULL
              END AS marketing_3
             ,CASE
               WHEN purchasing_9 = 'Strongly agree' THEN 5.0	
               WHEN purchasing_9 = 'Agree' THEN 4.0	
               WHEN purchasing_9 = 'Neutral' THEN 3.0	
               WHEN purchasing_9 = 'Disagree' THEN 2.0	
               WHEN purchasing_9 = 'Strongly disagree' THEN 1.0
               WHEN purchasing_9 = 'Not Applicable' THEN NULL
              END AS purchasing_9
             ,CASE
               WHEN purchasing_10 = 'Strongly agree' THEN 5.0	
               WHEN purchasing_10 = 'Agree' THEN 4.0	
               WHEN purchasing_10 = 'Neutral' THEN 3.0	
               WHEN purchasing_10 = 'Disagree' THEN 2.0	
               WHEN purchasing_10 = 'Strongly disagree' THEN 1.0
               WHEN purchasing_10 = 'Not Applicable' THEN NULL
              END AS purchasing_10
             ,CASE
               WHEN specialeducation_7 = 'Strongly agree' THEN 5.0	
               WHEN specialeducation_7 = 'Agree' THEN 4.0	
               WHEN specialeducation_7 = 'Neutral' THEN 3.0	
               WHEN specialeducation_7 = 'Disagree' THEN 2.0	
               WHEN specialeducation_7 = 'Strongly disagree' THEN 1.0
               WHEN specialeducation_7 = 'Not Applicable' THEN NULL
              END AS specialeducation_7
             ,CASE
               WHEN specialeducation_6 = 'Strongly agree' THEN 5.0	
               WHEN specialeducation_6 = 'Agree' THEN 4.0	
               WHEN specialeducation_6 = 'Neutral' THEN 3.0	
               WHEN specialeducation_6 = 'Disagree' THEN 2.0	
               WHEN specialeducation_6 = 'Strongly disagree' THEN 1.0
               WHEN specialeducation_6 = 'Not Applicable' THEN NULL
              END AS specialeducation_6
             ,CASE
               WHEN specialeducation_6 = 'Yes' THEN 5.0	
               WHEN specialeducation_6 = 'No' THEN 1.0	
               WHEN specialeducation_6 = 'Not Applicable' THEN NULL
              END AS region_1 --yes/no
             ,CASE
               WHEN region_2 = 'Strongly agree' THEN 5.0	
               WHEN region_2 = 'Agree' THEN 4.0	
               WHEN region_2 = 'Neutral' THEN 3.0	
               WHEN region_2 = 'Disagree' THEN 2.0	
               WHEN region_2 = 'Strongly disagree' THEN 1.0
               WHEN region_2 = 'Not Applicable' THEN NULL
              END AS region_2
             ,CASE
               WHEN schooloperations_11 = 'Strongly agree' THEN 5.0	
               WHEN schooloperations_11 = 'Agree' THEN 4.0	
               WHEN schooloperations_11 = 'Neutral' THEN 3.0	
               WHEN schooloperations_11 = 'Disagree' THEN 2.0	
               WHEN schooloperations_11 = 'Strongly disagree' THEN 1.0
               WHEN schooloperations_11 = 'Not Applicable' THEN NULL
              END AS schooloperations_11
             ,CASE
               WHEN region_3 = 'Strongly agree' THEN 5.0	
               WHEN region_3 = 'Agree' THEN 4.0	
               WHEN region_3 = 'Neutral' THEN 3.0	
               WHEN region_3 = 'Disagree' THEN 2.0	
               WHEN region_3 = 'Strongly disagree' THEN 1.0
               WHEN region_3 = 'Not Applicable' THEN NULL
              END AS region_3
             ,CASE
               WHEN region_4 = 'Strongly agree' THEN 5.0	
               WHEN region_4 = 'Agree' THEN 4.0	
               WHEN region_4 = 'Neutral' THEN 3.0	
               WHEN region_4 = 'Disagree' THEN 2.0	
               WHEN region_4 = 'Strongly disagree' THEN 1.0
               WHEN region_4 = 'Not Applicable' THEN NULL
              END AS region_4
             ,CASE
               WHEN region_5 = 'Strongly agree' THEN 5.0	
               WHEN region_5 = 'Agree' THEN 4.0	
               WHEN region_5 = 'Neutral' THEN 3.0	
               WHEN region_5 = 'Disagree' THEN 2.0	
               WHEN region_5 = 'Strongly disagree' THEN 1.0
               WHEN region_5 = 'Not Applicable' THEN NULL
              END AS region_5
             ,CASE
               WHEN teachinglearning_11 = 'Strongly agree' THEN 5.0	
               WHEN teachinglearning_11 = 'Agree' THEN 4.0	
               WHEN teachinglearning_11 = 'Neutral' THEN 3.0	
               WHEN teachinglearning_11 = 'Disagree' THEN 2.0	
               WHEN teachinglearning_11 = 'Strongly disagree' THEN 1.0
               WHEN teachinglearning_11 = 'Not Applicable' THEN NULL
              END AS teachinglearning_11
             ,CASE
               WHEN teachinglearning_12 = 'Strongly agree' THEN 5.0	
               WHEN teachinglearning_12 = 'Agree' THEN 4.0	
               WHEN teachinglearning_12 = 'Neutral' THEN 3.0	
               WHEN teachinglearning_12 = 'Disagree' THEN 2.0	
               WHEN teachinglearning_12 = 'Strongly disagree' THEN 1.0
               WHEN teachinglearning_12 = 'Not Applicable' THEN NULL
              END AS teachinglearning_12
             ,CASE
               WHEN teachinglearning_13 = 'Strongly agree' THEN 5.0	
               WHEN teachinglearning_13 = 'Agree' THEN 4.0	
               WHEN teachinglearning_13 = 'Neutral' THEN 3.0	
               WHEN teachinglearning_13 = 'Disagree' THEN 2.0	
               WHEN teachinglearning_13 = 'Strongly disagree' THEN 1.0
               WHEN teachinglearning_13 = 'Not Applicable' THEN NULL
              END AS teachinglearning_13
             ,CASE
               WHEN technology_14 = 'Strongly agree' THEN 5.0	
               WHEN technology_14 = 'Agree' THEN 4.0	
               WHEN technology_14 = 'Neutral' THEN 3.0	
               WHEN technology_14 = 'Disagree' THEN 2.0	
               WHEN technology_14 = 'Strongly disagree' THEN 1.0
               WHEN technology_14 = 'Not Applicable' THEN NULL
              END AS technology_14
             ,CASE
               WHEN technology_16 = 'Strongly agree' THEN 5.0	
               WHEN technology_16 = 'Agree' THEN 4.0	
               WHEN technology_16 = 'Neutral' THEN 3.0	
               WHEN technology_16 = 'Disagree' THEN 2.0	
               WHEN technology_16 = 'Strongly disagree' THEN 1.0
               WHEN technology_16 = 'Not Applicable' THEN NULL
              END AS technology_16
             ,CASE
               WHEN technology_15 = 'Strongly agree' THEN 5.0	
               WHEN technology_15 = 'Agree' THEN 4.0	
               WHEN technology_15 = 'Neutral' THEN 3.0	
               WHEN technology_15 = 'Disagree' THEN 2.0	
               WHEN technology_15 = 'Strongly disagree' THEN 1.0
               WHEN technology_15 = 'Not Applicable' THEN NULL
              END AS technology_15
             ,CASE
               WHEN region_8 = 'Strongly agree' THEN 5.0	
               WHEN region_8 = 'Agree' THEN 4.0	
               WHEN region_8 = 'Neutral' THEN 3.0	
               WHEN region_8 = 'Disagree' THEN 2.0	
               WHEN region_8 = 'Strongly disagree' THEN 1.0
               WHEN region_8 = 'Not Applicable' THEN NULL
              END AS region_8
       FROM gabby.surveys.r9engagement_survey_final
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
                         ,technologysl                         
                         ,data_1
                         ,data_2
                         ,ER_1
                         ,ER_2
                         ,facilities_7
                         ,facilities_8
                         ,humanresources_1
                         ,humanresources_2
                         ,humanresource_3
                         ,marketing_3
                         ,purchasing_9
                         ,purchasing_10
                         ,specialeducation_7
                         ,specialeducation_6
                         ,region_1
                         ,region_2
                         ,schooloperations_11
                         ,region_3
                         ,region_4
                         ,region_5
                         ,teachinglearning_11
                         ,teachinglearning_12
                         ,teachinglearning_13
                         ,technology_14
                         ,technology_16
                         ,technology_15
                         ,region_8)
   ) u
 )

SELECT su.academic_year
      ,su.reporting_term
      ,su.term_name
      ,su.participant_id
      ,su.associate_id
      ,su.email
      ,su.location
      ,su.n
      ,su.question_code
      ,su.response_value
      ,CASE 
        WHEN su.location = 'Rise' THEN 73252
        WHEN su.location = 'Rise Academy' THEN 73252
        WHEN su.location = 'KIPP Rise Academy' THEN 73252
        WHEN su.location = 'NCA' THEN 73253
        WHEN su.location = 'Newark Collegiate Academy' THEN 73253
        WHEN su.location = 'KIPP Newark Collegiate Academy' THEN 73253
        WHEN su.location = 'SPARK' THEN 73254
        WHEN su.location = 'SPARK Academy' THEN 73254
        WHEN su.location = 'KIPP SPARK Academy' THEN 73254
        WHEN su.location = 'THRIVE' THEN 73255
        WHEN su.location = 'THRIVE Academy' THEN 73255
        WHEN su.location = 'KIPP THRIVE Academy' THEN 73255
        WHEN su.location = 'Seek' THEN 73256
        WHEN su.location = 'Seek Academy' THEN 73256
        WHEN su.location = 'KIPP Seek Academy'  THEN 73256
        WHEN su.location = 'Life Upper' THEN 73257
        WHEN su.location = 'Life Lower' THEN 73257
        WHEN su.location = 'Life' THEN 73257
        WHEN su.location = 'Life Academy' THEN 73257
        WHEN su.location = 'KIPP Life Academy'  THEN 73257
        WHEN su.location = 'Bold' THEN 73258
        WHEN su.location = 'Bold Academy' THEN 73258
        WHEN su.location = 'KIPP BOLD Academy' THEN 73258
        WHEN su.location = 'Revolution' THEN 179901
        WHEN su.location = 'LSP' THEN 179901
        WHEN su.location = 'Lanning Square Primary' THEN 179901
        WHEN su.location = 'KIPP Lanning Square Primary' THEN 179901
        WHEN su.location = 'Lanning Square MS' THEN 179902
        WHEN su.location = 'LSMS' THEN 179902
        WHEN su.location = 'KIPP Lanning Square Middle' THEN 179902
        WHEN su.location = 'Whittier Elementary' THEN 179903
        WHEN su.location = 'KIPP Whittier Elementary' THEN 179903
        WHEN su.location = 'Whittier Middle' THEN 179903
        WHEN su.location = 'Whitter MS' THEN 179903
        WHEN su.location = 'KIPP Whittier Middle' THEN 179903
        WHEN su.location = 'TEAM' THEN 133570965
        WHEN su.location = 'TEAM Academy' THEN 133570965
        WHEN su.location = 'KIPP TEAM Academy' THEN 133570965
        WHEN su.location = 'Pathways' THEN 732574573
        WHEN su.location = 'KIPP Pathways at Bragaw' THEN 732574573
        WHEN su.location = 'KIPP Pathways at 18th Ave' THEN 732585074
        WHEN su.location = 'KIPP Sunrise Academy' THEN 30200801
        WHEN su.location = 'Whitter ES' THEN 1799015075
       END AS reporting_schoolid
      ,CASE 
        WHEN su.location = 'Revolution' THEN 'KCNA'
        WHEN su.location = 'LSP' THEN 'KCNA'
        WHEN su.location = 'Lanning Square Primary' THEN 'KCNA'
        WHEN su.location = 'Lanning Square MS' THEN 'KCNA'
        WHEN su.location = 'LSMS' THEN 'KCNA'
        WHEN su.location = 'Whittier Elementary' THEN 'KCNA'
        WHEN su.location = 'Whittier Middle' THEN 'KCNA'
        WHEN su.location = 'Whitter MS' THEN 'KCNA'
        WHEN su.location = 'Whitter ES' THEN 'KCNA'
        WHEN su.location = 'Lanning Square Campus' THEN 'KCNA'
        WHEN su.location = 'KCNA' THEN 'KCNA'
        WHEN su.location = 'KIPP NJ' THEN 'KNJ'
        WHEN su.location = 'SL''s' THEN 'KNJ'
        WHEN su.location = 'Room9' THEN 'KNJ'
        WHEN su.location = 'Overall' THEN 'KNJ'
        WHEN su.location = 'Room 9' THEN 'KNJ'
        WHEN su.location = 'Rise' THEN 'TEAM'
        WHEN su.location = 'Rise Academy' THEN 'TEAM'
        WHEN su.location = 'NCA' THEN 'TEAM'
        WHEN su.location = 'Newark Collegiate Academy' THEN 'TEAM'
        WHEN su.location = 'SPARK' THEN 'TEAM'
        WHEN su.location = 'SPARK Academy' THEN 'TEAM'
        WHEN su.location = 'THRIVE' THEN 'TEAM'
        WHEN su.location = 'THRIVE Academy' THEN 'TEAM'
        WHEN su.location = 'Seek' THEN 'TEAM'
        WHEN su.location = 'Seek Academy' THEN 'TEAM'
        WHEN su.location = 'Life Upper' THEN 'TEAM'
        WHEN su.location = 'Life Lower' THEN 'TEAM'
        WHEN su.location = 'Life' THEN 'TEAM'
        WHEN su.location = 'Life Academy' THEN 'TEAM'
        WHEN su.location = 'Bold' THEN 'TEAM'
        WHEN su.location = 'Bold Academy' THEN 'TEAM'
        WHEN su.location = 'TEAM' THEN 'TEAM'
        WHEN su.location = 'TEAM Academy' THEN 'TEAM'
        WHEN su.location = 'Pathways' THEN 'TEAM'
        WHEN su.location = 'TEAM Schools' THEN 'TEAM'
        WHEN su.location = '18th Avenue Campus' THEN 'TEAM'
        WHEN su.location = 'KIPP SPARK Academy' THEN 'TEAM'
        WHEN su.location = 'Room 10 - 740 Chestnut St' THEN 'KCNA'
        WHEN su.location = 'KIPP Whittier Middle' THEN 'KCNA'
        WHEN su.location = 'Room 11 - 6745 NW 23rd Ave' THEN 'KNJ'
        WHEN su.location = 'KIPP Newark Collegiate Academy' THEN 'TEAM'
        WHEN su.location = 'KIPP BOLD Academy' THEN 'TEAM'
        WHEN su.location = 'KIPP Lanning Sq Campus' THEN 'KCNA'
        WHEN su.location = 'KIPP Pathways at 18th Ave' THEN 'TEAM'
        WHEN su.location = 'KIPP Seek Academy' THEN 'TEAM'
        WHEN su.location = 'Room 9 - 60 Park Pl' THEN 'KNJ'
        WHEN su.location = 'KIPP TEAM Academy' THEN 'TEAM'
        WHEN su.location = '18th Ave Campus' THEN 'TEAM'
        WHEN su.location = 'KIPP Pathways at Bragaw' THEN 'TEAM'
        WHEN su.location = 'KIPP Life Academy' THEN 'TEAM'
        WHEN su.location = 'KIPP Lanning Square Middle' THEN 'KCNA'
        WHEN su.location = 'KIPP Lanning Square Primary' THEN 'KCNA'
        WHEN su.location = 'KIPP Sunrise Academy' THEN 'KMS'
        WHEN su.location = 'KIPP THRIVE Academy' THEN 'TEAM'
        WHEN su.location = 'KIPP Rise Academy' THEN 'TEAM'
        WHEN su.location = 'KIPP Whittier Elementary' THEN 'KCNA'
       END AS region
      ,CASE 
        WHEN su.location = 'Revolution' THEN 'ES'
        WHEN su.location = 'LSP' THEN 'ES'
        WHEN su.location = 'Lanning Square Primary' THEN 'ES'
        WHEN su.location = 'Whitter ES' THEN 'ES'
        WHEN su.location = 'SPARK' THEN 'ES'
        WHEN su.location = 'SPARK Academy' THEN 'ES'
        WHEN su.location = 'THRIVE' THEN 'ES'
        WHEN su.location = 'THRIVE Academy' THEN 'ES'
        WHEN su.location = 'Seek' THEN 'ES'
        WHEN su.location = 'Seek Academy' THEN 'ES'
        WHEN su.location = 'Life Upper' THEN 'ES'
        WHEN su.location = 'Life Lower' THEN 'ES'
        WHEN su.location = 'Life' THEN 'ES'
        WHEN su.location = 'Life Academy' THEN 'ES'
        WHEN su.location = 'Pathways' THEN 'ES'
        WHEN su.location = 'NCA' THEN 'HS'
        WHEN su.location = 'Newark Collegiate Academy' THEN 'HS'
        WHEN su.location = 'Lanning Square MS' THEN 'MS'
        WHEN su.location = 'LSMS' THEN 'MS'
        WHEN su.location = 'Whittier Elementary' THEN 'MS'
        WHEN su.location = 'Whittier Middle' THEN 'MS'
        WHEN su.location = 'Whitter MS' THEN 'MS'
        WHEN su.location = 'Rise' THEN 'MS'
        WHEN su.location = 'Rise Academy' THEN 'MS'
        WHEN su.location = 'Bold' THEN 'MS'
        WHEN su.location = 'Bold Academy' THEN 'MS'
        WHEN su.location = 'TEAM' THEN 'MS'
        WHEN su.location = 'TEAM Academy' THEN 'MS'
        WHEN su.location = 'KIPP SPARK Academy' THEN 'ES'
        WHEN su.location = 'KIPP Whittier Middle' THEN 'MS'
        WHEN su.location = 'KIPP Newark Collegiate Academy' THEN 'HS'
        WHEN su.location = 'KIPP BOLD Academy' THEN 'HS'
        WHEN su.location = 'KIPP Pathways at 18th Ave' THEN 'MS'
        WHEN su.location = 'KIPP Seek Academy' THEN 'ES'
        WHEN su.location = 'KIPP TEAM Academy' THEN 'MS'
        WHEN su.location = 'KIPP Pathways at Bragaw' THEN 'ES'
        WHEN su.location = 'KIPP Life Academy' THEN 'ES'
        WHEN su.location = 'KIPP Lanning Square Middle' THEN 'MS'
        WHEN su.location = 'KIPP Lanning Square Primary' THEN 'ES'
        WHEN su.location = 'KIPP Sunrise Academy' THEN 'ES'
        WHEN su.location = 'KIPP THRIVE Academy' THEN 'ES'
        WHEN su.location = 'KIPP Rise Academy' THEN 'MS'
        WHEN su.location = 'KIPP Whittier Elementary' THEN 'ES'
       END AS school_level

      ,qk.survey_type
      ,qk.competency
      ,qk.question_text
FROM survey_unpivoted su
LEFT OUTER JOIN gabby.surveys.question_key qk
  ON su.question_code = qk.question_code
 AND su.academic_year = ISNULL(qk.academic_year, su.academic_year)
 AND qk.survey_type = 'R9'