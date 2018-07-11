USE gabby
GO

CREATE OR ALTER VIEW tableau.ops_enrollment_audit AS

WITH caredox_enrollment AS (
  SELECT student_id
        ,status_clean AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.enrollment
  WHERE ISNUMERIC(student_id) = 1
    AND status_clean != 'new'
 )

,caredox_immunization AS (
  SELECT student_id_clean AS student_id
        ,status_clean AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id_clean
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated  
  FROM gabby.caredox.immunization
  WHERE ISNUMERIC(student_id_clean) = 1
    AND status_clean IN ('Valid', 'N/A')
 )

,caredox_screenings AS (
  SELECT student_id
        ,status_clean AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.screenings
  WHERE ISNUMERIC(student_id) = 1
    AND status_clean = 'compliant'
 )

,caredox_medications AS (
  SELECT student_id
        ,gabby.dbo.GROUP_CONCAT_D(medication, ' | ') AS medication
  FROM
      (
       SELECT student_id
             ,CONCAT(inventory_id_and_date_created, ' - ', medication_name) AS medication
             ,ROW_NUMBER() OVER(
                PARTITION BY student_id, medication_name
                  ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
       FROM gabby.caredox.medication_inventory
       WHERE ISNUMERIC(student_id) = 1
         AND event = 'create'
      ) sub
  WHERE rn_last_updated = 1
  GROUP BY student_id
 )

,residency_verification AS (
  SELECT nen
        ,verification_date        
  FROM
      (
       SELECT nen
             ,verification_date
             ,ROW_NUMBER() OVER(
               PARTITION BY nen
                 ORDER BY verification_date DESC) AS rn_recent
       FROM
           (
            SELECT CONVERT(VARCHAR(25),subject_line) AS nen
                  ,CONVERT(DATETIME,REPLACE(timestamp, ' at ', ' ')) AS verification_date
            FROM gabby.enrollment.residency_verification
            WHERE ISNUMERIC(subject_line) = 1
              AND CONVERT(DATETIME,REPLACE(timestamp, ' at ', ' ')) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 5, 1)
           ) sub
      ) sub
  WHERE rn_recent = 1
 )

