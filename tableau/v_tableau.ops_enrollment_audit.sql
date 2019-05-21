USE gabby
GO

CREATE OR ALTER VIEW tableau.ops_enrollment_audit AS

WITH caredox_enrollment AS (
  SELECT student_id_clean AS student_id
        ,status_clean AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id_clean
             ORDER BY CONVERT(DATETIME2,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.enrollment
  WHERE status_clean != 'new'
 )

,caredox_immunization AS (
  SELECT student_id_clean AS student_id
        ,status_clean AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id_clean
             ORDER BY CONVERT(DATETIME2,last_updated_at) DESC) AS rn_last_updated  
  FROM gabby.caredox.immunization
  WHERE status_clean IN ('Valid', 'N/A')
 )

,caredox_screenings AS (
  SELECT student_id_clean AS student_id
        ,status_clean AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id_clean
             ORDER BY CONVERT(DATETIME2,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.screenings
  WHERE status_clean = 'compliant'
 )

,caredox_medications AS (
  SELECT student_id
        ,gabby.dbo.GROUP_CONCAT_D(medication, ' | ') AS medication
  FROM
      (
       SELECT student_id_clean AS student_id
             ,CONCAT(inventory_id_and_date_created, ' - ', medication_name) AS medication
             ,ROW_NUMBER() OVER(
                PARTITION BY student_id_clean, medication_name
                  ORDER BY CONVERT(DATETIME2,last_updated_at) DESC) AS rn_last_updated
       FROM gabby.caredox.medication_inventory
       WHERE event = 'create'
      ) sub
  WHERE rn_last_updated = 1
  GROUP BY student_id
 )

,residency_verification AS (
  SELECT nen
        ,academic_year
        ,verification_date
        ,approved
  FROM
      (
       SELECT CONVERT(VARCHAR(25),subject_line) AS nen
             ,academic_year
             ,[timestamp] AS verification_date
             ,approved
             ,ROW_NUMBER() OVER(
               PARTITION BY subject_line, academic_year
                 ORDER BY [timestamp] DESC) AS rn_recent
       FROM gabby.enrollment.residency_verification
      ) sub
  WHERE rn_recent = 1
 )

,all_data AS (
  SELECT sub.student_number
        ,sub.newark_enrollment_number
        ,sub.lastfirst
        ,sub.region
        ,sub.reporting_schoolid
        ,sub.grade_level
        ,sub.academic_year
        ,sub.entry_status
        
        ,CONVERT(VARCHAR(500),sub.lunch_app_status) COLLATE Latin1_General_BIN AS lunch_app_status
        ,CONVERT(VARCHAR(500),sub.lunch_balance) COLLATE Latin1_General_BIN AS lunch_balance
        ,CONVERT(VARCHAR(500),sub.iep_registration_followup) COLLATE Latin1_General_BIN AS iep_registration_followup_required
        ,CONVERT(VARCHAR(500),sub.lep_registration_followup) COLLATE Latin1_General_BIN AS lep_registration_followup_required
        ,CONVERT(VARCHAR(500),sub.caredox_enrollment_status) COLLATE Latin1_General_BIN AS caredox_enrollment_status
        ,CONVERT(VARCHAR(500),sub.caredox_immunization_status) COLLATE Latin1_General_BIN AS caredox_immunization_status
        ,CONVERT(VARCHAR(500),sub.caredox_screenings_status) COLLATE Latin1_General_BIN AS caredox_screenings_status
        ,CONVERT(VARCHAR(500),sub.caredox_medication_status) COLLATE Latin1_General_BIN AS caredox_medication_status
        ,CONVERT(VARCHAR(500),sub.birth_certificate_proof) COLLATE Latin1_General_BIN AS birth_certificate_proof
        ,CONVERT(VARCHAR(500),sub.residency_proof_1) COLLATE Latin1_General_BIN AS residency_proof_1
        ,CONVERT(VARCHAR(500),sub.residency_proof_2) COLLATE Latin1_General_BIN AS residency_proof_2
        ,CONVERT(VARCHAR(500),sub.residency_proof_3) COLLATE Latin1_General_BIN AS residency_proof_3
        ,CONVERT(VARCHAR(500),sub.residency_verification_scanned) COLLATE Latin1_General_BIN AS residency_verification_scanned
        ,CONVERT(VARCHAR(500),sub.residency_verification_approved) COLLATE Latin1_General_BIN AS residency_verification_approved
        
        ,CONVERT(VARCHAR(500),sub.region + sub.city) COLLATE Latin1_General_BIN AS region_city
        
        ,CONVERT(VARCHAR(500),CASE
                               WHEN sub.iep_registration_followup = '1'
                                AND sub.specialed_classification != ''
                                     THEN 'Y'
                               WHEN sub.iep_registration_followup = '1'
                                AND sub.specialed_classification = ''
                                     THEN 'N'
                               ELSE ''
                              END) COLLATE Latin1_General_BIN AS iep_registration_followup_complete
        ,CONVERT(VARCHAR(500),CASE
                               WHEN sub.lep_registration_followup = '1'
                                AND sub.lep_status != ''
                                     THEN 'Y'
                               WHEN sub.lep_registration_followup = '1'
                                AND sub.lep_status = ''
                                     THEN 'N'
                               ELSE ''
                              END) COLLATE Latin1_General_BIN AS lep_registration_followup_complete
        ,CONVERT(VARCHAR(500),CASE 
                               WHEN CONCAT(sub.residency_proof_1, sub.residency_proof_2, sub.residency_proof_3) NOT LIKE '%Missing%' THEN 'Y' 
                               ELSE 'N'
                              END) COLLATE Latin1_General_BIN AS residency_proof_all
  FROM
      (
       SELECT s.student_number
             ,s.lastfirst
             ,s.grade_level
             ,s.enroll_status
             ,s.city
             ,CASE
               WHEN s.db_name = 'kippcamden' THEN 'KCNA' 
               WHEN s.db_name = 'kippnewark' THEN 'TEAM' 
               WHEN s.db_name = 'kippmiami' THEN 'KMS' 
              END AS region

             ,COALESCE(co.reporting_schoolid, s.schoolid) AS reporting_schoolid
             ,ISNULL(co.specialed_classification, '') AS specialed_classification
             ,ISNULL(co.lep_status, '') AS lep_status
             ,ISNULL(co.lunch_app_status, '') AS lunch_app_status
             ,CONVERT(MONEY, ISNULL(co.lunch_balance, 0)) AS lunch_balance
             ,CASE
               WHEN s.enroll_status = -1 THEN 'Pre-Registered'
               WHEN COALESCE(co.year_in_network, 1) = 1 THEN 'New to KIPP NJ'
               WHEN COALESCE(co.year_in_school, 1) = 1 THEN 'New to School'
               ELSE 'Returning Student'
              END AS entry_status

             ,suf.newark_enrollment_number

             ,ISNULL(uxs.residency_proof_1, 'Missing') AS residency_proof_1
             ,CASE
               WHEN (s.enroll_status = -1 OR COALESCE(co.year_in_network, 1) = 1) THEN ISNULL(uxs.residency_proof_2, 'Missing') 
              END AS residency_proof_2
             ,CASE
               WHEN (s.enroll_status = -1 OR COALESCE(co.year_in_network, 1) = 1) THEN ISNULL(uxs.residency_proof_3, 'Missing') 
              END AS residency_proof_3
             ,ISNULL(uxs.birth_certificate_proof, 'N') AS birth_certificate_proof
             ,ISNULL(uxs.iep_registration_followup, '') AS iep_registration_followup
             ,ISNULL(uxs.lep_registration_followup, '') AS lep_registration_followup

             ,CASE WHEN rv.nen IS NOT NULL THEN 'Y' ELSE 'N' END AS residency_verification_scanned
             ,ISNULL(rv.approved, '') AS residency_verification_approved

             ,ISNULL(cde.status, '') AS caredox_enrollment_status
             ,ISNULL(cdi.status, '') AS caredox_immunization_status
             ,ISNULL(cds.status, '') AS caredox_screenings_status
             ,ISNULL(cdm.medication, '') AS caredox_medication_status

             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
       FROM gabby.powerschool.students s
       LEFT JOIN gabby.powerschool.cohort_identifiers_static co
         ON s.student_number = co.student_number
        AND s.db_name = co.db_name
        AND co.rn_undergrad = 1
       LEFT JOIN gabby.powerschool.u_studentsuserfields suf
         ON s.dcid = suf.studentsdcid
        AND s.db_name = suf.db_name
       LEFT JOIN gabby.powerschool.u_def_ext_students uxs
         ON s.dcid = uxs.studentsdcid
        AND s.db_name = uxs.db_name
       LEFT JOIN residency_verification rv
         ON suf.newark_enrollment_number = rv.nen
        AND rv.academic_year = 2019 /* update manually */
       LEFT JOIN caredox_enrollment cde
         ON s.student_number = cde.student_id
        AND cde.rn_last_updated = 1
       LEFT JOIN caredox_immunization cdi
         ON s.student_number = cdi.student_id
        AND cdi.rn_last_updated = 1
       LEFT JOIN caredox_screenings cds
         ON s.student_number = cds.student_id
        AND cds.rn_last_updated = 1
       LEFT JOIN caredox_medications cdm
         ON s.student_number = cdm.student_id
       WHERE s.enroll_status IN (-1, 0)
      ) sub
 )

,unpivoted AS (
  SELECT student_number
        ,academic_year
        ,field
        ,value
  FROM all_data
  UNPIVOT(
    value
    FOR field IN (region_city
                 ,iep_registration_followup_required
                 ,iep_registration_followup_complete
                 ,lep_registration_followup_required
                 ,lep_registration_followup_complete
                 ,lunch_app_status
                 ,lunch_balance
                 ,residency_proof_1
                 ,residency_proof_2
                 ,residency_proof_3
                 ,birth_certificate_proof
                 ,caredox_enrollment_status
                 ,caredox_immunization_status
                 ,caredox_screenings_status
                 ,caredox_medication_status
                 ,residency_proof_all
                 ,residency_verification_scanned
                 ,residency_verification_approved)
   ) u
 )

SELECT a.student_number
      ,a.newark_enrollment_number
      ,a.lastfirst
      ,a.academic_year
      ,a.region
      ,a.reporting_schoolid
      ,a.grade_level
      ,a.entry_status
      ,a.lunch_app_status
      ,a.lunch_balance
      ,a.residency_proof_1
      ,a.residency_proof_2
      ,a.residency_proof_3
      ,a.residency_proof_all
      ,NULL AS reverification_date
      ,a.birth_certificate_proof
      ,a.residency_verification_scanned
      ,a.residency_verification_approved
      ,a.iep_registration_followup_required
      ,a.iep_registration_followup_complete
      ,a.lep_registration_followup_required
      ,a.lep_registration_followup_complete
      ,a.caredox_enrollment_status
      ,a.caredox_immunization_status
      ,a.caredox_screenings_status
      ,a.caredox_medication_status

      ,u.field AS audit_field
      ,u.value AS audit_value
      ,CASE
        /* 0 = FLAG || -1 = BAD || 1 = OK */        
        WHEN u.field = 'region_city' AND u.value NOT IN ('TEAMNewark', 'KCNACamden', 'KMSMiami') THEN 0
        WHEN u.field = 'region_city' AND u.value IN ('TEAMNewark', 'KCNACamden', 'KMSMiami') THEN 1
        WHEN u.field = 'caredox_enrollment_status' AND u.value = 'approved' THEN 1
        WHEN u.field = 'caredox_enrollment_status' AND u.value IN ('review_pending','started') THEN 0
        WHEN u.field = 'caredox_enrollment_status' AND u.value IN ('rejected','') THEN -1
        WHEN u.field = 'caredox_immunization_status' AND u.value IN ('Valid', 'N/A') THEN 1        
        WHEN u.field = 'caredox_immunization_status' AND (u.value LIKE 'Not Valid%' OR u.value = '') THEN -1        
        WHEN u.field = 'caredox_medication_status' AND u.value != '' THEN 0
        WHEN u.field = 'caredox_screenings_status' AND u.value = 'compliant' THEN 1
        WHEN u.field = 'caredox_screenings_status' AND u.value = '' THEN -1
        WHEN u.field = 'iep_registration_followup_required' AND a.iep_registration_followup_complete = 'Y' THEN 1
        WHEN u.field = 'iep_registration_followup_required' AND u.value = '1' THEN 0
        WHEN u.field = 'iep_registration_followup_complete' AND u.value = 'Y' THEN 1
        WHEN u.field = 'iep_registration_followup_complete' AND u.value = 'N' THEN -1
        WHEN u.field = 'lep_registration_followup_required' AND a.lep_registration_followup_complete = 'Y' THEN 1
        WHEN u.field = 'lep_registration_followup_required' AND u.value = '1' THEN 0
        WHEN u.field = 'lep_registration_followup_complete' AND u.value = 'Y' THEN 1
        WHEN u.field = 'lep_registration_followup_complete' AND u.value = 'N' THEN -1
        WHEN u.field = 'lunch_app_status' AND u.value IN ('F','R','P','Free (Income)','Free (SNAP)','Denied (High Income)','Reduced','Zero Income','Free (TANF)','Direct Certification','Denied (Special Circumstances)','Free (Special Circumstances)','Reduced (Special Circumstances)') THEN 1
        WHEN u.field = 'lunch_app_status' AND u.value NOT IN ('F','R','P','Free (Income)','Free (SNAP)','Denied (High Income)','Reduced','Zero Income','Free (TANF)','Direct Certification','Denied (Special Circumstances)','Free (Special Circumstances)','Reduced (Special Circumstances)') THEN -1
        WHEN u.field = 'lunch_balance' AND CONVERT(MONEY,u.value) > 0 THEN 1
        WHEN u.field = 'lunch_balance' AND CONVERT(MONEY,u.value) = 0 THEN 0
        WHEN u.field = 'lunch_balance' AND CONVERT(MONEY,u.value) < 0 THEN -1
        WHEN u.field = 'birth_certificate_proof' AND u.value NOT IN ('','N') THEN 1
        WHEN u.field = 'birth_certificate_proof' AND u.value IN ('','N') THEN -1
        WHEN u.field = 'residency_proof_1' AND u.value NOT IN ('','Missing') THEN 1
        WHEN u.field = 'residency_proof_1' AND u.value IN ('','Missing') THEN -1
        WHEN u.field = 'residency_proof_2' AND u.value NOT IN ('','Missing') THEN 1
        WHEN u.field = 'residency_proof_2' AND u.value IN ('','Missing') THEN -1
        WHEN u.field = 'residency_proof_3' AND u.value NOT IN ('','Missing') THEN 1
        WHEN u.field = 'residency_proof_3' AND u.value IN ('','Missing') THEN -1
        WHEN u.field = 'residency_proof_all' AND u.value = 'Y' THEN 1
        WHEN u.field = 'residency_proof_all' AND u.value = 'N' THEN -1
        WHEN u.field = 'residency_verification_scanned' AND u.value = 'Y' THEN 1
        WHEN u.field = 'residency_verification_scanned' AND u.value IN ('','N') THEN -1
        WHEN u.field = 'residency_verification_approved' AND u.value = 'Yes' THEN 1
        WHEN u.field = 'residency_verification_approved' AND u.value = 'No' THEN -1
        WHEN u.field = 'residency_verification_approved' AND u.value = '' THEN 0
       END AS audit_status
FROM all_data a
JOIN unpivoted u
  ON a.student_number = u.student_number
 AND a.academic_year = u.academic_year