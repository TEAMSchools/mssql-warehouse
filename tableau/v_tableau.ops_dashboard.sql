USE gabby
GO

ALTER VIEW tableau.ops_dashboard AS

SELECT student_number
      ,lastfirst
      ,academic_year
      ,current_academic_year
      ,entrydate
      ,exitdate
      ,entrydate_year
      ,exitdate_year
      ,exitcode
      ,school_level
      ,schoolid
      ,grade_level
      ,enroll_status
      ,iep_status
      ,sped_code
      ,lep_status
      ,lunchstatus
      ,lunch_app_status
      ,ethnicity
      ,gender
      ,rn_year
      ,target_enrollment
      ,target_enrollment_sped
      ,target_enrollment_fr
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
           ,co.school_level
           ,co.reporting_schoolid AS schoolid
           ,co.grade_level
           ,co.enroll_status
           ,co.iep_status
           ,co.specialed_classification AS sped_code
           ,co.lep_status
           ,co.lunchstatus
           ,co.lunch_app_status
           ,co.ethnicity
           ,co.gender            
           ,co.rn_year

           ,NULL AS target_enrollment
           ,NULL AS target_enrollment_sped
           ,NULL AS target_enrollment_fr
           --,t.target_enrollment
           --,t.sped_enrollment AS target_enrollment_sped
           --,t.fr_enrollment AS target_enrollment_fr      

           ,iep.referral_date
           ,iep.parental_consent_eval_date
           ,iep.eligibility_determ_date
           ,iep.early_intervention_yn
           ,iep.initial_iep_meeting_date
           ,iep.parent_consent_obtain_code
           ,iep.parent_consent_intial_iep_date
           ,iep.annual_iep_review_meeting_date
           ,iep.reevaluation_date
           ,iep.initial_process_delay_reason
           ,iep.special_education_placement
           ,iep.determined_ineligible_yn
           ,iep.time_in_regular_program
           ,iep.counseling_services_yn
           ,iep.occupational_therapy_serv_yn
           ,iep.physical_therapy_services_yn
           ,iep.speech_lang_theapy_services_yn
           ,iep.other_related_services_yn
     FROM gabby.powerschool.cohort_identifiers_static co WITH(NOLOCK)            
     LEFT OUTER JOIN gabby.powerschool.s_nj_stu_x iep WITH(NOLOCK)
       ON co.students_dcid = iep.studentsdcid
      AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
     --LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_FINANCE_enrollment_targets t WITH(NOLOCK)
     --  ON co.academic_year = t.academic_year
     -- AND co.reporting_schoolid = t.schoolid
     -- AND co.grade_level = t.grade_level
    ) sub