USE gabby
GO

CREATE OR ALTER VIEW tableau.ops_dashboard AS

SELECT student_number
      ,lastfirst
      ,academic_year
      ,current_academic_year
      ,entrydate
      ,exitdate
      ,entrydate_year
      ,exitdate_year
      ,exitcode
      ,region
      ,school_level
      ,schoolid
      ,grade_level
      ,enroll_status
      ,iep_status
      ,sped_code
      ,lep_status
      ,is_pathways
      ,lunchstatus
      ,lunch_app_status
      ,ethnicity
      ,gender
      ,rn_year
      ,target_enrollment
      ,target_enrollment_sped
      ,target_enrollment_fr
      ,districtcoderesident
      ,referral_date
      ,parental_consent_eval_date
      ,eligibility_determ_date
      ,early_intervention_yn
      ,initial_iep_meeting_date
      ,parent_consent_obtain_code
      ,parent_consent_intial_iep_date
      ,annual_iep_review_meeting_date
      ,reevaluation_date
      ,initial_process_delay_reason
      ,special_education_placement
      ,determined_ineligible_yn
      ,time_in_regular_program
      ,counseling_services_yn
      ,occupational_therapy_serv_yn
      ,physical_therapy_services_yn
      ,speech_lang_theapy_services_yn
      ,other_related_services_yn
      ,LEAD(sub.entrydate_year, 1) OVER(PARTITION BY sub.student_number, sub.rn_year ORDER BY sub.academic_year ASC) AS next_entrydate
      ,LEAD(sub.exitdate_year, 1) OVER(PARTITION BY sub.student_number, sub.rn_year ORDER BY sub.academic_year  ASC) AS next_exitdate
      ,LEAD(sub.schoolid, 1) OVER(PARTITION BY sub.student_number, sub.rn_year ORDER BY sub.academic_year  ASC) AS next_schoolid
      ,LEAD(sub.academic_year, 1) OVER(PARTITION BY sub.student_number, sub.rn_year ORDER BY sub.academic_year  ASC) AS next_academic_year
FROM
    (
     SELECT co.student_number
           ,co.lastfirst
           ,co.academic_year      
           ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS current_academic_year
           ,co.entrydate
           ,co.exitdate
           ,MIN(co.entrydate) OVER(PARTITION BY co.student_number, co.academic_year) AS entrydate_year
           ,MIN(co.exitdate) OVER(PARTITION BY co.student_number, co.academic_year) AS exitdate_year
           ,co.exitcode
           ,co.region
           ,co.school_level
           ,co.reporting_schoolid AS schoolid
           ,co.grade_level
           ,co.enroll_status
           ,co.iep_status
           ,co.specialed_classification AS sped_code
           ,co.lep_status
           ,co.is_pathways
           ,co.lunchstatus
           ,co.lunch_app_status
           ,co.ethnicity
           ,co.gender            
           ,co.rn_year

           ,t.target_enrollment
           ,t.sped_enrollment AS target_enrollment_sped
           ,t.f_r_enrollment AS target_enrollment_fr      

           ,nj.districtcoderesident
           ,nj.referral_date
           ,nj.parental_consent_eval_date
           ,nj.eligibility_determ_date
           ,nj.initial_iep_meeting_date
           ,nj.parent_consent_intial_iep_date
           ,nj.annual_iep_review_meeting_date
           ,nj.reevaluation_date
           ,CONVERT(VARCHAR(1),nj.parent_consent_obtain_code) AS parent_consent_obtain_code
           ,CONVERT(VARCHAR(5),nj.initial_process_delay_reason) AS initial_process_delay_reason
           ,CONVERT(VARCHAR(5),nj.special_education_placement) AS special_education_placement
           ,CONVERT(VARCHAR(5),nj.time_in_regular_program) AS time_in_regular_program
           ,CONVERT(VARCHAR(1),nj.early_intervention_yn) AS early_intervention_yn
           ,CONVERT(VARCHAR(1),nj.determined_ineligible_yn) AS determined_ineligible_yn
           ,CONVERT(VARCHAR(1),nj.counseling_services_yn) AS counseling_services_yn
           ,CONVERT(VARCHAR(1),nj.occupational_therapy_serv_yn) AS occupational_therapy_serv_yn
           ,CONVERT(VARCHAR(1),nj.physical_therapy_services_yn) AS physical_therapy_services_yn
           ,CONVERT(VARCHAR(1),nj.speech_lang_theapy_services_yn) AS speech_lang_theapy_services_yn
           ,CONVERT(VARCHAR(1),nj.other_related_services_yn) AS other_related_services_yn
     FROM gabby.powerschool.cohort_identifiers_static co
     LEFT JOIN gabby.powerschool.s_nj_stu_x nj
       ON co.students_dcid = nj.studentsdcid
      AND co.db_name = nj.db_name
      AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
     LEFT JOIN gabby.finance.enrollment_targets t
       ON co.academic_year = t.academic_year
      AND co.reporting_schoolid = t.schoolid
      AND co.grade_level = t.grade_level
    ) sub