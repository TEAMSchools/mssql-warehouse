USE gabby
GO

CREATE OR ALTER VIEW tableau.ktc_basic_contact_dump AS

WITH next_yr_enrollment AS (
  SELECT student_c
        ,pursuing_degree_type_c
  FROM gabby.alumni.enrollment_c
  WHERE type_c = 'College'
    AND pursuing_degree_type_c IN ('Associate''s (2 year)','Bachelor''s (4-year)')
    AND start_date_c >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() + 1, 1, 1)
    AND status_c IN ('Attending','Matriculated')
    AND is_deleted = 0
 )

,gpa AS (
  SELECT student_c        
        ,[fall_semester_gpa]
        ,[fall_academic_status]
        ,[spring_semester_gpa]
        ,[spring_academic_status]
        ,[prev_spring_semester_gpa]
        ,[prev_spring_academic_status]
  FROM
      (
       SELECT student_c             
             ,semester + '_' + field AS pivot_field
             ,value
       FROM
           (
            SELECT student_c                  
                  ,transcript_date_c
                  ,CASE
                    WHEN transcript_date_c = '2018-05-31' THEN 'prev_spring'
                    WHEN transcript_date_c = '2018-12-31' THEN 'fall'
                    WHEN transcript_date_c = '2019-05-31' THEN 'spring'
                   END AS semester
                  ,CONVERT(VARCHAR,semester_gpa_c) AS semester_gpa
                  ,CONVERT(VARCHAR,academic_status_c) AS academic_status
            FROM gabby.alumni.gpa_c
            WHERE transcript_date_c >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
           ) sub
       UNPIVOT(
         value
         FOR field IN (semester_gpa, academic_status)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([fall_semester_gpa]
                       ,[fall_academic_status]
                       ,[spring_semester_gpa]
                       ,[spring_academic_status]
                       ,[prev_spring_semester_gpa]
                       ,[prev_spring_academic_status])
   ) p
 )

,stipends AS (
  SELECT student_c
        ,CASE 
          WHEN [F] IS NOT NULL THEN 'Picked Up'
          WHEN [F] IS NULL THEN 'Not Picked Up'
         END AS stipend_status_fall
        ,CASE 
          WHEN [S] IS NOT NULL THEN 'Picked Up'
          WHEN [S] IS NULL THEN 'Not Picked Up'
         END AS stipend_status_spr
  FROM
      (
       SELECT a.student_c        
             ,a.date_c
             ,CASE 
               WHEN DATEPART(MONTH, a.created_date) BETWEEN 7 AND 12 THEN 'F'
               ELSE 'S'
              END AS semester             
       FROM gabby.alumni.kipp_aid_c a 
       WHERE a.type_c = 'College Book Stipend Program'
         AND a.Status_c = 'Approved'
         AND a.is_deleted = 0
         AND a.created_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
      ) sub
  PIVOT(
    MAX(date_c)
    FOR semester IN ([F], [S])
   ) p
 )

,oot_roster AS (
  SELECT contact_id
        ,last_successful_contact_date
        ,missing_start_date
        ,found_date
        ,is_still_missing
        ,n_months_elapsed
        ,gabby.utilities.DATE_TO_SY(missing_start_date) AS missing_academic_year
        ,gabby.utilities.DATE_TO_SY(found_date) AS found_academic_year
        ,ROW_NUMBER() OVER(
           PARTITION BY contact_id, gabby.utilities.DATE_TO_SY(missing_start_date)
             ORDER BY last_successful_contact_date DESC) AS rn
  FROM
      (
       SELECT Contact_c AS contact_id
             ,Date_c AS last_successful_contact_date
             ,DATEADD(MONTH, 12, Date_c) AS missing_start_date
             ,COALESCE(LEAD(Date_c, 1) OVER(PARTITION BY Contact_c ORDER BY Date_c ASC), GETDATE()) AS found_date
             ,CASE WHEN LEAD(Date_c, 1) OVER(PARTITION BY Contact_c ORDER BY Date_c ASC) IS NULL THEN 1 END AS is_still_missing
             ,DATEDIFF(MONTH
                      ,Date_c
                      ,COALESCE(LEAD(Date_c, 1) OVER(PARTITION BY Contact_c ORDER BY Date_c), GETDATE())) AS n_months_elapsed
       FROM gabby.alumni.contact_note_c c
       WHERE Status_c = 'Successful'
         AND is_deleted = 0
      ) sub
 ) 

,counselor_changes AS (
  SELECT contact_id      
        ,new_value
        ,ROW_NUMBER() OVER(
           PARTITION BY contact_id
             ORDER BY created_date DESC) AS rn
  FROM gabby.alumni.contact_history
  WHERE field = 'Owner'
    AND created_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 07, 01)
    AND old_value IN ('Jessica Gersh','Eric Fisher','KNJ Admin')    
    AND is_deleted = 0
)

