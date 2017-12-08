USE gabby
GO

CREATE OR ALTER VIEW tableau.ktc_college_placement_tracker AS

WITH roster AS (
  SELECT co.student_number
        ,co.studentid
        ,co.academic_year
        ,co.schoolid
        ,co.lastfirst      
        ,co.reporting_schoolid
        ,co.grade_level        
        ,co.enroll_status
        
        ,c.id AS contact_id
        ,c.latest_fafsa_date_c
        ,c.latest_state_financial_aid_app_date_c              
        ,c.college_match_display_gpa_c
        ,c.highest_act_score_c

        ,COALESCE(n.counselor_name, u.name) AS counselor_name
        ,COALESCE(n.class_year, co.cohort) AS cohort

        ,0 AS is_taf
  FROM gabby.powerschool.cohort_identifiers_static co
  LEFT OUTER JOIN gabby.alumni.contact c
    ON co.student_number = c.school_specific_id_c 
   AND c.is_deleted = 0
  LEFT OUTER JOIN gabby.naviance.students n
    ON co.student_number = n.hs_student_id
  LEFT OUTER JOIN gabby.alumni.[user] u
    ON c.owner_id = u.id
  WHERE co.rn_undergrad = 1
    AND co.grade_level BETWEEN 9 AND 12
    AND co.enroll_status IN (0, 3)

  UNION ALL

  SELECT taf.student_number
        ,taf.studentid
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
        ,taf.schoolid
        ,taf.lastfirst      
        ,999999 AS reporting_schoolid
        ,taf.approx_grade_level        
        ,CASE           
          WHEN c.kipp_hs_class_c > gabby.utilities.GLOBAL_ACADEMIC_YEAR() THEN 2
          WHEN c.post_hs_simple_admin_c IS NOT NULL THEN 23
         END AS enroll_status
        
        ,c.id AS contact_id
        ,c.latest_fafsa_date_c
        ,c.latest_state_financial_aid_app_date_c              
        ,c.college_match_display_gpa_c
        ,c.highest_act_score_c
        
        ,u.name
        ,c.kipp_hs_class_c AS cohort
        
        ,1 AS is_taf
  FROM gabby.alumni.taf_roster taf
  LEFT OUTER JOIN gabby.alumni.contact c
    ON taf.student_number = c.school_specific_id_c 
   AND c.is_deleted = 0
  LEFT OUTER JOIN gabby.alumni.[user] u
    ON c.owner_id = u.id
)

,nav_applications AS (
  SELECT hs_student_id
        ,SUM(CASE WHEN result_code = 'accepted' THEN award ELSE 0 END) AS n_award_letters_collected
        ,MAX(CASE WHEN result_code = 'accepted' THEN decis ELSE 0 END) AS is_acceptance_letter_collected
  FROM gabby.naviance.college_applications
  WHERE stage != 'cancelled'
  GROUP BY hs_student_id
 )

,act_month AS (
  SELECT student_number
        ,academic_year
        ,[act_jan]
        ,[act_feb]
        ,[act_mar]
        ,[act_apr]
        ,[act_may]
        ,[act_jun]
        ,[act_jul]
        ,[act_aug]
        ,[act_sep]
        ,[act_oct]
        ,[act_nov]
        ,[act_dec]
        ,[sat_jan]
        ,[sat_feb]
        ,[sat_mar]
        ,[sat_apr]
        ,[sat_may]
        ,[sat_jun]
        ,[sat_jul]
        ,[sat_aug]
        ,[sat_sep]
        ,[sat_oct]
        ,[sat_nov]
        ,[sat_dec]
        ,[sat2_ch]
        ,[sat2_fl]
        ,[sat2_lr]
        ,[sat2_m1]
        ,[sat2_m2]
        ,[sat2_sp]
  FROM
      (
       SELECT student_number
             ,academic_year
             ,'act_' + LOWER(LEFT(DATENAME(MONTH, test_date), 3)) AS test_month
             ,composite
       FROM gabby.naviance.act_scores_clean

       UNION ALL

       SELECT student_number
             ,academic_year
             ,'sat_' + LOWER(LEFT(DATENAME(MONTH, test_date), 3)) AS test_month
             ,all_tests_total
       FROM gabby.naviance.sat_scores_clean

       UNION ALL

       SELECT student_number
             ,academic_year
             ,'sat2_' + LOWER(test_code) AS test_month
             ,score
       FROM gabby.naviance.sat_2_scores_clean
      ) sub
  PIVOT(
    MAX(composite)
    FOR test_month IN ([act_jan]
                      ,[act_feb]
                      ,[act_mar]
                      ,[act_apr]
                      ,[act_may]
                      ,[act_jun]
                      ,[act_jul]
                      ,[act_aug]
                      ,[act_sep]
                      ,[act_oct]
                      ,[act_nov]
                      ,[act_dec]
                      ,[sat_jan]
                      ,[sat_feb]
                      ,[sat_mar]
                      ,[sat_apr]
                      ,[sat_may]
                      ,[sat_jun]
                      ,[sat_jul]
                      ,[sat_aug]
                      ,[sat_sep]
                      ,[sat_oct]
                      ,[sat_nov]
                      ,[sat_dec]
                      ,[sat2_ch]
                      ,[sat2_fl]
                      ,[sat2_lr]
                      ,[sat2_m1]
                      ,[sat2_m2]
                      ,[sat2_sp])
   ) p
 )

