USE gabby GO
CREATE OR ALTER VIEW
  surveys.r9engagement_survey_detail AS
WITH
  survey_unpivoted AS (
    SELECT
      academic_year,
      reporting_term,
      term_name,
      participant_id,
      associate_id,
      email,
      location,
      n,
      REPLACE(question_code, '_', '') AS question_code,
      response_value
    FROM
      (
        SELECT
          academic_year,
          reporting_term,
          term_name,
          participant_id,
          associate_id,
          email,
          location,
          n,
          CAST(
            academicsupportdataanalyticsandstudentinformation_1_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_1_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_2_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_2_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_3_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_3_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_4_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_4_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_5_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_5_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_6_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_6_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_7_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_7_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_8_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_8_s,
          CAST(
            academicsupportdataanalyticsandstudentinformation_9_s AS FLOAT
          ) AS academicsupportdataanalyticsandstudentinformation_9_s,
          CAST(academicsupportteam_1 AS FLOAT) AS academicsupportteam_1,
          CAST(academicsupportteam_10 AS FLOAT) AS academicsupportteam_10,
          CAST(academicsupportteam_11 AS FLOAT) AS academicsupportteam_11,
          CAST(academicsupportteam_2 AS FLOAT) AS academicsupportteam_2,
          CAST(academicsupportteam_3 AS FLOAT) AS academicsupportteam_3,
          CAST(academicsupportteam_4 AS FLOAT) AS academicsupportteam_4,
          CAST(academicsupportteam_5 AS FLOAT) AS academicsupportteam_5,
          CAST(academicsupportteam_6 AS FLOAT) AS academicsupportteam_6,
          CAST(academicsupportteam_7 AS FLOAT) AS academicsupportteam_7,
          CAST(academicsupportteam_8 AS FLOAT) AS academicsupportteam_8,
          CAST(academicsupportteam_9 AS FLOAT) AS academicsupportteam_9,
          CAST(advocacysl_1 AS FLOAT) AS advocacysl_1,
          CAST(advocacysl_2 AS FLOAT) AS advocacysl_2,
          CAST(advocacysl_3 AS FLOAT) AS advocacysl_3,
          CAST(benefits_1 AS FLOAT) AS benefits_1,
          CAST(benefits_2 AS FLOAT) AS benefits_2,
          CAST(benefits_3 AS FLOAT) AS benefits_3,
          CAST(blendedlearning_1 AS FLOAT) AS blendedlearning_1,
          CAST(blendedlearning_2 AS FLOAT) AS blendedlearning_2,
          CAST(blendedlearning_3 AS FLOAT) AS blendedlearning_3,
          CAST(dataandanalysis_1 AS FLOAT) AS dataandanalysis_1,
          CAST(dataandanalysis_2 AS FLOAT) AS dataandanalysis_2,
          CAST(enrollmentschoolleadersonly_1 AS FLOAT) AS enrollmentschoolleadersonly_1,
          CAST(enrollmentschoolleadersonly_2 AS FLOAT) AS enrollmentschoolleadersonly_2,
          CAST(enrollmentschoolleadersonly_3 AS FLOAT) AS enrollmentschoolleadersonly_3,
          CAST(enrollmentschoolleadersonly_4 AS FLOAT) AS enrollmentschoolleadersonly_4,
          CAST(enrollmentschoolleadersonly_5 AS FLOAT) AS enrollmentschoolleadersonly_5,
          CAST(enrollmentschoolleadersonly_6 AS FLOAT) AS enrollmentschoolleadersonly_6,
          CAST(facilities_1 AS FLOAT) AS facilities_1,
          CAST(facilities_1_s AS FLOAT) AS facilities_1_s,
          CAST(facilities_2 AS FLOAT) AS facilities_2,
          CAST(facilities_2_s AS FLOAT) AS facilities_2_s,
          CAST(facilities_3 AS FLOAT) AS facilities_3,
          CAST(facilities_3_s AS FLOAT) AS facilities_3_s,
          CAST(facilities_4 AS FLOAT) AS facilities_4,
          CAST(facilities_4_s AS FLOAT) AS facilities_4_s,
          CAST(facilities_5 AS FLOAT) AS facilities_5,
          CAST(facilities_6 AS FLOAT) AS facilities_6,
          CAST(facilitiesschoolleadersonly_1 AS FLOAT) AS facilitiesschoolleadersonly_1,
          CAST(facilitiesschoolleadersonly_2 AS FLOAT) AS facilitiesschoolleadersonly_2,
          CAST(facilitiesschoolleadersonly_3 AS FLOAT) AS facilitiesschoolleadersonly_3,
          CAST(facilitiessl AS FLOAT) AS facilitiessl,
          CAST(financeaccounting_1_s AS FLOAT) AS financeaccounting_1_s,
          CAST(financeaccounting_2_s AS FLOAT) AS financeaccounting_2_s,
          CAST(financeaccounting_3_s AS FLOAT) AS financeaccounting_3_s,
          CAST(financeaccounting_4_s AS FLOAT) AS financeaccounting_4_s,
          CAST(financeaccountingschoolleadersonly_1_s AS FLOAT) AS financeaccountingschoolleadersonly_1_s,
          CAST(financeaccountingschoolleadersonly_2_s AS FLOAT) AS financeaccountingschoolleadersonly_2_s,
          CAST(financeaccountingschoolleadersonly_3_s AS FLOAT) AS financeaccountingschoolleadersonly_3_s,
          CAST(financeaccountingsl_1 AS FLOAT) AS financeaccountingsl_1,
          CAST(financeaccountingsl_2 AS FLOAT) AS financeaccountingsl_2,
          CAST(financeaccountingsl_3 AS FLOAT) AS financeaccountingsl_3,
          CAST(financeaccountingsl_4 AS FLOAT) AS financeaccountingsl_4,
          CAST(financeaccountingsl_5 AS FLOAT) AS financeaccountingsl_5,
          CAST(financeaccountingsl_6 AS FLOAT) AS financeaccountingsl_6,
          CAST(financeaccountingsl_7 AS FLOAT) AS financeaccountingsl_7,
          CAST(hasl AS FLOAT) AS hasl,
          CAST(humanassets_1 AS FLOAT) AS humanassets_1,
          CAST(humanassets_1_s AS FLOAT) AS humanassets_1_s,
          CAST(humanassets_10 AS FLOAT) AS humanassets_10,
          CAST(humanassets_11 AS FLOAT) AS humanassets_11,
          CAST(humanassets_12 AS FLOAT) AS humanassets_12,
          CAST(humanassets_13 AS FLOAT) AS humanassets_13,
          CAST(humanassets_14 AS FLOAT) AS humanassets_14,
          CAST(humanassets_15 AS FLOAT) AS humanassets_15,
          CAST(humanassets_16 AS FLOAT) AS humanassets_16,
          CAST(humanassets_2 AS FLOAT) AS humanassets_2,
          CAST(humanassets_2_s AS FLOAT) AS humanassets_2_s,
          CAST(humanassets_3 AS FLOAT) AS humanassets_3,
          CAST(humanassets_3_s AS FLOAT) AS humanassets_3_s,
          CAST(humanassets_4 AS FLOAT) AS humanassets_4,
          CAST(humanassets_4_s AS FLOAT) AS humanassets_4_s,
          CAST(humanassets_5 AS FLOAT) AS humanassets_5,
          CAST(humanassets_5_s AS FLOAT) AS humanassets_5_s,
          CAST(humanassets_6 AS FLOAT) AS humanassets_6,
          CAST(humanassets_6_s AS FLOAT) AS humanassets_6_s,
          CAST(humanassets_7 AS FLOAT) AS humanassets_7,
          CAST(humanassets_8 AS FLOAT) AS humanassets_8,
          CAST(humanassets_9 AS FLOAT) AS humanassets_9,
          CAST(humanassetsschoolleadersonly_1 AS FLOAT) AS humanassetsschoolleadersonly_1,
          CAST(humanassetsschoolleadersonly_2 AS FLOAT) AS humanassetsschoolleadersonly_2,
          CAST(humanassetsschoolleadersonly_3 AS FLOAT) AS humanassetsschoolleadersonly_3,
          CAST(kippsharefrequency_5_s AS FLOAT) AS kippsharefrequency_5_s,
          CAST(kippthroughcollege_1 AS FLOAT) AS kippthroughcollege_1,
          CAST(maintenance_1 AS FLOAT) AS maintenance_1,
          CAST(maintenance_11 AS FLOAT) AS maintenance_11,
          CAST(maintenance_12 AS FLOAT) AS maintenance_12,
          CAST(maintenance_13 AS FLOAT) AS maintenance_13,
          CAST(maintenance_14 AS FLOAT) AS maintenance_14,
          CAST(maintenance_15 AS FLOAT) AS maintenance_15,
          CAST(maintenance_2 AS FLOAT) AS maintenance_2,
          CAST(maintenance_21 AS FLOAT) AS maintenance_21,
          CAST(maintenance_22 AS FLOAT) AS maintenance_22,
          CAST(maintenance_23 AS FLOAT) AS maintenance_23,
          CAST(maintenance_3 AS FLOAT) AS maintenance_3,
          CAST(maintenance_4 AS FLOAT) AS maintenance_4,
          CAST(maintenance_5 AS FLOAT) AS maintenance_5,
          CAST(maintenance_6 AS FLOAT) AS maintenance_6,
          CAST(maintenance_7 AS FLOAT) AS maintenance_7,
          CAST(maintenance_8 AS FLOAT) AS maintenance_8,
          CAST(maintenance_9_a AS FLOAT) AS maintenance_9_a,
          CAST(maintenance_9_b AS FLOAT) AS maintenance_9_b,
          CAST(maintenance_9_c AS FLOAT) AS maintenance_9_c,
          CAST(maintenance_9_d AS FLOAT) AS maintenance_9_d,
          CAST(maintenance_9_e AS FLOAT) AS maintenance_9_e,
          CAST(marketing_1 AS FLOAT) AS marketing_1,
          CAST(marketing_2 AS FLOAT) AS marketing_2,
          CAST(marketingschoolleadersonly_1 AS FLOAT) AS marketingschoolleadersonly_1,
          CAST(marketingschoolleadersonly_2 AS FLOAT) AS marketingschoolleadersonly_2,
          CAST(noninstructionalhiringdsor_9_directors_1 AS FLOAT) AS noninstructionalhiringdsor_9_directors_1,
          CAST(noninstructionalhiringdsor_9_directors_2 AS FLOAT) AS noninstructionalhiringdsor_9_directors_2,
          CAST(noninstructionalhiringdsor_9_directors_3 AS FLOAT) AS noninstructionalhiringdsor_9_directors_3,
          CAST(noninstructionalhiringdsor_9_directors_4 AS FLOAT) AS noninstructionalhiringdsor_9_directors_4,
          CAST(noninstructionalhiringdsor_9_directors_5 AS FLOAT) AS noninstructionalhiringdsor_9_directors_5,
          CAST(noninstructionalhiringdsor_9_directors_6 AS FLOAT) AS noninstructionalhiringdsor_9_directors_6,
          CAST(noninstructionalhiringdsor_9_directors_7 AS FLOAT) AS noninstructionalhiringdsor_9_directors_7,
          CAST(nutritionprogramfoodservice_1 AS FLOAT) AS nutritionprogramfoodservice_1,
          CAST(nutritionprogramfoodservice_1_s AS FLOAT) AS nutritionprogramfoodservice_1_s,
          CAST(nutritionprogramfoodservice_2 AS FLOAT) AS nutritionprogramfoodservice_2,
          CAST(nutritionprogramfoodservice_3 AS FLOAT) AS nutritionprogramfoodservice_3,
          CAST(nutritionprogramfoodservice_4 AS FLOAT) AS nutritionprogramfoodservice_4,
          CAST(nutritionprogramfoodservice_5 AS FLOAT) AS nutritionprogramfoodservice_5,
          CAST(nutritionprogramfoodservice_6 AS FLOAT) AS nutritionprogramfoodservice_6,
          CAST(nutritionprogramfoodservice_7 AS FLOAT) AS nutritionprogramfoodservice_7,
          CAST(
            nutritionprogramfoodserviceschoolleadersonly_1 AS FLOAT
          ) AS nutritionprogramfoodserviceschoolleadersonly_1,
          CAST(
            nutritionprogramfoodserviceschoolleadersonly_2 AS FLOAT
          ) AS nutritionprogramfoodserviceschoolleadersonly_2,
          CAST(
            nutritionprogramfoodserviceschoolleadersonly_3 AS FLOAT
          ) AS nutritionprogramfoodserviceschoolleadersonly_3,
          CAST(nutritionschoolleadersonly_1 AS FLOAT) AS nutritionschoolleadersonly_1,
          CAST(nutritionschoolleadersonly_2 AS FLOAT) AS nutritionschoolleadersonly_2,
          CAST(nutritionschoolleadersonly_3 AS FLOAT) AS nutritionschoolleadersonly_3,
          CAST(nutritionschoolleadersonly_4 AS FLOAT) AS nutritionschoolleadersonly_4,
          CAST(purchasing_1 AS FLOAT) AS purchasing_1,
          CAST(purchasing_1_s AS FLOAT) AS purchasing_1_s,
          CAST(purchasing_2 AS FLOAT) AS purchasing_2,
          CAST(purchasing_2_s AS FLOAT) AS purchasing_2_s,
          CAST(purchasing_3 AS FLOAT) AS purchasing_3,
          CAST(purchasing_3_s AS FLOAT) AS purchasing_3_s,
          CAST(purchasing_4 AS FLOAT) AS purchasing_4,
          CAST(purchasing_4_s AS FLOAT) AS purchasing_4_s,
          CAST(purchasing_5 AS FLOAT) AS purchasing_5,
          CAST(purchasing_5_s AS FLOAT) AS purchasing_5_s,
          CAST(purchasing_6 AS FLOAT) AS purchasing_6,
          CAST(purchasing_7 AS FLOAT) AS purchasing_7,
          CAST(purchasing_8 AS FLOAT) AS purchasing_8,
          CAST(purchasingsl AS FLOAT) AS purchasingsl,
          CAST(r_9_q_1201 AS FLOAT) AS r_9_q_1201,
          CAST(r_9_q_1202 AS FLOAT) AS r_9_q_1202,
          CAST(r_9_q_1203 AS FLOAT) AS r_9_q_1203,
          CAST(r_9_q_1204 AS FLOAT) AS r_9_q_1204,
          CAST(r_9_q_1205 AS FLOAT) AS r_9_q_1205,
          CAST(r_9_q_1206 AS FLOAT) AS r_9_q_1206,
          CAST(r_9_q_1207 AS FLOAT) AS r_9_q_1207,
          CAST(r_9_q_1208 AS FLOAT) AS r_9_q_1208,
          CAST(r_9_q_1209 AS FLOAT) AS r_9_q_1209,
          CAST(r_9_q_1210 AS FLOAT) AS r_9_q_1210,
          CAST(r_9_q_1211 AS FLOAT) AS r_9_q_1211,
          CAST(r_9_q_1212 AS FLOAT) AS r_9_q_1212,
          CAST(recruitingschoolleadersonly_1_s AS FLOAT) AS recruitingschoolleadersonly_1_s,
          CAST(recruitingschoolleadersonly_10_s AS FLOAT) AS recruitingschoolleadersonly_10_s,
          CAST(recruitingschoolleadersonly_2_s AS FLOAT) AS recruitingschoolleadersonly_2_s,
          CAST(recruitingschoolleadersonly_3_s AS FLOAT) AS recruitingschoolleadersonly_3_s,
          CAST(recruitingschoolleadersonly_4_s AS FLOAT) AS recruitingschoolleadersonly_4_s,
          CAST(recruitingschoolleadersonly_5_s AS FLOAT) AS recruitingschoolleadersonly_5_s,
          CAST(recruitingschoolleadersonly_6_s AS FLOAT) AS recruitingschoolleadersonly_6_s,
          CAST(recruitingschoolleadersonly_7_s AS FLOAT) AS recruitingschoolleadersonly_7_s,
          CAST(recruitingschoolleadersonly_8_s AS FLOAT) AS recruitingschoolleadersonly_8_s,
          CAST(recruitingschoolleadersonly_9_s AS FLOAT) AS recruitingschoolleadersonly_9_s,
          CAST(recruitmentschoolleadersonly_1 AS FLOAT) AS recruitmentschoolleadersonly_1,
          CAST(recruitmentschoolleadersonly_10 AS FLOAT) AS recruitmentschoolleadersonly_10,
          CAST(recruitmentschoolleadersonly_11 AS FLOAT) AS recruitmentschoolleadersonly_11,
          CAST(recruitmentschoolleadersonly_2 AS FLOAT) AS recruitmentschoolleadersonly_2,
          CAST(recruitmentschoolleadersonly_3 AS FLOAT) AS recruitmentschoolleadersonly_3,
          CAST(recruitmentschoolleadersonly_4 AS FLOAT) AS recruitmentschoolleadersonly_4,
          CAST(recruitmentschoolleadersonly_5 AS FLOAT) AS recruitmentschoolleadersonly_5,
          CAST(recruitmentschoolleadersonly_6 AS FLOAT) AS recruitmentschoolleadersonly_6,
          CAST(recruitmentschoolleadersonly_7 AS FLOAT) AS recruitmentschoolleadersonly_7,
          CAST(recruitmentschoolleadersonly_8 AS FLOAT) AS recruitmentschoolleadersonly_8,
          CAST(recruitmentschoolleadersonly_9 AS FLOAT) AS recruitmentschoolleadersonly_9,
          CAST(schooloperations_1 AS FLOAT) AS schooloperations_1,
          CAST(schooloperations_10 AS FLOAT) AS schooloperations_10,
          CAST(schooloperations_2 AS FLOAT) AS schooloperations_2,
          CAST(schooloperations_3 AS FLOAT) AS schooloperations_3,
          CAST(schooloperations_4 AS FLOAT) AS schooloperations_4,
          CAST(schooloperations_5 AS FLOAT) AS schooloperations_5,
          CAST(schooloperations_6 AS FLOAT) AS schooloperations_6,
          CAST(schooloperations_7 AS FLOAT) AS schooloperations_7,
          CAST(schooloperations_8 AS FLOAT) AS schooloperations_8,
          CAST(schooloperations_9 AS FLOAT) AS schooloperations_9,
          CAST(sharing_1_s AS FLOAT) AS sharing_1_s,
          CAST(sharing_2_s AS FLOAT) AS sharing_2_s,
          CAST(sharing_3_s AS FLOAT) AS sharing_3_s,
          CAST(sharing_4_s AS FLOAT) AS sharing_4_s,
          CAST(specialed_1 AS FLOAT) AS specialed_1,
          CAST(specialeducation_1 AS FLOAT) AS specialeducation_1,
          CAST(specialeducation_1_s AS FLOAT) AS specialeducation_1_s,
          CAST(specialeducation_2 AS FLOAT) AS specialeducation_2,
          CAST(specialeducation_2_s AS FLOAT) AS specialeducation_2_s,
          CAST(specialeducation_3 AS FLOAT) AS specialeducation_3,
          CAST(specialeducation_4 AS FLOAT) AS specialeducation_4,
          CAST(specialeducation_5 AS FLOAT) AS specialeducation_5,
          CAST(studentinformation_1 AS FLOAT) AS studentinformation_1,
          CAST(studentinformation_2 AS FLOAT) AS studentinformation_2,
          CAST(studentinformation_3 AS FLOAT) AS studentinformation_3,
          CAST(teachinglearning_1 AS FLOAT) AS teachinglearning_1,
          CAST(teachinglearning_10 AS FLOAT) AS teachinglearning_10,
          CAST(teachinglearning_2 AS FLOAT) AS teachinglearning_2,
          CAST(teachinglearning_3 AS FLOAT) AS teachinglearning_3,
          CAST(teachinglearning_4 AS FLOAT) AS teachinglearning_4,
          CAST(teachinglearning_5 AS FLOAT) AS teachinglearning_5,
          CAST(teachinglearning_6 AS FLOAT) AS teachinglearning_6,
          CAST(teachinglearning_7 AS FLOAT) AS teachinglearning_7,
          CAST(teachinglearning_8 AS FLOAT) AS teachinglearning_8,
          CAST(teachinglearning_9 AS FLOAT) AS teachinglearning_9,
          CAST(technology_1 AS FLOAT) AS technology_1,
          CAST(technology_1_s AS FLOAT) AS technology_1_s,
          CAST(technology_2 AS FLOAT) AS technology_2,
          CAST(technology_2_s AS FLOAT) AS technology_2_s,
          CAST(technology_3 AS FLOAT) AS technology_3,
          CAST(technology_3_s AS FLOAT) AS technology_3_s,
          CAST(technology_4 AS FLOAT) AS technology_4,
          CAST(technology_4_s AS FLOAT) AS technology_4_s,
          CAST(technology_5 AS FLOAT) AS technology_5,
          CAST(technology_6 AS FLOAT) AS technology_6,
          CAST(technologyschoolleadersonly_1 AS FLOAT) AS technologyschoolleadersonly_1,
          CAST(technologyschoolleadersonly_2 AS FLOAT) AS technologyschoolleadersonly_2,
          CAST(technologyschoolleadersonly_3 AS FLOAT) AS technologyschoolleadersonly_3,
          CAST(technologysl AS FLOAT) AS technologysl,
          CAST(NULL AS FLOAT) AS data_1,
          CAST(NULL AS FLOAT) AS data_2,
          CAST(NULL AS FLOAT) AS ER_1,
          CAST(NULL AS FLOAT) AS ER_2,
          CAST(NULL AS FLOAT) AS facilities_7,
          CAST(NULL AS FLOAT) AS facilities_8,
          CAST(NULL AS FLOAT) AS humanresources_1,
          CAST(NULL AS FLOAT) AS humanresources_2,
          CAST(NULL AS FLOAT) AS humanresource_3,
          CAST(NULL AS FLOAT) AS marketing_3,
          CAST(NULL AS FLOAT) AS purchasing_9,
          CAST(NULL AS FLOAT) AS purchasing_10,
          CAST(NULL AS FLOAT) AS specialeducation_7,
          CAST(NULL AS FLOAT) AS specialeducation_6,
          CAST(NULL AS FLOAT) AS region_1,
          CAST(NULL AS FLOAT) AS region_2,
          CAST(NULL AS FLOAT) AS schooloperations_11,
          CAST(NULL AS FLOAT) AS region_3,
          CAST(NULL AS FLOAT) AS region_4,
          CAST(NULL AS FLOAT) AS region_5,
          CAST(NULL AS FLOAT) AS teachinglearning_11,
          CAST(NULL AS FLOAT) AS teachinglearning_12,
          CAST(NULL AS FLOAT) AS teachinglearning_13,
          CAST(NULL AS FLOAT) AS technology_14,
          CAST(NULL AS FLOAT) AS technology_16,
          CAST(NULL AS FLOAT) AS technology_15,
          CAST(NULL AS FLOAT) AS region_8
        FROM
          gabby.surveys.r9engagement_survey_archive
        UNION ALL
        SELECT
          academic_year,
          reporting_term,
          term_name,
          participant_id,
          associate_id,
          email,
          location,
          NULL AS n,
          NULL AS academicsupportdataanalyticsandstudentinformation_1_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_2_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_3_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_4_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_5_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_6_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_7_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_8_s,
          NULL AS academicsupportdataanalyticsandstudentinformation_9_s,
          NULL AS academicsupportteam_1,
          NULL AS academicsupportteam_10,
          NULL AS academicsupportteam_11,
          NULL AS academicsupportteam_2,
          NULL AS academicsupportteam_3,
          NULL AS academicsupportteam_4,
          NULL AS academicsupportteam_5,
          NULL AS academicsupportteam_6,
          NULL AS academicsupportteam_7,
          NULL AS academicsupportteam_8,
          NULL AS academicsupportteam_9,
          NULL AS advocacysl_1,
          NULL AS advocacysl_2,
          NULL AS advocacysl_3,
          NULL AS benefits_1,
          NULL AS benefits_2,
          NULL AS benefits_3,
          NULL AS blendedlearning_1,
          NULL AS blendedlearning_2,
          NULL AS blendedlearning_3,
          NULL AS dataandanalysis_1,
          NULL AS dataandanalysis_2,
          NULL AS enrollmentschoolleadersonly_1,
          NULL AS enrollmentschoolleadersonly_2,
          NULL AS enrollmentschoolleadersonly_3,
          NULL AS enrollmentschoolleadersonly_4,
          NULL AS enrollmentschoolleadersonly_5,
          NULL AS enrollmentschoolleadersonly_6,
          NULL AS facilities_1,
          NULL AS facilities_1_s,
          NULL AS facilities_2,
          NULL AS facilities_2_s,
          NULL AS facilities_3,
          NULL AS facilities_3_s,
          NULL AS facilities_4,
          NULL AS facilities_4_s,
          NULL AS facilities_5,
          NULL AS facilities_6,
          NULL AS facilitiesschoolleadersonly_1,
          NULL AS facilitiesschoolleadersonly_2,
          NULL AS facilitiesschoolleadersonly_3,
          NULL AS facilitiessl,
          NULL AS financeaccounting_1_s,
          NULL AS financeaccounting_2_s,
          NULL AS financeaccounting_3_s,
          NULL AS financeaccounting_4_s,
          NULL AS financeaccountingschoolleadersonly_1_s,
          NULL AS financeaccountingschoolleadersonly_2_s,
          NULL AS financeaccountingschoolleadersonly_3_s,
          NULL AS financeaccountingsl_1,
          NULL AS financeaccountingsl_2,
          NULL AS financeaccountingsl_3,
          NULL AS financeaccountingsl_4,
          NULL AS financeaccountingsl_5,
          NULL AS financeaccountingsl_6,
          NULL AS financeaccountingsl_7,
          NULL AS hasl,
          NULL AS humanassets_1,
          NULL AS humanassets_1_s,
          NULL AS humanassets_10,
          NULL AS humanassets_11,
          NULL AS humanassets_12,
          NULL AS humanassets_13,
          NULL AS humanassets_14,
          NULL AS humanassets_15,
          NULL AS humanassets_16,
          NULL AS humanassets_2,
          NULL AS humanassets_2_s,
          NULL AS humanassets_3,
          NULL AS humanassets_3_s,
          NULL AS humanassets_4,
          NULL AS humanassets_4_s,
          NULL AS humanassets_5,
          NULL AS humanassets_5_s,
          NULL AS humanassets_6,
          NULL AS humanassets_6_s,
          NULL AS humanassets_7,
          NULL AS humanassets_8,
          NULL AS humanassets_9,
          NULL AS humanassetsschoolleadersonly_1,
          NULL AS humanassetsschoolleadersonly_2,
          NULL AS humanassetsschoolleadersonly_3,
          NULL AS kippsharefrequency_5_s,
          NULL AS kippthroughcollege_1,
          NULL AS maintenance_1,
          NULL AS maintenance_11,
          NULL AS maintenance_12,
          NULL AS maintenance_13,
          NULL AS maintenance_14,
          NULL AS maintenance_15,
          NULL AS maintenance_2,
          NULL AS maintenance_21,
          NULL AS maintenance_22,
          NULL AS maintenance_23,
          NULL AS maintenance_3,
          NULL AS maintenance_4,
          NULL AS maintenance_5,
          NULL AS maintenance_6,
          NULL AS maintenance_7,
          NULL AS maintenance_8,
          NULL AS maintenance_9_a,
          NULL AS maintenance_9_b,
          NULL AS maintenance_9_c,
          NULL AS maintenance_9_d,
          NULL AS maintenance_9_e,
          NULL AS marketing_1,
          NULL AS marketing_2,
          NULL AS marketingschoolleadersonly_1,
          NULL AS marketingschoolleadersonly_2,
          NULL AS noninstructionalhiringdsor_9_directors_1,
          NULL AS noninstructionalhiringdsor_9_directors_2,
          NULL AS noninstructionalhiringdsor_9_directors_3,
          NULL AS noninstructionalhiringdsor_9_directors_4,
          NULL AS noninstructionalhiringdsor_9_directors_5,
          NULL AS noninstructionalhiringdsor_9_directors_6,
          NULL AS noninstructionalhiringdsor_9_directors_7,
          NULL AS nutritionprogramfoodservice_1,
          NULL AS nutritionprogramfoodservice_1_s,
          NULL AS nutritionprogramfoodservice_2,
          NULL AS nutritionprogramfoodservice_3,
          NULL AS nutritionprogramfoodservice_4,
          NULL AS nutritionprogramfoodservice_5,
          NULL AS nutritionprogramfoodservice_6,
          NULL AS nutritionprogramfoodservice_7,
          NULL AS nutritionprogramfoodserviceschoolleadersonly_1,
          NULL AS nutritionprogramfoodserviceschoolleadersonly_2,
          NULL AS nutritionprogramfoodserviceschoolleadersonly_3,
          NULL AS nutritionschoolleadersonly_1,
          NULL AS nutritionschoolleadersonly_2,
          NULL AS nutritionschoolleadersonly_3,
          NULL AS nutritionschoolleadersonly_4,
          NULL AS purchasing_1,
          NULL AS purchasing_1_s,
          NULL AS purchasing_2,
          NULL AS purchasing_2_s,
          NULL AS purchasing_3,
          NULL AS purchasing_3_s,
          NULL AS purchasing_4,
          NULL AS purchasing_4_s,
          NULL AS purchasing_5,
          NULL AS purchasing_5_s,
          NULL AS purchasing_6,
          NULL AS purchasing_7,
          NULL AS purchasing_8,
          NULL AS purchasingsl,
          CASE
            WHEN r_9_q_1201 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1201 = 'Agree' THEN 4.0
            WHEN r_9_q_1201 = 'Neutral' THEN 3.0
            WHEN r_9_q_1201 = 'Disagree' THEN 2.0
            WHEN r_9_q_1201 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1201,
          CASE
            WHEN r_9_q_1202 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1202 = 'Agree' THEN 4.0
            WHEN r_9_q_1202 = 'Neutral' THEN 3.0
            WHEN r_9_q_1202 = 'Disagree' THEN 2.0
            WHEN r_9_q_1202 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1202,
          CASE
            WHEN r_9_q_1203 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1203 = 'Agree' THEN 4.0
            WHEN r_9_q_1203 = 'Neutral' THEN 3.0
            WHEN r_9_q_1203 = 'Disagree' THEN 2.0
            WHEN r_9_q_1203 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1203,
          CASE
            WHEN r_9_q_1204 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1204 = 'Agree' THEN 4.0
            WHEN r_9_q_1204 = 'Neutral' THEN 3.0
            WHEN r_9_q_1204 = 'Disagree' THEN 2.0
            WHEN r_9_q_1204 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1204,
          CASE
            WHEN r_9_q_1205 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1205 = 'Agree' THEN 4.0
            WHEN r_9_q_1205 = 'Neutral' THEN 3.0
            WHEN r_9_q_1205 = 'Disagree' THEN 2.0
            WHEN r_9_q_1205 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1205,
          CASE
            WHEN r_9_q_1206 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1206 = 'Agree' THEN 4.0
            WHEN r_9_q_1206 = 'Neutral' THEN 3.0
            WHEN r_9_q_1206 = 'Disagree' THEN 2.0
            WHEN r_9_q_1206 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1206,
          CASE
            WHEN r_9_q_1207 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1207 = 'Agree' THEN 4.0
            WHEN r_9_q_1207 = 'Neutral' THEN 3.0
            WHEN r_9_q_1207 = 'Disagree' THEN 2.0
            WHEN r_9_q_1207 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1207,
          CASE
            WHEN r_9_q_1208 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1208 = 'Agree' THEN 4.0
            WHEN r_9_q_1208 = 'Neutral' THEN 3.0
            WHEN r_9_q_1208 = 'Disagree' THEN 2.0
            WHEN r_9_q_1208 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1208,
          CASE
            WHEN r_9_q_1209 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1209 = 'Agree' THEN 4.0
            WHEN r_9_q_1209 = 'Neutral' THEN 3.0
            WHEN r_9_q_1209 = 'Disagree' THEN 2.0
            WHEN r_9_q_1209 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1209,
          CASE
            WHEN r_9_q_1210 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1210 = 'Agree' THEN 4.0
            WHEN r_9_q_1210 = 'Neutral' THEN 3.0
            WHEN r_9_q_1210 = 'Disagree' THEN 2.0
            WHEN r_9_q_1210 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1210,
          CASE
            WHEN r_9_q_1211 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1211 = 'Agree' THEN 4.0
            WHEN r_9_q_1211 = 'Neutral' THEN 3.0
            WHEN r_9_q_1211 = 'Disagree' THEN 2.0
            WHEN r_9_q_1211 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1211,
          CASE
            WHEN r_9_q_1212 = 'Strongly agree' THEN 5.0
            WHEN r_9_q_1212 = 'Agree' THEN 4.0
            WHEN r_9_q_1212 = 'Neutral' THEN 3.0
            WHEN r_9_q_1212 = 'Disagree' THEN 2.0
            WHEN r_9_q_1212 = 'Strongly disagree' THEN 1.0
          END AS r_9_q_1212,
          NULL AS recruitingschoolleadersonly_1_s,
          NULL AS recruitingschoolleadersonly_10_s,
          NULL AS recruitingschoolleadersonly_2_s,
          NULL AS recruitingschoolleadersonly_3_s,
          NULL AS recruitingschoolleadersonly_4_s,
          NULL AS recruitingschoolleadersonly_5_s,
          NULL AS recruitingschoolleadersonly_6_s,
          NULL AS recruitingschoolleadersonly_7_s,
          NULL AS recruitingschoolleadersonly_8_s,
          NULL AS recruitingschoolleadersonly_9_s,
          NULL AS recruitmentschoolleadersonly_1,
          NULL AS recruitmentschoolleadersonly_10,
          NULL AS recruitmentschoolleadersonly_11,
          NULL AS recruitmentschoolleadersonly_2,
          NULL AS recruitmentschoolleadersonly_3,
          NULL AS recruitmentschoolleadersonly_4,
          NULL AS recruitmentschoolleadersonly_5,
          NULL AS recruitmentschoolleadersonly_6,
          NULL AS recruitmentschoolleadersonly_7,
          NULL AS recruitmentschoolleadersonly_8,
          NULL AS recruitmentschoolleadersonly_9,
          NULL AS schooloperations_1,
          NULL AS schooloperations_10,
          NULL AS schooloperations_2,
          NULL AS schooloperations_3,
          NULL AS schooloperations_4,
          NULL AS schooloperations_5,
          NULL AS schooloperations_6,
          NULL AS schooloperations_7,
          NULL AS schooloperations_8,
          NULL AS schooloperations_9,
          NULL AS sharing_1_s,
          NULL AS sharing_2_s,
          NULL AS sharing_3_s,
          NULL AS sharing_4_s,
          NULL AS specialed_1,
          NULL AS specialeducation_1,
          NULL AS specialeducation_1_s,
          NULL AS specialeducation_2,
          NULL AS specialeducation_2_s,
          NULL AS specialeducation_3,
          NULL AS specialeducation_4,
          NULL AS specialeducation_5,
          NULL AS studentinformation_1,
          NULL AS studentinformation_2,
          NULL AS studentinformation_3,
          NULL AS teachinglearning_1,
          NULL AS teachinglearning_10,
          NULL AS teachinglearning_2,
          NULL AS teachinglearning_3,
          NULL AS teachinglearning_4,
          NULL AS teachinglearning_5,
          NULL AS teachinglearning_6,
          NULL AS teachinglearning_7,
          NULL AS teachinglearning_8,
          NULL AS teachinglearning_9,
          NULL AS technology_1,
          NULL AS technology_1_s,
          NULL AS technology_2,
          NULL AS technology_2_s,
          NULL AS technology_3,
          NULL AS technology_3_s,
          NULL AS technology_4,
          NULL AS technology_4_s,
          NULL AS technology_5,
          NULL AS technology_6,
          NULL AS technologyschoolleadersonly_1,
          NULL AS technologyschoolleadersonly_2,
          NULL AS technologyschoolleadersonly_3,
          NULL AS technologysl,
          CASE
            WHEN data_1 = 'Strongly agree' THEN 5.0
            WHEN data_1 = 'Agree' THEN 4.0
            WHEN data_1 = 'Neutral' THEN 3.0
            WHEN data_1 = 'Disagree' THEN 2.0
            WHEN data_1 = 'Strongly disagree' THEN 1.0
            WHEN data_1 = 'Not Applicable' THEN NULL
          END AS data_1,
          CASE
            WHEN data_2 = 'Strongly agree' THEN 5.0
            WHEN data_2 = 'Agree' THEN 4.0
            WHEN data_2 = 'Neutral' THEN 3.0
            WHEN data_2 = 'Disagree' THEN 2.0
            WHEN data_2 = 'Strongly disagree' THEN 1.0
            WHEN data_2 = 'Not Applicable' THEN NULL
          END AS data_2,
          CASE
            WHEN ER_1 = 'Strongly agree' THEN 5.0
            WHEN ER_1 = 'Agree' THEN 4.0
            WHEN ER_1 = 'Neutral' THEN 3.0
            WHEN ER_1 = 'Disagree' THEN 2.0
            WHEN ER_1 = 'Strongly disagree' THEN 1.0
            WHEN ER_1 = 'Not Applicable' THEN NULL
          END AS ER_1,
          CASE
            WHEN ER_2 = 'Strongly agree' THEN 5.0
            WHEN ER_2 = 'Agree' THEN 4.0
            WHEN ER_2 = 'Neutral' THEN 3.0
            WHEN ER_2 = 'Disagree' THEN 2.0
            WHEN ER_2 = 'Strongly disagree' THEN 1.0
            WHEN ER_2 = 'Not Applicable' THEN NULL
          END AS ER_2,
          CASE
            WHEN facilities_7 = 'Strongly agree' THEN 5.0
            WHEN facilities_7 = 'Agree' THEN 4.0
            WHEN facilities_7 = 'Neutral' THEN 3.0
            WHEN facilities_7 = 'Disagree' THEN 2.0
            WHEN facilities_7 = 'Strongly disagree' THEN 1.0
            WHEN facilities_7 = 'Not Applicable' THEN NULL
          END AS facilities_7,
          CASE
            WHEN facilities_8 = 'Strongly agree' THEN 5.0
            WHEN facilities_8 = 'Agree' THEN 4.0
            WHEN facilities_8 = 'Neutral' THEN 3.0
            WHEN facilities_8 = 'Disagree' THEN 2.0
            WHEN facilities_8 = 'Strongly disagree' THEN 1.0
            WHEN facilities_8 = 'Not Applicable' THEN NULL
          END AS facilities_8,
          CASE
            WHEN humanresources_1 = 'Strongly agree' THEN 5.0
            WHEN humanresources_1 = 'Agree' THEN 4.0
            WHEN humanresources_1 = 'Neutral' THEN 3.0
            WHEN humanresources_1 = 'Disagree' THEN 2.0
            WHEN humanresources_1 = 'Strongly disagree' THEN 1.0
            WHEN humanresources_1 = 'Not Applicable' THEN NULL
          END AS humanresourcess_1,
          CASE
            WHEN humanresources_2 = 'Strongly agree' THEN 5.0
            WHEN humanresources_2 = 'Agree' THEN 4.0
            WHEN humanresources_2 = 'Neutral' THEN 3.0
            WHEN humanresources_2 = 'Disagree' THEN 2.0
            WHEN humanresources_2 = 'Strongly disagree' THEN 1.0
            WHEN humanresources_2 = 'Not Applicable' THEN NULL
          END AS humanresources_2,
          CASE
            WHEN humanresource_3 = 'Strongly agree' THEN 5.0
            WHEN humanresource_3 = 'Agree' THEN 4.0
            WHEN humanresource_3 = 'Neutral' THEN 3.0
            WHEN humanresource_3 = 'Disagree' THEN 2.0
            WHEN humanresource_3 = 'Strongly disagree' THEN 1.0
            WHEN humanresource_3 = 'Not Applicable' THEN NULL
          END AS humanresource_3,
          CASE
            WHEN marketing_3 = 'Strongly agree' THEN 5.0
            WHEN marketing_3 = 'Agree' THEN 4.0
            WHEN marketing_3 = 'Neutral' THEN 3.0
            WHEN marketing_3 = 'Disagree' THEN 2.0
            WHEN marketing_3 = 'Strongly disagree' THEN 1.0
            WHEN marketing_3 = 'Not Applicable' THEN NULL
          END AS marketing_3,
          CASE
            WHEN purchasing_9 = 'Strongly agree' THEN 5.0
            WHEN purchasing_9 = 'Agree' THEN 4.0
            WHEN purchasing_9 = 'Neutral' THEN 3.0
            WHEN purchasing_9 = 'Disagree' THEN 2.0
            WHEN purchasing_9 = 'Strongly disagree' THEN 1.0
            WHEN purchasing_9 = 'Not Applicable' THEN NULL
          END AS purchasing_9,
          CASE
            WHEN purchasing_10 = 'Strongly agree' THEN 5.0
            WHEN purchasing_10 = 'Agree' THEN 4.0
            WHEN purchasing_10 = 'Neutral' THEN 3.0
            WHEN purchasing_10 = 'Disagree' THEN 2.0
            WHEN purchasing_10 = 'Strongly disagree' THEN 1.0
            WHEN purchasing_10 = 'Not Applicable' THEN NULL
          END AS purchasing_10,
          CASE
            WHEN specialeducation_7 = 'Strongly agree' THEN 5.0
            WHEN specialeducation_7 = 'Agree' THEN 4.0
            WHEN specialeducation_7 = 'Neutral' THEN 3.0
            WHEN specialeducation_7 = 'Disagree' THEN 2.0
            WHEN specialeducation_7 = 'Strongly disagree' THEN 1.0
            WHEN specialeducation_7 = 'Not Applicable' THEN NULL
          END AS specialeducation_7,
          CASE
            WHEN specialeducation_6 = 'Strongly agree' THEN 5.0
            WHEN specialeducation_6 = 'Agree' THEN 4.0
            WHEN specialeducation_6 = 'Neutral' THEN 3.0
            WHEN specialeducation_6 = 'Disagree' THEN 2.0
            WHEN specialeducation_6 = 'Strongly disagree' THEN 1.0
            WHEN specialeducation_6 = 'Not Applicable' THEN NULL
          END AS specialeducation_6,
          CASE
            WHEN specialeducation_6 = 'Yes' THEN 5.0
            WHEN specialeducation_6 = 'No' THEN 1.0
            WHEN specialeducation_6 = 'Not Applicable' THEN NULL
          END AS region_1 --yes/no
,
          CASE
            WHEN region_2 = 'Strongly agree' THEN 5.0
            WHEN region_2 = 'Agree' THEN 4.0
            WHEN region_2 = 'Neutral' THEN 3.0
            WHEN region_2 = 'Disagree' THEN 2.0
            WHEN region_2 = 'Strongly disagree' THEN 1.0
            WHEN region_2 = 'Not Applicable' THEN NULL
          END AS region_2,
          CASE
            WHEN schooloperations_11 = 'Strongly agree' THEN 5.0
            WHEN schooloperations_11 = 'Agree' THEN 4.0
            WHEN schooloperations_11 = 'Neutral' THEN 3.0
            WHEN schooloperations_11 = 'Disagree' THEN 2.0
            WHEN schooloperations_11 = 'Strongly disagree' THEN 1.0
            WHEN schooloperations_11 = 'Not Applicable' THEN NULL
          END AS schooloperations_11,
          CASE
            WHEN region_3 = 'Strongly agree' THEN 5.0
            WHEN region_3 = 'Agree' THEN 4.0
            WHEN region_3 = 'Neutral' THEN 3.0
            WHEN region_3 = 'Disagree' THEN 2.0
            WHEN region_3 = 'Strongly disagree' THEN 1.0
            WHEN region_3 = 'Not Applicable' THEN NULL
          END AS region_3,
          CASE
            WHEN region_4 = 'Strongly agree' THEN 5.0
            WHEN region_4 = 'Agree' THEN 4.0
            WHEN region_4 = 'Neutral' THEN 3.0
            WHEN region_4 = 'Disagree' THEN 2.0
            WHEN region_4 = 'Strongly disagree' THEN 1.0
            WHEN region_4 = 'Not Applicable' THEN NULL
          END AS region_4,
          CASE
            WHEN region_5 = 'Strongly agree' THEN 5.0
            WHEN region_5 = 'Agree' THEN 4.0
            WHEN region_5 = 'Neutral' THEN 3.0
            WHEN region_5 = 'Disagree' THEN 2.0
            WHEN region_5 = 'Strongly disagree' THEN 1.0
            WHEN region_5 = 'Not Applicable' THEN NULL
          END AS region_5,
          CASE
            WHEN teachinglearning_11 = 'Strongly agree' THEN 5.0
            WHEN teachinglearning_11 = 'Agree' THEN 4.0
            WHEN teachinglearning_11 = 'Neutral' THEN 3.0
            WHEN teachinglearning_11 = 'Disagree' THEN 2.0
            WHEN teachinglearning_11 = 'Strongly disagree' THEN 1.0
            WHEN teachinglearning_11 = 'Not Applicable' THEN NULL
          END AS teachinglearning_11,
          CASE
            WHEN teachinglearning_12 = 'Strongly agree' THEN 5.0
            WHEN teachinglearning_12 = 'Agree' THEN 4.0
            WHEN teachinglearning_12 = 'Neutral' THEN 3.0
            WHEN teachinglearning_12 = 'Disagree' THEN 2.0
            WHEN teachinglearning_12 = 'Strongly disagree' THEN 1.0
            WHEN teachinglearning_12 = 'Not Applicable' THEN NULL
          END AS teachinglearning_12,
          CASE
            WHEN teachinglearning_13 = 'Strongly agree' THEN 5.0
            WHEN teachinglearning_13 = 'Agree' THEN 4.0
            WHEN teachinglearning_13 = 'Neutral' THEN 3.0
            WHEN teachinglearning_13 = 'Disagree' THEN 2.0
            WHEN teachinglearning_13 = 'Strongly disagree' THEN 1.0
            WHEN teachinglearning_13 = 'Not Applicable' THEN NULL
          END AS teachinglearning_13,
          CASE
            WHEN technology_14 = 'Strongly agree' THEN 5.0
            WHEN technology_14 = 'Agree' THEN 4.0
            WHEN technology_14 = 'Neutral' THEN 3.0
            WHEN technology_14 = 'Disagree' THEN 2.0
            WHEN technology_14 = 'Strongly disagree' THEN 1.0
            WHEN technology_14 = 'Not Applicable' THEN NULL
          END AS technology_14,
          CASE
            WHEN technology_16 = 'Strongly agree' THEN 5.0
            WHEN technology_16 = 'Agree' THEN 4.0
            WHEN technology_16 = 'Neutral' THEN 3.0
            WHEN technology_16 = 'Disagree' THEN 2.0
            WHEN technology_16 = 'Strongly disagree' THEN 1.0
            WHEN technology_16 = 'Not Applicable' THEN NULL
          END AS technology_16,
          CASE
            WHEN technology_15 = 'Strongly agree' THEN 5.0
            WHEN technology_15 = 'Agree' THEN 4.0
            WHEN technology_15 = 'Neutral' THEN 3.0
            WHEN technology_15 = 'Disagree' THEN 2.0
            WHEN technology_15 = 'Strongly disagree' THEN 1.0
            WHEN technology_15 = 'Not Applicable' THEN NULL
          END AS technology_15,
          CASE
            WHEN region_8 = 'Strongly agree' THEN 5.0
            WHEN region_8 = 'Agree' THEN 4.0
            WHEN region_8 = 'Neutral' THEN 3.0
            WHEN region_8 = 'Disagree' THEN 2.0
            WHEN region_8 = 'Strongly disagree' THEN 1.0
            WHEN region_8 = 'Not Applicable' THEN NULL
          END AS region_8
        FROM
          gabby.surveys.r9engagement_survey_final
      ) sub UNPIVOT (
        response_value FOR question_code IN (
          academicsupportdataanalyticsandstudentinformation_1_s,
          academicsupportdataanalyticsandstudentinformation_2_s,
          academicsupportdataanalyticsandstudentinformation_3_s,
          academicsupportdataanalyticsandstudentinformation_4_s,
          academicsupportdataanalyticsandstudentinformation_5_s,
          academicsupportdataanalyticsandstudentinformation_6_s,
          academicsupportdataanalyticsandstudentinformation_7_s,
          academicsupportdataanalyticsandstudentinformation_8_s,
          academicsupportdataanalyticsandstudentinformation_9_s,
          academicsupportteam_1,
          academicsupportteam_10,
          academicsupportteam_11,
          academicsupportteam_2,
          academicsupportteam_3,
          academicsupportteam_4,
          academicsupportteam_5,
          academicsupportteam_6,
          academicsupportteam_7,
          academicsupportteam_8,
          academicsupportteam_9,
          advocacysl_1,
          advocacysl_2,
          advocacysl_3,
          benefits_1,
          benefits_2,
          benefits_3,
          blendedlearning_1,
          blendedlearning_2,
          blendedlearning_3,
          dataandanalysis_1,
          dataandanalysis_2,
          enrollmentschoolleadersonly_1,
          enrollmentschoolleadersonly_2,
          enrollmentschoolleadersonly_3,
          enrollmentschoolleadersonly_4,
          enrollmentschoolleadersonly_5,
          enrollmentschoolleadersonly_6,
          facilities_1,
          facilities_1_s,
          facilities_2,
          facilities_2_s,
          facilities_3,
          facilities_3_s,
          facilities_4,
          facilities_4_s,
          facilities_5,
          facilities_6,
          facilitiesschoolleadersonly_1,
          facilitiesschoolleadersonly_2,
          facilitiesschoolleadersonly_3,
          facilitiessl,
          financeaccounting_1_s,
          financeaccounting_2_s,
          financeaccounting_3_s,
          financeaccounting_4_s,
          financeaccountingschoolleadersonly_1_s,
          financeaccountingschoolleadersonly_2_s,
          financeaccountingschoolleadersonly_3_s,
          financeaccountingsl_1,
          financeaccountingsl_2,
          financeaccountingsl_3,
          financeaccountingsl_4,
          financeaccountingsl_5,
          financeaccountingsl_6,
          financeaccountingsl_7,
          hasl,
          humanassets_1,
          humanassets_1_s,
          humanassets_10,
          humanassets_11,
          humanassets_12,
          humanassets_13,
          humanassets_14,
          humanassets_15,
          humanassets_16,
          humanassets_2,
          humanassets_2_s,
          humanassets_3,
          humanassets_3_s,
          humanassets_4,
          humanassets_4_s,
          humanassets_5,
          humanassets_5_s,
          humanassets_6,
          humanassets_6_s,
          humanassets_7,
          humanassets_8,
          humanassets_9,
          humanassetsschoolleadersonly_1,
          humanassetsschoolleadersonly_2,
          humanassetsschoolleadersonly_3,
          kippsharefrequency_5_s,
          kippthroughcollege_1,
          maintenance_1,
          maintenance_11,
          maintenance_12,
          maintenance_13,
          maintenance_14,
          maintenance_15,
          maintenance_2,
          maintenance_21,
          maintenance_22,
          maintenance_23,
          maintenance_3,
          maintenance_4,
          maintenance_5,
          maintenance_6,
          maintenance_7,
          maintenance_8,
          maintenance_9_a,
          maintenance_9_b,
          maintenance_9_c,
          maintenance_9_d,
          maintenance_9_e,
          marketing_1,
          marketing_2,
          marketingschoolleadersonly_1,
          marketingschoolleadersonly_2,
          noninstructionalhiringdsor_9_directors_1,
          noninstructionalhiringdsor_9_directors_2,
          noninstructionalhiringdsor_9_directors_3,
          noninstructionalhiringdsor_9_directors_4,
          noninstructionalhiringdsor_9_directors_5,
          noninstructionalhiringdsor_9_directors_6,
          noninstructionalhiringdsor_9_directors_7,
          nutritionprogramfoodservice_1,
          nutritionprogramfoodservice_1_s,
          nutritionprogramfoodservice_2,
          nutritionprogramfoodservice_3,
          nutritionprogramfoodservice_4,
          nutritionprogramfoodservice_5,
          nutritionprogramfoodservice_6,
          nutritionprogramfoodservice_7,
          nutritionprogramfoodserviceschoolleadersonly_1,
          nutritionprogramfoodserviceschoolleadersonly_2,
          nutritionprogramfoodserviceschoolleadersonly_3,
          nutritionschoolleadersonly_1,
          nutritionschoolleadersonly_2,
          nutritionschoolleadersonly_3,
          nutritionschoolleadersonly_4,
          purchasing_1,
          purchasing_1_s,
          purchasing_2,
          purchasing_2_s,
          purchasing_3,
          purchasing_3_s,
          purchasing_4,
          purchasing_4_s,
          purchasing_5,
          purchasing_5_s,
          purchasing_6,
          purchasing_7,
          purchasing_8,
          purchasingsl,
          r_9_q_1201,
          r_9_q_1202,
          r_9_q_1203,
          r_9_q_1204,
          r_9_q_1205,
          r_9_q_1206,
          r_9_q_1207,
          r_9_q_1208,
          r_9_q_1209,
          r_9_q_1210,
          r_9_q_1211,
          r_9_q_1212,
          recruitingschoolleadersonly_1_s,
          recruitingschoolleadersonly_10_s,
          recruitingschoolleadersonly_2_s,
          recruitingschoolleadersonly_3_s,
          recruitingschoolleadersonly_4_s,
          recruitingschoolleadersonly_5_s,
          recruitingschoolleadersonly_6_s,
          recruitingschoolleadersonly_7_s,
          recruitingschoolleadersonly_8_s,
          recruitingschoolleadersonly_9_s,
          recruitmentschoolleadersonly_1,
          recruitmentschoolleadersonly_11,
          recruitmentschoolleadersonly_2,
          recruitmentschoolleadersonly_3,
          recruitmentschoolleadersonly_4,
          recruitmentschoolleadersonly_5,
          recruitmentschoolleadersonly_6,
          recruitmentschoolleadersonly_7,
          recruitmentschoolleadersonly_8,
          recruitmentschoolleadersonly_9,
          recruitmentschoolleadersonly_10,
          schooloperations_1,
          schooloperations_10,
          schooloperations_2,
          schooloperations_3,
          schooloperations_4,
          schooloperations_5,
          schooloperations_6,
          schooloperations_7,
          schooloperations_8,
          schooloperations_9,
          sharing_1_s,
          sharing_2_s,
          sharing_3_s,
          sharing_4_s,
          specialed_1,
          specialeducation_1,
          specialeducation_1_s,
          specialeducation_2,
          specialeducation_2_s,
          specialeducation_3,
          specialeducation_4,
          specialeducation_5,
          studentinformation_1,
          studentinformation_2,
          studentinformation_3,
          teachinglearning_1,
          teachinglearning_10,
          teachinglearning_2,
          teachinglearning_3,
          teachinglearning_4,
          teachinglearning_5,
          teachinglearning_6,
          teachinglearning_7,
          teachinglearning_8,
          teachinglearning_9,
          technology_1,
          technology_1_s,
          technology_2,
          technology_2_s,
          technology_3,
          technology_3_s,
          technology_4,
          technology_4_s,
          technology_5,
          technology_6,
          technologyschoolleadersonly_1,
          technologyschoolleadersonly_2,
          technologyschoolleadersonly_3,
          technologysl,
          data_1,
          data_2,
          ER_1,
          ER_2,
          facilities_7,
          facilities_8,
          humanresources_1,
          humanresources_2,
          humanresource_3,
          marketing_3,
          purchasing_9,
          purchasing_10,
          specialeducation_7,
          specialeducation_6,
          region_1,
          region_2,
          schooloperations_11,
          region_3,
          region_4,
          region_5,
          teachinglearning_11,
          teachinglearning_12,
          teachinglearning_13,
          technology_14,
          technology_16,
          technology_15,
          region_8
        )
      ) u
  )
SELECT
  su.academic_year,
  su.reporting_term,
  su.term_name,
  su.participant_id,
  su.associate_id,
  su.email,
  su.location,
  su.n,
  su.question_code,
  su.response_value,
  CASE
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
    WHEN su.location = 'KIPP Seek Academy' THEN 73256
    WHEN su.location = 'Life Upper' THEN 73257
    WHEN su.location = 'Life Lower' THEN 73257
    WHEN su.location = 'Life' THEN 73257
    WHEN su.location = 'Life Academy' THEN 73257
    WHEN su.location = 'KIPP Life Academy' THEN 73257
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
  END AS reporting_schoolid,
  CASE
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
  END AS region,
  CASE
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
  END AS school_level,
  qk.survey_type,
  qk.competency,
  qk.question_text
FROM
  survey_unpivoted su
  LEFT OUTER JOIN gabby.surveys.question_key qk ON su.question_code = qk.question_code
  AND su.academic_year = ISNULL(qk.academic_year, su.academic_year)
  AND qk.survey_type = 'R9'
