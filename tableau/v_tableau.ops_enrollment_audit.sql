USE gabby
GO

CREATE OR ALTER VIEW tableau.ops_enrollment_audit AS

WITH caredox_enrollment AS (
  SELECT student_id
        ,status        
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.enrollment
  WHERE ISNUMERIC(student_id) = 1
    AND status != 'new'
 )

,caredox_immunization AS (
  --SELECT student_id
  --      ,CONCAT(status, ' - ' + status_notes) AS status
  --      ,ROW_NUMBER() OVER(
  --         PARTITION BY student_id
  --           ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  SELECT student_id      
        ,last_updated_at
        ,SUBSTRING(fml, status_position_start + 1, CHARINDEX(',', fml, status_position_start + 1) - status_position_start - 1) AS status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  FROM
      (
       SELECT LEFT(fml, CHARINDEX(',', fml) - 1) AS student_id      
             ,CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml,
                CHARINDEX(',', fml, 
                CHARINDEX(',', fml) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) AS status_position_start
             ,CASE 
               WHEN ISDATE(REVERSE(LEFT(REVERSE(fml), CHARINDEX(',', REVERSE(fml)) - 1))) = 1
                      THEN CONVERT(DATETIME,REVERSE(LEFT(REVERSE(fml), CHARINDEX(',', REVERSE(fml)) - 1)))
               ELSE GETDATE()
              END AS last_updated_at
             ,fml
       FROM
           (
            SELECT student_id_health_record_id_health_record_instance_id_full_name_health_profile_birth_date_age_program_id_session_grade_status_s AS fml
            FROM gabby.caredox.immunization
           ) sub
       WHERE ISNUMERIC(LEFT(fml,1)) = 1
      ) sub
 )

,caredox_screenings AS (
  SELECT student_id
        ,status
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.screenings
  WHERE ISNUMERIC(student_id) = 1
    AND status = 'compliant'
)

,caredox_medications AS (
  SELECT student_id
        ,CONCAT(inventory_id_and_date_created, ' - ', medication_name) AS medication
        ,ROW_NUMBER() OVER(
           PARTITION BY student_id, medication_name
             ORDER BY CONVERT(DATETIME,last_updated_at) DESC) AS rn_last_updated
  FROM gabby.caredox.medication_inventory
  WHERE ISNUMERIC(student_id) = 1
    AND event = 'create'
 )

,residency_verification AS (
  SELECT NEN
        ,verification_date
  FROM
      (
       SELECT subject_line AS NEN      
             ,CONVERT(DATE,REPLACE(date, ' at ', ' ')) AS verification_date
             ,ROW_NUMBER() OVER(
                PARTITION BY subject_line
                  ORDER BY CONVERT(DATETIME,REPLACE(date, ' at ', ' ')) DESC) AS rn_recent
       FROM gabby.enrollment.residency_verification
       WHERE ISNUMERIC(subject_line) = 1
      ) sub
  WHERE rn_recent = 1
 )

,all_data AS (
  SELECT co.student_number
        ,co.lastfirst
        ,co.academic_year
        ,co.reporting_schoolid
        ,co.grade_level
        ,CASE
          WHEN co.year_in_network = 1 THEN 'New to KIPP NJ'
          WHEN co.year_in_school = 1 THEN 'New to School'
          ELSE 'Returning Student'
         END AS entry_status                 
           
        ,ISNULL(CONVERT(NVARCHAR(MAX),co.lunch_app_status),'') AS lunch_app_status
        ,CONVERT(NVARCHAR(MAX),CONVERT(MONEY,ISNULL(co.lunch_balance,0))) AS lunch_balance
      
        ,ISNULL(CONVERT(NVARCHAR(MAX),uxs.residency_proof_1),'Missing') AS residency_proof_1
        ,CONVERT(NVARCHAR(MAX),CASE WHEN co.year_in_network = 1 THEN ISNULL(uxs.residency_proof_2,'Missing') END) AS residency_proof_2
        ,CONVERT(NVARCHAR(MAX),CASE WHEN co.year_in_network = 1 THEN ISNULL(uxs.residency_proof_3,'Missing') END) AS residency_proof_3
        ,CONVERT(NVARCHAR(MAX),CASE
                                WHEN year_in_network = 1 AND CONCAT(ISNULL(uxs.residency_proof_1,'Missing')
									                                ,ISNULL(uxs.residency_proof_2,'Missing')
									                                ,ISNULL(uxs.residency_proof_3,'Missing')) NOT LIKE '%Missing%' 
		                                THEN 'Y'
                                WHEN year_in_network > 1 
                                AND ISNULL(uxs.residency_proof_1,'Missing') != 'N' 
                                AND rv.verification_date IS NOT NULL
		                                THEN 'Y'
                                ELSE 'N'
                                END) AS residency_proof_all
        --,ISNULL(CONVERT(NVARCHAR(MAX),uxs.reverification_date),'1900-07-01') AS reverification_date
        ,ISNULL(CONVERT(NVARCHAR(MAX),uxs.birth_certificate_proof),'N') AS birth_certificate_proof        
        ,ISNULL(CONVERT(NVARCHAR(MAX),CASE WHEN rv.NEN IS NOT NULL THEN 'Y' END),'N') AS residency_verification_scanned
        ,CONVERT(NVARCHAR(MAX),CASE WHEN co.year_in_network > 1 THEN ISNULL(rv.verification_date,'1900-07-01') END) AS reverification_date
           
        ,ISNULL(CONVERT(NVARCHAR(MAX),uxs.iep_registration_followup),'') AS iep_registration_followup_required
        ,CONVERT(NVARCHAR(MAX),CASE 
          WHEN uxs.iep_registration_followup IS NULL THEN ''
          WHEN uxs.iep_registration_followup = 1 AND co.specialed_classification IS NOT NULL THEN 'Y'
          ELSE 'N'
         END) AS iep_registration_followup_complete
        ,ISNULL(CONVERT(NVARCHAR(MAX),uxs.lep_registration_followup),'') AS lep_registration_followup_required
        ,CONVERT(NVARCHAR(MAX),CASE 
          WHEN uxs.lep_registration_followup IS NULL THEN ''
          WHEN uxs.lep_registration_followup = 1 AND co.lep_status IS NOT NULL THEN 'Y'
          ELSE 'N'
         END) AS lep_registration_followup_complete

        ,ISNULL(CONVERT(NVARCHAR(MAX),cde.status),'') AS caredox_enrollment_status
        ,ISNULL(CONVERT(NVARCHAR(MAX),cdi.status),'') AS caredox_immunization_status
        ,ISNULL(CONVERT(NVARCHAR(MAX),cds.status),'') AS caredox_screenings_status
        ,ISNULL(CONVERT(NVARCHAR(MAX),cdm.medication),'') AS caredox_medication_status
  FROM gabby.powerschool.cohort_identifiers_static co  
  LEFT OUTER JOIN gabby.powerschool.u_def_ext_students uxs
    ON co.students_dcid = uxs.studentsdcid
  LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
    ON co.students_dcid = suf.studentsdcid
  LEFT OUTER JOIN caredox_enrollment cde
    ON co.student_number = cde.student_id
   AND cde.rn_last_updated = 1
  LEFT OUTER JOIN caredox_immunization cdi
    ON co.student_number = cdi.student_id
   AND cdi.rn_last_updated = 1
  LEFT OUTER JOIN caredox_screenings cds
    ON co.student_number = cds.student_id
   AND cds.rn_last_updated = 1
  LEFT OUTER JOIN caredox_medications cdm
    ON co.student_number = cdm.student_id
   AND cdm.rn_last_updated = 1
  LEFT OUTER JOIN residency_verification rv
    ON suf.newark_enrollment_number = rv.NEN
  WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND co.schoolid != 999999    
    AND co.rn_year = 1
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
    FOR field IN (iep_registration_followup_required
                 ,iep_registration_followup_complete
                 ,lep_registration_followup_required
                 ,lep_registration_followup_complete
                 ,lunch_app_status
                 ,lunch_balance
                 ,residency_proof_1
                 ,residency_proof_2
                 ,residency_proof_3
                 ,reverification_date
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
      ,a.lastfirst
      ,a.academic_year
      ,a.reporting_schoolid
      ,a.grade_level
      ,a.entry_status
      ,a.lunch_app_status
      ,a.lunch_balance
      ,a.residency_proof_1
      ,a.residency_proof_2
      ,a.residency_proof_3
      ,a.residency_proof_all
      ,a.reverification_date      
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
        /* 0 = ! / -1 = X / 1 = OK */        
        WHEN u.field = 'caredox_enrollment_status' AND u.value = 'approved' THEN 1
        WHEN u.field = 'caredox_enrollment_status' AND u.value IN ('review_pending','started') THEN 0
        WHEN u.field = 'caredox_enrollment_status' AND u.value IN ('rejected','') THEN -1
        WHEN u.field = 'caredox_immunization_status' AND u.value = 'Valid' THEN 1        
        WHEN u.field = 'caredox_immunization_status' AND u.value = 'N/A' THEN 0
        WHEN u.field = 'caredox_immunization_status' AND (u.value LIKE 'Not Valid%' OR u.value = '') THEN -1        
        WHEN u.field = 'caredox_medication_status' AND u.value != '' THEN 0
        WHEN u.field = 'caredox_screenings_status' AND u.value = 'compliant' THEN 1
        WHEN u.field = 'caredox_screenings_status' AND u.value = '' THEN -1
        WHEN u.field = 'iep_registration_followup_required' AND u.value = '1' THEN 0
        WHEN u.field = 'iep_registration_followup_complete' AND u.value = 'Y' THEN 1
        WHEN u.field = 'iep_registration_followup_complete' AND u.value = 'N' THEN -1
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
        WHEN u.field = 'reverification_date' AND CONVERT(DATE,u.value) >= DATEFROMPARTS(2017, 5, 17) THEN 1 /* UPDATE ANNUALLY WITH VERIFICATION DATE CUTOFF */
        WHEN u.field = 'reverification_date' AND CONVERT(DATE,u.value) < DATEFROMPARTS(2017, 5, 17) THEN -1 /* UPDATE ANNUALLY WITH VERIFICATION DATE CUTOFF */
        WHEN u.field = 'residency_verification_scanned' AND u.value = 'Y' THEN 1
        WHEN u.field = 'residency_verification_scanned' AND u.value IN ('','N') THEN -1
       END AS audit_status
FROM all_data a
JOIN unpivoted u
  ON a.student_number = u.student_number
 AND a.academic_year = u.academic_year