,act_presenior AS (
  SELECT a.student_number      
        ,a.composite
        ,ROW_NUMBER() OVER(
           PARTITION BY a.student_number
             ORDER BY a.composite DESC) AS rn_highest_presenior
  FROM gabby.naviance.act_scores_clean a
  JOIN gabby.powerschool.cohort_identifiers_static co
    ON a.student_number = co.student_number
   AND a.academic_year = co.academic_year
   AND co.grade_level < 12
   AND co.rn_year = 1
 )

,college_apps AS (
  SELECT applicant_c        
        ,application_submission_status_c
        ,COUNT(id) AS n_applications_submitted
        ,SUM(is_ltr_match) AS n_ltr_applications        
        ,SUM(is_closed_application) AS n_closed_applications
        ,SUM(is_efc_entered) AS n_efc_entered
        ,MAX(is_eaed_application) AS is_eaed_applicant
        ,MAX(is_accepted_4yr) AS is_accepted_4yr
        ,MAX(is_award_information_entered) AS is_award_information_entered
        ,AVG(unmet_need_c) AS avg_unmet_need
  FROM
      (
       SELECT a.id
             ,a.applicant_c
             ,a.name
             ,a.application_status_c
             ,a.application_submission_status_c
             ,a.application_admission_type_c
             ,a.match_type_c
             ,a.matriculation_decision_c
             ,a.starting_application_status_c
             ,a.financial_aid_eligibility_c
             ,a.efc_from_fafsa_c      
             ,a.primary_reason_for_not_attending_c             
             ,a.unmet_need_c
             ,CASE
               WHEN a.match_type_c = 'Unable to Calculate' THEN NULL
               WHEN a.match_type_c IN ('Likely Plus','Target','Reach') THEN 1.0
               WHEN a.match_type_c NOT IN ('Likely Plus','Target','Reach') THEN 0.0
              END AS is_ltr_match
             ,CASE WHEN a.application_admission_type_c IN ('Early Action', 'Early Decision') THEN 1.0 ELSE 0.0 END AS is_eaed_application
             ,CASE WHEN a.application_status_c != 'Unknown' THEN 1.0 ELSE 0.0 END AS is_closed_application
             ,CASE WHEN a.efc_from_fafsa_c IS NOT NULL THEN 1.0 ELSE 0.0 END AS is_efc_entered
             ,CASE
               WHEN a.matriculation_decision_c = 'Matriculated (Intent to Enroll)'
                AND a.unmet_need_c IS NOT NULL THEN 1.0 
               ELSE 0.0 
              END AS is_award_information_entered
             ,CASE 
               WHEN a.application_status_c = 'Accepted' 
                AND SUBSTRING(s.type, PATINDEX('%[24] yr%', s.type), 1) = '4' THEN 1.0 
               ELSE 0.0 
              END AS is_accepted_4yr

             ,s.type        
       FROM gabby.alumni.application_c a       
       JOIN gabby.alumni.account s
         ON a.school_c = s.id
        AND s.is_deleted = 0
       WHERE a.is_deleted = 0
      ) sub
  GROUP BY applicant_c
          ,application_submission_status_c
 )