,transfer_apps AS (
  SELECT applicant_c
        ,[4YR]
        ,[2YR]
        ,[4YR_T]
        ,[2YR_T]
        ,[ALL]
  FROM
      (
       SELECT a.applicant_c      
             ,ISNULL(CASE 
                      WHEN s.type LIKE '%2 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '2YR'
                      WHEN s.type LIKE '%4 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '4YR'
                      WHEN s.type LIKE '%2 yr' AND a.transfer_application_c = 1 THEN '2YR_T'
                      WHEN s.type LIKE '%4 yr' AND a.transfer_application_c = 1 THEN '4YR_T'       
                     END,'ALL') AS school_type
             ,COUNT(a.id) AS N
       FROM gabby.alumni.application_c a
       JOIN gabby.alumni.account s
         ON a.school_c = s.id
       WHERE a.application_submission_status_c = 'Submitted'                  
         AND a.created_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 07, 01)
         AND a.is_deleted = 0
       GROUP BY a.applicant_c      
               ,CUBE(CASE 
                      WHEN s.type LIKE '%2 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '2YR'
                      WHEN s.type LIKE '%4 yr' AND ISNULL(a.transfer_application_c, 0) = 0 THEN '4YR'
                      WHEN s.type LIKE '%2 yr' AND a.transfer_application_c = 1 THEN '2YR_T'
                      WHEN s.type LIKE '%4 yr' AND a.transfer_application_c = 1 THEN '4YR_T'
                     END)
      ) sub
  PIVOT(
    MAX(N)
    FOR school_type IN ([4YR],[2YR],[4YR_T],[2YR_T],[ALL]) 
   ) p
)