,all_data AS (
  SELECT co.student_number
        ,co.newark_enrollment_number
        ,co.lastfirst
        ,co.academic_year
        ,co.region
        ,co.reporting_schoolid
        ,co.grade_level        
        ,CASE
          WHEN co.enroll_status = -1 THEN 'Pre-Registered'
          WHEN co.year_in_network = 1 THEN 'New to KIPP NJ'
          WHEN co.year_in_school = 1 THEN 'New to School'
          ELSE 'Returning Student'
         END AS entry_status           
        ,CONVERT(VARCHAR(500),ISNULL(co.region + co.city, '')) COLLATE Latin1_General_BIN AS region_city
        ,CONVERT(VARCHAR(500),ISNULL(co.lunch_app_status,'')) COLLATE Latin1_General_BIN AS lunch_app_status
        ,CONVERT(VARCHAR(500),CONVERT(MONEY,ISNULL(co.lunch_balance,0))) COLLATE Latin1_General_BIN AS lunch_balance
      
        ,CONVERT(VARCHAR(500),ISNULL(uxs.residency_proof_1,'Missing')) COLLATE Latin1_General_BIN AS residency_proof_1
        ,CONVERT(VARCHAR(500),CASE WHEN co.year_in_network = 1 THEN ISNULL(uxs.residency_proof_2,'Missing') END) COLLATE Latin1_General_BIN AS residency_proof_2
        ,CONVERT(VARCHAR(500),CASE WHEN co.year_in_network = 1 THEN ISNULL(uxs.residency_proof_3,'Missing') END) COLLATE Latin1_General_BIN AS residency_proof_3        
        ,CONVERT(VARCHAR(500),ISNULL(uxs.birth_certificate_proof,'N')) COLLATE Latin1_General_BIN AS birth_certificate_proof        
        ,CONVERT(VARCHAR(500),ISNULL(uxs.iep_registration_followup,'')) COLLATE Latin1_General_BIN AS iep_registration_followup_required
        ,CONVERT(VARCHAR(500),CASE 
                               WHEN uxs.iep_registration_followup IS NULL THEN ''
                               WHEN uxs.iep_registration_followup = 1 AND co.specialed_classification IS NOT NULL THEN 'Y'
                               ELSE 'N'
                              END) COLLATE Latin1_General_BIN AS iep_registration_followup_complete
        ,CONVERT(VARCHAR(500),ISNULL(uxs.lep_registration_followup,'')) COLLATE Latin1_General_BIN AS lep_registration_followup_required
        ,CONVERT(VARCHAR(500),CASE 
                               WHEN uxs.lep_registration_followup IS NULL THEN ''
                               WHEN uxs.lep_registration_followup = 1 AND co.lep_status IS NOT NULL THEN 'Y'
                               ELSE 'N'
                              END) COLLATE Latin1_General_BIN AS lep_registration_followup_complete
        ,CONVERT(VARCHAR(500),CASE
                               WHEN co.year_in_network = 1 
                                AND CONCAT(ISNULL(uxs.residency_proof_1,'Missing')
									                                 ,ISNULL(uxs.residency_proof_2,'Missing')
									                                 ,ISNULL(uxs.residency_proof_3,'Missing')) NOT LIKE '%Missing%' 
		                                    THEN 'Y'
                               WHEN co.year_in_network > 1 
                                AND ISNULL(uxs.residency_proof_1,'Missing') != 'N' 
                                AND rv.verification_date IS NOT NULL
		                                    THEN 'Y'
                               ELSE 'N'
                              END) COLLATE Latin1_General_BIN AS residency_proof_all

        ,CONVERT(VARCHAR(500),ISNULL(CASE WHEN rv.NEN IS NOT NULL THEN 'Y' END,'N')) COLLATE Latin1_General_BIN AS residency_verification_scanned
        --,CONVERT(VARCHAR(500),CASE WHEN co.year_in_network > 1 THEN ISNULL(rv.verification_date,'1900-07-01') END) AS reverification_date

        ,CONVERT(VARCHAR(500),ISNULL(cde.status,'')) COLLATE Latin1_General_BIN AS caredox_enrollment_status
        
        ,CONVERT(VARCHAR(500),ISNULL(cdi.status,'')) COLLATE Latin1_General_BIN AS caredox_immunization_status
        
        ,CONVERT(VARCHAR(500),ISNULL(cds.status,'')) COLLATE Latin1_General_BIN AS caredox_screenings_status
        
        ,CONVERT(VARCHAR(500),ISNULL(cdm.medication,'')) COLLATE Latin1_General_BIN AS caredox_medication_status
  FROM gabby.powerschool.cohort_identifiers_static co  
  LEFT JOIN gabby.powerschool.u_def_ext_students uxs
    ON co.students_dcid = uxs.studentsdcid
  LEFT JOIN residency_verification rv
    ON co.newark_enrollment_number = rv.nen  
  LEFT JOIN caredox_enrollment cde
    ON co.student_number = cde.student_id
   AND cde.rn_last_updated = 1
  LEFT JOIN caredox_immunization cdi
    ON co.student_number = cdi.student_id
   AND cdi.rn_last_updated = 1
  LEFT JOIN caredox_screenings cds
    ON co.student_number = cds.student_id
   AND cds.rn_last_updated = 1
  LEFT JOIN caredox_medications cdm
    ON co.student_number = cdm.student_id
  WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()    
    AND co.rn_year = 1
    AND co.schoolid != 999999    
    AND co.enroll_status IN (-1, 0)
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
                 --,reverification_date
                 ,birth_certificate_proof               
                 ,caredox_enrollment_status
                 ,caredox_immunization_status
                 ,caredox_screenings_status
                 ,caredox_medication_status
                 ,residency_proof_all
                 ,residency_verification_scanned)
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
        --WHEN u.field = 'reverification_date' AND CONVERT(DATE,u.value) >= DATEFROMPARTS(2017, 5, 17) THEN 1 /* UPDATE ANNUALLY WITH VERIFICATION DATE CUTOFF */
        --WHEN u.field = 'reverification_date' AND CONVERT(DATE,u.value) < DATEFROMPARTS(2017, 5, 17) THEN -1 /* UPDATE ANNUALLY WITH VERIFICATION DATE CUTOFF */
        WHEN u.field = 'residency_verification_scanned' AND u.value = 'Y' THEN 1
        WHEN u.field = 'residency_verification_scanned' AND u.value IN ('','N') THEN -1
       END AS audit_status
FROM all_data a
INNER JOIN unpivoted u
   ON a.student_number = u.student_number
  AND a.academic_year = u.academic_year