SELECT co.student_number
      ,co.lastfirst      
      ,co.reporting_schoolid
      ,co.grade_level      
      ,co.enroll_status
      ,co.counselor_name
      ,co.is_taf      
      ,co.cohort
      ,co.latest_fafsa_date_c
      ,co.latest_state_financial_aid_app_date_c              
      
      ,CASE 
        WHEN co.is_taf = 0 AND co.grade_level = 12 THEN gpa.cumulative_Y1_gpa
        WHEN co.is_taf = 0 AND co.grade_level = 11 THEN gpa.cumulative_Y1_gpa_projected
        WHEN co.is_taf = 1 THEN co.college_match_display_gpa_c
       END cumulative_Y1_gpa      

      ,ctcs.attended_2018_junior_kickoff      
      --scholarships
      ,ctcs.fafsa_4_caster_complete
      --complete CTE survey
      ,ctcs.matriculation_checklist_complete_transfer_to_persistence_counselor      
      --resume
      --brag sheet      
      ,ctcs.college_decision_meeting_complete_with_parent_and_persistence_      
      --Juniors requested LOR & Common App eval
      --Junior wishlist
      --parents attending RC conference Q2
      --parents attending RC conference Q3
      --parents attending RC conference Q4      
      ,ctcs.submit_most_recent_taxes_income      
      ,ctcs.submit_most_recent_tax_transcripts
      ,ctcs.submit_previous_year_s_taxes      
      ,ctcs.submit_previous_year_s_tax_transcripts                  
      ,ctcs.counselor_lor_submitted_to_naviance      
      ,ctcs.counselor_lor_common_app_eval_uploaded_to_naviance
      ,ctcs.teacher_lor_1_submitted_to_naviance      
      ,ctcs.teacher_lor_2_submitted_to_naviance
      ,ctcs.teacher_ca_eval_1_submitted_to_naviance
      ,ctcs.teacher_ca_eval_2_submitted_to_naviance      
      ,ctcs.common_app_complete_and_synced_to_naviance      
      ,ctcs.personal_statement_complete_and_submitted_to_counselor      
      ,ctcs.first_1_1_meeting_with_counselor_junior_year_
      ,ctcs.q_1_counselor_1_1_meeting_complete      
      ,ctcs.q_2_counselor_meeting_1_of_2_complete
      ,ctcs.q_2_counselor_meeting_2_of_2_complete
      ,ctcs._3_q_counselor_meeting_1_of_2
      ,ctcs._3_q_counselor_meeting_2_of_2
      ,ctcs._4_q_counselor_meeting_1_of_2
      ,ctcs._4_q_counselor_meeting_2_of_2
      ,ctcs.senior_parent_meeting_1_of_2
      ,ctcs.senior_parent_meeting_2_of_2 
      --register for July ACT      
      ,ctcs.registered_for_october_act
      --register for December ACT      
      --completing test release application      
      --submitting test release report      
      --register for June SAT
      --register for March SAT      
      
      ,na.n_award_letters_collected
      ,na.is_acceptance_letter_collected

      ,COALESCE(act.composite, highest_act_score_c) AS act_composite_highest
      
      ,ap.composite AS act_composite_highest_presenior_year
      
      ,am.act_dec
      ,am.act_oct
      ,am.act_apr
      ,CASE WHEN CONCAT(am.sat2_ch, am.sat2_fl, am.sat2_lr, am.sat2_m1, am.sat2_m2, am.sat2_sp) != '' THEN 1.0 ELSE 0.0 END AS took_sat2      

      ,ca.n_applications_submitted
      ,ca.n_ltr_applications      
      ,ca.n_efc_entered      
      ,ca.n_closed_applications      
      ,ca.is_accepted_4yr
      ,ca.is_award_information_entered
      ,ca.avg_unmet_need
      ,COALESCE(ca.is_eaed_applicant, 0) AS is_eaed_applicant

      ,ei.ecc_adjusted_6_year_minority_graduation_rate AS ecc_rate
      ,CASE 
        WHEN SUBSTRING(ei.ecc_pursuing_degree_type, PATINDEX('%[24]%year%', ei.ecc_pursuing_degree_type), 1) = '4' THEN 1.0         
        ELSE 0.0
       END AS is_matriculating_4yr
      ,CASE 
        WHEN SUBSTRING(ei.ecc_pursuing_degree_type, PATINDEX('%[24]%year%', ei.ecc_pursuing_degree_type), 1) = '2' THEN 1.0         
        ELSE 0.0
       END AS is_matriculating_2yr
      ,CASE 
        WHEN SUBSTRING(ei.ugrad_pursuing_degree_type, PATINDEX('%[24]%year%', ei.ugrad_pursuing_degree_type), 1) = '4' THEN 1.0         
        ELSE 0.0
       END AS is_attending_4yr
FROM roster co
LEFT OUTER JOIN gabby.powerschool.gpa_cumulative gpa
  ON co.studentid = gpa.studentid
 AND co.schoolid = gpa.schoolid
LEFT OUTER JOIN gabby.naviance.current_task_completion_status ctcs
  ON co.student_number = ctcs.student_id
LEFT OUTER JOIN nav_applications na
  ON co.student_number = na.hs_student_id
LEFT OUTER JOIN gabby.naviance.act_scores_clean act
  ON co.student_number = act.student_number
 AND act.rn_highest = 1
LEFT OUTER JOIN act_presenior ap
  ON co.student_number = ap.student_number
 AND ap.rn_highest_presenior = 1
LEFT OUTER JOIN act_month am
  ON co.student_number = am.student_number
 AND co.academic_year = am.academic_year
LEFT OUTER JOIN college_apps ca
  ON co.contact_id = ca.applicant_c
 AND ca.application_submission_status_c = 'Submitted'
LEFT OUTER JOIN gabby.alumni.enrollment_identifiers ei
  ON co.contact_id = ei.student_c