SELECT c.sf_contact_id AS contact_id
      ,c.student_number
      ,CONCAT(c.first_name, ' ', c.last_name) AS Full_Name_c
      ,c.first_name AS FirstName
      ,c.last_name AS LastName
      ,c.ktc_cohort AS kipp_hs_class_c
      ,c.years_out_of_hs
      ,c.college_status AS college_status_c
      ,c.currently_enrolled_school AS currently_enrolled_school_c
      ,c.is_kipp_ms_graduate AS kipp_ms_graduate_c
      ,c.middle_school_attended AS middle_school_attended_c
      ,c.is_kipp_hs_graduate AS kipp_hs_graduate_c
      ,c.high_school_graduated_from AS high_school_graduated_from_c
      ,c.college_graduated_from AS college_graduated_from_c
      ,c.gender AS gender_c
      ,c.ethnicity AS ethnicity_c
      ,c.cumulative_gpa AS cumulative_gpa_c
      ,c.current_college_semester_gpa
      ,c.college_credits_attempted AS college_credits_attempted_c
      ,c.accumulated_credits_college AS accumulated_credits_college_c
      ,c.is_transcript_release AS transcript_release_c
      ,c.latest_fafsa_date AS latest_fafsa_date_c
      ,c.latest_state_financial_aid_app_date AS latest_state_financial_aid_app_date_c
      ,c.latest_resume_date AS latest_resume_c
      ,c.is_informed_consent AS informed_consent_c 
      ,c.expected_college_graduation_date AS expected_college_graduation_c
      ,c.expected_hs_graduation_date AS expected_hs_graduation_c
      ,c.post_hs_simple_admin AS post_hs_simple_admin_c
      ,c.last_outreach_date AS last_outreach_c
      ,c.last_successful_contact_date AS last_successful_contact_c
      ,c.actual_hs_graduation_date AS actual_hs_graduation_date_c
      ,c.actual_college_graduation_date AS actual_college_graduation_date_c      
      ,c.kipp_region_name AS kipp_region_name_c
      ,c.record_type_name AS record_type
      ,c.counselor_name AS ktc_manager

      ,oot.n_months_elapsed
      ,CASE         
        WHEN (oot.n_months_elapsed >= 12 OR oot.contact_id IS NULL) THEN 1
        ELSE 0 
       END AS is_oot_baseline
      ,CASE         
        WHEN (oot.n_months_elapsed >= 12 OR oot.contact_id IS NULL)
         AND oot.is_still_missing = 1 THEN 1
        ELSE 0 
       END AS is_out_of_touch            
      ,CASE         
        WHEN (oot.n_months_elapsed >= 12 OR oot.contact_id IS NULL)
         AND c.counselor_name = cc.new_value 
             THEN 1 
        ELSE 0 
       END AS is_oot_assigned
      ,CASE         
        WHEN oot.found_date IS NOT NULL THEN 1 
        ELSE 0 
       END AS is_found_this_term

      ,e.ugrad_college_major_declared AS college_major_declared_c
      ,e.ugrad_major AS major_c
      ,e.ugrad_pursuing_degree_type AS pursuing_degree_type_c
      ,e.ugrad_start_date AS start_date_c
      ,e.ugrad_anticipated_graduation AS anticipated_graduation_c
      ,e.ugrad_status AS enrollment_status
      ,e.ugrad_account_name AS account_name
      ,e.ugrad_account_type AS account_type  
      ,e.ugrad_billing_state AS billing_state
      ,e.ugrad_ncesid AS ncesid_c
      ,e.ugrad_date_last_verified AS date_last_verified_c

      ,cn.[AAS1F]
      ,cn.[AAS2F]
      ,cn.[AAS1S]
      ,cn.[AAS2S]
      ,cn.[PSCF]
      ,cn.[PSCS]
      ,cn.[BBBF]
      ,cn.[BBBS]
      ,cn.[BMF]
      ,cn.[BMS]
      ,cn.[GPF]
      ,cn.[GPS]              
      
      ,gpa.fall_academic_status 
      ,gpa.spring_academic_status
      ,gpa.prev_spring_academic_status
      ,CONVERT(FLOAT,gpa.fall_semester_gpa) AS gpa_mp1
      ,CONVERT(FLOAT,gpa.spring_semester_gpa) AS gpa_mp2      
      ,CONVERT(FLOAT,gpa.prev_spring_semester_gpa) AS gpa_prev_mp2 
      ,CONVERT(FLOAT,COALESCE(gpa.spring_semester_gpa, gpa.fall_semester_gpa, gpa.prev_spring_semester_gpa)) AS gpa_recent
      ,CASE
        WHEN gpa.prev_spring_semester_gpa IS NOT NULL THEN 1        
        ELSE 0
       END AS transcript_collected_prev_mp2
      ,CASE
        WHEN gpa.fall_semester_gpa IS NOT NULL THEN 1        
        ELSE 0
       END AS transcript_collected_mp1
      ,CASE
        WHEN gpa.spring_semester_gpa IS NOT NULL THEN 1
        ELSE 0
       END AS transcript_collected_mp2

      ,s.stipend_status_fall
      ,s.stipend_status_spr           

      ,app.[2YR] AS N_2YR_apps
      ,app.[4YR] AS N_4YR_apps
      ,app.[2YR_T] AS N_2YR_transfer_apps
      ,app.[4YR_T] AS N_4YR_transfer_apps
      ,app.[ALL] AS N_apps_all

      ,nye.pursuing_degree_type_c AS next_year_pursuing_degree_type
FROM gabby.alumni.ktc_roster c 
LEFT JOIN gabby.alumni.enrollment_identifiers e
  ON c.sf_contact_id = e.student_c
LEFT JOIN gabby.alumni.contact_note_rollup cn
  ON c.sf_contact_id = cn.contact_id
 AND cn.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
LEFT JOIN gpa
  ON c.sf_contact_id = gpa.student_c
LEFT JOIN stipends s
  ON c.sf_contact_id = s.student_c
LEFT JOIN oot_roster oot
  ON c.sf_contact_id = oot.contact_id
 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR() BETWEEN oot.missing_academic_year AND oot.found_academic_year
 AND oot.rn = 1
LEFT JOIN counselor_changes cc
  ON c.sf_contact_id = cc.contact_id
 AND cc.rn = 1
LEFT JOIN transfer_apps app
  ON c.sf_contact_id = app.applicant_c
LEFT JOIN next_yr_enrollment nye
  ON c.sf_contact_id = nye.student_c
WHERE c.ktc_status IN ('HSG', 'TAF')