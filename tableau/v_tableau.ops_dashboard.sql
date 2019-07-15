USE gabby
GO

CREATE OR ALTER VIEW tableau.ops_dashboard AS

WITH att_mem AS (
  SELECT studentid
        ,db_name
        ,yearid      
        ,SUM(attendancevalue) AS n_attendance
        ,SUM(membershipvalue) AS n_membership
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,yearid
          ,db_name
 )

,targets AS (
  SELECT sub.academic_year
        ,sub.schoolid
        ,sub.is_pathways
        ,sub.grade_level
        ,SUM(sub.target_enrollment) AS target_enrollment
        ,SUM(sub.target_enrollment_finance) AS target_enrollment_finance
        ,MAX(grade_band_ratio) AS grade_band_ratio
        ,MAX(at_risk_and_lep_ratio) AS at_risk_and_lep_ratio
        ,MAX(at_risk_only_ratio) AS at_risk_only_ratio
        ,MAX(lep_only_ratio) AS lep_only_ratio
        ,MAX(sped_ratio) AS sped_ratio
  FROM
      (
       SELECT academic_year
             ,schoolid
             ,0 AS is_pathways
             ,grade_level             
             ,target_enrollment
             ,financial_model_enrollment AS target_enrollment_finance
             ,grade_band_ratio
             ,at_risk_and_lep_ratio
             ,at_risk_only_ratio
             ,lep_only_ratio
             ,sped_ratio
       FROM gabby.finance.enrollment_targets
       WHERE _fivetran_deleted = 0

       UNION ALL

       SELECT academic_year
             ,reporting_schoolid
             ,is_pathways
             ,grade_level
             ,1 AS target_enrollment
             ,1 AS target_enrollment_finance
             ,NULL AS grade_band_ratio
             ,NULL AS at_risk_and_lep_ratio
             ,NULL AS at_risk_only_ratio
             ,NULL AS lep_only_ratio
             ,NULL AS sped_ratio
       FROM gabby.powerschool.cohort_identifiers_static
       WHERE (is_pathways = 1 OR school_name = 'Out of District')
         AND is_enrolled_y1 = 1
      ) sub
  GROUP BY sub.academic_year
          ,sub.schoolid
          ,sub.grade_level
          ,sub.is_pathways
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region
      ,co.school_level
      ,co.schoolid
      ,co.reporting_schoolid
      ,co.school_name
      ,co.grade_level
      ,co.enroll_status
      ,co.entrydate
      ,co.exitdate
      ,co.exitcode
      ,co.exitcomment
      ,co.iep_status
      ,co.specialed_classification
      ,co.lep_status
      ,co.c_504_status
      ,co.is_pathways
      ,co.lunchstatus
      ,co.lunch_app_status
      ,co.ethnicity
      ,co.gender
      ,co.is_enrolled_y1
      ,co.is_enrolled_oct01
      ,co.is_enrolled_oct15
      ,co.is_enrolled_recent
      ,co.is_enrolled_oct15_week
      ,co.is_enrolled_jan15_week
      ,co.track

      ,LEAD(co.schoolid, 1) OVER(PARTITION BY co.student_number ORDER BY co.academic_year  ASC) AS next_schoolid
      ,LEAD(co.exitdate, 1) OVER(PARTITION BY co.student_number ORDER BY co.academic_year  ASC) AS next_exitdate
      ,LEAD(co.is_enrolled_oct01, 1, 0) OVER(PARTITION BY co.student_number ORDER BY co.academic_year) AS is_enrolled_oct01_next

      ,cal.days_remaining
      ,cal.days_total

      ,ISNULL(att_mem.n_attendance, 0) AS n_attendance
      ,ISNULL(att_mem.n_membership, 0) AS n_membership

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

      ,t.target_enrollment
      ,t.target_enrollment_finance
      ,t.grade_band_ratio
      ,t.at_risk_and_lep_ratio
      ,t.at_risk_only_ratio
      ,t.lep_only_ratio
      ,t.sped_ratio
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.calendar_rollup_static cal
  ON co.schoolid = cal.schoolid
 AND co.yearid = cal.yearid
 AND co.track = cal.track
 AND co.db_name = cal.db_name
LEFT JOIN att_mem
  ON co.studentid = att_mem.studentid
 AND co.yearid = att_mem.yearid
 AND co.db_name = att_mem.db_name
LEFT JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
 AND co.db_name = nj.db_name
 AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
LEFT JOIN targets t
  ON co.academic_year = t.academic_year
 AND co.reporting_schoolid = t.schoolid
 AND co.grade_level = t.grade_level
 AND co.is_pathways = t.is_pathways
WHERE co.rn_year = 1